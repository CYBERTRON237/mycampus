import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/faculty_model.dart';
import '../../../../features/auth/services/auth_service.dart';

class FacultyRemoteDataSource {
  final http.Client client;
  final AuthService authService;

  FacultyRemoteDataSource({
    required this.client,
    required this.authService,
  });

  Future<List<FacultyModel>> getFaculties({
    String? institutionId,
    String? search,
    FacultyStatus? status,
    int? page,
    int? limit,
  }) async {
    try {
      final token = await authService.getToken();
      
      try {
        final queryParams = <String, String>{
          if (institutionId != null && institutionId.isNotEmpty) 'institution_id': institutionId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null) 'status': status.value,
          if (page != null) 'page': page.toString(),
          if (limit != null) 'limit': limit.toString(),
        };

        final uri = Uri.parse('http://localhost/mycampus/api/faculties/index.php')
            .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

        print('Requesting faculties from: $uri');

        final headers = <String, String>{
          'Content-Type': 'application/json',
        };
        
        // Ajouter l'header d'autorisation seulement si un token est disponible
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }

        final response = await client.get(
          uri,
          headers: headers,
        ).timeout(const Duration(seconds: 15));

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseBody = response.body.trim();
          
          // Nettoyer la réponse si nécessaire
          String cleanBody = responseBody;
          if (cleanBody.endsWith('null')) {
            cleanBody = cleanBody.substring(0, cleanBody.length - 4);
          }
          
          final data = json.decode(cleanBody);
          if (data['success'] == true) {
            final facultiesList = data['data'] as List;
            print('Found ${facultiesList.length} faculties');
            
            return facultiesList.map((json) {
              try {
                return FacultyModel.fromJson(json);
              } catch (e) {
                print('Error parsing faculty: $e');
                print('JSON data: $json');
                rethrow;
              }
            }).toList();
          } else {
            throw Exception(data['message'] ?? 'Erreur lors de la récupération des facultés');
          }
        } else {
          throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception in getFaculties: $e');
        rethrow;
      }
    } catch (e) {
      print('Exception getting token: $e');
      // Continuer sans token si l'authentification échoue
      rethrow;
    }
  }

  Future<FacultyModel> getFacultyById(String id) async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        Uri.parse('http://localhost/mycampus/api/faculties/index.php?id=$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return FacultyModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Faculté non trouvée');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getFacultyById: $e');
      rethrow;
    }
  }

  Future<FacultyModel> createFaculty(FacultyModel faculty) async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.post(
        Uri.parse('http://localhost/mycampus/api/faculties/index.php'),
        headers: headers,
        body: json.encode(faculty.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return FacultyModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la création de la faculté');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in createFaculty: $e');
      rethrow;
    }
  }

  Future<FacultyModel> updateFaculty(String id, FacultyModel faculty) async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.put(
        Uri.parse('http://localhost/mycampus/api/faculties/index.php?id=$id'),
        headers: headers,
        body: json.encode(faculty.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return FacultyModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la mise à jour de la faculté');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in updateFaculty: $e');
      rethrow;
    }
  }

  Future<void> deleteFaculty(String id) async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.delete(
        Uri.parse('http://localhost/mycampus/api/faculties/index.php?id=$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Erreur lors de la suppression de la faculté');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in deleteFaculty: $e');
      rethrow;
    }
  }

  Future<void> toggleFacultyStatus(String id, FacultyStatus status) async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.patch(
        Uri.parse('http://localhost/mycampus/api/faculties/index.php?id=$id&action=toggle_status'),
        headers: headers,
        body: json.encode({'status': status.value}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Erreur lors de la mise à jour du statut');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in toggleFacultyStatus: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getStatistics({String? institutionId}) async {
    try {
      final token = await authService.getToken();
      
      final queryParams = <String, String>{
        if (institutionId != null && institutionId.isNotEmpty) 'institution_id': institutionId,
      };

      final uri = Uri.parse('http://localhost/mycampus/api/faculties/statistics.php')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print('Statistics response status: ${response.statusCode}');
      print('Statistics response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        
        // Nettoyer la réponse si nécessaire
        String cleanBody = responseBody;
        if (cleanBody.endsWith('null')) {
          cleanBody = cleanBody.substring(0, cleanBody.length - 4);
        }
        
        final data = json.decode(cleanBody);
        if (data['success'] == true) {
          final stats = data['data'] as Map<String, dynamic>;
          
          // Convertir toutes les valeurs en int
          final Map<String, int> intStats = {};
          stats.forEach((key, value) {
            if (value is Map) {
              // Pour les objets comme 'by_status', on les convertit en chaîne JSON
              intStats[key] = json.encode(value).length;
            } else {
              intStats[key] = int.parse(value.toString());
            }
          });
          
          return intStats;
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération des statistiques');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getStatistics: $e');
      rethrow;
    }
  }
}
