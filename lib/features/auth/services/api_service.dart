import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../config/api_config.dart' as config;
import '../../../../constants/storage_keys.dart';

class ApiService {
  // S'assure que l'URL de base se termine par un slash
  static final String baseUrl = config.ApiConfig.baseUrl.endsWith('/') 
      ? config.ApiConfig.baseUrl 
      : '${config.ApiConfig.baseUrl}/';
  static final Duration defaultTimeout = config.ApiConfig.connectTimeout;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  factory ApiService() => _instance;

  ApiService._internal();

  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      if (kDebugMode) {
        print('🔍 Tentative de récupération du token avec la clé: ${StorageKeys.authToken}');
      }
      
      final token = await _storage.read(key: StorageKeys.authToken);
      
      if (kDebugMode) {
        if (token == null) {
          print('❌ Aucun token trouvé dans le stockage sécurisé');
        } else {
          print('🔑 Token récupéré: ${token.substring(0, 10)}... (${token.length} caractères)');
        }
      }
      
      if (token == null || token.isEmpty) {
        throw ApiException('Session expirée. Veuillez vous reconnecter.');
      }
      
      final headers = {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      
      if (kDebugMode) {
        print('🔄 En-têtes générés:');
        headers.forEach((key, value) {
          print('   $key: ${key == 'Authorization' ? '${value.substring(0, 20)}...' : value}');
        });
      }
      
      return headers;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur d\'authentification: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    // Vérifier le code de statut HTTP
    if (response.statusCode == 401) {
      // Déclencher la déconnexion si le token est invalide
      _storage.delete(key: 'auth_token');
      throw ApiException('Session expirée. Veuillez vous reconnecter.', statusCode: 401);
    } else if (response.statusCode >= 500) {
      throw ApiException(
        'Erreur serveur (${response.statusCode}). Veuillez réessayer plus tard.',
        statusCode: response.statusCode,
      );
    }

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final isJson = contentType.contains('application/json');
    
    // Vérifier si la réponse est du HTML alors qu'on attend du JSON
    if (contentType.contains('text/html')) {
      throw ApiException(
        'Le serveur a renvoyé une page HTML au lieu de données JSON. Vérifiez que l\'URL de l\'API est correcte et que le serveur fonctionne correctement.',
        statusCode: response.statusCode,
      );
    }
    
    dynamic responseBody;
    if (response.body.isNotEmpty && isJson) {
      try {
        responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Vérifier si la réponse contient une erreur
        if (responseBody is Map && responseBody['success'] == false) {
          throw ApiException(
            responseBody['message']?.toString() ?? 'Erreur inconnue',
            statusCode: response.statusCode,
          );
        }
      } catch (e) {
        throw const FormatException('Erreur de décodage de la réponse du serveur');
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody ?? response.body;
    } else {
      String errorMessage = 'Erreur inconnue';
      
      if (responseBody is Map) {
        errorMessage = responseBody['message'] ?? 
                      responseBody['error'] ?? 
                      responseBody['detail'] ?? 
                      'Erreur inconnue';
      } else if (response.body.isNotEmpty) {
        errorMessage = response.body;
      }

      switch (response.statusCode) {
        case 400:
          throw ApiException('Requête incorrecte: $errorMessage', 
              statusCode: 400, data: responseBody);
        case 401:
          _storage.delete(key: 'auth_token');
          throw ApiException('Session expirée. Veuillez vous reconnecter.', 
              statusCode: 401);
        case 403:
          throw ApiException('Accès refusé: $errorMessage', 
              statusCode: 403, data: responseBody);
        case 404:
          throw ApiException('Ressource non trouvée', 
              statusCode: 404, data: responseBody);
        case 500:
          throw ApiException('Erreur interne du serveur', 
              statusCode: 500, data: responseBody);
        default:
          throw ApiException('Erreur ${response.statusCode}: $errorMessage', 
              statusCode: response.statusCode, data: responseBody);
      }
    }
  }

  String? _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    return jsonEncode(body);
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) async {
    try {
      // Nettoyer les slashes en double dans le chemin
      String cleanPath = endpoint.replaceAll(RegExp(r'/+'), '/');
      
      // Construire l'URI de manière sécurisée
      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/$cleanPath'.replaceAll(RegExp(r'/+'), '/'),
        queryParameters: queryParams?.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );
      
      if (kDebugMode) {
        print('🔗 URL construite: $uri');
      }

      // Journalisation pour le débogage
      if (kDebugMode) {
        print('\n📡 API Request: $method $uri');
        if (body != null) {
          print('📦 Request Body: $body');
        }
      }

      final request = http.Request(method, uri);
      
      try {
        final authHeaders = await _getAuthHeaders();
        if (headers != null) {
          authHeaders.addAll(headers);
        }
        if (kDebugMode) {
          print('🔑 Headers à ajouter à la requête:');
          headers?.forEach((key, value) {
            print('   $key: ${key == 'Authorization' ? '${value.substring(0, 20)}...' : value}');
          });
        }
        
        // Ajouter les en-têtes à la requête
        request.headers.addAll(authHeaders);
        
        if (kDebugMode) {
          print('📤 En-têtes de la requête après ajout:');
          request.headers.forEach((key, values) {
            print('   $key: $values');
          });
          print('🌐 Envoi de la requête à: ${request.url}');
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print('❌ Erreur d\'authentification: ${e.message}');
        }
        rethrow;
      } catch (e) {
        final errorMsg = 'Erreur lors de la préparation de la requête: $e';
        if (kDebugMode) {
          print('❌ $errorMsg');
        }
        throw ApiException(errorMsg);
      }

      if (body != null) {
        request.body = _encodeBody(body) ?? '';
        if (kDebugMode) {
          print('Request Body: ${request.body}');
        }
      }

      http.StreamedResponse streamedResponse;
      try {
        if (kDebugMode) {
          print('\n🔄 Envoi de la requête...');
          print('   URL: ${request.url}');
          print('   Méthode: ${request.method}');
          print('   En-têtes:');
          request.headers.forEach((key, value) => print('     $key: $value'));
        }
        
        final stopwatch = Stopwatch()..start();
        streamedResponse = await request.send().timeout(timeout ?? defaultTimeout);
        
        if (kDebugMode) {
          print('\n🔄 Réponse reçue en ${stopwatch.elapsedMilliseconds}ms');
          print('   Code de statut: ${streamedResponse.statusCode}');
          print('   En-têtes de la réponse:');
          streamedResponse.headers.forEach((key, value) => print('     $key: $value'));
        }
      } on TimeoutException {
        throw ApiException('La requête a expiré. Veuillez réessayer plus tard.');
      } catch (e) {
        if (kDebugMode) {
          print('❌ Erreur lors de l\'envoi de la requête: $e');
        }
        rethrow;
      }

      final response = await http.Response.fromStream(streamedResponse);
      
      // Afficher les en-têtes et le début du corps pour le débogage
      if (kDebugMode) {
        final statusEmoji = response.statusCode >= 200 && response.statusCode < 300 ? '✅' : '❌';
        print('\n📡 Réponse du serveur:');
        print('$statusEmoji Status Code: ${response.statusCode}');
        
        // Afficher les en-têtes
        if (response.headers.isNotEmpty) {
          print('📋 Headers:');
          response.headers.forEach((key, value) => print('   $key: $value'));
        }
        
        // Afficher le corps de la réponse (limité pour éviter les logs trop longs)
        final bodyPreview = response.body.length > 500 
            ? '${response.body.substring(0, 500)}... (${response.body.length} caractères au total)' 
            : response.body;
            
        print('📦 Body:');
        print(bodyPreview);
        
        // Si c'est une erreur 401, vérifier si l'en-tête Authorization est présent
        if (response.statusCode == 401) {
          print('\n🔍 Détails de l\'erreur 401:');
          print('   - URL: ${request.url}');
          print('   - Méthode: ${request.method}');
          print('   - En-têtes de la requête:');
          request.headers.forEach((key, value) => print('     $key: ${key == 'Authorization' ? '${value.substring(0, 20)}...' : value}'));
        }
      }
      
      // Vérifier si la réponse est du HTML (erreur serveur)
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('text/html') && response.statusCode >= 400) {
        // Afficher la réponse complète du serveur pour le débogage
        print('\n❌ ERREUR SERVEUR (${response.statusCode})');
        print('=' * 80);
        print('URL: ${response.request?.url}');
        print('-' * 80);
        
        // Extraire et afficher le titre de l'erreur
        final titleMatch = RegExp(r'<title>(.*?)</title>', caseSensitive: false).firstMatch(response.body);
        if (titleMatch != null) {
          print('TITRE: ${titleMatch.group(1)?.trim() ?? 'Aucun titre trouvé'}');
          print('-' * 80);
        }
        
        // Essayer d'extraire le message d'erreur du body
        final bodyMatch = RegExp(r'<body[^>]*>(.*?)</body>', caseSensitive: false, dotAll: true).firstMatch(response.body);
        if (bodyMatch != null) {
          // Nettoyer le HTML pour une meilleure lisibilité
          String bodyText = bodyMatch.group(1) ?? '';
          // Supprimer les balises script et style
          bodyText = bodyText.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
          bodyText = bodyText.replaceAll(RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true), '');
          // Remplacer les balises de saut de ligne
          bodyText = bodyText.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
          // Supprimer les balises HTML restantes
          bodyText = bodyText.replaceAll(RegExp(r'<[^>]+>', multiLine: true), '');
          // Nettoyer les espaces multiples
          bodyText = bodyText.replaceAll(RegExp(r'\s+', multiLine: true), ' ').trim();
          
          if (bodyText.isNotEmpty) {
            print('MESSAGE D\'ERREUR:');
            print('-' * 80);
            print(bodyText);
            print('-' * 80);
          }
        }
        
