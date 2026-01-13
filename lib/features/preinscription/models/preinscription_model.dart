class PreinscriptionModel {
  final String? uniqueCode;
  final String faculty;
  final String lastName;
  final String firstName;
  final String? middleName;
  final DateTime dateOfBirth;
  final bool isBirthDateOnCertificate;
  final String placeOfBirth;
  final String gender;
  final String? cniNumber;
  final String residenceAddress;
  final String maritalStatus;
  final String phoneNumber;
  final String email;
  final String firstLanguage;
  final String professionalSituation;
  final DateTime createdAt;

  PreinscriptionModel({
    this.uniqueCode,
    required this.faculty,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.dateOfBirth,
    required this.isBirthDateOnCertificate,
    required this.placeOfBirth,
    required this.gender,
    this.cniNumber,
    required this.residenceAddress,
    required this.maritalStatus,
    required this.phoneNumber,
    required this.email,
    required this.firstLanguage,
    required this.professionalSituation,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'unique_code': uniqueCode,
      'faculty': faculty,
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'is_birth_date_on_certificate': isBirthDateOnCertificate ? 1 : 0,
      'place_of_birth': placeOfBirth,
      'gender': gender,
      'cni_number': cniNumber,
      'residence_address': residenceAddress,
      'marital_status': maritalStatus,
      'phone_number': phoneNumber,
      'email': email,
      'first_language': firstLanguage,
      'professional_situation': professionalSituation,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PreinscriptionModel.fromJson(Map<String, dynamic> json) {
    return PreinscriptionModel(
      uniqueCode: json['unique_code'],
      faculty: json['faculty'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      isBirthDateOnCertificate: json['is_birth_date_on_certificate'] == 1,
      placeOfBirth: json['place_of_birth'],
      gender: json['gender'],
      cniNumber: json['cni_number'],
      residenceAddress: json['residence_address'],
      maritalStatus: json['marital_status'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      firstLanguage: json['first_language'],
      professionalSituation: json['professional_situation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PreinscriptionConstants {
  static const List<String> genders = ['MASCULIN', 'FEMININ'];
  static const List<String> maritalStatuses = ['CELIBATAIRE', 'MARIE(E)', 'DIVORCE(E)'];
  static const List<String> languages = ['FRANÇAIS', 'ANGLAIS'];
  static const List<String> professionalSituations = ['SANS EMPLOI', 'SALARIE(E)', 'EN AUTO-EMPLOI'];
  
  static const int registrationFee = 10000; // FCFA
}
