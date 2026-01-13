import 'package:dartz/dartz.dart';
import '../models/institution_model.dart';

abstract class InstitutionRepository {
  Future<Either<String, List<InstitutionModel>>> getInstitutions({
    String? search,
    InstitutionType? type,
    InstitutionStatus? status,
    String? region,
    int? page,
    int? limit,
  });

  Future<Either<String, InstitutionModel>> getInstitutionById(String id);

  Future<Either<String, InstitutionModel>> createInstitution(InstitutionModel institution);

  Future<Either<String, InstitutionModel>> updateInstitution(String id, InstitutionModel institution);

  Future<Either<String, void>> deleteInstitution(String id);

  Future<Either<String, void>> toggleInstitutionStatus(String id, InstitutionStatus status);

  Future<Either<String, List<String>>> getRegions();

  Future<Either<String, Map<String, int>>> getStatistics();
}
