import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/department_model.dart';
import '../../../../features/auth/services/auth_service.dart';

class DepartmentRemoteDataSource {
  final http.Client client;
  final AuthService authService;
  final String baseUrl = 'http://localhost/mycampus/api/departments';

  DepartmentRemoteDataSource({
    required this.client,
    required this.authService,
  });

  Future<List<DepartmentModel>> getDepartments({
    String? facultyId,
    String? institutionId,
    String? search,
    DepartmentLevel? level,
    DepartmentStatus? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (facultyId != null) queryParams['faculty_id'] = facultyId;
      if (institutionId != null) queryParams['institution_id'] = institutionId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (level != null) queryParams['level'] = level.toJson();
      if (status != null) queryParams['status'] = status.toJson();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/index.php').replace(queryParameters: queryParams);
      
      final headers = await _getHeaders();
      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as List;
          return data.map((item) => DepartmentModel.fromJson(item)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load departments');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  Future<DepartmentModel> getDepartmentById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/index.php').replace(queryParameters: {'id': id});
      
      final headers = await _getHeaders();
      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] == true) {
          return DepartmentModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Department not found');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load department: $e');
    }
  }

  Future<DepartmentModel> createDepartment(DepartmentModel department) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/index.php'),
        headers: headers,
        body: json.encode(department.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] == true) {
          return DepartmentModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to create department');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create department: $e');
    }
  }

  Future<DepartmentModel> updateDepartment(String id, DepartmentModel department) async {
    try {
      final headers = await _getHeaders();
      final response = await client.put(
        Uri.parse('$baseUrl/index.php').replace(queryParameters: {'id': id}),
        headers: headers,
        body: json.encode(department.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] == true) {
          return DepartmentModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update department');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update department: $e');
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl/index.php').replace(queryParameters: {'id': id}),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] != true) {
          throw Exception(jsonResponse['message'] ?? 'Failed to delete department');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete department: $e');
    }
  }

  Future<void> toggleDepartmentStatus(String id, DepartmentStatus status) async {
    try {
      final headers = await _getHeaders();
      final response = await client.patch(
        Uri.parse('$baseUrl/index.php').replace(queryParameters: {
          'id': id,
          'action': 'toggle_status',
        }),
        headers: headers,
        body: json.encode({'status': status.toJson()}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] != true) {
          throw Exception(jsonResponse['message'] ?? 'Failed to toggle department status');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to toggle department status: $e');
    }
  }

  Future<Map<String, int>> getStatistics({
    String? facultyId,
    String? institutionId,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (facultyId != null) queryParams['faculty_id'] = facultyId;
      if (institutionId != null) queryParams['institution_id'] = institutionId;

      final uri = Uri.parse('$baseUrl/statistics.php').replace(queryParameters: queryParams);
      
      final headers = await _getHeaders();
      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(_cleanJsonResponse(response.body));
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          return data.map((key, value) => MapEntry(key, value as int));
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load statistics');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Ajouter le header d'autorisation si un token est disponible
    final token = await authService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String _cleanJsonResponse(String responseBody) {
    // Nettoyer la réponse JSON pour éviter les erreurs de parsing
    return responseBody.trim();
  }
}
