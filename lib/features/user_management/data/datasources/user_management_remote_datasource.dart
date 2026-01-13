import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../../../auth/services/auth_service.dart';

abstract class UserManagementRemoteDataSource {
  Future<List<UserModel>> getUsers({UserFilters? filters});
  Future<UserModel> getUserById(int id);
  Future<UserManagementResult> createUser(Map<String, dynamic> userData);
  Future<UserManagementResult> updateUser(int id, Map<String, dynamic> userData);
  Future<UserManagementResult> deleteUser(int id);
  Future<List<UserRoleStats>> getUserStats();
  Future<UserManagementResult> assignRole(int userId, String role);
  Future<CurrentUserInfo> getCurrentUser();
  Future<List<UserModel>> searchUsers(Map<String, dynamic> searchParams);
}

class UserManagementRemoteDataSourceImpl implements UserManagementRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  UserManagementRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://127.0.0.1/mycampus/api/user_management',
  });

  @override
  Future<List<UserModel>> getUsers({UserFilters? filters}) async {
    print('DEBUG: RemoteDataSource.getUsers - Début avec filtres: ${filters?.toJson()}');
    try {
      final queryParams = <String, String>{
        'page': (filters?.page ?? 1).toString(),
        'limit': (filters?.limit ?? 20).toString(),
      };

      if (filters?.search != null && filters!.search!.isNotEmpty) {
        queryParams['search'] = filters.search!;
      }
      if (filters?.role != null && filters!.role!.isNotEmpty) {
        queryParams['role'] = filters.role!;
      }
      if (filters?.status != null && filters!.status!.isNotEmpty) {
        queryParams['status'] = filters.status!;
      }
      if (filters?.institutionId != null) {
        queryParams['institution_id'] = filters!.institutionId.toString();
      }

      final uri = Uri.parse('$baseUrl/users').replace(queryParameters: queryParams);
      print('DEBUG: RemoteDataSource.getUsers - URL: $uri');
      
      final headers = await _getHeaders();
      print('DEBUG: RemoteDataSource.getUsers - Headers: $headers');
      
      final response = await client.get(uri, headers: headers);
      print('DEBUG: RemoteDataSource.getUsers - Status: ${response.statusCode}');
      print('DEBUG: RemoteDataSource.getUsers - Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      if (response.statusCode == 200) {
        // Vérifier si la réponse est du HTML (erreur PHP) ou du JSON
        if (response.body.trim().startsWith('<')) {
          print('DEBUG: RemoteDataSource.getUsers - Erreur PHP détectée (HTML retourné)');
          throw Exception('Erreur serveur PHP - Vérifiez les logs WAMP');
        }
        
        final jsonData = json.decode(response.body);
        print('DEBUG: RemoteDataSource.getUsers - Response: ${jsonData['success']}');
        if (jsonData['success'] == true) {
          final usersData = jsonData['data'] as List;
          final result = usersData.map((user) => UserModel.fromJson(user)).toList();
          print('DEBUG: RemoteDataSource.getUsers - ${result.length} utilisateurs parsés');
          return result;
        } else {
          print('DEBUG: RemoteDataSource.getUsers - Erreur API: ${jsonData['message']}');
          throw Exception(jsonData['message'] ?? 'Failed to load users');
        }
      } else {
        print('DEBUG: RemoteDataSource.getUsers - Erreur HTTP: ${response.statusCode}');
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: RemoteDataSource.getUsers - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    print('DEBUG: RemoteDataSource.getUserById - Début pour ID: $id');
    try {
      final uri = Uri.parse('$baseUrl/users/$id');
      print('DEBUG: RemoteDataSource.getUserById - URL: $uri');
      final response = await client.get(uri, headers: await _getHeaders());
      print('DEBUG: RemoteDataSource.getUserById - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return UserModel.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'User not found');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<UserManagementResult> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      );

      final jsonData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return UserManagementResult.fromJson(jsonData);
      } else {
        return UserManagementResult.fromJson(jsonData);
      }
    } catch (e) {
      return UserManagementResult.error('Network error: $e');
    }
  }

  @override
  Future<UserManagementResult> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      );

      final jsonData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return UserManagementResult.fromJson(jsonData);
      } else {
        return UserManagementResult.fromJson(jsonData);
      }
    } catch (e) {
      return UserManagementResult.error('Network error: $e');
    }
  }

  @override
  Future<UserManagementResult> deleteUser(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: await _getHeaders(),
      );

      final jsonData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return UserManagementResult.fromJson(jsonData);
      } else {
        return UserManagementResult.fromJson(jsonData);
      }
    } catch (e) {
      return UserManagementResult.error('Network error: $e');
    }
  }

  @override
  Future<List<UserRoleStats>> getUserStats() async {
    print('DEBUG: RemoteDataSource.getUserStats - Début');
    try {
      final uri = Uri.parse('$baseUrl/users/stats');
      print('DEBUG: RemoteDataSource.getUserStats - URL: $uri');
      
      final headers = await _getHeaders();
      print('DEBUG: RemoteDataSource.getUserStats - Headers: $headers');
      
      final response = await client.get(uri, headers: headers);
      print('DEBUG: RemoteDataSource.getUserStats - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('DEBUG: RemoteDataSource.getUserStats - Response: ${jsonData['success']}');
        if (jsonData['success'] == true) {
          final statsData = jsonData['data'] as List;
          final result = statsData.map((stat) => UserRoleStats.fromJson(stat)).toList();
          print('DEBUG: RemoteDataSource.getUserStats - ${result.length} statistiques parsées');
          return result;
        } else {
          print('DEBUG: RemoteDataSource.getUserStats - Erreur API: ${jsonData['message']}');
          throw Exception(jsonData['message'] ?? 'Failed to load stats');
        }
      } else {
        print('DEBUG: RemoteDataSource.getUserStats - Erreur HTTP: ${response.statusCode}');
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: RemoteDataSource.getUserStats - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<UserManagementResult> assignRole(int userId, String role) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/$userId/roles'),
        headers: await _getHeaders(),
        body: json.encode({'role': role}),
      );

      final jsonData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return UserManagementResult.fromJson(jsonData);
      } else {
        return UserManagementResult.fromJson(jsonData);
      }
    } catch (e) {
      return UserManagementResult.error('Network error: $e');
    }
  }

  @override
  Future<CurrentUserInfo> getCurrentUser() async {
    print('DEBUG: RemoteDataSource.getCurrentUser - Début');
    try {
      final uri = Uri.parse('$baseUrl/users/current');
      print('DEBUG: RemoteDataSource.getCurrentUser - URL: $uri');
      
      final headers = await _getHeaders();
      print('DEBUG: RemoteDataSource.getCurrentUser - Headers: $headers');
      
      final response = await client.get(uri, headers: headers);
      print('DEBUG: RemoteDataSource.getCurrentUser - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('DEBUG: RemoteDataSource.getCurrentUser - Response: ${jsonData['success']}');
        if (jsonData['success'] == true) {
          final result = CurrentUserInfo.fromJson(jsonData['data']);
          print('DEBUG: RemoteDataSource.getCurrentUser - Utilisateur: ${result.user.fullName}');
          return result;
        } else {
          print('DEBUG: RemoteDataSource.getCurrentUser - Erreur API: ${jsonData['message']}');
          throw Exception(jsonData['message'] ?? 'Failed to load current user');
        }
      } else {
        print('DEBUG: RemoteDataSource.getCurrentUser - Erreur HTTP: ${response.statusCode}');
        throw Exception('Failed to load current user: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: RemoteDataSource.getCurrentUser - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(Map<String, dynamic> searchParams) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/search'),
        headers: await _getHeaders(),
        body: json.encode(searchParams),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final usersData = jsonData['data'] as List;
          return usersData.map((user) => UserModel.fromJson(user)).toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Search failed');
        }
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    print('DEBUG: _getHeaders - Début');
    final authService = AuthService();
    final token = await authService.getToken();
    print('DEBUG: _getHeaders - Token: ${token != null ? "Présent" : "Absent"}');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('DEBUG: _getHeaders - Authorization ajoutée');
    }
    
    print('DEBUG: _getHeaders - Headers finaux: $headers');
    return headers;
  }
}
