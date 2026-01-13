import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';

abstract class EnhancedStudentRepository {
  // Basic CRUD operations
  Future<List<EnhancedStudentModel>> getStudents({
    StudentFilters? filters,
    int page = 1,
    int limit = 20,
  });

  Future<EnhancedStudentModel?> getStudentById(int id);
  Future<EnhancedStudentModel?> getStudentByUuid(String uuid);
  Future<EnhancedStudentModel?> getStudentByMatricule(String matricule);

  Future<EnhancedStudentModel> createStudent(EnhancedStudentModel student);
  Future<EnhancedStudentModel> updateStudent(int id, EnhancedStudentModel student);
  Future<bool> deleteStudent(int id);
  Future<bool> restoreStudent(int id);
  Future<bool> permanentDeleteStudent(int id);

  // Bulk operations
  Future<List<EnhancedStudentModel>> createStudents(List<EnhancedStudentModel> students);
  Future<List<EnhancedStudentModel>> updateStudents(List<EnhancedStudentModel> students);
  Future<bool> deleteStudents(List<int> studentIds);
  Future<bool> activateStudents(List<int> studentIds);
  Future<bool> deactivateStudents(List<int> studentIds);
  Future<bool> verifyStudents(List<int> studentIds);

  // Search and filtering
  Future<List<EnhancedStudentModel>> searchStudents(String query, {int limit = 20});
  Future<List<EnhancedStudentModel>> getStudentsByStatus(StudentStatus status);
  Future<List<EnhancedStudentModel>> getStudentsByLevel(AcademicLevel level);
  Future<List<EnhancedStudentModel>> getStudentsByInstitution(int institutionId);
  Future<List<EnhancedStudentModel>> getStudentsByFaculty(int facultyId);
  Future<List<EnhancedStudentModel>> getStudentsByDepartment(int departmentId);
  Future<List<EnhancedStudentModel>> getStudentsByProgram(int programId);
  Future<List<EnhancedStudentModel>> getStudentsByRegion(String region);
  Future<List<EnhancedStudentModel>> getStudentsByGender(String gender);

  // Academic operations
  Future<EnhancedStudentModel> updateStudentLevel(int studentId, AcademicLevel newLevel);
  Future<EnhancedStudentModel> updateStudentStatus(int studentId, StudentStatus newStatus);
  Future<EnhancedStudentModel> updateStudentGpa(int studentId, double gpa);
  Future<EnhancedStudentModel> addCredits(int studentId, int credits);
  Future<EnhancedStudentModel> updateThesisInfo(int studentId, {
    String? thesisTitle,
    String? thesisSupervisor,
    DateTime? defenseDate,
  });

  // Scholarship operations
  Future<EnhancedStudentModel> updateScholarship(int studentId, {
    ScholarshipStatus? status,
    String? details,
    double? amount,
  });
  Future<List<EnhancedStudentModel>> getStudentsWithScholarships();
  Future<List<EnhancedStudentModel>> getStudentsByScholarshipStatus(ScholarshipStatus status);

  // Statistics and analytics
  Future<StudentStatistics> getStudentStatistics();
  Future<StudentStatistics> getStudentStatisticsByInstitution(int institutionId);
  Future<StudentStatistics> getStudentStatisticsByFaculty(int facultyId);
  Future<StudentStatistics> getStudentStatisticsByDepartment(int departmentId);
  Future<StudentStatistics> getStudentStatisticsByProgram(int programId);
  Future<Map<String, dynamic>> getAcademicPerformanceStats();
  Future<Map<String, dynamic>> getGraduationStats();
  Future<Map<String, dynamic>> getScholarshipStats();

  // Export operations
  Future<List<Map<String, dynamic>>> exportStudents({
    StudentFilters? filters,
    String format = 'csv',
  });
  Future<String> exportStudentsToCsv({
    StudentFilters? filters,
  });
  Future<String> exportStudentsToExcel({
    StudentFilters? filters,
  });
  Future<String> exportStudentsToPdf({
    StudentFilters? filters,
  });

  // Validation operations
  Future<bool> validateStudentData(EnhancedStudentModel student);
  Future<List<String>> getStudentValidationErrors(EnhancedStudentModel student);
  Future<bool> isMatriculeUnique(String matricule, {int? excludeId});
  Future<bool> isEmailUnique(String email, {int? excludeId});

  // File operations
  Future<String> uploadProfilePhoto(int studentId, String filePath);
  Future<String> uploadDocument(int studentId, String documentType, String filePath);
  Future<bool> deleteDocument(int studentId, String documentId);
  Future<List<Map<String, dynamic>>> getStudentDocuments(int studentId);

  // Communication operations
  Future<bool> sendEmailToStudents(List<int> studentIds, String subject, String message);
  Future<bool> sendSmsToStudents(List<int> studentIds, String message);
  Future<bool> sendNotificationToStudents(List<int> studentIds, String title, String message);

  // Batch operations
  Future<Map<String, dynamic>> importStudentsFromCsv(String csvContent);
  Future<Map<String, dynamic>> importStudentsFromExcel(String excelContent);
  Future<List<Map<String, dynamic>>> validateImportData(String content, String format);

  // Advanced filtering
  Future<List<EnhancedStudentModel>> getStudentsWithAdvancedFilters({
    StudentFilters? filters,
    List<String>? includeFields,
    List<String>? excludeFields,
    String? groupBy,
    String? having,
  });

  // Reporting
  Future<Map<String, dynamic>> generateStudentReport({
    StudentFilters? filters,
    String reportType = 'summary',
    String format = 'json',
  });
  Future<Map<String, dynamic>> generateAcademicReport({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    AcademicLevel? level,
  });
  Future<Map<String, dynamic>> generateDemographicReport({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
  });

  // Academic year operations
  Future<List<EnhancedStudentModel>> promoteStudentsToNextLevel(List<int> studentIds);
  Future<List<EnhancedStudentModel>> graduateStudents(List<int> studentIds);
  Future<bool> enrollStudentsInAcademicYear(List<int> studentIds, int academicYearId);

  // Attendance and performance
  Future<Map<String, dynamic>> getStudentAttendanceReport(int studentId);
  Future<Map<String, dynamic>> getStudentPerformanceReport(int studentId);
  Future<List<Map<String, dynamic>>> getClassRanking(int programId, AcademicLevel level);

  // Emergency operations
  Future<List<EnhancedStudentModel>> getStudentsByEmergencyContact(String contactPhone);
  Future<bool> updateEmergencyContact(int studentId, {
    String? name,
    String? phone,
    String? relationship,
    String? email,
  });

  // Medical information
  Future<bool> updateMedicalInfo(int studentId, {
    String? bloodGroup,
    String? medicalConditions,
    String? allergies,
    String? dietaryRestrictions,
    String? physicalDisabilities,
    bool? needsSpecialAccommodation,
  });

  // Skills and interests
  Future<bool> updateSkillsAndInterests(int studentId, {
    String? languages,
    String? hobbies,
    String? skills,
  });

  // History and logs
  Future<List<Map<String, dynamic>>> getStudentHistory(int studentId);
  Future<List<Map<String, dynamic>>> getStudentModificationHistory(int studentId);
  Future<bool> logStudentAction(int studentId, String action, Map<String, dynamic> details);
}
