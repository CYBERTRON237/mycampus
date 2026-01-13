import 'dart:convert';
import 'package:http/http.dart' as http;

// Test simple pour vérifier la connexion Flutter au backend
class TestFlutterConnection {
  static const String baseUrl = 'http://127.0.0.1/mycampus/api/user_management';
  
  // Token JWT simple pour les tests
  static const String testToken = 'eyJ1c2VyX2lkIjoxLCJleHAiOjE3NjU1MjEyMTZ9.test';
  
  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $testToken',
    };
  }

  static Future<void> testConnection() async {
    print('=== Test de connexion Flutter vers Backend ===\n');
    
    try {
      // Test 1: GET users
      print('1. Test GET /users');
      final response1 = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: await _getHeaders(),
      );
      
      if (response1.statusCode == 200) {
        final data = json.decode(response1.body);
        print('Status: SUCCESS');
        print('Utilisateurs trouvés: ${data['data'].length}');
        print('Response: ${response1.body}\n');
      } else {
        print('Status: FAILED (${response1.statusCode})');
        print('Response: ${response1.body}\n');
      }
      
      // Test 2: GET current user
      print('2. Test GET /users/current');
      final response2 = await http.get(
        Uri.parse('$baseUrl/users/current'),
        headers: await _getHeaders(),
      );
      
      if (response2.statusCode == 200) {
        final data = json.decode(response2.body);
        print('Status: SUCCESS');
        print('Utilisateur: ${data['data']['user']['first_name']} ${data['data']['user']['last_name']}');
        print('Niveau: ${data['data']['highest_level']}\n');
      } else {
        print('Status: FAILED (${response2.statusCode})');
        print('Response: ${response2.body}\n');
      }
      
      // Test 3: GET stats
      print('3. Test GET /users/stats');
      final response3 = await http.get(
        Uri.parse('$baseUrl/users/stats'),
        headers: await _getHeaders(),
      );
      
      if (response3.statusCode == 200) {
        final data = json.decode(response3.body);
        print('Status: SUCCESS');
        print('Statistiques disponibles: ${data['data'].length}\n');
      } else {
        print('Status: FAILED (${response3.statusCode})');
        print('Response: ${response3.body}\n');
      }
      
      print('=== Tests terminés ===');
      print('L\'API est prête pour la connexion Flutter !');
      
    } catch (e) {
      print('Erreur de connexion: $e');
    }
  }
}

void main() {
  TestFlutterConnection.testConnection();
}
