// Extension du AuthService pour vérifier l'existence d'utilisateurs
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> checkUserExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1/mycampus/api/auth/check_user_exists.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'exists': data['exists'] ?? false,
          'user': data['user'] ?? null,
          'message': data['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'exists': false,
          'message': 'Erreur serveur',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'exists': false,
        'message': 'Erreur de connexion',
      };
    }
  }

  // Méthode pour créer un compte invite automatiquement
  static Future<Map<String, dynamic>> createInviteAccount({
    required String email,
    String? phone,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1/mycampus/api/auth/create_invite_account.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'first_name': firstName,
          'last_name': lastName,
          'role': 'invite',
          'status': 'pending_verification',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'user': data['user'] ?? null,
          'message': data['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    }
  }
}
