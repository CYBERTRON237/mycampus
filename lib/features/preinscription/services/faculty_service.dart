import 'dart:async';
import '../../faculty/domain/models/faculty_model.dart';
import '../../faculty/domain/repositories/faculty_repository.dart';
import '../../faculty/data/repositories/faculty_repository_impl.dart';
import '../../faculty/data/datasources/faculty_remote_datasource.dart';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';

class FacultyService {
  late FacultyRepository _facultyRepository;
  bool _disposed = false;

  FacultyService() {
    final dataSource = FacultyRemoteDataSource(
      client: http.Client(),
      authService: AuthService(),
    );
    _facultyRepository = FacultyRepositoryImpl(remoteDataSource: dataSource);
  }

  Future<List<FacultyModel>> getFacultiesByUniversity({
    required String universityId,
    String? search,
    FacultyStatus? status,
    int page = 1,
    int limit = 50,
  }) async {
    if (_disposed) throw StateError('FacultyService has been disposed');

    try {
      final result = await _facultyRepository.getFaculties(
        institutionId: universityId,
        search: search,
        status: status,
        page: page,
        limit: limit,
      );

      return result.fold(
        (error) => throw Exception(error),
        (faculties) => faculties,
      );
    } catch (e) {
      print('Error in getFacultiesByUniversity: $e');
      rethrow;
    }
  }

  Future<FacultyModel> getFacultyById(String id) async {
    if (_disposed) throw StateError('FacultyService has been disposed');

    try {
      final result = await _facultyRepository.getFacultyById(id);

      return result.fold(
        (error) => throw Exception(error),
        (faculty) => faculty,
      );
    } catch (e) {
      print('Error in getFacultyById: $e');
      rethrow;
    }
  }

  Future<List<FacultyModel>> searchFaculties({
    required String universityId,
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (_disposed) throw StateError('FacultyService has been disposed');

    return getFacultiesByUniversity(
      universityId: universityId,
      search: query,
      page: page,
      limit: limit,
    );
  }

  void dispose() {
    _disposed = true;
  }
}