        // Afficher les en-têtes de la réponse
        print('EN-TÊTES DE LA RÉPONSE:');
        print('-' * 80);
        response.headers.forEach((key, value) => print('$key: $value'));
        print('=' * 80);
        
        // Créer un message d'erreur lisible
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Requête incorrecte: ${titleMatch?.group(1)?.trim() ?? 'Vérifiez les données envoyées'}';
            break;
          case 401:
            errorMessage = 'Non autorisé: Votre session a expiré. Veuillez vous reconnecter.';
            break;
          case 403:
            errorMessage = 'Accès refusé: Vous n\'avez pas les droits nécessaires.';
            break;
          case 404:
            errorMessage = 'Ressource non trouvée: ${response.request?.url}';
            break;
          case 500:
            errorMessage = 'Erreur interne du serveur (500). Vérifiez les logs du serveur pour plus de détails.';
            break;
          default:
            errorMessage = 'Erreur ${response.statusCode}: ${titleMatch?.group(1)?.trim() ?? 'Erreur inconnue'}';
        }
        
        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
      
      // Vérifier si la réponse est valide
      if (response.body.isEmpty) {
        throw const FormatException('Réponse vide du serveur');
      }
      
      return _handleResponse(response);
      
    } on ApiException {
      rethrow; // On laisse passer les ApiException telles quelles
    } on SocketException catch (e) {
      throw ApiException('Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException('Erreur de format: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw ApiException('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) => _request('GET', endpoint, 
    headers: headers,
    queryParams: queryParams,
    timeout: timeout
  );

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) => _request('POST', endpoint, body: body, queryParams: queryParams, timeout: timeout);

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) => _request('PUT', endpoint, body: body, queryParams: queryParams, timeout: timeout);

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) => _request('PATCH', endpoint, body: body, queryParams: queryParams, timeout: timeout);

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) => _request('DELETE', endpoint, body: body, queryParams: queryParams, timeout: timeout);

  /// Récupère les données du tableau de bord depuis l'API
  Future<Map<String, dynamic>> fetchDashboardData() async {
    if (kDebugMode) {
      print('\n🔄 fetchDashboardData() appelé');
      print('🔗 Endpoint: ${config.ApiConfig.dashboard}');
    }
    
    try {
      // Récupérer les en-têtes d'authentification
      final headers = await _getAuthHeaders();
      if (kDebugMode) {
        print('🔑 En-têtes d\'authentification récupérés avec succès');
        print('   Authorization: ${headers['Authorization']?.substring(0, 20)}...');
      }
      
      // Utilisation de la constante ApiConfig.dashboard pour le chemin
      final response = await get(
        config.ApiConfig.dashboard,
        headers: headers,  // Pass the authentication headers
        timeout: const Duration(seconds: 30),
      ) as Map<String, dynamic>;

      if (kDebugMode) {
        print('✅ Réponse reçue du serveur');
        print('   Réponse: ${response.toString().substring(0, 100)}...');
      }

      // Vérifier que la réponse est valide
      if (response.isEmpty) {
        throw const FormatException('Réponse vide du serveur');
      }

      // Vérifier si la réponse contient une erreur
      if (response['success'] == false) {
        final errorMsg = response['message']?.toString() ?? 'Erreur lors de la récupération des données';
        if (kDebugMode) {
          print('❌ Erreur dans la réponse: $errorMsg');
        }
        throw ApiException(
          errorMsg,
          statusCode: response['statusCode'] ?? 400,
        );
      }

      // S'assurer que les champs requis sont présents
      if (response['user'] == null) {
        throw const FormatException('Données utilisateur manquantes dans la réponse');
      }

      if (kDebugMode) {
        print('✅ Données utilisateur trouvées dans la réponse');
      }
      
      return response;
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ApiException('Erreur de format des données: ${e.message}');
    } catch (e) {
      throw ApiException('Erreur lors de la récupération des données du tableau de bord: ${e.toString()}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}
