import 'package:equatable/equatable.dart';

enum PreinscriptionStatus {
  brouillon,
  enAttentePaiement,
  paye,
  documentsIncomplets,
  enCoursValidation,
  valide,
  rejete,
}

class Preinscription extends Equatable {
  final String? id;
  final String etablissementId;
  final String filiereId;
  final String niveau;
  final String nom;
  final String prenoms;
  final DateTime dateNaissance;
  final String lieuNaissance;
  final String email;
  final String telephone;
  final String? adresse;
  final String? ville;
  final String? pays;
  final String? photoUrl;
  final List<String> piecesJointes;
  final PreinscriptionStatus statut;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;
  final String? referencePaiement;
  final double montantPaiement;
  final DateTime? datePaiement;
  final String? modePaiement;

  Preinscription({
    this.id,
    required this.etablissementId,
    required this.filiereId,
    required this.niveau,
    required this.nom,
    required this.prenoms,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.email,
    required this.telephone,
    this.adresse,
    this.ville,
    this.pays,
    this.photoUrl,
    this.piecesJointes = const [],
    this.statut = PreinscriptionStatus.brouillon,
    DateTime? dateCreation,
    this.dateMiseAJour,
    this.referencePaiement,
    this.montantPaiement = 0.0,
    this.datePaiement,
    this.modePaiement,
  }) : dateCreation = dateCreation ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        etablissementId,
        filiereId,
        niveau,
        nom,
        prenoms,
        dateNaissance,
        lieuNaissance,
        email,
        telephone,
        adresse,
        ville,
        pays,
        photoUrl,
        piecesJointes,
        statut,
        dateCreation,
        dateMiseAJour,
        referencePaiement,
        montantPaiement,
        datePaiement,
        modePaiement,
      ];

  Preinscription copyWith({
    String? id,
    String? etablissementId,
    String? filiereId,
    String? niveau,
    String? nom,
    String? prenoms,
    DateTime? dateNaissance,
    String? lieuNaissance,
    String? email,
    String? telephone,
    String? adresse,
    String? ville,
    String? pays,
    String? photoUrl,
    List<String>? piecesJointes,
    PreinscriptionStatus? statut,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
    String? referencePaiement,
    double? montantPaiement,
    DateTime? datePaiement,
    String? modePaiement,
  }) {
    return Preinscription(
      id: id ?? this.id,
      etablissementId: etablissementId ?? this.etablissementId,
      filiereId: filiereId ?? this.filiereId,
      niveau: niveau ?? this.niveau,
      nom: nom ?? this.nom,
      prenoms: prenoms ?? this.prenoms,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      lieuNaissance: lieuNaissance ?? this.lieuNaissance,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      pays: pays ?? this.pays,
      photoUrl: photoUrl ?? this.photoUrl,
      piecesJointes: piecesJointes ?? this.piecesJointes,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
      referencePaiement: referencePaiement ?? this.referencePaiement,
      montantPaiement: montantPaiement ?? this.montantPaiement,
      datePaiement: datePaiement ?? this.datePaiement,
      modePaiement: modePaiement ?? this.modePaiement,
    );
  }
}
