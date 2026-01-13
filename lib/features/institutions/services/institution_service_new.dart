import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../features/auth/services/auth_service.dart';
import '../models/institution_model.dart';

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Service pour gérer les opérations liées aux institutions
class InstitutionService with ChangeNotifier {
  // Configuration de base
  static String get baseUrl => '${ApiConfig.baseUrl}/institutions';
  
  // Cache pour les tokens d'authentification
  static const storage = FlutterSecureStorage();
  
  // Instance unique (singleton)
  static final InstitutionService _instance = InstitutionService._internal();
  factory InstitutionService() => _instance;
  InstitutionService._internal();

  // Cache pour les institutions
  final Map<String, InstitutionModel> _institutionsCache = {};
  List<InstitutionModel>? _allInstitutions;
  
  // Pagination et filtres
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _perPage = 20;
  final Map<String, dynamic> _currentFilters = {};

  // Getters
  List<InstitutionModel>? get allInstitutions => _allInstitutions?.toList();
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  Map<String, dynamic> get currentFilters => Map.unmodifiable(_currentFilters);

  /// Gère les erreurs HTTP et les réponses non valides
  Exception _handleError(dynamic response) {
    try {
      // Journalisation détaillée de l'erreur
      developer.log('Erreur API - Réponse reçue: ${response.toString()}', 
          name: 'InstitutionService',
          error: response is Exception ? response : null);
      
      if (response is http.Response) {
        // Journalisation des en-têtes pour le débogage
        developer.log('En-têtes de la réponse: ${response.headers}', 
            name: 'InstitutionService');
            
        // Vérifier si la réponse est vide
        if (response.body.isEmpty) {
          return ApiException(
            'La réponse du serveur est vide',
            statusCode: response.statusCode,
            data: {'statusCode': response.statusCode},
          );
        }
        
        // Essayer de parser la réponse JSON
        try {
          final dynamic data = json.decode(response.body);
          
          // Vérifier si c'est une réponse d'erreur HTML (comme une page d'erreur PHP)
          if (response.body.trim().startsWith('<!DOCTYPE html>') || 
              response.body.trim().startsWith('<br />')) {
            return ApiException(
              'Le serveur a renvoyé une page d\'erreur HTML au lieu de JSON',
              statusCode: response.statusCode,
              data: {'contentType': response.headers['content-type']},
            );
          }
          
          // Vérifier si c'est une réponse d'erreur JSON standard
          if (data is Map) {
            return ApiException(
              data['message']?.toString() ?? 
              data['error']?.toString() ?? 
              'Erreur inconnue du serveur',
              statusCode: response.statusCode,
              data: data,
            );
          }
          
          // Si la réponse n'est pas un objet JSON valide
          return ApiException(
            'Format de réponse inattendu du serveur',
            statusCode: response.statusCode,
            data: {'body': response.body},
          );
          
        } catch (jsonError) {
          // En cas d'échec du décodage JSON
          return ApiException(
            'Impossible de décoder la réponse du serveur: ${jsonError.toString()}',
            statusCode: response.statusCode,
            data: {
              'contentType': response.headers['content-type'],
              'bodyPreview': response.body.length > 100 
                  ? '${response.body.substring(0, 100)}...' 
                  : response.body,
            },
          );
        }
        
      } else if (response is Map) {
        // Gestion des erreurs déjà formatées en Map
        return ApiException(
          response['message']?.toString() ?? 
          response['error']?.toString() ?? 
          'Erreur inconnue',
          statusCode: response['statusCode'] as int?,
          data: response,
        );
        
      } else if (response is Exception) {
        // Si c'est déjà une exception, la retourner telle quelle
        return response;
        
      } else {
        // Autres types d'erreurs
        return ApiException(
          'Erreur inattendue: ${response?.toString() ?? 'Réponse nulle'}' 
        );
      }
      
    } catch (e, stackTrace) {
      // En cas d'erreur lors du traitement de l'erreur
      developer.log('Erreur lors du traitement de l\'erreur: $e', 
          name: 'InstitutionService',
          error: e,
          stackTrace: stackTrace);
          
      return ApiException(
        'Erreur lors du traitement de la réponse du serveur: ${e.toString()}',
        data: {'originalError': response?.toString()},
      );
    }
  }
  
