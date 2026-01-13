import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'http://127.0.0.1/mycampus';
  
  print('=== Test des endpoints de préinscriptions depuis Flutter ===\n');
  
  // Test 1: Lister les préinscriptions
  print('1. Test de l\'endpoint list_preinscriptions.php:');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/preinscriptions/list_preinscriptions.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'page': 1, 'limit': 5}),
    );
    
    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Message: ${data['message'] ?? 'N/A'}');
      print('Nombre de préinscriptions: ${data['data']?.length ?? 0}');
      
      // Afficher les détails de la première préinscription
      if (data['data'] != null && data['data'].isNotEmpty) {
        final first = data['data'][0];
        print('Première préinscription: ${first['first_name']} ${first['last_name']} (${first['unique_code']})');
      }
    } else {
      print('Erreur HTTP: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
  
  print('\n');
  
  // Test 2: Récupérer une préinscription spécifique
  print('2. Test de l\'endpoint get_preinscription.php:');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/preinscriptions/get_preinscription.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'unique_code': 'PRE2025000417'}),
    );
    
    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Message: ${data['message'] ?? 'N/A'}');
      if (data['success']) {
        final preinscription = data['data'];
        print('Préinscription trouvée: ${preinscription['first_name']} ${preinscription['last_name']}');
        print('Faculté: ${preinscription['faculty']}');
        print('Email: ${preinscription['email']}');
        print('Statut: ${preinscription['status']}');
      }
    } else {
      print('Erreur HTTP: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
  
  print('\n=== Fin des tests ===');
}
