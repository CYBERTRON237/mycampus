import '../models/student_model.dart';
import '../models/student_model_simple.dart';
import '../models/simple_student_model.dart';

abstract class StudentRepository {
  /// Récupérer tous les étudiants avec filtres
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
  });

  /// Récupérer un étudiant par son ID
  Future<StudentModelSimple?> getStudentById(int id);

  /// Créer un nouvel étudiant
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData);

  /// Mettre à jour un étudiant
  Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData);

  /// Supprimer un étudiant
  Future<Map<String, dynamic>> deleteStudent(int id);

  /// Récupérer les statistiques des étudiants
  Future<StudentStats> getStudentStats({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    int? academicYearId,
  });

  /// Récupérer les inscriptions d'un étudiant
  Future<List<Map<String, dynamic>>> getStudentEnrollments(int studentId);

  /// Récupérer les résultats académiques d'un étudiant
  Future<List<Map<String, dynamic>>> getStudentAcademicRecords(int studentId);

  /// Récupérer les documents d'un étudiant
  Future<List<Map<String, dynamic>>> getStudentDocuments(int studentId);

  /// Exporter les étudiants
  Future<List<Map<String, dynamic>>> exportStudents({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    String? level,
    String? status,
  });
}
