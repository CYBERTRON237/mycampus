import 'package:dartz/dartz.dart';
import '../models/faculty_model.dart';

abstract class FacultyRepository {
  Future<Either<String, List<FacultyModel>>> getFaculties({
    String? institutionId,
    String? search,
    FacultyStatus? status,
    int? page,
    int? limit,
  });

  Future<Either<String, FacultyModel>> getFacultyById(String id);
  
  Future<Either<String, FacultyModel>> createFaculty(FacultyModel faculty);
  
  Future<Either<String, FacultyModel>> updateFaculty(String id, FacultyModel faculty);
  
  Future<Either<String, void>> deleteFaculty(String id);
  
  Future<Either<String, void>> toggleFacultyStatus(String id, FacultyStatus status);
  
  Future<Either<String, Map<String, int>>> getStatistics({String? institutionId});
}
