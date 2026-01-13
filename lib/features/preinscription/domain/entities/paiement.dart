import 'package:equatable/equatable.dart';

enum StatutPaiement {
  enAttente,
  enCoursTraitement,
  paye,
  echec,
  annule,
  rembourse,
  erreur,
}

enum ModePaiement {
  mtnMobileMoney,
  orangeMoney,
  expressUnionMobile,
  ccaBank,
  especes,
  virementBancaire,
  autre,
}

class Paiement extends Equatable {
  final String id;
  final String reference;
  final String preinscriptionId;
  final double montant;
  final String devise;
  final StatutPaiement statut;
  final ModePaiement modePaiement;
  final String? referenceTransaction;
  final String? operateurPaiement;
  final String? numeroTelephone;
  final String? nomPrenomPayeur;
  final String? emailPayeur;
  final String? motifPaiement;
  final String? urlPaiement;
  final String? callbackUrl;
  final String? reponseApiPaiement;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;
  final DateTime? datePaiement;
  final String? utilisateurId;
  final String? commentaire;

  Paiement({
    required this.id,
    required this.reference,
    required this.preinscriptionId,
    required this.montant,
    this.devise = 'XAF',
    this.statut = StatutPaiement.enAttente,
    required this.modePaiement,
    this.referenceTransaction,
    this.operateurPaiement,
    this.numeroTelephone,
    this.nomPrenomPayeur,
    this.emailPayeur,
    this.motifPaiement,
    this.urlPaiement,
    this.callbackUrl,
    this.reponseApiPaiement,
    DateTime? dateCreation,
    this.dateMiseAJour,
    this.datePaiement,
    this.utilisateurId,
    this.commentaire,
  }) : dateCreation = dateCreation ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        reference,
        preinscriptionId,
        montant,
        devise,
        statut,
        modePaiement,
        referenceTransaction,
        operateurPaiement,
        numeroTelephone,
        nomPrenomPayeur,
        emailPayeur,
        motifPaiement,
        urlPaiement,
        callbackUrl,
        reponseApiPaiement,
        dateCreation,
        dateMiseAJour,
        datePaiement,
        utilisateurId,
        commentaire,
      ];

  Paiement copyWith({
    String? id,
    String? reference,
    String? preinscriptionId,
    double? montant,
    String? devise,
    StatutPaiement? statut,
    ModePaiement? modePaiement,
    String? referenceTransaction,
    String? operateurPaiement,
    String? numeroTelephone,
    String? nomPrenomPayeur,
    String? emailPayeur,
    String? motifPaiement,
    String? urlPaiement,
    String? callbackUrl,
    String? reponseApiPaiement,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
    DateTime? datePaiement,
    String? utilisateurId,
    String? commentaire,
  }) {
    return Paiement(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      preinscriptionId: preinscriptionId ?? this.preinscriptionId,
      montant: montant ?? this.montant,
      devise: devise ?? this.devise,
      statut: statut ?? this.statut,
      modePaiement: modePaiement ?? this.modePaiement,
      referenceTransaction: referenceTransaction ?? this.referenceTransaction,
      operateurPaiement: operateurPaiement ?? this.operateurPaiement,
      numeroTelephone: numeroTelephone ?? this.numeroTelephone,
      nomPrenomPayeur: nomPrenomPayeur ?? this.nomPrenomPayeur,
      emailPayeur: emailPayeur ?? this.emailPayeur,
      motifPaiement: motifPaiement ?? this.motifPaiement,
      urlPaiement: urlPaiement ?? this.urlPaiement,
      callbackUrl: callbackUrl ?? this.callbackUrl,
      reponseApiPaiement: reponseApiPaiement ?? this.reponseApiPaiement,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
      datePaiement: datePaiement ?? this.datePaiement,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      commentaire: commentaire ?? this.commentaire,
    );
  }
}
