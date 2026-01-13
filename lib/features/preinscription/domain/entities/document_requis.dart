import 'package:equatable/equatable.dart';

enum TypeDocument {
  copieDiplome,
  releveNotes,
  acteNaissance,
  pieceIdentite,
  photoIdentite,
  attestationReussite,
  autre,
}

class DocumentRequis extends Equatable {
  final String id;
  final String etablissementId;
  final String? filiereId; // null si le document est requis pour toutes les filières
  final String libelle;
  final String description;
  final TypeDocument type;
  final bool estObligatoire;
  final int? ordreAffichage;
  final bool estActif;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;

  DocumentRequis({
    required this.id,
    required this.etablissementId,
    this.filiereId,
    required this.libelle,
    required this.description,
    required this.type,
    this.estObligatoire = true,
    this.ordreAffichage,
    this.estActif = true,
    DateTime? dateCreation,
    this.dateMiseAJour,
  }) : dateCreation = dateCreation ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        etablissementId,
        filiereId,
        libelle,
        description,
        type,
        estObligatoire,
        ordreAffichage,
        estActif,
        dateCreation,
        dateMiseAJour,
      ];

  DocumentRequis copyWith({
    String? id,
    String? etablissementId,
    String? filiereId,
    String? libelle,
    String? description,
    TypeDocument? type,
    bool? estObligatoire,
    int? ordreAffichage,
    bool? estActif,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
  }) {
    return DocumentRequis(
      id: id ?? this.id,
      etablissementId: etablissementId ?? this.etablissementId,
      filiereId: filiereId ?? this.filiereId,
      libelle: libelle ?? this.libelle,
      description: description ?? this.description,
      type: type ?? this.type,
      estObligatoire: estObligatoire ?? this.estObligatoire,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
    );
  }
}
