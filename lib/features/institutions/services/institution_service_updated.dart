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
  
  /// Formatte les en-têtes pour les logs en masquant les informations sensibles
  String _formatHeaders(Map<String, String> headers) {
    return headers.entries
        .map((e) => '   ${e.key}: ${e.key.toLowerCase().contains('auth') ? '***' : e.value}')
        .join('\n');
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
        error: 'Headers: ${_formatHeaders(headers)}');

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
      
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: Map.fromEntries(
          params.entries.map((e) => MapEntry(e.key, e.value?.toString()))
        ),
      );
      
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
      
      // Mise à jour des filtres actuels
      if (filters != null) {
        _currentFilters.clear();
        _currentFilters.addAll(filters);
      }
      
      // Notification des écouteurs
      notifyListeners();
      
    } catch (e) {
      developer.log('Erreur lors du chargement des institutions: $e', 
          name: 'InstitutionService',
          error: e);
      rethrow;
    }
  }

  /// Réinitialise la pagination et les filtres
  void resetPagination() {
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _currentFilters.clear();
    notifyListeners();
  }

  /// Change la page courante
  void setPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    loadInstitutions();
  }

  /// Rafraîchit les données actuelles
  Future<void> refresh() async {
    return loadInstitutions(filters: _currentFilters);
  }

  /// Nettoie le cache des institutions
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
