import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../features/auth/services/auth_service.dart';
import '../models/institution_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class InstitutionService with ChangeNotifier {
  static const String _tag = 'InstitutionService';
  
  static String get baseUrl => '${ApiConfig.baseUrl}/institutions';
  
  static const storage = FlutterSecureStorage();
  
  static final InstitutionService _instance = InstitutionService._internal();
  factory InstitutionService() => _instance;
  InstitutionService._internal() {
    AppLogger.debug('Initialisation du service InstitutionService', tag: _tag);
  }

  final Map<String, InstitutionModel> _institutionsCache = {};
  List<InstitutionModel>? _allInstitutions;
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _perPage = 20;
  Map<String, dynamic> _currentFilters = {};

  List<InstitutionModel>? get allInstitutions => _allInstitutions?.toList();
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get perPage => _perPage;
  Map<String, dynamic> get currentFilters => Map.unmodifiable(_currentFilters);
  
  Future<Map<String, dynamic>> getStats() async {
    const methodName = 'getStats';
    final requestId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    
    AppLogger.info('🔵 Début de la récupération des statistiques', 
        tag: '$_tag.$methodName',
        context: {'request_id': requestId});
    
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié - Token manquant', statusCode: 401);
      }

      final url = '$baseUrl/stats';
      final headers = await ApiConfig.getAuthHeaders(token);
      
      AppLogger.debug('Envoi de la requête GET: $url', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Délai d\'attente dépassé'),
      );

      AppLogger.debug('Réponse reçue: ${response.statusCode}', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          AppLogger.info('✅ Statistiques récupérées avec succès', 
              tag: '$_tag.$methodName',
              context: {'request_id': requestId});
          return data['data'];
        }
        throw ApiException(
          data['message'] ?? 'Format de réponse invalide',
          statusCode: 200,
          data: data,
        );
      } else {
        throw _handleError(response, requestId);
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Erreur lors de la récupération des statistiques', 
          tag: '$_tag.$methodName',
          error: e,
          stackTrace: stackTrace,
          context: {'request_id': requestId});
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
    const methodName = 'getAllInstitutions';
    final requestId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    
    AppLogger.info('🔵 Début du chargement des institutions', 
        tag: '$_tag.$methodName',
        context: {
          'request_id': requestId,
          'page': page,
          'search': searchQuery,
        });
    
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié', statusCode: 401);
      }
      
      if (filters != null) {
        _currentFilters = Map.from(filters);
      }
      
      final params = {
        'page': page.toString(),
        'per_page': _perPage.toString(),
        if (searchQuery?.isNotEmpty ?? false) 'search': searchQuery!,
        if (orderBy != null) 'order_by': orderBy,
        'order_dir': ascending ? 'asc' : 'desc',
        ..._currentFilters.map((key, value) => 
          MapEntry(key, value?.toString() ?? ''))
      }..removeWhere((key, value) => value.isEmpty);
      
      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      
      AppLogger.debug('Envoi de la requête GET: ${uri.toString()}', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});
      
      final headers = await ApiConfig.getAuthHeaders(token);
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Délai d\'attente dépassé'),
      );

      AppLogger.debug('Réponse reçue: ${response.statusCode}', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data['success'] == true) {
          _currentPage = page;
          _totalPages = data['pagination']?['total_pages'] ?? 1;
          _totalItems = data['pagination']?['total'] ?? 0;
          
          final institutions = (data['data'] as List)
              .map((json) => InstitutionModel.fromJson(json))
              .toList();
          
          _allInstitutions = institutions;
          
          for (var inst in institutions) {
            _institutionsCache[inst.id] = inst;
          }
          
          AppLogger.info('✅ ${institutions.length} institutions chargées avec succès', 
              tag: '$_tag.$methodName',
              context: {'request_id': requestId});
          
          notifyListeners();
          return institutions;
        }
        
        throw ApiException(
          data['message'] ?? 'Format de réponse invalide',
          statusCode: 200,
          data: data,
        );
      } else {
        throw _handleError(response, requestId);
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Erreur lors du chargement des institutions', 
          tag: '$_tag.$methodName',
          error: e,
          stackTrace: stackTrace,
          context: {'request_id': requestId});
      rethrow;
    }
  }

  Future<InstitutionModel> getInstitutionById(String id) async {
    if (_institutionsCache.containsKey(id)) {
      return _institutionsCache[id]!;
    }

    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié', statusCode: 401);
      }

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
        throw ApiException(
          data['message'] ?? 'Format de réponse invalide',
          statusCode: 200,
          data: data,
        );
      } else if (response.statusCode == 404) {
        throw ApiException('Institution non trouvée', statusCode: 404);
      } else {
        throw _handleError(response, 'getById');
      }
    } catch (e) {
      developer.log('Erreur lors de la récupération de l\'institution: $e', 
          name: _tag);
      rethrow;
    }
  }

  Future<InstitutionModel> createInstitution(InstitutionModel institution) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié', statusCode: 401);
      }

      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: json.encode(institution.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final newInstitution = InstitutionModel.fromJson(data['data']);
          _institutionsCache[newInstitution.id] = newInstitution;
          _allInstitutions?.add(newInstitution);
          _totalItems++;
          notifyListeners();
          return newInstitution;
        }
        throw ApiException(
          data['message'] ?? 'Échec de la création de l\'institution',
          statusCode: 201,
          data: data,
        );
      } else {
        throw _handleError(response, 'create');
      }
    } catch (e) {
      developer.log('Erreur lors de la création de l\'institution: $e', 
          name: _tag);
      rethrow;
    }
  }

  Future<InstitutionModel> updateInstitution(InstitutionModel institution) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié', statusCode: 401);
      }

      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.put(
        Uri.parse('$baseUrl/${institution.id}'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: json.encode(institution.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          final updatedInstitution = InstitutionModel.fromJson(data['data']);
          _institutionsCache[updatedInstitution.id] = updatedInstitution;
          _allInstitutions = _allInstitutions?.map((i) => 
            i.id == updatedInstitution.id ? updatedInstitution : i).toList();
          notifyListeners();
          return updatedInstitution;
        }
        throw ApiException(
          data['message'] ?? 'Échec de la mise à jour de l\'institution',
          statusCode: 200,
          data: data,
        );
      } else {
        throw _handleError(response, 'update');
      }
    } catch (e) {
      developer.log('Erreur lors de la mise à jour de l\'institution: $e', 
          name: _tag);
      rethrow;
    }
  }

  Future<bool> deleteInstitution(String id) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié', statusCode: 401);
      }

      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _institutionsCache.remove(id);
        _allInstitutions = _allInstitutions?.where((i) => i.id != id).toList();
        _totalItems = _totalItems > 0 ? _totalItems - 1 : 0;
        notifyListeners();
        return true;
      } else {
        throw _handleError(response, 'delete');
      }
    } catch (e) {
      developer.log('Erreur lors de la suppression de l\'institution: $e', 
          name: _tag);
      rethrow;
    }
  }

  Future<List<InstitutionModel>> searchInstitutions(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final token = await AuthService().getToken();
      if (token == null) {
        throw ApiException('Non authentifié', statusCode: 401);
      }

      final headers = await ApiConfig.getAuthHeaders(token);
      final response = await http.get(
        Uri.parse('$baseUrl/search').replace(
          queryParameters: {'q': query},
        ),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          return (data['data'] as List)
              .map((json) => InstitutionModel.fromJson(json))
              .toList();
        }
        throw ApiException(
          data['message'] ?? 'Erreur lors de la recherche',
          statusCode: 200,
          data: data,
        );
      } else {
        throw _handleError(response, 'search');
      }
    } catch (e) {
      developer.log('Erreur lors de la recherche d\'institutions: $e', 
          name: _tag);
      rethrow;
    }
  }

  void clearCache() {
    _institutionsCache.clear();
    _allInstitutions = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _currentFilters.clear();
    notifyListeners();
  }
  
  Exception _handleError(http.Response response, String requestId) {
    try {
      AppLogger.error(
        '❌ Erreur API - Status: ${response.statusCode}',
        tag: '$_tag._handleError',
        context: {
          'request_id': requestId,
          'url': response.request?.url.toString(),
          'method': response.request?.method,
          'status_code': response.statusCode,
          'reason_phrase': response.reasonPhrase,
          'content_type': response.headers['content-type'],
        },
      );

      if (response.body.isEmpty) {
        return ApiException(
          'Réponse vide du serveur',
          statusCode: response.statusCode,
        );
      }

      try {
        final data = json.decode(response.body);
        
        if (response.body.trim().startsWith('<!DOCTYPE html>') || 
            response.body.trim().startsWith('<br />')) {
          return ApiException(
            'Le serveur a renvoyé une page d\'erreur HTML au lieu de JSON',
            statusCode: response.statusCode,
          );
        }
        
        if (data is Map) {
          final errorMessage = data['message']?.toString() ?? 
                             data['error']?.toString() ?? 
                             'Une erreur est survenue lors du traitement de votre demande';
                             
          AppLogger.error(
            'Erreur API: $errorMessage',
            tag: '$_tag._handleError',
            context: {
              'request_id': requestId,
              'response_data': data,
            },
          );
          
          return ApiException(
            errorMessage,
            statusCode: response.statusCode,
            data: data,
          );
        }
        
        return ApiException(
          'Format de réponse inattendu du serveur',
          statusCode: response.statusCode,
        );
        
      } catch (jsonError) {
        return ApiException(
          'Impossible de décoder la réponse du serveur: ${jsonError.toString()}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur lors du traitement de la réponse d\'erreur',
        tag: '$_tag._handleError',
        error: e,
        stackTrace: stackTrace,
      );
      
      return ApiException(
        'Erreur lors du traitement de la réponse du serveur: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
}
