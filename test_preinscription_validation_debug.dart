import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';

void main() async {
  print('Test de validation des préinscriptions...');
  
  try {
    // Test direct de l'API
    final response = await http.get(
      Uri.parse('http://127.0.0.1/mycampus/api/preinscription_validation/test_api_response.php'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body.substring(0, 500)}...');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        print('API Success: ${data['success']}');
        print('Data count: ${data['data'].length}');
        
        if (data['data'].isNotEmpty) {
          print('Testing PreinscriptionValidationModel.fromJson...');
          
          try {
            final model = PreinscriptionValidationModel.fromJson(data['data'][0]);
            print('Model created successfully!');
            print('Model ID: ${model.id}');
            print('Model Faculty: ${model.faculty}');
            print('Has User Account: ${model.hasUserAccount} (${model.hasUserAccount.runtimeType})');
            print('Can Be Validated: ${model.canBeValidated} (${model.canBeValidated.runtimeType})');
          } catch (e) {
            print('Error creating model: $e');
            print('Error type: ${e.runtimeType}');
            
            // Afficher les champs problématiques
            final problematicFields = ['scholarship_requested', 'interview_required', 'registration_completed', 
                                     'marketing_consent', 'data_processing_consent', 'newsletter_subscription',
                                     'is_processed', 'has_user_account', 'can_be_validated'];
            
            for (String field in problematicFields) {
              if (data['data'][0].containsKey(field)) {
                final value = data['data'][0][field];
                print('Field $field: value=$value, type=${value.runtimeType}');
              }
            }
          }
        }
      } else {
        print('API Error: ${data['message']}');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Connection Error: $e');
    print('Error type: ${e.runtimeType}');
  }
}
