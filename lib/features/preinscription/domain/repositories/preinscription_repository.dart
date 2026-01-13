import 'package:dartz/dartz.dart';
import 'package:mycampus/core/errors/failures.dart';
import 'package:mycampus/features/preinscription/domain/entities/preinscription.dart';

abstract class PreinscriptionRepository {
  // Créer une nouvelle préinscription
  Future<Either<Failure, Preinscription>> creerPreinscription(Preinscription preinscription);

  // Récupérer une préinscription par son ID
  Future<Either<Failure, Preinscription>> obtenirPreinscriptionParId(String id);

  // Récupérer toutes les préinscriptions d'un étudiant
  Future<Either<Failure, List<Preinscription>>> obtenirPreinscriptionsParEtudiant(String etudiantId);

  // Mettre à jour une préinscription existante
  Future<Either<Failure, Preinscription>> mettreAJourPreinscription(Preinscription preinscription);

  // Supprimer une préinscription
  Future<Either<Failure, bool>> supprimerPreinscription(String id);

  // Valider une préinscription (pour l'administration)
  Future<Either<Failure, Preinscription>> validerPreinscription(String id, String validateurId);

  // Rejeter une préinscription (pour l'administration)
  Future<Either<Failure, Preinscription>> rejeterPreinscription(String id, String validateurId, String motifRejet);

  // Marquer les documents comme reçus (pour l'administration)
  Future<Either<Failure, Preinscription>> marquerDocumentsRecus(String id, List<String> documentsRecus);

  // Récupérer les préinscriptions par statut (pour l'administration)
  Future<Either<Failure, List<Preinscription>>> obtenirPreinscriptionsParStatut(String statut, {String? etablissementId});

  // Récupérer les préinscriptions par filière (pour l'administration)
  Future<Either<Failure, List<Preinscription>>> obtenirPreinscriptionsParFiliere(String filiereId);

  // Récupérer les préinscriptions par établissement (pour l'administration)
  Future<Either<Failure, List<Preinscription>>> obtenirPreinscriptionsParEtablissement(String etablissementId);

  // Vérifier si un étudiant est déjà préinscrit à une filière donnée
  Future<Either<Failure, bool>> verifierPreinscriptionExistante(String etudiantId, String filiereId);

  // Récupérer le nombre de préinscriptions par filière (pour les statistiques)
  Future<Either<Failure, Map<String, int>>> obtenirNombrePreinscriptionsParFiliere();
}
