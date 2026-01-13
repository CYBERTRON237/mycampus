import 'package:dartz/dartz.dart';
import 'package:mycampus/features/preinscription/domain/entities/etablissement.dart';

abstract class EtablissementRepository {
  // Récupérer tous les établissements
  Future<Either<Exception, List<Etablissement>>> obtenirTousLesEtablissements();

  // Récupérer un établissement par son ID
  Future<Either<Exception, Etablissement>> obtenirEtablissementParId(String id);

  // Récupérer les établissements par statut (actif/inactif)
  Future<Either<Exception, List<Etablissement>>> obtenirEtablissementsParStatut(bool estActif);

  // Créer un nouvel établissement (administration)
  Future<Either<Exception, Etablissement>> creerEtablissement(Etablissement etablissement);

  // Mettre à jour un établissement existant (administration)
  Future<Either<Exception, Etablissement>> mettreAJourEtablissement(Etablissement etablissement);

  // Activer/désactiver un établissement (administration)
  Future<Either<Exception, bool>> changerStatutEtablissement(String id, bool estActif);

  // Rechercher des établissements par nom ou sigle
  Future<Either<Exception, List<Etablissement>>> rechercherEtablissements(String termeRecherche);

  // Obtenir le nombre total d'établissements
  Future<Either<Exception, int>> obtenirNombreTotalEtablissements();
}