  /// Récupère les statistiques des institutions avec une meilleure gestion des erreurs
  Future<Map<String, dynamic>> getStats() async {
    // Journalisation de l'appel
    developer.log('Récupération des statistiques des institutions...', 
        name: 'InstitutionService');
    
    // Vérification de l'authentification
    final token = await AuthService().getToken();
    if (token == null) {
      throw ApiException('Non authentifié - Aucun token disponible', statusCode: 401);
    }

    // Configuration de la requête
    final headers = await ApiConfig.getAuthHeaders(token);
    final uri = Uri.parse('$baseUrl/stats');
    
    // Journalisation des détails de la requête
    developer.log('Envoi de la requête GET à $uri', 
        name: 'InstitutionService',
        error: 'Headers: $headers');

    // Envoi de la requête avec gestion du timeout
    http.Response response;
    try {
      response = await http.get(uri, headers: headers)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException(
            'La requête a expiré après 30 secondes',
            const Duration(seconds: 30),
          ),
        );
    } on TimeoutException catch (e) {
      throw ApiException('Délai d\'attente dépassé: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw ApiException('Erreur lors de l\'envoi de la requête: ${e.toString()}');
    }

    // Journalisation de la réponse brute
    developer.log('Réponse reçue - Status: ${response.statusCode}', 
        name: 'InstitutionService',
        error: 'Headers: ${response.headers}\nBody: ${response.body}');

    // Vérification du code de statut HTTP
    if (response.statusCode != 200) {
      throw _handleError(response);
    }

    // Vérification du corps de la réponse
    if (response.body.isEmpty) {
      throw ApiException('La réponse du serveur est vide', statusCode: 200);
    }

    // Décodage de la réponse JSON
    dynamic data;
    try {
      data = json.decode(response.body);
    } catch (e) {
      // Si le décodage échoue, vérifier si c'est une erreur HTML
      if (response.body.trim().startsWith('<!DOCTYPE html>') || 
          response.body.trim().startsWith('<br />')) {
        throw ApiException(
          'Le serveur a renvoyé une page d\'erreur HTML au lieu de JSON',
          statusCode: 500,
          data: {
            'contentType': response.headers['content-type'],
            'bodyPreview': response.body.length > 200 
                ? '${response.body.substring(0, 200)}...' 
                : response.body,
          },
        );
      }
      throw ApiException('Erreur de décodage JSON: ${e.toString()}');
    }

    // Vérification de la structure de la réponse
    if (data is! Map) {
      throw ApiException('Format de réponse inattendu', 
          statusCode: 200, 
          data: data);
    }

    // Vérification du statut de la réponse
    if (data['success'] != true) {
      throw ApiException(
        data['message']?.toString() ?? 'Échec de la requête',
        statusCode: 200,
        data: data,
      );
    }

    // Vérification des données de la réponse
    if (data['data'] == null || data['data'] is! Map) {
      throw ApiException(
        'Données de statistiques manquantes ou invalides',
        statusCode: 200,
        data: data,
      );
    }

