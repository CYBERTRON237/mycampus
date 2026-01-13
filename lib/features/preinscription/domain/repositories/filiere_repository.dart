import 'package:dartz/dartz.dart';
import 'package:mycampus/features/preinscription/domain/entities/filiere.dart';

abstract class FiliereRepository {
  // Récupérer toutes les filières d'un établissement
  Future<Either<Exception, List<Filiere>>> obtenirFilieresParEtablissement(String etablissementId);

  // Récupérer une filière par son ID
  Future<Either<Exception, Filiere>> obtenirFiliereParId(String id);

  // Récupérer les filières par niveau d'entrée
  Future<Either<Exception, List<Filiere>>> obtenirFilieresParNiveau(String niveau);

  // Vérifier si une filière a encore des places disponibles
  Future<Either<Exception, bool>> verifierPlacesDisponibles(String filiereId);

  // Créer une nouvelle filière (administration)
  Future<Either<Exception, Filiere>> creerFiliere(Filiere filiere);

  // Mettre à jour une filière existante (administration)
  Future<Either<Exception, Filiere>> mettreAJourFiliere(Filiere filiere);

  // Activer/désactiver une filière (administration)
  Future<Either<Exception, bool>> changerStatutFiliere(String id, bool estActive);

  // Rechercher des filières par nom ou code
  Future<Either<Exception, List<Filiere>>> rechercherFilieres(String termeRecherche, {String? etablissementId});

  // Obtenir le nombre de filières par établissement
  Future<Either<Exception, Map<String, int>>> obtenirNombreFilieresParEtablissement();

  // Mettre à jour le nombre de places disponibles pour une filière
  Future<Either<Exception, bool>> mettreAJourPlacesDisponibles(String filiereId, int nouvellesPlaces);
}
