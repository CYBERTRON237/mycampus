import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'http://127.0.0.1/mycampus';
  const endpoint = '/api/preinscriptions/preinscriptions_list_api.php';
  
  print('Test du backend de préinscriptions...');
  
  // Test 1: Lister les préinscriptions
  try {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint?page=1&limit=5'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Success: ${data['success']}');
      if (data['success'] == true) {
        print('Nombre de préinscriptions: ${(data['data'] as List).length}');
        print('Pagination: ${data['pagination']}');
        print('Statistiques: ${data['statistics']}');
      }
    }
  } catch (e) {
    print('Erreur: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 2: Rechercher par code unique
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/preinscriptions/get_preinscription.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'unique_code': 'TEST001'}),
    );
    
    print('Test recherche par code unique:');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('Erreur recherche: $e');
  }
}
