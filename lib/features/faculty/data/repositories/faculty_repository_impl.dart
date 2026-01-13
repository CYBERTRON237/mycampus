import 'package:dartz/dartz.dart';
import '../../domain/repositories/faculty_repository.dart';
import '../../domain/models/faculty_model.dart';
import '../datasources/faculty_remote_datasource.dart';

class FacultyRepositoryImpl implements FacultyRepository {
  final FacultyRemoteDataSource remoteDataSource;

  FacultyRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<FacultyModel>>> getFaculties({
    String? institutionId,
    String? search,
    FacultyStatus? status,
    int? page,
    int? limit,
  }) async {
    try {
      final faculties = await remoteDataSource.getFaculties(
        institutionId: institutionId,
        search: search,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(faculties);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, FacultyModel>> getFacultyById(String id) async {
    try {
      final faculty = await remoteDataSource.getFacultyById(id);
      return Right(faculty);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, FacultyModel>> createFaculty(FacultyModel faculty) async {
    try {
      final createdFaculty = await remoteDataSource.createFaculty(faculty);
      return Right(createdFaculty);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, FacultyModel>> updateFaculty(String id, FacultyModel faculty) async {
    try {
      final updatedFaculty = await remoteDataSource.updateFaculty(id, faculty);
      return Right(updatedFaculty);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteFaculty(String id) async {
    try {
      await remoteDataSource.deleteFaculty(id);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleFacultyStatus(String id, FacultyStatus status) async {
    try {
      await remoteDataSource.toggleFacultyStatus(id, status);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, int>>> getStatistics({String? institutionId}) async {
    try {
      final statistics = await remoteDataSource.getStatistics(institutionId: institutionId);
      return Right(statistics);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
