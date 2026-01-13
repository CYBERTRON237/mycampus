import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycampus/constants/storage_keys.dart';
import '../models/user_model.dart' as auth_models;
import 'otp_service.dart';
import 'package:mycampus/config/api_config.dart';

class AuthService with ChangeNotifier {
  // Configuration de base
  static String get baseUrl => ApiConfig.baseUrl;
  static final OTPService _otpService = OTPService();

  // Singleton pattern pour éviter les conflits de stockage
  static final AuthService _instance = AuthService._internal();
  
  // Factory pour obtenir l'instance unique
  factory AuthService({String? userId}) {
    return _instance;
  }
  
  // Constructeur interne
  AuthService._internal() {
    // Initialiser le storage unique et les clés
    _initializeStorage();
    // Initialisation différée pour éviter les appels async dans le constructeur
    Future.microtask(() => loadUserData());
  }
  
  void _initializeStorage() {
    // Créer un storage unique sans préfixe d'instance
    _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
        sharedPreferencesName: 'mycampus_secure_storage',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    
    // Initialiser les clés sans préfixe d'instance
    _tokenKey = StorageKeys.authToken;
    _userDataKey = StorageKeys.userData;
    _userIdKey = StorageKeys.userId;
    _userEmailKey = StorageKeys.userEmail;
    _userNameKey = StorageKeys.userName;
  }
  
    
  // Storage unique pour éviter les conflits
  late FlutterSecureStorage _storage;
  
  // Utilisateur actuel
  auth_models.UserModel? _currentUser;
  
  // Getter pour l'utilisateur actuel
  auth_models.UserModel? get currentUser => _currentUser;
  
  // Utilisation des constantes pour les clés de stockage
  late String _tokenKey;
  late String _userDataKey;
  late String _userIdKey;
  late String _userEmailKey;
  late String _userNameKey;
  static const _is2FAEnabledKey = 'is_2fa_enabled';
  
