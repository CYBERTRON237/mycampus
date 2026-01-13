import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Configuration de base de l'API
class ApiConfig {
  // Singleton
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  // Configuration de base
  static String get baseUrl {
    if (kIsWeb) {
      // Pour le web, utiliser localhost est souvent plus fiable que 127.0.0.1
      return 'http://localhost/mycampus/api';
    } else {
      // Pour mobile/desktop, 127.0.0.1 est standard
      return 'http://127.0.0.1/mycampus/api';
    }
  }
  static const bool _isDebug = true;
  
  // Timeouts
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  
  // Storage pour le token
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  
  // Endpoints principaux
  // baseUrl constant is already defined above
  
  // Endpoints d'authentification
  static const String me = 'auth/me';
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-token';
  
  // Endpoints des institutions
  static const String institutions = 'institutions';
  
  // Endpoint du tableau de bord
  static const String dashboard = 'dashboards/dashboard.php';
  
  // Headers par défaut
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Méthode pour obtenir les headers avec authentification
  static Future<Map<String, String>> getAuthHeaders([String? token]) async {
    final headers = Map<String, String>.from(ApiConfig.headers);
    
    // Si un token est fourni, on l'utilise
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      return headers;
    }
    
    // Sinon, on essaie de récupérer le token stocké
    final storedToken = await getToken();
    if (storedToken != null) {
      headers['Authorization'] = 'Bearer $storedToken';
    }
    
    return headers;
  }
  
  // Gestion du token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      _log('Error getting token: $e');
      return null;
    }
  }
  
  static Future<void> setToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      _log('Error setting token: $e');
    }
  }
  
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _log('Error getting refresh token: $e');
      return null;
    }
  }
  
  static Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      _log('Error setting refresh token: $e');
    }
  }
  
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  static Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      _log('Error clearing auth: $e');
    }
  }
  
  // Méthode utilitaire pour le logging en mode debug
  static void _log(String message) {
    if (_isDebug) {
      debugPrint('🔵 API Config: $message');
    }
  }
  
  // Méthode utilitaire pour gérer les réponses HTTP
  static dynamic handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;
    
    _log('Response [${response.request?.method} ${response.request?.url}] - $statusCode');
    
    try {
      final jsonResponse = json.decode(responseBody);
      
      if (statusCode >= 200 && statusCode < 300) {
        return jsonResponse;
      } else {
        final errorMessage = jsonResponse['message'] ?? 'Une erreur est survenue';
        throw ApiException(
          errorMessage,
          statusCode: statusCode,
          data: jsonResponse,
        );
      }
    } catch (e) {
      _log('Error parsing response: $e');
      throw ApiException(
        'Erreur lors de la lecture de la réponse du serveur',
        statusCode: statusCode,
        data: responseBody,
      );
    }
  }
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  const ApiException(this.message, {this.statusCode, this.data});
  
  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}
