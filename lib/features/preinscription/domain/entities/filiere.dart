import 'package:equatable/equatable.dart';

class Filiere extends Equatable {
  final String id;
  final String etablissementId;
  final String code;
  final String intitule;
  final String? description;
  final String? diplome;
  final int dureeEtudes;
  final String niveauEntree;
  final String? conditionsAdmission;
  final int placesDisponibles;
  final double fraisInscription;
  final bool estActive;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;

  Filiere({
    required this.id,
    required this.etablissementId,
    required this.code,
    required this.intitule,
    this.description,
    this.diplome,
    required this.dureeEtudes,
    required this.niveauEntree,
    this.conditionsAdmission,
    required this.placesDisponibles,
    required this.fraisInscription,
    this.estActive = true,
    DateTime? dateCreation,
    this.dateMiseAJour,
  }) : dateCreation = dateCreation ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        etablissementId,
        code,
        intitule,
        description,
        diplome,
        dureeEtudes,
        niveauEntree,
        conditionsAdmission,
        placesDisponibles,
        fraisInscription,
        estActive,
        dateCreation,
        dateMiseAJour,
      ];

  Filiere copyWith({
    String? id,
    String? etablissementId,
    String? code,
    String? intitule,
    String? description,
    String? diplome,
    int? dureeEtudes,
    String? niveauEntree,
    String? conditionsAdmission,
    int? placesDisponibles,
    double? fraisInscription,
    bool? estActive,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
  }) {
    return Filiere(
      id: id ?? this.id,
      etablissementId: etablissementId ?? this.etablissementId,
      code: code ?? this.code,
      intitule: intitule ?? this.intitule,
      description: description ?? this.description,
      diplome: diplome ?? this.diplome,
      dureeEtudes: dureeEtudes ?? this.dureeEtudes,
      niveauEntree: niveauEntree ?? this.niveauEntree,
      conditionsAdmission: conditionsAdmission ?? this.conditionsAdmission,
      placesDisponibles: placesDisponibles ?? this.placesDisponibles,
      fraisInscription: fraisInscription ?? this.fraisInscription,
      estActive: estActive ?? this.estActive,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
    );
  }
}
