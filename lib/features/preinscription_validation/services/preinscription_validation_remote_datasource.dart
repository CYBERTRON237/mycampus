import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';
import 'package:mycampus/features/preinscription_validation/services/preinscription_validation_repository.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';

class PreinscriptionValidationRemoteDataSource implements PreinscriptionValidationRepository {
  final http.Client client;
  final AuthService authService;
  
  PreinscriptionValidationRemoteDataSource({
    required this.client,
    required this.authService,
  });

  // URL de base pour l'API
  static const String baseUrl = 'http://127.0.0.1/mycampus';

  @override
  Future<List<PreinscriptionValidationModel>> getPendingPreinscriptions() async {
    try {
      final token = await authService.getToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await client.get(
        Uri.parse('$baseUrl/api/preinscription_validation/validation_api_working_final.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> preinscriptionsJson = data['data'];
          return preinscriptionsJson
              .map((json) => PreinscriptionValidationModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération des préinscriptions');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> validatePreinscription(
    int preinscriptionId, 
    String comments
  ) async {
    try {
      final token = await authService.getToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await client.post(
        Uri.parse('$baseUrl/api/preinscription_validation/validation_api_working_final.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'action': 'validate',
          'preinscription_id': preinscriptionId,
          'admin_id': (await authService.getCurrentUser())?.id ?? 1,
          'comments': comments,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la validation');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<bool> rejectPreinscription(
    int preinscriptionId, 
    String rejectionReason
  ) async {
    try {
      final token = await authService.getToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await client.post(
        Uri.parse('$baseUrl/api/preinscription_validation/validation_api_working_final.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'action': 'reject',
          'preinscription_id': preinscriptionId,
          'admin_id': (await authService.getCurrentUser())?.id ?? 1,
          'rejection_reason': rejectionReason,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  @override
  Future<ValidationStatsModel> getValidationStats() async {
    try {
      final token = await authService.getToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await client.get(
        Uri.parse('$baseUrl/api/preinscription_validation/validation_api_working_final.php?action=stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ValidationStatsModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération des statistiques');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
