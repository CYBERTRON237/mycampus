import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Test de l\'endpoint regions...');
  
  try {
    final response = await http.get(
      Uri.parse('http://localhost/mycampus/api/institutions/regions.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer test',
      },
    );
    
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final regions = data['data'] as List;
        print('Régions récupérées avec succès:');
        for (final region in regions) {
          print('- $region');
        }
      } else {
        print('Erreur: ${data['message']}');
      }
    } else {
      print('Erreur HTTP: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
