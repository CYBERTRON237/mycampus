import 'package:dartz/dartz.dart';
import '../../domain/repositories/university_repository.dart';
import '../../domain/models/university_model.dart';
import '../datasources/university_remote_datasource.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  final UniversityRemoteDataSource remoteDataSource;

  UniversityRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<UniversityModel>>> getUniversities({
    String? search,
    UniversityType? type,
    UniversityStatus? status,
    String? region,
    int? page,
    int? limit,
  }) async {
    try {
      final universities = await remoteDataSource.getUniversities(
        search: search,
        type: type,
        status: status,
        region: region,
        page: page,
        limit: limit,
      );
      return Right(universities);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UniversityModel>> getUniversityById(String id) async {
    try {
      final university = await remoteDataSource.getUniversityById(id);
      return Right(university);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UniversityModel>> createUniversity(UniversityModel university) async {
    try {
      final createdUniversity = await remoteDataSource.createUniversity(university);
      return Right(createdUniversity);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UniversityModel>> updateUniversity(String id, UniversityModel university) async {
    try {
      final updatedUniversity = await remoteDataSource.updateUniversity(id, university);
      return Right(updatedUniversity);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteUniversity(String id) async {
    try {
      await remoteDataSource.deleteUniversity(id);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleUniversityStatus(String id, UniversityStatus status) async {
    try {
      await remoteDataSource.toggleUniversityStatus(id, status);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> verifyUniversity(String id) async {
    try {
      await remoteDataSource.verifyUniversity(id);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<String>>> getRegions() async {
    try {
      final regions = await remoteDataSource.getRegions();
      return Right(regions);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, int>>> getStatistics() async {
    try {
      final statistics = await remoteDataSource.getStatistics();
      return Right(statistics);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
