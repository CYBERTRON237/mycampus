import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_model.dart';
import '../models/student_model_simple.dart';
import '../repositories/student_repository.dart';

class StudentRemoteDataSource implements StudentRepository {
  final String baseUrl;
  final http.Client client;

  StudentRemoteDataSource({
    required this.baseUrl,
    required this.client,
  }) {
    print('StudentRemoteDataSource constructor: baseUrl = $baseUrl');
  }

  @override
  Future<StudentResponse> getStudents({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    String? level,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
      if (facultyId != null) queryParams['faculty_id'] = facultyId.toString();
      if (departmentId != null) queryParams['department_id'] = departmentId.toString();
      if (programId != null) queryParams['program_id'] = programId.toString();
      if (level != null) queryParams['level'] = level;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students';
      } else {
        url = '$baseUrl/student_management/students';
      }
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StudentResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la récupération des étudiants');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<StudentModelSimple?> getStudentById(int id) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/$id';
      } else {
        url = '$baseUrl/student_management/students/$id';
      }
      print('Appel API: $url');
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          return StudentModelSimple.fromJson(jsonData['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Étudiant non trouvé');
      }
    } catch (e) {
      print('Erreur dans getStudentById: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students';
      } else {
        url = '$baseUrl/student_management/students';
      }
      
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(studentData),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': jsonData['message'],
          'data': jsonData['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonData['error'] ?? 'Erreur lors de la création',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/$id';
      } else {
        url = '$baseUrl/student_management/students/$id';
      }
      
      final response = await client.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(studentData),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonData['message'],
          'data': jsonData['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonData['error'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteStudent(int id) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/$id';
      } else {
        url = '$baseUrl/student_management/students/$id';
      }
      
      final response = await client.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonData['message'],
        };
      } else {
        return {
          'success': false,
          'message': jsonData['error'] ?? 'Erreur lors de la suppression',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e',
      };
    }
  }

  @override
  Future<StudentStats> getStudentStats({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    int? academicYearId,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
      if (facultyId != null) queryParams['faculty_id'] = facultyId.toString();
      if (departmentId != null) queryParams['department_id'] = departmentId.toString();
      if (programId != null) queryParams['program_id'] = programId.toString();
      if (academicYearId != null) queryParams['academic_year_id'] = academicYearId.toString();

      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/stats';
      } else {
        url = '$baseUrl/student_management/students/stats';
      }
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StudentStats.fromJson(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentEnrollments(int studentId) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/$studentId/enrollments';
      } else {
        url = '$baseUrl/student_management/students/$studentId/enrollments';
      }
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la récupération des inscriptions');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentAcademicRecords(int studentId) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/$studentId/academic-records';
      } else {
        url = '$baseUrl/student_management/students/$studentId/academic-records';
      }
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la récupération des résultats académiques');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentDocuments(int studentId) async {
    try {
      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/$studentId/documents';
      } else {
        url = '$baseUrl/student_management/students/$studentId/documents';
      }
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la récupération des documents');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> exportStudents({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    String? level,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
      if (facultyId != null) queryParams['faculty_id'] = facultyId.toString();
      if (departmentId != null) queryParams['department_id'] = departmentId.toString();
      if (programId != null) queryParams['program_id'] = programId.toString();
      if (level != null) queryParams['level'] = level;
      if (status != null) queryParams['status'] = status;

      // Construire l'URL en évitant les doublons de /student_management
      String url;
      if (baseUrl.endsWith('/student_management')) {
        url = '$baseUrl/students/export';
      } else {
        url = '$baseUrl/student_management/students/export';
      }
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/csv',
        },
      );

      if (response.statusCode == 200) {
        // Pour l'export CSV, nous retournons les données brutes
        final lines = response.body.split('\n');
        final headers = lines[0].split(',');
        final data = <Map<String, dynamic>>[];

        for (int i = 1; i < lines.length; i++) {
          if (lines[i].trim().isEmpty) continue;
          
          final values = lines[i].split(',');
          final Map<String, dynamic> row = {};
          
          for (int j = 0; j < headers.length && j < values.length; j++) {
            row[headers[j].trim()] = values[j].trim();
          }
          
          data.add(row);
        }
        
        return data;
      } else {
        throw Exception('Erreur lors de l\'exportation des étudiants');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
