import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';
import 'package:mycampus/features/preinscription_validation/services/preinscription_validation_repository.dart';
import 'package:mycampus/features/preinscription_validation/services/preinscription_validation_remote_datasource.dart';

class PreinscriptionValidationRepositoryImpl implements PreinscriptionValidationRepository {
  final PreinscriptionValidationRemoteDataSource remoteDataSource;

  PreinscriptionValidationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PreinscriptionValidationModel>> getPendingPreinscriptions() {
    return remoteDataSource.getPendingPreinscriptions();
  }

  @override
  Future<Map<String, dynamic>> validatePreinscription(
    int preinscriptionId, 
    String comments
  ) {
    return remoteDataSource.validatePreinscription(preinscriptionId, comments);
  }

  @override
  Future<bool> rejectPreinscription(
    int preinscriptionId, 
    String rejectionReason
  ) {
    return remoteDataSource.rejectPreinscription(preinscriptionId, rejectionReason);
  }

  @override
  Future<ValidationStatsModel> getValidationStats() {
    return remoteDataSource.getValidationStats();
  }
}
