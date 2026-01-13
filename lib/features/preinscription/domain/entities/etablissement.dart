import 'package:equatable/equatable.dart';

class Etablissement extends Equatable {
  final String id;
  final String nom;
  final String? sigle;
  final String? description;
  final String? logoUrl;
  final String? adresse;
  final String? ville;
  final String? pays;
  final String? telephone;
  final String? email;
  final String? siteWeb;
  final bool estActif;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;

  Etablissement({
    required this.id,
    required this.nom,
    this.sigle,
    this.description,
    this.logoUrl,
    this.adresse,
    this.ville,
    this.pays,
    this.telephone,
    this.email,
    this.siteWeb,
    this.estActif = true,
    DateTime? dateCreation,
    this.dateMiseAJour,
  }) : dateCreation = dateCreation ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        nom,
        sigle,
        description,
        logoUrl,
        adresse,
        ville,
        pays,
        telephone,
        email,
        siteWeb,
        estActif,
        dateCreation,
        dateMiseAJour,
      ];

  Etablissement copyWith({
    String? id,
    String? nom,
    String? sigle,
    String? description,
    String? logoUrl,
    String? adresse,
    String? ville,
    String? pays,
    String? telephone,
    String? email,
    String? siteWeb,
    bool? estActif,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
  }) {
    return Etablissement(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      sigle: sigle ?? this.sigle,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      pays: pays ?? this.pays,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      siteWeb: siteWeb ?? this.siteWeb,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
    );
  }
}
