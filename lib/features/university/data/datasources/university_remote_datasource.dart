import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/university_model.dart';
import '../../../../features/auth/services/auth_service.dart';

class UniversityRemoteDataSource {
  final http.Client client;
  final AuthService authService;

  UniversityRemoteDataSource({
    required this.client,
    required this.authService,
  });

  Future<List<UniversityModel>> getUniversities({
    String? search,
    UniversityType? type,
    UniversityStatus? status,
    String? region,
    int? page,
    int? limit,
  }) async {
    try {
      final token = await authService.getToken();
      
      try {
        final queryParams = <String, String>{
          if (search != null && search.isNotEmpty) 'search': search,
          if (type != null) 'type': type.name,
          if (status != null) 'status': status.name,
          if (region != null && region.isNotEmpty) 'region': region,
          if (page != null) 'page': page.toString(),
          if (limit != null) 'limit': limit.toString(),
        };

        final uri = Uri.parse('http://localhost/mycampus/api/institutions/index.php')
            .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

        print('Requesting universities from: $uri');

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
            final universitiesList = data['data'] as List;
            print('Found ${universitiesList.length} universities');
            
            return universitiesList.map((json) {
              try {
                return UniversityModel.fromJson(json);
              } catch (e) {
                print('Error parsing university: $e');
                print('JSON data: $json');
                rethrow;
              }
            }).toList();
          } else {
            throw Exception(data['message'] ?? 'Erreur lors de la récupération des universités');
          }
        } else {
          throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception in getUniversities: $e');
        rethrow;
      }
    } catch (e) {
      print('Exception getting token: $e');
      // Continuer sans token si l'authentification échoue
      rethrow;
    }
  }

  Future<UniversityModel> getUniversityById(String id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.get(
      Uri.parse('http://localhost/mycampus/api/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return UniversityModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Université non trouvée');
      }
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<UniversityModel> createUniversity(UniversityModel university) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.post(
      Uri.parse('http://localhost/mycampus/api/institutions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(university.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return UniversityModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la création de l\'université');
      }
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<UniversityModel> updateUniversity(String id, UniversityModel university) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.put(
      Uri.parse('http://localhost/mycampus/api/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(university.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return UniversityModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la mise à jour de l\'université');
      }
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<void> deleteUniversity(String id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.delete(
      Uri.parse('http://localhost/mycampus/api/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Erreur lors de la suppression de l\'université');
      }
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<void> toggleUniversityStatus(String id, UniversityStatus status) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.patch(
      Uri.parse('http://localhost/mycampus/api/institutions/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status.name}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Erreur lors de la mise à jour du statut');
      }
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<void> verifyUniversity(String id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.patch(
      Uri.parse('http://localhost/mycampus/api/institutions/$id/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Erreur lors de la vérification de l\'université');
      }
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<List<String>> getRegions() async {
    try {
      final token = await authService.getToken();
      
      try {
        final response = await client.get(
          Uri.parse('http://localhost/mycampus/api/institutions/regions.php'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));

        print('Regions response status: ${response.statusCode}');
        print('Regions response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseBody = response.body.trim();
          
          // Nettoyer la réponse si nécessaire
          String cleanBody = responseBody;
          if (cleanBody.endsWith('null')) {
            cleanBody = cleanBody.substring(0, cleanBody.length - 4);
          }
          
          final data = json.decode(cleanBody);
          if (data['success'] == true) {
            final regionsList = data['data'] as List;
            return regionsList.map((region) => region.toString()).toList();
          } else {
            throw Exception(data['message'] ?? 'Erreur lors de la récupération des régions');
          }
        } else {
          throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception in getRegions: $e');
        rethrow;
      }
    } catch (e) {
      print('Exception getting token: $e');
      // Continuer sans token si l'authentification échoue
      rethrow;
    }
  }

  Future<Map<String, int>> getStatistics() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    try {
      final response = await client.get(
        Uri.parse('http://localhost/mycampus/api/institutions/statistics.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
              // Pour les objets comme 'by_region', on les convertit en chaîne JSON
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
