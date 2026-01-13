import 'package:dartz/dartz.dart';
import '../../domain/repositories/department_repository.dart';
import '../../domain/models/department_model.dart';
import '../datasources/department_remote_datasource.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remoteDataSource;

  DepartmentRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<DepartmentModel>>> getDepartments({
    String? facultyId,
    String? institutionId,
    String? search,
    DepartmentLevel? level,
    DepartmentStatus? status,
    int? page,
    int? limit,
  }) async {
    try {
      final departments = await remoteDataSource.getDepartments(
        facultyId: facultyId,
        institutionId: institutionId,
        search: search,
        level: level,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(departments);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DepartmentModel>> getDepartmentById(String id) async {
    try {
      final department = await remoteDataSource.getDepartmentById(id);
      return Right(department);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DepartmentModel>> createDepartment(DepartmentModel department) async {
    try {
      final createdDepartment = await remoteDataSource.createDepartment(department);
      return Right(createdDepartment);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DepartmentModel>> updateDepartment(String id, DepartmentModel department) async {
    try {
      final updatedDepartment = await remoteDataSource.updateDepartment(id, department);
      return Right(updatedDepartment);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteDepartment(String id) async {
    try {
      await remoteDataSource.deleteDepartment(id);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleDepartmentStatus(String id, DepartmentStatus status) async {
    try {
      await remoteDataSource.toggleDepartmentStatus(id, status);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, int>>> getStatistics({
    String? facultyId,
    String? institutionId,
  }) async {
    try {
      final statistics = await remoteDataSource.getStatistics(
        facultyId: facultyId,
        institutionId: institutionId,
      );
      return Right(statistics);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
