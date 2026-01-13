import 'package:dartz/dartz.dart';
import '../../domain/models/institution_model.dart';
import '../../domain/repositories/institution_repository.dart';
import '../datasources/institution_remote_datasource.dart';

class InstitutionRepositoryImpl implements InstitutionRepository {
  final InstitutionRemoteDataSource remoteDataSource;

  InstitutionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<InstitutionModel>>> getInstitutions({
    String? search,
    InstitutionType? type,
    InstitutionStatus? status,
    String? region,
    int? page,
    int? limit,
  }) async {
    try {
      final institutions = await remoteDataSource.getInstitutions(
        search: search,
        type: type,
        status: status,
        region: region,
        page: page,
        limit: limit,
      );
      return Right(institutions);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InstitutionModel>> getInstitutionById(String id) async {
    try {
      final institution = await remoteDataSource.getInstitutionById(id);
      return Right(institution);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InstitutionModel>> createInstitution(InstitutionModel institution) async {
    try {
      final createdInstitution = await remoteDataSource.createInstitution(institution);
      return Right(createdInstitution);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, InstitutionModel>> updateInstitution(String id, InstitutionModel institution) async {
    try {
      final updatedInstitution = await remoteDataSource.updateInstitution(id, institution);
      return Right(updatedInstitution);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteInstitution(String id) async {
    try {
      await remoteDataSource.deleteInstitution(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleInstitutionStatus(String id, InstitutionStatus status) async {
    try {
      await remoteDataSource.toggleInstitutionStatus(id, status);
      return const Right(null);
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
