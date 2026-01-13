import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycampus/features/auth/services/auth_service.dart';
import 'package:mycampus/features/profile/models/profile_model.dart';

class ProfileRemoteDataSource {
  final http.Client client;
  final AuthService authService;
  final String baseUrl;

  ProfileRemoteDataSource({
    required this.client,
    required this.authService,
    required this.baseUrl,
  });

  // Headers for authenticated requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // Get current user's complete profile
  Future<Map<String, dynamic>> getMyProfile() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get profile');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Get another user's profile (admin access)
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get user profile');
      }
    } else if (response.statusCode == 403) {
      throw Exception('Access denied: Insufficient permissions');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Get current user's preinscription details
  Future<Map<String, dynamic>?> getMyPreinscription() async {
    final headers = await _getHeaders();
    
    // Utiliser l'email de l'utilisateur connecté
    final currentUser = await authService.getCurrentUser();
    if (currentUser?.email == null) {
      throw Exception('User not authenticated or email missing');
    }
    
    final response = await client.post(
      Uri.parse('$baseUrl/preinscriptions/get_my_preinscription.php'),
      headers: headers,
      body: json.encode({'email': currentUser!.email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get preinscription');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Get academic profile information
  Future<Map<String, dynamic>> getAcademicProfile() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/academic'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get academic profile');
      }
    } else if (response.statusCode == 404) {
      throw Exception('No academic information found');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Get professional profile information
  Future<Map<String, dynamic>> getProfessionalProfile() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/professional'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get professional profile');
      }
    } else if (response.statusCode == 404) {
      throw Exception('No professional information found');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Get profile statistics
  Future<Map<String, dynamic>> getProfileStats() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get profile stats');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Update profile information
  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/api/profile/user'),
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else if (response.statusCode == 400) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Invalid update request');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Update profile photo
  Future<bool> updateProfilePhoto(String photoPath) async {
    final headers = await _getHeaders();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/profile/photo'));
    
    // Add headers
    request.headers.addAll(headers);
    
    // Add photo file
    final photoFile = await http.MultipartFile.fromPath('photo', photoPath);
    request.files.add(photoFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
