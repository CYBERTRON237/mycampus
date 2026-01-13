import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../features/configs/services/api_config.dart';
import '../../../../features/auth/services/auth_service.dart';
import '../../domain/models/institution_model.dart';

class InstitutionRemoteDataSource {
  final http.Client client;
  final AuthService authService;

  InstitutionRemoteDataSource({
    required this.client,
    required this.authService,
  });

  Future<List<InstitutionModel>> getInstitutions({
    String? search,
    InstitutionType? type,
    InstitutionStatus? status,
    String? region,
    int? page = 1,
    int? limit = 20,
  }) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null) queryParams['search'] = search;
    if (type != null) queryParams['type'] = type.name;
    if (status != null) queryParams['status'] = status.name;
    if (region != null) queryParams['region'] = region;

    final uri = Uri.parse('${ApiConfig.baseUrl}/institutions')
        .replace(queryParameters: queryParams);

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final institutionsList = data['data'] as List;
      
      return institutionsList
          .map((json) => InstitutionModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Erreur lors de la récupération des institutions: ${response.statusCode}');
    }
  }

  Future<InstitutionModel> getInstitutionById(String id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return InstitutionModel.fromJson(data['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Institution non trouvée');
    } else {
      throw Exception('Erreur lors de la récupération de l\'institution: ${response.statusCode}');
    }
  }

  Future<InstitutionModel> createInstitution(InstitutionModel institution) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/institutions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(institution.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return InstitutionModel.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de la création de l\'institution: ${response.statusCode}');
    }
  }

  Future<InstitutionModel> updateInstitution(String id, InstitutionModel institution) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(institution.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return InstitutionModel.fromJson(data['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Institution non trouvée');
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'institution: ${response.statusCode}');
    }
  }

  Future<void> deleteInstitution(String id) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Institution non');
    } else {
      throw Exception('Erreur lors de la suppression de l\'institution: ${response.statusCode}');
    }
  }

  Future<void> toggleInstitutionStatus(String id, InstitutionStatus status) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/institutions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status.name}),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Institution non trouvée');
    } else {
      throw Exception('Erreur lors de la mise à jour du statut: ${response.statusCode}');
    }
  }

  Future<List<String>> getRegions() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/institutions/regions'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final regionsList = data['data'] as List;
      return regionsList.cast<String>();
    } else {
      throw Exception('Erreur lors de la récupération des régions: ${response.statusCode}');
    }
  }

  Future<Map<String, int>> getStatistics() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/institutions/statistics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Map<String, int>.from(data['data']);
    } else {
      throw Exception('Erreur lors de la récupération des statistiques: ${response.statusCode}');
    }
  }
}