  // Méthode pour rafraîchir le token
  Future<bool> refreshToken() async {
    try {
      print('🔄 Tentative de rafraîchissement du token...');
      final refreshToken = await _storage.read(key: 'refresh_token');
      
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ Aucun refresh token disponible');
        await logout();
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Authorization': 'Bearer $refreshToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: _tokenKey, value: data['access_token']);
        print('✅ Token rafraîchi avec succès');
        return true;
      } else {
        print('❌ Échec du rafraîchissement du token: ${response.statusCode}');
        await logout();
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement du token: $e');
      await logout();
      return false;
    }
  }

  // Charger les données utilisateur au démarrage
  Future<void> loadUserData() async {
    try {
      print('🔍 Chargement des données utilisateur...');
      final token = await _storage.read(key: _tokenKey);
      print('🔑 Token stocké: ${token != null ? 'Oui' : 'Non'}');
      
      if (token != null) {
        print('🔄 Récupération des données utilisateur...');
        final userData = await getCurrentUser();
        if (userData != null) {
          print('✅ Utilisateur chargé: ${userData.fullName} (${userData.email})');
          _currentUser = userData;
          notifyListeners();
        } else {
          print('⚠️ Aucune donnée utilisateur trouvée malgré la présence d\'un token');
          // Essayer de rafraîchir le token
          final refreshed = await refreshToken();
          if (refreshed) {
            await loadUserData(); // Recharger les données après rafraîchissement
          }
        }
      } else {
        print('ℹ️ Aucun token trouvé, utilisateur non connecté');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données utilisateur: $e');
      developer.log('Erreur lors du chargement des données utilisateur: $e');
    }
  }
  
  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      developer.log('Erreur lors de la vérification de la connexion: $e');
      return false;
    }
  }

  // Obtenir l'utilisateur actuel
  Future<auth_models.UserModel?> getCurrentUser() async {
    try {
      // D'abord essayer de récupérer depuis le stockage local
      final storedUserData = await _storage.read(key: _userDataKey);
      if (storedUserData != null) {
        try {
          _currentUser = auth_models.UserModel.fromJson(jsonDecode(storedUserData));
          return _currentUser;
        } catch (e) {
          developer.log('Erreur lors du décodage des données utilisateur: $e');
        }
      }

      // Si pas de données locales ou erreur, essayer de récupérer depuis l'API
      final token = await _storage.read(key: _tokenKey);
      
      if (token == null || token.isEmpty) {
        print('❌ Aucun token trouvé dans le stockage');
        return null;
      }
      
      print('🔑 Token trouvé, longueur: ${token.length} caractères');
      final url = '$baseUrl/auth/me';
      print('🌐 Appel API vers: $url');
      
      final headers = await _getHeaders(token: token);
      print('📤 En-têtes de la requête:');
      headers.forEach((key, value) {
        print('   $key: ${key == 'Authorization' ? '${value.substring(0, 20)}...' : value}');
      });
      
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      print('✅ Réponse reçue en ${stopwatch.elapsedMilliseconds}ms');
      print('📥 Code de statut: ${response.statusCode}');
      print('📦 En-têtes de la réponse: ${response.headers}');
      print('📄 Corps de la réponse (début): ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('🔍 Données JSON décodées avec succès');
          
          if (responseData is Map) {
            print('🔍 Vérification de la clé "success" dans la réponse');
            if (responseData['success'] == true) {
              print('✅ Réponse marquée comme succès');
              final dynamic responseUserData = responseData['user'] ?? responseData;
              
              if (responseUserData is Map) {
                try {
                  print('🔍 Création du modèle utilisateur à partir des données:');
                  print('   - ID: ${responseUserData['id']}');
                  print('   - Email: ${responseUserData['email']}');
                  print('   - Nom: ${responseUserData['lastName']}');
                  print('   - Prénom: ${responseUserData['firstName']}');
                  
                  _currentUser = auth_models.UserModel.fromJson(Map<String, dynamic>.from(responseUserData));
                  print('✅ Modèle utilisateur créé avec succès');
                  
                  // Sauvegarder les données utilisateur
                  await _storage.write(key: _userDataKey, value: jsonEncode(_currentUser!.toJson()));
                  await _storage.write(key: _userIdKey, value: _currentUser!.id);
                  
                  if (_currentUser!.email.isNotEmpty) {
                    await _storage.write(key: _userEmailKey, value: _currentUser!.email);
                  }
                  
                  final fullName = '${_currentUser!.firstName} ${_currentUser!.lastName}';
                  await _storage.write(key: _userNameKey, value: fullName);
                  print('👤 Nom complet enregistré: $fullName');
                  
                  notifyListeners();
                  print('✅ getCurrentUser terminé avec succès');
                  return _currentUser;
                } catch (e) {
                  print('❌ Erreur lors de la création du modèle utilisateur: $e');
                  print('❌ Stack trace: ${StackTrace.current}');
                  return null;
                }
              } else {
                print('❌ Le format des données utilisateur est invalide (pas un Map)');
              }
            } else {
              print('❌ La réponse n\'est pas marquée comme succès');
              print('❌ Message d\'erreur: ${responseData['message'] ?? 'Aucun message d\'erreur'}');
            }
          } else {
            print('❌ La réponse n\'est pas un objet JSON valide');
          }
        } catch (e) {
          print('❌ Erreur lors du décodage de la réponse JSON: $e');
          print('❌ Réponse brute: ${response.body}');
        }
      } else {
        print('❌ Erreur HTTP ${response.statusCode}');
        print('❌ Réponse du serveur: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('❌ Erreur non gérée dans getCurrentUser: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Se connecter avec email et mot de passe
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Vérifier l'URL avant l'envoi
      final loginUrl = '$baseUrl/auth/login.php';  // Ajout de /auth/ dans le chemin
      developer.log('Tentative de connexion à: $loginUrl');
      
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      developer.log('Réponse de connexion: Status ${response.statusCode}');
      developer.log('- Headers: ${response.headers}');
      developer.log('- Body: ${response.body}');
      
      // Vérifier si la réponse est vide
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Le serveur a renvoyé une réponse vide',
          'error': 'Réponse vide',
          'statusCode': response.statusCode,
        };
      }
      
      // Tenter de parser la réponse en JSON
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        // Si le parsing échoue, c'est probablement du HTML
        final trimmed = response.body.trim();
        if (trimmed.startsWith('<!DOCTYPE html>') || trimmed.startsWith('<html>')) {
          return {
            'success': false,
            'message': 'Erreur de configuration du serveur. Le serveur a renvoyé une page HTML au lieu des données attendues.',
            'error': 'Réponse HTML inattendue',
            'statusCode': response.statusCode,
          };
        }
        return {
          'success': false,
          'message': 'Erreur lors de l\'analyse de la réponse du serveur',
          'error': e.toString(),
          'response': response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body,
        };
      }

      // Maintenant traiter le JSON
      if (response.statusCode == 200) {
        if (responseData is Map && responseData['success'] == true && responseData['token'] != null) {
          // Sauvegarder le token
          final token = responseData['token'].toString();
          await _storage.write(key: _tokenKey, value: token);
          
          if (kDebugMode) {
            print('🔑 Token enregistré avec succès: ${token.substring(0, 10)}...');
            print('📌 Clé utilisée: $_tokenKey');
          }
          
          // Mettre à jour l'utilisateur actuel
          final dynamic userPayload = responseData['user'] ?? responseData['data'];
          if (userPayload != null && userPayload is Map) {
            _currentUser = auth_models.UserModel.fromJson(Map<String, dynamic>.from(userPayload));
            await _storage.write(key: _userDataKey, value: jsonEncode(_currentUser!.toJson()));
            notifyListeners();
          }

          return {
            'success': true,
            'message': 'Connexion réussie',
            'token': responseData['token'],
            'user': _currentUser?.toJson(),
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Échec de la connexion',
            'error': responseData['error'],
            'statusCode': response.statusCode,
          };
        }
      } else {
        // status != 200
        if (responseData is Map) {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Erreur de connexion',
            'error': responseData['error'],
            'statusCode': response.statusCode,
          };
        } else {
          return {
            'success': false,
            'message': 'Erreur de connexion: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      developer.log('Erreur lors de la connexion: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // Se déconnecter
  Future<bool> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      
      // Essayer de se déconnecter du serveur si on a un token
      if (token != null) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/auth/logout.php'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          // Même en cas d'échec de la déconnexion côté serveur, on se déconnecte localement
          if (response.statusCode != 200) {
            developer.log('Erreur lors de la déconnexion du serveur: ${response.body}');
          }
        } catch (e) {
          developer.log('Erreur lors de la déconnexion du serveur: $e');
        }
      }

      // Déconnexion locale
      await _clearUserData();
      return true;
    } catch (e) {
      developer.log('Erreur lors de la déconnexion: $e');
      return false;
    }
  }

  // Effacer toutes les données utilisateur
  Future<void> _clearUserData() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userDataKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userNameKey);
      await _storage.delete(key: _is2FAEnabledKey);
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      developer.log('Erreur lors de la suppression des données utilisateur: $e');
      rethrow;
    }
  }

  // Récupérer le token d'authentification
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Vérifier si la 2FA est activée
  Future<bool> is2FAEnabled() async {
    try {
      final enabled = await _storage.read(key: _is2FAEnabledKey);
      return enabled == 'true';
    } catch (e) {
      developer.log('Erreur lors de la vérification de la 2FA: $e');
      return false;
    }
  }

  // Activer la 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    return await _manage2FA(true);
  }

  // Enregistrer un nouvel utilisateur
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? nationality,
    String? address,
    String? city,
    String? region,
    String? postalCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
    String? academicLevel,
    String? studentId,
    String? matricule,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'firstName': firstName,  // camelCase pour correspondre au backend
        'lastName': lastName,    // camelCase pour correspondre au backend
        'phone': phone,
        if (gender != null) 'gender': gender,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return await _handleAuthResponse(response, 'Inscription réussie');
    } catch (e) {
      return _handleError(e, 'Erreur lors de l\'inscription');
    }
  }

  // Désactiver la 2FA
  Future<Map<String, dynamic>> disable2FA() async {
    return await _manage2FA(false);
  }

  // Gestion commune pour l'activation/désactivation 2FA
  Future<Map<String, dynamic>> _manage2FA(bool enable) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final endpoint = enable ? 'enable_2fa.php' : 'disable_2fa.php';
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _parseResponse(response);
      
      if (responseData['success'] == true) {
        try {
          await _otpService.set2FAEnabled(enable);
        } catch (e) {
          developer.log('OTP service error (set2FAEnabled): $e');
        }
        await _storage.write(key: _is2FAEnabledKey, value: enable.toString());
      }
      
      return responseData;
    } catch (e) {
      final action = enable ? 'activation' : 'désactivation';
      return _handleError(e, 'Erreur lors de l\'$action de la 2FA');
    }
  }

  // Envoyer un code OTP
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_otp.php'),
        headers: _getHeaders(),
        body: jsonEncode({'phone': phoneNumber}),
      );

      return _handleResponse(response, 'Code OTP envoyé avec succès');
    } catch (e) {
      return _handleError(e, 'Erreur lors de l\'envoi du code OTP');
    }
  }

  // Vérifier le code OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String code,
    required String tempToken,
  }) async {
    try {
      if (code.isEmpty || code.length != 6) {
        return {
          'success': false,
          'message': 'Le code doit contenir 6 chiffres',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/verify_otp.php'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $tempToken',
        },
        body: jsonEncode({'code': code}),
      );

      return await _handleAuthResponse(response, 'Vérification réussie');
    } catch (e) {
      return _handleError(e, 'Erreur lors de la vérification');
    }
  }


  // ==================== MÉTHODES D'AIDE ====================

  // Obtenir les en-têtes HTTP
  Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Parser la réponse HTTP
  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur'};
      }
      
      final data = jsonDecode(responseBody);
      if (data is! Map<String, dynamic>) {
        return {'success': false, 'message': 'Format de réponse invalide'};
      }
      
      return data;
    } catch (e) {
      developer.log('Erreur lors de l\'analyse de la réponse: $e');
      return {
        'success': false,
        'message': 'Erreur lors de l\'analyse de la réponse du serveur',
        'error': e.toString(),
      };
    }
  }
  
  // Gérer les erreurs
  Map<String, dynamic> _handleError(dynamic error, String defaultMessage) {
    developer.log('Erreur: $error');
    
    if (error is http.ClientException) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${error.message}',
        'error': error.toString(),
      };
    } else if (error is FormatException) {
      return {
        'success': false,
        'message': 'Erreur de format de données',
        'error': error.toString(),
      };
    } else {
      return {
        'success': false,
        'message': defaultMessage,
        'error': error.toString(),
      };
    }
  }

  // Traitement des réponses d'authentification
  Future<Map<String, dynamic>> _handleAuthResponse(
    http.Response response,
    String successMessage,
  ) async {
    developer.log('Traitement de la réponse d\'authentification...');
    final responseData = _parseResponse(response);
    
    developer.log('Données de réponse analysées: $responseData');
    
    if (responseData['success'] == true) {
      if (responseData['requires_2fa'] == true) {
        developer.log('2FA requise, token temporaire: ${responseData['temp_token']}');
        return {
          'success': true,
          'requires2FA': true,
          'tempToken': responseData['temp_token'],
          'message': 'Veuillez entrer le code de vérification',
        };
      } else {
        developer.log('Sauvegarde des données d\'authentification...');
        await _saveAuthData(responseData);
        responseData['message'] = successMessage;
        developer.log('Données sauvegardées avec succès');
      }
    } else {
      developer.log('Échec de la connexion. Message: ${responseData['message']}');
      developer.log('Erreur: ${responseData['error']}');
    }
    
    return responseData;
  }

  // Traitement des réponses génériques
  Map<String, dynamic> _handleResponse(
    http.Response response, 
    String successMessage,
  ) {
    final responseData = _parseResponse(response);
    if (responseData['success'] == true) {
      responseData['message'] = successMessage;
    }
    return responseData;
  }

  // Sauvegarde des données d'authentification
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    try {
      if (data['token'] != null) {
        await _storage.write(key: _tokenKey, value: data['token']);
      }
      
      if (data['user'] != null && data['user'] is Map) {
        final user = Map<String, dynamic>.from(data['user']);
        final futures = <Future>[];
        if (user['id'] != null) {
          futures.add(_storage.write(key: _userIdKey, value: user['id'].toString()));
        }
        if (user['email'] != null) {
          futures.add(_storage.write(key: _userEmailKey, value: user['email'].toString()));
        }
        if (user['first_name'] != null && user['last_name'] != null) {
          futures.add(_storage.write(
            key: _userNameKey, 
            value: '${user['first_name']} ${user['last_name']}'
          ));
        }
        if (user['role'] != null) {
          futures.add(_storage.write(key: 'user_role', value: user['role'].toString()));
        }
        if (user['phone'] != null) {
          futures.add(_storage.write(key: 'user_phone', value: user['phone'].toString()));
        }
        if (user['institution_name'] != null) {
          futures.add(_storage.write(key: 'user_institution', value: user['institution_name'].toString()));
        }
        if (user['avatar_url'] != null) {
          futures.add(_storage.write(key: 'user_avatar', value: user['avatar_url'].toString()));
        }

        if (futures.isNotEmpty) {
          await Future.wait(futures);
        }
      }
    } catch (e) {
      developer.log('Erreur lors de la sauvegarde des données: $e', error: e);
      rethrow;
    }
  }


  // Sauvegarder les données utilisateur
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final futures = <Future>[];
      
      // Données de base
      if (userData['id'] != null) {
        futures.add(_storage.write(key: _userIdKey, value: userData['id'].toString()));
      }
      
      if (userData['email'] != null) {
        futures.add(_storage.write(key: _userEmailKey, value: userData['email'].toString()));
      }
      
      if (userData['first_name'] != null && userData['last_name'] != null) {
        futures.add(_storage.write(
          key: _userNameKey,
          value: '${userData['first_name']} ${userData['last_name']}',
        ));
      }
      
      // Données supplémentaires
      if (userData['role'] != null) {
        futures.add(_storage.write(key: 'user_role', value: userData['role'].toString()));
      }
      
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    } catch (e) {
      developer.log('Erreur lors de la sauvegarde des données utilisateur: $e');
      rethrow;
    }
  }

  // Mettre à jour les données de l'utilisateur
  Future<auth_models.UserModel> updateUserData(dynamic user) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final updatedUser = auth_models.UserModel.fromJson(responseData['user']);
          _currentUser = updatedUser;
          await _storage.write(key: _userDataKey, value: jsonEncode(updatedUser.toJson()));
          notifyListeners();
          return updatedUser;
        } else {
          throw Exception(responseData['message'] ?? 'Échec de la mise à jour du profil');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la mise à jour du profil: ${response.body}');
      }
    } catch (e) {
      developer.log('Erreur lors de la mise à jour du profil: $e');
      rethrow;
    }
  }

  // Upload de l'avatar
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        throw Exception('Non authentifié');
      }

      // Création d'un FormData pour l'upload
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}',
        ),
      });

      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/auth/upload_avatar.php',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final String avatarUrl = response.data['avatar_url'];
        
        // Mettre à jour l'utilisateur local avec la nouvelle URL
        if (_currentUser != null) {
          _currentUser = auth_models.UserModel(
            id: _currentUser!.id,
            firstName: _currentUser!.firstName,
            lastName: _currentUser!.lastName,
            email: _currentUser!.email,
            phone: _currentUser!.phone,
            address: _currentUser!.address,
            bio: _currentUser!.bio,
            role: _currentUser!.role,
            avatarUrl: avatarUrl,
          );
          await _storage.write(key: _userDataKey, value: jsonEncode(_currentUser!.toJson()));
          notifyListeners();
        }
        
        return avatarUrl;
      } else {
        throw Exception(response.data['message'] ?? 'Échec de l\'upload de l\'avatar');
      }
    } catch (e) {
      developer.log('Erreur lors de l\'upload de l\'avatar: $e');
      rethrow;
    }
  }

  // Changer le mot de passe de l'utilisateur
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la mise à jour du mot de passe');
      }
    } catch (e) {
      developer.log('Erreur lors du changement de mot de passe: $e');
      rethrow;
    }
  }

}
