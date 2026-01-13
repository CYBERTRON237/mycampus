import 'package:dartz/dartz.dart';
import '../models/program_model.dart';

abstract class ProgramRepository {
  /// Récupérer la liste des programmes/filières
  Future<Either<String, List<ProgramModel>>> getPrograms({
    String? departmentId,
    String? facultyId,
    String? institutionId,
    String? search,
    DegreeLevel? degreeLevel,
    ProgramStatus? status,
    int? page,
    int? limit,
  });

  /// Récupérer un programme par son ID
  Future<Either<String, ProgramModel>> getProgramById(String id);

  /// Créer un nouveau programme
  Future<Either<String, ProgramModel>> createProgram(ProgramModel program);

  /// Mettre à jour un programme existant
  Future<Either<String, ProgramModel>> updateProgram(String id, ProgramModel program);

  /// Supprimer un programme
  Future<Either<String, void>> deleteProgram(String id);

  /// Basculer le statut d'un programme
  Future<Either<String, void>> toggleProgramStatus(String id, ProgramStatus status);

  /// Récupérer les statistiques des programmes
  Future<Either<String, Map<String, int>>> getStatistics({
    String? departmentId,
    String? facultyId,
    String? institutionId,
  });
}
