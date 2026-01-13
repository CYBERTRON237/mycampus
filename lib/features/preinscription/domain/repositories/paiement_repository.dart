import 'package:dartz/dartz.dart';
import 'package:mycampus/features/preinscription/domain/entities/paiement.dart';

abstract class PaiementRepository {
  // Initialiser un nouveau paiement
  Future<Either<Exception, Paiement>> initierPaiement({
    required String preinscriptionId,
    required double montant,
    required ModePaiement modePaiement,
    String? numeroTelephone,
    String? email,
  });

  // Vérifier le statut d'un paiement
  Future<Either<Exception, Paiement>> verifierStatutPaiement(String reference);

  // Récupérer un paiement par son ID
  Future<Either<Exception, Paiement>> obtenirPaiementParId(String id);

  // Récupérer les paiements d'une préinscription
  Future<Either<Exception, List<Paiement>>> obtenirPaiementsParPreinscription(String preinscriptionId);

  // Récupérer les paiements par statut
  Future<Either<Exception, List<Paiement>>> obtenirPaiementsParStatut(StatutPaiement statut);

  // Traiter un callback de paiement (pour les API externes)
  Future<Either<Exception, Paiement>> traiterCallbackPaiement(Map<String, dynamic> donneesCallback);

  // Annuler un paiement
  Future<Either<Exception, bool>> annulerPaiement(String reference);

  // Rembourser un paiement
  Future<Either<Exception, Paiement>> effectuerRemboursement(String referencePaiement, double montant, String motif);

  // Générer un reçu de paiement
  Future<Either<Exception, String>> genererRecuPaiement(String referencePaiement);

  // Obtenir l'historique des paiements d'un utilisateur
  Future<Either<Exception, List<Paiement>>> obtenirHistoriquePaiementsUtilisateur(String utilisateurId);

  // Obtenir les statistiques de paiement (pour le tableau de bord admin)
  Future<Either<Exception, Map<String, dynamic>>> obtenirStatistiquesPaiements({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? etablissementId,
    String? filiereId,
  });
}
