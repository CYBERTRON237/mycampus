import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/preinscription_model.dart';
import '../models/complete_preinscription_model.dart';

class PreinscriptionService {
  static const String baseUrl = 'http://127.0.0.1/mycampus/api/preinscription';

  Future<Map<String, dynamic>> submitPreinscription(PreinscriptionModel preinscription) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(preinscription.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? '',
          'data': responseData['data'] ?? null,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> submitCompletePreinscription(CompletePreinscriptionModel preinscription) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(preinscription.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? '',
          'data': responseData['data'] ?? null,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getPreinscriptionByCode(String uniqueCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get.php?code=$uniqueCode'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? '',
          'data': responseData['data'] ?? null,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updatePreinscription(String uniqueCode, PreinscriptionModel preinscription) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update.php?code=$uniqueCode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(preinscription.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? '',
          'data': responseData['data'] ?? null,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }
}
