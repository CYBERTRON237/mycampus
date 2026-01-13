import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/university_model.dart';
import '../../../../features/auth/services/auth_service.dart';

class UniversityService {
  final http.Client client;
  final AuthService authService;

  UniversityService({
    http.Client? client,
    AuthService? authService,
  }) : client = client ?? http.Client(),
       authService = authService ?? AuthService();

  Future<List<UniversityModel>> getUniversities({
    String? search,
    String? type,
    String? status,
    String? region,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = await authService.getToken();
      
      try {
        final queryParams = <String, String>{
          'page': page.toString(),
          'limit': limit.toString(),
        };

        if (search != null && search.isNotEmpty) queryParams['search'] = search;
        if (type != null && type.isNotEmpty) queryParams['type'] = type;
        if (status != null && status.isNotEmpty) queryParams['status'] = status;
        if (region != null && region.isNotEmpty) queryParams['region'] = region;

        final uri = Uri.parse('http://127.0.0.1/mycampus/api/universities')
            .replace(queryParameters: queryParams);

        print('DEBUG: UniversityService - URL: $uri');

        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        
        // Ajouter l'header d'autorisation seulement si un token est disponible
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }

        final response = await client.get(
          uri,
          headers: headers,
        ).timeout(const Duration(seconds: 15));

        print('DEBUG: UniversityService - Status: ${response.statusCode}');
        print('DEBUG: UniversityService - Body: ${response.body}');

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

  Future<UniversityModel?> getUniversityById(int id) async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        Uri.parse('http://127.0.0.1/mycampus/api/universities/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UniversityModel.fromJson(data['data']);
        } else {
          throw Exception('University not found');
        }
      } else {
        throw Exception('Failed to load university: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR: UniversityService - $e');
      throw Exception('Erreur lors du chargement de l\'université: $e');
    }
  }

  Future<List<String>> getRegions() async {
    try {
      final token = await authService.getToken();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        Uri.parse('http://127.0.0.1/mycampus/api/universities/regions'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> regionsData = data['data'];
          return regionsData.map((region) => region.toString()).toList();
        } else {
          throw Exception('Failed to load regions');
        }
      } else {
        throw Exception('Failed to load regions: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR: UniversityService - $e');
      return [];
    }
  }

  void dispose() {
    client.close();
  }
}
