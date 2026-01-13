import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';

abstract class PreinscriptionValidationRepository {
  /// Récupère toutes les préinscriptions en attente de validation
  Future<List<PreinscriptionValidationModel>> getPendingPreinscriptions();
  
  /// Valide une préinscription et met à jour le rôle utilisateur
  Future<Map<String, dynamic>> validatePreinscription(
    int preinscriptionId, 
    String comments
  );
  
  /// Rejette une préinscription
  Future<bool> rejectPreinscription(
    int preinscriptionId, 
    String rejectionReason
  );
  
  /// Récupère les statistiques de validation
  Future<ValidationStatsModel> getValidationStats();
}
