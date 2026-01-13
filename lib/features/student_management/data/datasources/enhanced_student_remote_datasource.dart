import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';
import 'package:mycampus/features/student_management/data/repositories/enhanced_student_repository.dart';

class EnhancedStudentRemoteDataSource implements EnhancedStudentRepository {
  final http.Client client;
  final String baseUrl;

  EnhancedStudentRemoteDataSource({
    required this.client,
    this.baseUrl = 'http://127.0.0.1/mycampus/api/student_management',
  });

  // Helper method to get headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Helper method to handle HTTP response
  T _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Operation failed');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<List<EnhancedStudentModel>> getStudents({
    StudentFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (filters != null) {
      final filtersJson = filters.toJson();
      filtersJson.forEach((key, value) {
        if (value != null) {
          queryParams[key] = value.toString();
        }
      });
    }

    final uri = Uri.parse('$baseUrl/students').replace(queryParameters: queryParams);
    final response = await client.get(uri, headers: _getHeaders());
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<EnhancedStudentModel?> getStudentById(int id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/$id'),
      headers: _getHeaders(),
    );
    
    try {
      return _handleResponse(response, (json) {
        return EnhancedStudentModel.fromJson(json['data']);
      });
    } catch (e) {
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }

  @override
  Future<EnhancedStudentModel?> getStudentByUuid(String uuid) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/uuid/$uuid'),
      headers: _getHeaders(),
    );
    
    try {
      return _handleResponse(response, (json) {
        return EnhancedStudentModel.fromJson(json['data']);
      });
    } catch (e) {
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }

  @override
  Future<EnhancedStudentModel?> getStudentByMatricule(String matricule) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/matricule/$matricule'),
      headers: _getHeaders(),
    );
    
    try {
      return _handleResponse(response, (json) {
        return EnhancedStudentModel.fromJson(json['data']);
      });
    } catch (e) {
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }

  @override
  Future<EnhancedStudentModel> createStudent(EnhancedStudentModel student) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students'),
      headers: _getHeaders(),
      body: json.encode(student.toJson()),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<EnhancedStudentModel> updateStudent(int id, EnhancedStudentModel student) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$id'),
      headers: _getHeaders(),
      body: json.encode(student.toJson()),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<bool> deleteStudent(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/students/$id'),
      headers: _getHeaders(),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> restoreStudent(int id) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/$id/restore'),
      headers: _getHeaders(),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> permanentDeleteStudent(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/students/$id/permanent'),
      headers: _getHeaders(),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<List<EnhancedStudentModel>> createStudents(List<EnhancedStudentModel> students) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk'),
      headers: _getHeaders(),
      body: json.encode({
        'students': students.map((s) => s.toJson()).toList(),
      }),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> updateStudents(List<EnhancedStudentModel> students) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/bulk'),
      headers: _getHeaders(),
      body: json.encode({
        'students': students.map((s) => s.toJson()).toList(),
      }),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<bool> deleteStudents(List<int> studentIds) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/students/bulk'),
      headers: _getHeaders(),
      body: json.encode({'student_ids': studentIds}),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> activateStudents(List<int> studentIds) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk/activate'),
      headers: _getHeaders(),
      body: json.encode({'student_ids': studentIds}),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> deactivateStudents(List<int> studentIds) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk/deactivate'),
      headers: _getHeaders(),
      body: json.encode({'student_ids': studentIds}),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> verifyStudents(List<int> studentIds) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk/verify'),
      headers: _getHeaders(),
      body: json.encode({'student_ids': studentIds}),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<List<EnhancedStudentModel>> searchStudents(String query, {int limit = 20}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/search').replace(queryParameters: {
        'q': query,
        'limit': limit.toString(),
      }),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByStatus(StudentStatus status) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/status/${status.value}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByLevel(AcademicLevel level) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/level/${level.value}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByInstitution(int institutionId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/institution/$institutionId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByFaculty(int facultyId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/faculty/$facultyId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByDepartment(int departmentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/department/$departmentId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByProgram(int programId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/program/$programId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByRegion(String region) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/region/$region'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByGender(String gender) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/gender/$gender'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<EnhancedStudentModel> updateStudentLevel(int studentId, AcademicLevel newLevel) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/level'),
      headers: _getHeaders(),
      body: json.encode({'level': newLevel.value}),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<EnhancedStudentModel> updateStudentStatus(int studentId, StudentStatus newStatus) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/status'),
      headers: _getHeaders(),
      body: json.encode({'status': newStatus.value}),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<EnhancedStudentModel> updateStudentGpa(int studentId, double gpa) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/gpa'),
      headers: _getHeaders(),
      body: json.encode({'gpa': gpa}),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<EnhancedStudentModel> addCredits(int studentId, int credits) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/$studentId/credits'),
      headers: _getHeaders(),
      body: json.encode({'credits': credits}),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<EnhancedStudentModel> updateThesisInfo(int studentId, {
    String? thesisTitle,
    String? thesisSupervisor,
    DateTime? defenseDate,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/thesis'),
      headers: _getHeaders(),
      body: json.encode({
        'thesis_title': thesisTitle,
        'thesis_supervisor': thesisSupervisor,
        'thesis_defense_date': defenseDate?.toIso8601String(),
      }),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<EnhancedStudentModel> updateScholarship(int studentId, {
    ScholarshipStatus? status,
    String? details,
    double? amount,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/scholarship'),
      headers: _getHeaders(),
      body: json.encode({
        'scholarship_status': status?.value,
        'scholarship_details': details,
        'scholarship_amount': amount,
      }),
    );
    
    return _handleResponse(response, (json) {
      return EnhancedStudentModel.fromJson(json['data']);
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsWithScholarships() async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/scholarships'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByScholarshipStatus(ScholarshipStatus status) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/scholarships/${status.value}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<StudentStatistics> getStudentStatistics() async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      return StudentStatistics.fromJson(json['data']);
    });
  }

  @override
  Future<StudentStatistics> getStudentStatisticsByInstitution(int institutionId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/institution/$institutionId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      return StudentStatistics.fromJson(json['data']);
    });
  }

  @override
  Future<StudentStatistics> getStudentStatisticsByFaculty(int facultyId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/faculty/$facultyId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      return StudentStatistics.fromJson(json['data']);
    });
  }

  @override
  Future<StudentStatistics> getStudentStatisticsByDepartment(int departmentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/department/$departmentId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      return StudentStatistics.fromJson(json['data']);
    });
  }

  @override
  Future<StudentStatistics> getStudentStatisticsByProgram(int programId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/program/$programId'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      return StudentStatistics.fromJson(json['data']);
    });
  }

  @override
  Future<Map<String, dynamic>> getAcademicPerformanceStats() async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/performance'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<Map<String, dynamic>> getGraduationStats() async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/graduation'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<Map<String, dynamic>> getScholarshipStats() async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/statistics/scholarships'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<List<Map<String, dynamic>>> exportStudents({
    StudentFilters? filters,
    String format = 'csv',
  }) async {
    final queryParams = <String, String>{'format': format};
    
    if (filters != null) {
      final filtersJson = filters.toJson();
      filtersJson.forEach((key, value) {
        if (value != null) {
          queryParams[key] = value.toString();
        }
      });
    }

    final response = await client.get(
      Uri.parse('$baseUrl/students/export').replace(queryParameters: queryParams),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Future<String> exportStudentsToCsv({StudentFilters? filters}) async {
    final data = await exportStudents(filters: filters, format: 'csv');
    return data.map((row) => row.values.join(',')).join('\n');
  }

  @override
  Future<String> exportStudentsToExcel({StudentFilters? filters}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/export/excel'),
      headers: _getHeaders(),
    );
    
    return response.body;
  }

  @override
  Future<String> exportStudentsToPdf({StudentFilters? filters}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/export/pdf'),
      headers: _getHeaders(),
    );
    
    return response.body;
  }

  @override
  Future<bool> validateStudentData(EnhancedStudentModel student) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/validate'),
      headers: _getHeaders(),
      body: json.encode(student.toJson()),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<List<String>> getStudentValidationErrors(EnhancedStudentModel student) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/validate/errors'),
      headers: _getHeaders(),
      body: json.encode(student.toJson()),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> errors = json['errors'] ?? [];
      return errors.map((e) => e.toString()).toList();
    });
  }

  @override
  Future<bool> isMatriculeUnique(String matricule, {int? excludeId}) async {
    final queryParams = <String, String>{'matricule': matricule};
    if (excludeId != null) {
      queryParams['exclude_id'] = excludeId.toString();
    }
    
    final response = await client.get(
      Uri.parse('$baseUrl/students/validate/matricule').replace(queryParameters: queryParams),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['is_unique'] ?? false);
  }

  @override
  Future<bool> isEmailUnique(String email, {int? excludeId}) async {
    final queryParams = <String, String>{'email': email};
    if (excludeId != null) {
      queryParams['exclude_id'] = excludeId.toString();
    }
    
    final response = await client.get(
      Uri.parse('$baseUrl/students/validate/email').replace(queryParameters: queryParams),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['is_unique'] ?? false);
  }

  @override
  Future<String> uploadProfilePhoto(int studentId, String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/students/$studentId/photo'),
    );
    request.headers.addAll(_getHeaders());
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response, (json) => json['photo_url']);
  }

  @override
  Future<String> uploadDocument(int studentId, String documentType, String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/students/$studentId/documents'),
    );
    request.headers.addAll(_getHeaders());
    request.fields['document_type'] = documentType;
    request.files.add(await http.MultipartFile.fromPath('document', filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response, (json) => json['document_id']);
  }

  @override
  Future<bool> deleteDocument(int studentId, String documentId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/students/$studentId/documents/$documentId'),
      headers: _getHeaders(),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentDocuments(int studentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/$studentId/documents'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Future<bool> sendEmailToStudents(List<int> studentIds, String subject, String message) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/communicate/email'),
      headers: _getHeaders(),
      body: json.encode({
        'student_ids': studentIds,
        'subject': subject,
        'message': message,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> sendSmsToStudents(List<int> studentIds, String message) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/communicate/sms'),
      headers: _getHeaders(),
      body: json.encode({
        'student_ids': studentIds,
        'message': message,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> sendNotificationToStudents(List<int> studentIds, String title, String message) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/communicate/notification'),
      headers: _getHeaders(),
      body: json.encode({
        'student_ids': studentIds,
        'title': title,
        'message': message,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<Map<String, dynamic>> importStudentsFromCsv(String csvContent) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/import/csv'),
      headers: _getHeaders(),
      body: json.encode({'content': csvContent}),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<Map<String, dynamic>> importStudentsFromExcel(String excelContent) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/import/excel'),
      headers: _getHeaders(),
      body: json.encode({'content': excelContent}),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<List<Map<String, dynamic>>> validateImportData(String content, String format) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/import/validate'),
      headers: _getHeaders(),
      body: json.encode({
        'content': content,
        'format': format,
      }),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsWithAdvancedFilters({
    StudentFilters? filters,
    List<String>? includeFields,
    List<String>? excludeFields,
    String? groupBy,
    String? having,
  }) async {
    final body = <String, dynamic>{};
    
    if (filters != null) {
      body['filters'] = filters.toJson();
    }
    if (includeFields != null) {
      body['include_fields'] = includeFields;
    }
    if (excludeFields != null) {
      body['exclude_fields'] = excludeFields;
    }
    if (groupBy != null) {
      body['group_by'] = groupBy;
    }
    if (having != null) {
      body['having'] = having;
    }

    final response = await client.post(
      Uri.parse('$baseUrl/students/advanced'),
      headers: _getHeaders(),
      body: json.encode(body),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<Map<String, dynamic>> generateStudentReport({
    StudentFilters? filters,
    String reportType = 'summary',
    String format = 'json',
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/reports'),
      headers: _getHeaders(),
      body: json.encode({
        'filters': filters?.toJson(),
        'report_type': reportType,
        'format': format,
      }),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<Map<String, dynamic>> generateAcademicReport({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    AcademicLevel? level,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/reports/academic'),
      headers: _getHeaders(),
      body: json.encode({
        'institution_id': institutionId,
        'faculty_id': facultyId,
        'department_id': departmentId,
        'program_id': programId,
        'level': level?.value,
      }),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<Map<String, dynamic>> generateDemographicReport({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/reports/demographic'),
      headers: _getHeaders(),
      body: json.encode({
        'institution_id': institutionId,
        'faculty_id': facultyId,
        'department_id': departmentId,
        'program_id': programId,
      }),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<List<EnhancedStudentModel>> promoteStudentsToNextLevel(List<int> studentIds) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk/promote'),
      headers: _getHeaders(),
      body: json.encode({'student_ids': studentIds}),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> graduateStudents(List<int> studentIds) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk/graduate'),
      headers: _getHeaders(),
      body: json.encode({'student_ids': studentIds}),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<bool> enrollStudentsInAcademicYear(List<int> studentIds, int academicYearId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/bulk/enroll'),
      headers: _getHeaders(),
      body: json.encode({
        'student_ids': studentIds,
        'academic_year_id': academicYearId,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<Map<String, dynamic>> getStudentAttendanceReport(int studentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/$studentId/attendance'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<Map<String, dynamic>> getStudentPerformanceReport(int studentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/$studentId/performance'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) => json['data']);
  }

  @override
  Future<List<Map<String, dynamic>>> getClassRanking(int programId, AcademicLevel level) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/ranking').replace(queryParameters: {
        'program_id': programId.toString(),
        'level': level.value,
      }),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Future<List<EnhancedStudentModel>> getStudentsByEmergencyContact(String contactPhone) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/emergency-contact/$contactPhone'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => EnhancedStudentModel.fromJson(item)).toList();
    });
  }

  @override
  Future<bool> updateEmergencyContact(int studentId, {
    String? name,
    String? phone,
    String? relationship,
    String? email,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/emergency-contact'),
      headers: _getHeaders(),
      body: json.encode({
        'emergency_contact_name': name,
        'emergency_contact_phone': phone,
        'emergency_contact_relationship': relationship,
        'emergency_contact_email': email,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> updateMedicalInfo(int studentId, {
    String? bloodGroup,
    String? medicalConditions,
    String? allergies,
    String? dietaryRestrictions,
    String? physicalDisabilities,
    bool? needsSpecialAccommodation,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/medical-info'),
      headers: _getHeaders(),
      body: json.encode({
        'blood_group': bloodGroup,
        'medical_conditions': medicalConditions,
        'allergies': allergies,
        'dietary_restrictions': dietaryRestrictions,
        'physical_disabilities': physicalDisabilities,
        'needs_special_accommodation': needsSpecialAccommodation == true ? 1 : 0,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<bool> updateSkillsAndInterests(int studentId, {
    String? languages,
    String? hobbies,
    String? skills,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/students/$studentId/skills-interests'),
      headers: _getHeaders(),
      body: json.encode({
        'languages': languages,
        'hobbies': hobbies,
        'skills': skills,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentHistory(int studentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/$studentId/history'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentModificationHistory(int studentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/students/$studentId/modification-history'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response, (json) {
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Future<bool> logStudentAction(int studentId, String action, Map<String, dynamic> details) async {
    final response = await client.post(
      Uri.parse('$baseUrl/students/$studentId/log'),
      headers: _getHeaders(),
      body: json.encode({
        'action': action,
        'details': details,
      }),
    );
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
