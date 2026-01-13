import 'package:dartz/dartz.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/models/course_model.dart';
import '../datasources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
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
  }) async {
    try {
      final courses = await remoteDataSource.getCourses(
        programId: programId,
        departmentId: departmentId,
        facultyId: facultyId,
        institutionId: institutionId,
        search: search,
        level: level,
        semester: semester,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(courses);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CourseModel>> getCourseById(String id) async {
    try {
      final course = await remoteDataSource.getCourseById(id);
      return Right(course);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CourseModel>> createCourse(CourseModel course) async {
    try {
      final createdCourse = await remoteDataSource.createCourse(course);
      return Right(createdCourse);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CourseModel>> updateCourse(String id, CourseModel course) async {
    try {
      final updatedCourse = await remoteDataSource.updateCourse(id, course);
      return Right(updatedCourse);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteCourse(String id) async {
    try {
      await remoteDataSource.deleteCourse(id);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleCourseStatus(String id, CourseStatus status) async {
    try {
      await remoteDataSource.toggleCourseStatus(id, status);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, int>>> getStatistics({
    String? programId,
    String? departmentId,
    String? facultyId,
    String? institutionId,
  }) async {
    try {
      final statistics = await remoteDataSource.getStatistics(
        programId: programId,
        departmentId: departmentId,
        facultyId: facultyId,
        institutionId: institutionId,
      );
      return Right(statistics);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
