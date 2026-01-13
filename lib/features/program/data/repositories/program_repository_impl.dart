import 'package:dartz/dartz.dart';
import '../../domain/repositories/program_repository.dart';
import '../../domain/models/program_model.dart';
import '../datasources/program_remote_datasource.dart';

class ProgramRepositoryImpl implements ProgramRepository {
  final ProgramRemoteDataSource remoteDataSource;

  ProgramRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<ProgramModel>>> getPrograms({
    String? departmentId,
    String? facultyId,
    String? institutionId,
    String? search,
    DegreeLevel? degreeLevel,
    ProgramStatus? status,
    int? page,
    int? limit,
  }) async {
    try {
      final programs = await remoteDataSource.getPrograms(
        departmentId: departmentId,
        facultyId: facultyId,
        institutionId: institutionId,
        search: search,
        degreeLevel: degreeLevel,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(programs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ProgramModel>> getProgramById(String id) async {
    try {
      final program = await remoteDataSource.getProgramById(id);
      return Right(program);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ProgramModel>> createProgram(ProgramModel program) async {
    try {
      final createdProgram = await remoteDataSource.createProgram(program);
      return Right(createdProgram);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ProgramModel>> updateProgram(String id, ProgramModel program) async {
    try {
      final updatedProgram = await remoteDataSource.updateProgram(id, program);
      return Right(updatedProgram);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteProgram(String id) async {
    try {
      await remoteDataSource.deleteProgram(id);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleProgramStatus(String id, ProgramStatus status) async {
    try {
      await remoteDataSource.toggleProgramStatus(id, status);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, int>>> getStatistics({
    String? departmentId,
    String? facultyId,
    String? institutionId,
  }) async {
    try {
      final statistics = await remoteDataSource.getStatistics(
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
