import 'package:dartz/dartz.dart';
import '../models/department_model.dart';

abstract class DepartmentRepository {
  /// Récupérer la liste des départements
  Future<Either<String, List<DepartmentModel>>> getDepartments({
    String? facultyId,
    String? institutionId,
    String? search,
    DepartmentLevel? level,
    DepartmentStatus? status,
    int? page,
    int? limit,
  });

  /// Récupérer un département par son ID
  Future<Either<String, DepartmentModel>> getDepartmentById(String id);

  /// Créer un nouveau département
  Future<Either<String, DepartmentModel>> createDepartment(DepartmentModel department);

  /// Mettre à jour un département existant
  Future<Either<String, DepartmentModel>> updateDepartment(String id, DepartmentModel department);

  /// Supprimer un département
  Future<Either<String, void>> deleteDepartment(String id);

  /// Basculer le statut d'un département
  Future<Either<String, void>> toggleDepartmentStatus(String id, DepartmentStatus status);

  /// Récupérer les statistiques des départements
  Future<Either<String, Map<String, int>>> getStatistics({
    String? facultyId,
    String? institutionId,
  });
}