    return data['data'] as Map<String, dynamic>;
  }
  
  /// Formatte les en-têtes pour les logs en masquant les informations sensibles
  String _formatHeaders(Map<String, String> headers) {
    return headers.entries
        .map((e) => '   ${e.key}: ${e.key.toLowerCase().contains('auth') ? '***' : e.value}')
        .join('\n');
  }

  /// Récupère toutes les institutions avec pagination et filtres
  Future<void> loadInstitutions({Map<String, dynamic>? filters}) async {
    try {
      // Journalisation de l'appel
      developer.log('Chargement des institutions avec filtres: ${filters ?? 'aucun'}', 
          name: 'InstitutionService');
      
      // Vérification de l'authentification
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié - Aucun token disponible', statusCode: 401);
      }

      // Configuration de la requête
      final headers = await ApiConfig.getAuthHeaders(token);
      final params = <String, dynamic>{
        'page': _currentPage,
        'per_page': _perPage,
        ...?filters,
      };
      
      final uri = Uri.parse(baseUrl).replace(queryParameters: 
          Map.fromEntries(params.entries.map((e) => 
              MapEntry(e.key, e.value?.toString()))));
      
      // Journalisation des détails de la requête
      developer.log('Envoi de la requête GET à ${uri.toString()}', 
          name: 'InstitutionService',
          error: 'Headers: ${_formatHeaders(headers)}');

      // Envoi de la requête avec gestion du timeout
      final response = await http.get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'La requête a expiré après 30 secondes',
              const Duration(seconds: 30),
            ),
          );

      // Journalisation de la réponse brute
      developer.log('Réponse reçue - Status: ${response.statusCode}', 
          name: 'InstitutionService',
          error: 'Headers: ${_formatHeaders(response.headers)}\nBody: ${response.body}');

      // Vérification du code de statut HTTP
      if (response.statusCode != 200) {
        throw _handleError(response);
      }

      // Vérification du corps de la réponse
      if (response.body.isEmpty) {
        throw ApiException('La réponse du serveur est vide', statusCode: 200);
      }

      // Décodage de la réponse JSON
      final data = json.decode(response.body);

      // Vérification de la structure de la réponse
      if (data is! Map || data['success'] != true) {
        throw ApiException(
          data['message']?.toString() ?? 'Format de réponse inattendu',
          statusCode: 200,
          data: data,
        );
      }

      // Traitement des données reçues
      final institutionsData = data['data'] as List? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      
      // Mise à jour du cache et des données
      _allInstitutions = institutionsData
          .map<InstitutionModel>((json) => InstitutionModel.fromJson(json))
          .toList();
      
      // Mise à jour de la pagination
      _totalItems = (pagination['total'] as int?) ?? 0;
      _totalPages = (pagination['total_pages'] as int?) ?? 1;
      
      // Notification des écouteurs
      notifyListeners();
      
    } catch (e) {
      developer.log('Erreur lors du chargement des institutions: $e', 
          name: 'InstitutionService',
          error: e);
      rethrow;
    }
  }
  Future<List<InstitutionModel>> getAllInstitutions({
    bool forceRefresh = false,
    int page = 1,
    Map<String, dynamic>? filters,
    String? searchQuery,
    String? orderBy,
    bool ascending = true,
  }) async {
    developer.log('🔵 [InstitutionService] ===== DÉBUT getAllInstitutions =====');
    developer.log('� Paramètres: page=$page, searchQuery=$searchQuery, orderBy=$orderBy, ascending=$ascending');
    
    try {
      // 1. Récupération du token
      developer.log('🔄 Récupération du token d\'authentification...');
      final token = await AuthService().getToken();
      
      if (token == null) {
        developer.log('❌ Aucun token d\'authentification trouvé', level: 1000);
        throw Exception('Non authentifié');
      }
      
      developer.log('✅ Token récupéré avec succès (${token.length} caractères)');
      
      // 2. Construction des paramètres de requête
      final params = <String, String>{
        'page': page.toString(),
        'per_page': _perPage.toString(),
        if (searchQuery?.isNotEmpty ?? false) 'search': searchQuery!,
        if (orderBy != null) 'order_by': orderBy,
        'order_dir': ascending ? 'asc' : 'desc',
      };
      
      // Ajout des filtres actuels
      if (filters != null) {
        _currentFilters.clear();
        _currentFilters.addAll(Map<String, dynamic>.from(filters));
      }
      
      _currentFilters.removeWhere((key, value) => value == null || value.toString().isEmpty);
      _currentFilters.forEach((key, value) {
        params[key] = value.toString();
      });
      
      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      developer.log('🌐 URL de la requête: ${uri.toString()}');
      
      // 3. Préparation des en-têtes
      final headers = await ApiConfig.getAuthHeaders(token);
      developer.log('📤 En-têtes de la requête:\n${_formatHeaders(headers)}');
      
      // 4. Envoi de la requête
      developer.log('� Envoi de la requête GET...');
      final stopwatch = Stopwatch()..start();
      
      try {
        final response = await http.get(
          uri, 
          headers: headers,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            developer.log('⏱️ Timeout de la requête dépassé', level: 1000);
            throw TimeoutException('La requête a pris trop de temps');
          },
        );
        
        // 5. Analyse de la réponse
        developer.log('✅ Réponse reçue en ${stopwatch.elapsedMilliseconds}ms');
        developer.log('� Code de statut: ${response.statusCode}');
        developer.log('📋 En-têtes de la réponse: ${response.headers}');
        
        final responseBody = response.body;
        developer.log('📦 Taille de la réponse: ${responseBody.length} caractères');
        
        // Vérification du type de contenu
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.toLowerCase().contains('application/json')) {
          developer.log('⚠️ Attention: Le type de contenu n\'est pas JSON: $contentType', level: 1000);
          developer.log('📝 Début de la réponse: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
        }
        
        // Vérification des erreurs HTML
        if (responseBody.trim().startsWith('<!DOCTYPE') || 
            responseBody.trim().startsWith('<html') || 
            responseBody.trim().startsWith('<br') ||
            responseBody.trim().startsWith('&lt;')) {
          
          // Essayer d'extraire un message d'erreur PHP s'il existe
          String errorMessage = 'Le serveur a renvoyé une page HTML au lieu de JSON';
          
          // Vérifier les erreurs PHP courantes
          if (responseBody.contains('Fatal error') || 
              responseBody.contains('Parse error') ||
              responseBody.contains('Warning') ||
              responseBody.contains('Notice')) {
            errorMessage = 'Erreur PHP détectée sur le serveur';
          }
          
          // Journalisation détaillée
          developer.log('❌ ERREUR: $errorMessage', level: 1000);
          developer.log('📋 Code de statut: ${response.statusCode}');
          developer.log('� URL de la requête: $uri');
          developer.log('� Début de la réponse (200 premiers caractères):');
          developer.log(responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody);
          
          // Si c'est une erreur 500, on fournit un message plus explicite
          if (response.statusCode == 500) {
            errorMessage = 'Erreur interne du serveur (500). Veuillez vérifier les logs du serveur.';
          }
          
          throw Exception(errorMessage);
        }
        
        // Tentative de parsing JSON
        dynamic jsonData;
        try {
          jsonData = json.decode(responseBody);
          developer.log('✅ Réponse JSON parsée avec succès');
        } catch (e) {
          developer.log('❌ Erreur lors du parsing JSON: $e', level: 1000);
          developer.log('📝 Réponse brute: ${responseBody.length > 500 ? '${responseBody.substring(0, 500)}...' : responseBody}');
          throw Exception('Erreur de format JSON: ${e.toString()}');
        }
        
        // Vérification de la structure de la réponse
        if (jsonData is! Map<String, dynamic>) {
          developer.log('❌ Format de réponse inattendu: ${jsonData.runtimeType}', level: 1000);
          throw Exception('Format de réponse inattendu');
        }
        
        if (response.statusCode != 200) {
          final errorMessage = jsonData['message'] ?? 'Erreur inconnue du serveur (${response.statusCode})';
          developer.log('❌ Erreur du serveur: $errorMessage', level: 1000);
          throw Exception(errorMessage);
        }
        
        if (jsonData['success'] != true) {
          final errorMessage = jsonData['message'] ?? 'Erreur inconnue du serveur';
          developer.log('❌ Échec de la requête: $errorMessage', level: 1000);
          throw Exception(errorMessage);
        }
        
        // Traitement des données
        if (jsonData['data'] == null) {
          developer.log('⚠️ Aucune donnée dans la réponse', level: 1000);
          return [];
        }
        
        final data = jsonData['data'] as List;
        developer.log('📊 ${data.length} institutions reçues');
        
        final institutions = data
            .map((json) => InstitutionModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Mise à jour du cache
        _allInstitutions = institutions;
        for (var inst in institutions) {
          _institutionsCache[inst.id] = inst;
        }
        
        // Mise à jour de la pagination
        _currentPage = page;
        _totalPages = jsonData['pagination']?['total_pages'] ?? 1;
        _totalItems = jsonData['pagination']?['total_items'] ?? institutions.length;
        
        notifyListeners();
        return institutions;
      } on http.ClientException catch (e) {
        developer.log(' ERREUR HTTP: ${e.runtimeType}', level: 1000);
        developer.log(' Message: ${e.message}', level: 1000);
        if (e.uri != null) {
          developer.log(' URI: ${e.uri}', level: 1000);
        }
        developer.log(' Stack trace non disponible pour ClientException', level: 1000);
        rethrow;
      } on Exception catch (e) {
        developer.log(' [InstitutionService] ERREUR: $e', level: 1000);
        rethrow;
      }
    } catch (e) {
      developer.log('Error getting institutions: $e', name: 'InstitutionService');
      rethrow;
    }
  }
  
  /// Récupère une institution par son identifiant
  Future<InstitutionModel> getInstitutionById(String id) async {
    try {
      // Vérifier d'abord dans le cache
      if (_institutionsCache.containsKey(id)) {
        return _institutionsCache[id]!;
      }
      
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final institution = InstitutionModel.fromJson(data['data']);
          _institutionsCache[institution.id] = institution;
          return institution;
        }
        throw Exception(data['message']?.toString() ?? 'Format de réponse invalide');
      } else if (response.statusCode == 404) {
        throw Exception('Institution non trouvée');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération de l\'institution: $e');
      rethrow;
    }
  }
  
  /// Crée une nouvelle institution
  Future<InstitutionModel> createInstitution(Map<String, dynamic> institutionData) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: json.encode(institutionData),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final institution = InstitutionModel.fromJson(data['data']);
          _institutionsCache[institution.id] = institution;
          _allInstitutions?.add(institution);
          _totalItems++;
          notifyListeners();
          return institution;
        }
        throw Exception(data['message']?.toString() ?? 'Échec de la création de l\'institution');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      developer.log('Erreur lors de la création de l\'institution: $e');
      rethrow;
    }
  }
  
  /// Met à jour une institution existante
  Future<InstitutionModel> updateInstitution(String id, Map<String, dynamic> updates) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: json.encode(updates),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final updatedInstitution = InstitutionModel.fromJson(data['data']);
          _institutionsCache[updatedInstitution.id] = updatedInstitution;
          
          // Mettre à jour dans la liste des institutions
          if (_allInstitutions != null) {
            final index = _allInstitutions!.indexWhere((inst) => inst.id == id);
            if (index != -1) {
              _allInstitutions![index] = updatedInstitution;
            }
          }
          
          notifyListeners();
          return updatedInstitution;
        }
        throw Exception(data['message']?.toString() ?? 'Échec de la mise à jour de l\'institution');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de l\'institution: $e');
      rethrow;
    }
  }
  
  /// Supprime une institution
  Future<bool> deleteInstitution(String id) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        _institutionsCache.remove(id);
        _allInstitutions?.removeWhere((inst) => inst.id == id);
        if (_totalItems > 0) _totalItems--;
        notifyListeners();
        return true;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      developer.log('Erreur lors de la suppression de l\'institution: $e');
      rethrow;
    }
  }
  
  /// Active une institution
  Future<InstitutionModel> activateInstitution(String id) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.post(
        Uri.parse('$baseUrl/$id/activate'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final institution = InstitutionModel.fromJson(data['data']);
          _institutionsCache[institution.id] = institution;
          
          // Mettre à jour dans la liste des institutions
          if (_allInstitutions != null) {
            final index = _allInstitutions!.indexWhere((inst) => inst.id == id);
            if (index != -1) {
              _allInstitutions![index] = institution;
            }
          }
          
          notifyListeners();
          return institution;
        }
        throw Exception(data['message']?.toString() ?? 'Échec de l\'activation de l\'institution');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      developer.log('Erreur lors de l\'activation de l\'institution: $e');
      rethrow;
    }
  }
  
  /// Recherche des institutions par nom ou critères
  Future<List<InstitutionModel>> searchInstitutions(String query) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.get(
        Uri.parse('$baseUrl/search').replace(queryParameters: {'q': query}),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final institutions = (data['data'] as List)
              .map((json) => InstitutionModel.fromJson(json))
              .toList();
          
          // Mettre à jour le cache
          for (var inst in institutions) {
            _institutionsCache[inst.id] = inst;
          }
          
          return institutions;
        }
        throw Exception(data['message']?.toString() ?? 'Erreur lors de la recherche');
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      developer.log('Erreur lors de la recherche d\'institutions: $e');
      rethrow;
    }
  }
  
  /// Vide le cache des institutions
  void clearCache() {
    _institutionsCache.clear();
    _allInstitutions = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _currentFilters.clear();
    notifyListeners();
  }
}
