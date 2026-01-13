import 'package:dartz/dartz.dart';
import 'package:mycampus/features/preinscription/domain/entities/document_requis.dart';

abstract class DocumentRequisRepository {
  // Récupérer tous les documents requis pour une filière
  Future<Either<Exception, List<DocumentRequis>>> obtenirDocumentsParFiliere(String filiereId);
  
  // Récupérer un document requis par son ID
  Future<Either<Exception, DocumentRequis>> obtenirDocumentParId(String id);
  
  // Récupérer les documents requis par type
  Future<Either<Exception, List<DocumentRequis>>> obtenirDocumentsParType(TypeDocument type);
  
  // Créer un nouveau document requis (administration)
  Future<Either<Exception, DocumentRequis>> creerDocumentRequis(DocumentRequis document);
  
  // Mettre à jour un document requis existant (administration)
  Future<Either<Exception, DocumentRequis>> mettreAJourDocumentRequis(DocumentRequis document);
  
  // Supprimer un document requis (administration)
  Future<Either<Exception, bool>> supprimerDocumentRequis(String id);
  
  // Activer/désactiver un document requis (administration)
  Future<Either<Exception, bool>> changerStatutDocumentRequis(String id, bool estActif);
  
  // Vérifier si tous les documents requis sont fournis pour une préinscription
  Future<Either<Exception, bool>> verifierDocumentsFournis(String preinscriptionId, List<String> documentsFournis);
}
