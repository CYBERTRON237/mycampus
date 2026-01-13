import 'package:dartz/dartz.dart';
import '../models/course_model.dart';

abstract class CourseRepository {
  /// Récupérer la liste des cours
  Future<Either<String, List<CourseModel>>> getCourses({
    String? programId,
    String? departmentId,
    String? facultyId,
    String? institutionId,
    String? search,
    CourseLevel? level,
    CourseSemester? semester,
    CourseStatus? status,
    int? page,
    int? limit,
  });

  /// Récupérer un cours par son ID
  Future<Either<String, CourseModel>> getCourseById(String id);

  /// Créer un nouveau cours
  Future<Either<String, CourseModel>> createCourse(CourseModel course);

  /// Mettre à jour un cours existant
  Future<Either<String, CourseModel>> updateCourse(String id, CourseModel course);

  /// Supprimer un cours
  Future<Either<String, void>> deleteCourse(String id);

  /// Basculer le statut d'un cours
  Future<Either<String, void>> toggleCourseStatus(String id, CourseStatus status);

  /// Récupérer les statistiques des cours
  Future<Either<String, Map<String, int>>> getStatistics({
    String? programId,
    String? departmentId,
    String? facultyId,
    String? institutionId,
  });
}
