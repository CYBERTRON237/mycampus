import 'package:dartz/dartz.dart';
import '../models/university_model.dart';

abstract class UniversityRepository {
  Future<Either<String, List<UniversityModel>>> getUniversities({
    String? search,
    UniversityType? type,
    UniversityStatus? status,
    String? region,
    int? page,
    int? limit,
  });

  Future<Either<String, UniversityModel>> getUniversityById(String id);

  Future<Either<String, UniversityModel>> createUniversity(UniversityModel university);

  Future<Either<String, UniversityModel>> updateUniversity(String id, UniversityModel university);

  Future<Either<String, void>> deleteUniversity(String id);

  Future<Either<String, void>> toggleUniversityStatus(String id, UniversityStatus status);

  Future<Either<String, void>> verifyUniversity(String id);

  Future<Either<String, List<String>>> getRegions();

  Future<Either<String, Map<String, int>>> getStatistics();
}
