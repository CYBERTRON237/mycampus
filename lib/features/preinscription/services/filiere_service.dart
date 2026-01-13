import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filiere_model.dart';

class FiliereService {
  static const String baseUrl = 'http://127.0.0.1/mycampus/api/programs';

  Future<List<FiliereModel>> getFilieresByFaculty(String facultyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?faculty_id=$facultyId&status=active'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> programsJson = data['data'] ?? [];
          return programsJson.map((json) => FiliereModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération des filières');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching filieres: $e');
      throw Exception('Impossible de charger les filières: $e');
    }
  }

  Future<FiliereModel?> getFiliereById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?id=$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return FiliereModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération de la filière');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching filiere: $e');
      throw Exception('Impossible de charger la filière: $e');
    }
  }

  Future<List<FiliereModel>> searchFilieres(String query, {String? facultyId}) async {
    try {
      String url = '$baseUrl?search=$query';
      if (facultyId != null) {
        url += '&faculty_id=$facultyId';
      }
      url += '&status=active';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> programsJson = data['data'] ?? [];
          return programsJson.map((json) => FiliereModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la recherche des filières');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching filieres: $e');
      throw Exception('Impossible de rechercher les filières: $e');
    }
  }
}
