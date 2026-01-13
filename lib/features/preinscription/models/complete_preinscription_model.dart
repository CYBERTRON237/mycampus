class CompletePreinscriptionModel {
  // Informations de base
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

  // Informations académiques
  final String? previousDiploma;
  final String? previousInstitution;
  final int? graduationYear;
  final String? graduationMonth;
  final String? desiredProgram;
  final String? studyLevel;
  final String? specialization;
  final String? seriesBac;
  final int? bacYear;
  final String? bacCenter;
  final String? bacMention;
  final double? gpaScore;
  final int? rankInClass;

  // Informations parents
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final String? parentOccupation;
  final String? parentAddress;
  final String? parentRelationship;
  final String? parentIncomeLevel;

  // Informations paiement
  final String? paymentMethod;
  final String? paymentReference;
  final double? paymentAmount;
  final String? paymentCurrency;
  final DateTime? paymentDate;
  final String? paymentStatus;
  final String? paymentProofPath;
  final bool scholarshipRequested;
  final String? scholarshipType;
  final double? financialAidAmount;

  // Documents
  final String? birthCertificatePath;
  final String? cniPath;
  final String? diplomaPath;
  final String? transcriptPath;
  final String? photoPath;
  final String? recommendationLetterPath;
  final String? motivationLetterPath;
  final String? medicalCertificatePath;
  final String? otherDocumentsPath;

  // Préférences et consentements
  final String? contactPreference;
  final bool marketingConsent;
  final bool dataProcessingConsent;
  final bool newsletterSubscription;

  // Informations système
  final String? ipAddress;
  final String? userAgent;
  final String? deviceType;
  final String? browserInfo;
  final String? osInfo;
  final String? locationCountry;
  final String? locationCity;

  // Notes et informations supplémentaires
  final String? notes;
  final String? adminNotes;
  final String? internalComments;
  final String? specialNeeds;
  final String? medicalConditions;

  // Champs pour la gestion du compte invité
  final String? applicantEmail;
  final String? applicantPhone;
  final String relationship;
  final int? studentId;
  final bool isProcessed;
  final DateTime? processedAt;

  final DateTime createdAt;

  CompletePreinscriptionModel({
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

    // Académique
    this.previousDiploma,
    this.previousInstitution,
    this.graduationYear,
    this.graduationMonth,
    this.desiredProgram,
    this.studyLevel,
    this.specialization,
    this.seriesBac,
    this.bacYear,
    this.bacCenter,
    this.bacMention,
    this.gpaScore,
    this.rankInClass,

    // Parents
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.parentOccupation,
    this.parentAddress,
    this.parentRelationship,
    this.parentIncomeLevel,

    // Paiement
    this.paymentMethod,
    this.paymentReference,
    this.paymentAmount,
    this.paymentCurrency = 'XAF',
    this.paymentDate,
    this.paymentStatus = 'pending',
    this.paymentProofPath,
    this.scholarshipRequested = false,
    this.scholarshipType,
    this.financialAidAmount,

    // Documents
    this.birthCertificatePath,
    this.cniPath,
    this.diplomaPath,
    this.transcriptPath,
    this.photoPath,
    this.recommendationLetterPath,
    this.motivationLetterPath,
    this.medicalCertificatePath,
    this.otherDocumentsPath,

    // Préférences
    this.contactPreference,
    this.marketingConsent = false,
    this.dataProcessingConsent = false,
    this.newsletterSubscription = false,

    // Système
    this.ipAddress,
    this.userAgent,
    this.deviceType,
    this.browserInfo,
    this.osInfo,
    this.locationCountry,
    this.locationCity,

    // Notes
    this.notes,
    this.adminNotes,
    this.internalComments,
    this.specialNeeds,
    this.medicalConditions,

    // Champs pour la gestion du compte invité
    this.applicantEmail,
    this.applicantPhone,
    this.relationship = 'self',
    this.studentId,
    this.isProcessed = false,
    this.processedAt,

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

      // Académique
      'previous_diploma': previousDiploma,
      'previous_institution': previousInstitution,
      'graduation_year': graduationYear,
      'graduation_month': graduationMonth,
      'desired_program': desiredProgram,
      'study_level': studyLevel,
      'specialization': specialization,
      'series_bac': seriesBac,
      'bac_year': bacYear,
      'bac_center': bacCenter,
      'bac_mention': bacMention,
      'gpa_score': gpaScore,
      'rank_in_class': rankInClass,

      // Parents
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'parent_occupation': parentOccupation,
      'parent_address': parentAddress,
      'parent_relationship': parentRelationship,
      'parent_income_level': parentIncomeLevel,

      // Paiement
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_amount': paymentAmount,
      'payment_currency': paymentCurrency,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_status': paymentStatus,
      'payment_proof_path': paymentProofPath,
      'scholarship_requested': scholarshipRequested ? 1 : 0,
      'scholarship_type': scholarshipType,
      'financial_aid_amount': financialAidAmount,

      // Documents
      'birth_certificate_path': birthCertificatePath,
      'cni_path': cniPath,
      'diploma_path': diplomaPath,
      'transcript_path': transcriptPath,
      'photo_path': photoPath,
      'recommendation_letter_path': recommendationLetterPath,
      'motivation_letter_path': motivationLetterPath,
      'medical_certificate_path': medicalCertificatePath,
      'other_documents_path': otherDocumentsPath,

      // Préférences
      'contact_preference': contactPreference,
      'marketing_consent': marketingConsent ? 1 : 0,
      'data_processing_consent': dataProcessingConsent ? 1 : 0,
      'newsletter_subscription': newsletterSubscription ? 1 : 0,

      // Système
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'device_type': deviceType,
      'browser_info': browserInfo,
      'os_info': osInfo,
      'location_country': locationCountry,
      'location_city': locationCity,

      // Notes
      'notes': notes,
      'admin_notes': adminNotes,
      'internal_comments': internalComments,
      'special_needs': specialNeeds,
      'medical_conditions': medicalConditions,

      // Champs pour la gestion du compte invité
      'applicant_email': applicantEmail,
      'applicant_phone': applicantPhone,
      'relationship': relationship,
      'student_id': studentId,
      'is_processed': isProcessed ? 1 : 0,
      'processed_at': processedAt?.toIso8601String(),

      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CompletePreinscriptionModel.fromJson(Map<String, dynamic> json) {
    return CompletePreinscriptionModel(
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

      // Académique
      previousDiploma: json['previous_diploma'],
      previousInstitution: json['previous_institution'],
      graduationYear: json['graduation_year'],
      graduationMonth: json['graduation_month'],
      desiredProgram: json['desired_program'],
      studyLevel: json['study_level'],
      specialization: json['specialization'],
      seriesBac: json['series_bac'],
      bacYear: json['bac_year'],
      bacCenter: json['bac_center'],
      bacMention: json['bac_mention'],
      gpaScore: json['gpa_score']?.toDouble(),
      rankInClass: json['rank_in_class'],

      // Parents
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      parentOccupation: json['parent_occupation'],
      parentAddress: json['parent_address'],
      parentRelationship: json['parent_relationship'],
      parentIncomeLevel: json['parent_income_level'],

      // Paiement
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      paymentAmount: json['payment_amount']?.toDouble(),
      paymentCurrency: json['payment_currency'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      paymentStatus: json['payment_status'],
      paymentProofPath: json['payment_proof_path'],
      scholarshipRequested: json['scholarship_requested'] == 1,
      scholarshipType: json['scholarship_type'],
      financialAidAmount: json['financial_aid_amount']?.toDouble(),

      // Documents
      birthCertificatePath: json['birth_certificate_path'],
      cniPath: json['cni_path'],
      diplomaPath: json['diploma_path'],
      transcriptPath: json['transcript_path'],
      photoPath: json['photo_path'],
      recommendationLetterPath: json['recommendation_letter_path'],
      motivationLetterPath: json['motivation_letter_path'],
      medicalCertificatePath: json['medical_certificate_path'],
      otherDocumentsPath: json['other_documents_path'],

      // Préférences
      contactPreference: json['contact_preference'],
      marketingConsent: json['marketing_consent'] == 1,
      dataProcessingConsent: json['data_processing_consent'] == 1,
      newsletterSubscription: json['newsletter_subscription'] == 1,

      // Système
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      deviceType: json['device_type'],
      browserInfo: json['browser_info'],
      osInfo: json['os_info'],
      locationCountry: json['location_country'],
      locationCity: json['location_city'],

      // Notes
      notes: json['notes'],
      adminNotes: json['admin_notes'],
      internalComments: json['internal_comments'],
      specialNeeds: json['special_needs'],
      medicalConditions: json['medical_conditions'],

      // Champs pour la gestion du compte invité
      applicantEmail: json['applicant_email'],
      applicantPhone: json['applicant_phone'],
      relationship: json['relationship'] ?? 'self',
      studentId: json['student_id'],
      isProcessed: json['is_processed'] == 1,
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,

      createdAt: DateTime.parse(json['created_at']),
    );
  }

  CompletePreinscriptionModel copyWith({
    String? uniqueCode,
    String? faculty,
    String? lastName,
    String? firstName,
    String? middleName,
    DateTime? dateOfBirth,
    bool? isBirthDateOnCertificate,
    String? placeOfBirth,
    String? gender,
    String? cniNumber,
    String? residenceAddress,
    String? maritalStatus,
    String? phoneNumber,
    String? email,
    String? firstLanguage,
    String? professionalSituation,
    String? previousDiploma,
    String? previousInstitution,
    int? graduationYear,
    String? graduationMonth,
    String? desiredProgram,
    String? studyLevel,
    String? specialization,
    String? seriesBac,
    int? bacYear,
    String? bacCenter,
    String? bacMention,
    double? gpaScore,
    int? rankInClass,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? parentOccupation,
    String? parentAddress,
    String? parentRelationship,
    String? parentIncomeLevel,
    String? paymentMethod,
    String? paymentReference,
    double? paymentAmount,
    String? paymentCurrency,
    DateTime? paymentDate,
    String? paymentStatus,
    String? paymentProofPath,
    bool? scholarshipRequested,
    String? scholarshipType,
    double? financialAidAmount,
    String? birthCertificatePath,
    String? cniPath,
    String? diplomaPath,
    String? transcriptPath,
    String? photoPath,
    String? recommendationLetterPath,
    String? motivationLetterPath,
    String? medicalCertificatePath,
    String? otherDocumentsPath,
    String? contactPreference,
    bool? marketingConsent,
    bool? dataProcessingConsent,
    bool? newsletterSubscription,
    String? ipAddress,
    String? userAgent,
    String? deviceType,
    String? browserInfo,
    String? osInfo,
    String? locationCountry,
    String? locationCity,
    String? notes,
    String? adminNotes,
    String? internalComments,
    String? specialNeeds,
    String? medicalConditions,
    String? applicantEmail,
    String? applicantPhone,
    String? relationship,
    int? studentId,
    bool? isProcessed,
    DateTime? processedAt,
    DateTime? createdAt,
  }) {
    return CompletePreinscriptionModel(
      uniqueCode: uniqueCode ?? this.uniqueCode,
      faculty: faculty ?? this.faculty,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isBirthDateOnCertificate: isBirthDateOnCertificate ?? this.isBirthDateOnCertificate,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      gender: gender ?? this.gender,
      cniNumber: cniNumber ?? this.cniNumber,
      residenceAddress: residenceAddress ?? this.residenceAddress,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      firstLanguage: firstLanguage ?? this.firstLanguage,
      professionalSituation: professionalSituation ?? this.professionalSituation,
      previousDiploma: previousDiploma ?? this.previousDiploma,
      previousInstitution: previousInstitution ?? this.previousInstitution,
      graduationYear: graduationYear ?? this.graduationYear,
      graduationMonth: graduationMonth ?? this.graduationMonth,
      desiredProgram: desiredProgram ?? this.desiredProgram,
      studyLevel: studyLevel ?? this.studyLevel,
      specialization: specialization ?? this.specialization,
      seriesBac: seriesBac ?? this.seriesBac,
      bacYear: bacYear ?? this.bacYear,
      bacCenter: bacCenter ?? this.bacCenter,
      bacMention: bacMention ?? this.bacMention,
      gpaScore: gpaScore ?? this.gpaScore,
      rankInClass: rankInClass ?? this.rankInClass,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      parentOccupation: parentOccupation ?? this.parentOccupation,
      parentAddress: parentAddress ?? this.parentAddress,
      parentRelationship: parentRelationship ?? this.parentRelationship,
      parentIncomeLevel: parentIncomeLevel ?? this.parentIncomeLevel,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentProofPath: paymentProofPath ?? this.paymentProofPath,
      scholarshipRequested: scholarshipRequested ?? this.scholarshipRequested,
      scholarshipType: scholarshipType ?? this.scholarshipType,
      financialAidAmount: financialAidAmount ?? this.financialAidAmount,
      birthCertificatePath: birthCertificatePath ?? this.birthCertificatePath,
      cniPath: cniPath ?? this.cniPath,
      diplomaPath: diplomaPath ?? this.diplomaPath,
      transcriptPath: transcriptPath ?? this.transcriptPath,
      photoPath: photoPath ?? this.photoPath,
      recommendationLetterPath: recommendationLetterPath ?? this.recommendationLetterPath,
      motivationLetterPath: motivationLetterPath ?? this.motivationLetterPath,
      medicalCertificatePath: medicalCertificatePath ?? this.medicalCertificatePath,
      otherDocumentsPath: otherDocumentsPath ?? this.otherDocumentsPath,
      contactPreference: contactPreference ?? this.contactPreference,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      dataProcessingConsent: dataProcessingConsent ?? this.dataProcessingConsent,
      newsletterSubscription: newsletterSubscription ?? this.newsletterSubscription,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceType: deviceType ?? this.deviceType,
      browserInfo: browserInfo ?? this.browserInfo,
      osInfo: osInfo ?? this.osInfo,
      locationCountry: locationCountry ?? this.locationCountry,
      locationCity: locationCity ?? this.locationCity,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      internalComments: internalComments ?? this.internalComments,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      relationship: relationship ?? this.relationship,
      studentId: studentId ?? this.studentId,
      isProcessed: isProcessed ?? this.isProcessed,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CompletePreinscriptionConstants {
  // Options de base
  static const List<String> genders = ['MASCULIN', 'FEMININ'];
  static const List<String> maritalStatuses = ['CELIBATAIRE', 'MARIE(E)', 'DIVORCE(E)', 'VEUF(VE)'];
  static const List<String> languages = ['FRANÇAIS', 'ANGLAIS', 'BILINGUE'];
  static const List<String> professionalSituations = ['SANS EMPLOI', 'SALARIE(E)', 'EN AUTO-EMPLOI', 'STAGIAIRE', 'RETRAITE(E)'];

  // Options académiques
  static const List<String> studyLevels = ['LICENCE', 'MASTER', 'DOCTORAT', 'DUT', 'BTS', 'MASTER_PRO', 'DEUST', 'AUTRE'];
  
  // Séries du Baccalauréat Camerounais
  static const List<String> bacSeries = [
    'A1', // Littérature et Philosophie
    'A2', // Littérature, Philosophie et Langues
    'A3', // Littérature, Philosophie et Langues Vivantes
    'A4', // Littérature, Philosophie et Histoire-Géographie
    'A5', // Littérature, Philosophie et Arts
    'ABI', // Série Bilingue
    'C', // Mathématiques et Physique
    'D', // Mathématiques, Biologie et Géologie
    'TI', // Technologie et Informatique
    'SH', // Sciences Humaines
    'AC', // Arts et Cinématographiques
  ];
  
  static const List<String> bacMentions = ['PASSABLE', 'ASSEZ_BIEN', 'BIEN', 'TRES_BIEN', 'EXCELLENT'];
  static const List<String> diplomas = ['BACCALAUREAT', 'GCE A-LEVEL', 'GCE O-LEVEL', 'BREVET', 'AUTRE'];

  // Options parents
  static const List<String> parentRelationships = ['PERE', 'MERE', 'TUTEUR', 'AUTRE'];
  static const List<String> incomeLevels = ['FAIBLE', 'MOYEN', 'ELEVE'];

  // Options paiement
  static const List<String> paymentMethods = ['ORANGE_MONEY', 'MTN_MONEY', 'BANK_TRANSFER', 'CASH', 'MOBILE_MONEY', 'CHEQUE', 'OTHER'];
  static const List<String> paymentStatuses = ['pending', 'paid', 'confirmed', 'refunded', 'partial'];

  // Options contact
  static const List<String> contactPreferences = ['EMAIL', 'PHONE', 'SMS', 'WHATSAPP'];
  static const List<String> deviceTypes = ['DESKTOP', 'MOBILE', 'TABLET', 'OTHER'];

  // Options pour la gestion du compte invité
  static const List<String> relationships = ['self', 'parent', 'tutor', 'other'];
  static const List<String> statuses = ['pending', 'under_review', 'accepted', 'rejected', 'cancelled', 'deferred', 'waitlisted'];
  static const List<String> documentStatuses = ['pending', 'submitted', 'verified', 'incomplete', 'rejected'];
  static const List<String> reviewPriorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];

  // Frais d'inscription
  static const int registrationFee = 15000; // FCFA
  
  // Limites
  static int get maxGraduationYear => DateTime.now().year + 1;
  static const int minGraduationYear = 1900;
  static const double maxGpaScore = 5.0;
  static const double minGpaScore = 0.0;
}
