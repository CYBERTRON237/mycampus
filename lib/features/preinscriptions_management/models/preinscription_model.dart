import 'package:json_annotation/json_annotation.dart';

part 'preinscription_model.g.dart';

@JsonSerializable()
class PreinscriptionModel {
  final int? id;
  final String? uuid;
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
  final String? birthCertificatePath;
  final String? cniPath;
  final String? diplomaPath;
  final String? transcriptPath;
  final String? photoPath;
  final String? recommendationLetterPath;
  final String? motivationLetterPath;
  final String? medicalCertificatePath;
  final String? otherDocumentsPath;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final String? parentOccupation;
  final String? parentAddress;
  final String? parentRelationship;
  final String? parentIncomeLevel;
  final String? paymentMethod;
  final String? paymentReference;
  final double? paymentAmount;
  final String paymentCurrency;
  final DateTime? paymentDate;
  final String paymentStatus;
  final String? paymentProofPath;
  final bool scholarshipRequested;
  final String? scholarshipType;
  final double? financialAidAmount;
  final String status;
  final String documentsStatus;
  final String reviewPriority;
  final int? reviewedBy;
  final DateTime? reviewDate;
  final String? reviewComments;
  final String? rejectionReason;
  final bool interviewRequired;
  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewType;
  final String? interviewResult;
  final String? interviewNotes;
  final String? admissionNumber;
  final DateTime? admissionDate;
  final DateTime? registrationDeadline;
  final bool registrationCompleted;
  final String? studentId;
  final String? batchNumber;
  final String? contactPreference;
  final bool marketingConsent;
  final bool dataProcessingConsent;
  final bool newsletterSubscription;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceType;
  final String? browserInfo;
  final String? osInfo;
  final String? locationCountry;
  final String? locationCity;
  final String? notes;
  final String? adminNotes;
  final String? internalComments;
  final String? specialNeeds;
  final String? medicalConditions;
  final DateTime submissionDate;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PreinscriptionModel({
    this.id,
    this.uuid,
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
    this.birthCertificatePath,
    this.cniPath,
    this.diplomaPath,
    this.transcriptPath,
    this.photoPath,
    this.recommendationLetterPath,
    this.motivationLetterPath,
    this.medicalCertificatePath,
    this.otherDocumentsPath,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.parentOccupation,
    this.parentAddress,
    this.parentRelationship,
    this.parentIncomeLevel,
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
    this.status = 'pending',
    this.documentsStatus = 'pending',
    this.reviewPriority = 'NORMAL',
    this.reviewedBy,
    this.reviewDate,
    this.reviewComments,
    this.rejectionReason,
    this.interviewRequired = false,
    this.interviewDate,
    this.interviewLocation,
    this.interviewType,
    this.interviewResult,
    this.interviewNotes,
    this.admissionNumber,
    this.admissionDate,
    this.registrationDeadline,
    this.registrationCompleted = false,
    this.studentId,
    this.batchNumber,
    this.contactPreference,
    this.marketingConsent = false,
    this.dataProcessingConsent = false,
    this.newsletterSubscription = false,
    this.ipAddress,
    this.userAgent,
    this.deviceType,
    this.browserInfo,
    this.osInfo,
    this.locationCountry,
    this.locationCity,
    this.notes,
    this.adminNotes,
    this.internalComments,
    this.specialNeeds,
    this.medicalConditions,
    required this.submissionDate,
    required this.lastUpdated,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory PreinscriptionModel.fromJson(Map<String, dynamic> json) {
    // For API responses that only contain basic fields
    if (json.containsKey('last_name') && json.containsKey('first_name')) {
      return PreinscriptionModel(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        uniqueCode: json['unique_code'] as String?,
        faculty: json['faculty'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        middleName: json['middle_name'] as String?,
        dateOfBirth: json['date_of_birth'] != null 
            ? DateTime.parse(json['date_of_birth'] as String) 
            : DateTime.now(),
        isBirthDateOnCertificate: json['is_birth_date_on_certificate'] is bool ? json['is_birth_date_on_certificate'] as bool : (json['is_birth_date_on_certificate'] as int? ?? 0) == 1,
        placeOfBirth: json['place_of_birth'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        cniNumber: json['cni_number'] as String?,
        residenceAddress: json['residence_address'] as String? ?? '',
        maritalStatus: json['marital_status'] as String? ?? '',
        phoneNumber: json['phone_number'] as String? ?? '',
        email: json['email'] as String? ?? '',
        firstLanguage: json['first_language'] as String? ?? '',
        professionalSituation: json['professional_situation'] as String? ?? '',
        previousDiploma: json['previous_diploma'] as String?,
        previousInstitution: json['previous_institution'] as String?,
        graduationYear: json['graduation_year'] as int?,
        graduationMonth: json['graduation_month'] as String?,
        desiredProgram: json['desired_program'] as String?,
        studyLevel: json['study_level'] as String?,
        specialization: json['specialization'] as String?,
        seriesBac: json['series_bac'] as String?,
        bacYear: json['bac_year'] as int?,
        bacCenter: json['bac_center'] as String?,
        bacMention: json['bac_mention'] as String?,
        gpaScore: json['gpa_score'] as double?,
        rankInClass: json['rank_in_class'] as int?,
        birthCertificatePath: json['birth_certificate_path'] as String?,
        cniPath: json['cni_path'] as String?,
        diplomaPath: json['diploma_path'] as String?,
        transcriptPath: json['transcript_path'] as String?,
        photoPath: json['photo_path'] as String?,
        recommendationLetterPath: json['recommendation_letter_path'] as String?,
        motivationLetterPath: json['motivation_letter_path'] as String?,
        medicalCertificatePath: json['medical_certificate_path'] as String?,
        otherDocumentsPath: json['other_documents_path'] as String?,
        parentName: json['parent_name'] as String?,
        parentPhone: json['parent_phone'] as String?,
        parentEmail: json['parent_email'] as String?,
        parentOccupation: json['parent_occupation'] as String?,
        parentAddress: json['parent_address'] as String?,
        parentRelationship: json['parent_relationship'] as String?,
        parentIncomeLevel: json['parent_income_level'] as String?,
        paymentMethod: json['payment_method'] as String?,
        paymentReference: json['payment_reference'] as String?,
        paymentAmount: json['payment_amount'] != null 
            ? double.tryParse(json['payment_amount'].toString()) 
            : null,
        paymentCurrency: 'XAF',
        paymentDate: json['payment_date'] != null 
            ? DateTime.parse(json['payment_date'] as String) 
            : null,
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        paymentProofPath: json['payment_proof_path'] as String?,
        scholarshipRequested: json['scholarship_requested'] is bool ? json['scholarship_requested'] as bool : (json['scholarship_requested'] as int? ?? 0) == 1,
        scholarshipType: json['scholarship_type'] as String?,
        financialAidAmount: json['financial_aid_amount'] as double?,
        status: json['status'] as String? ?? 'pending',
        documentsStatus: json['documents_status'] as String? ?? 'pending',
        reviewPriority: json['review_priority'] as String? ?? 'NORMAL',
        reviewedBy: json['reviewed_by'] as int?,
        reviewDate: json['review_date'] != null ? DateTime.parse(json['review_date'] as String) : null,
        reviewComments: json['review_comments'] as String?,
        rejectionReason: json['rejection_reason'] as String?,
        interviewRequired: json['interview_required'] is bool ? json['interview_required'] as bool : (json['interview_required'] as int? ?? 0) == 1,
        interviewDate: json['interview_date'] != null ? DateTime.parse(json['interview_date'] as String) : null,
        interviewLocation: json['interview_location'] as String?,
        interviewType: json['interview_type'] as String?,
        interviewResult: json['interview_result'] as String?,
        interviewNotes: json['interview_notes'] as String?,
        admissionNumber: json['admission_number'] as String?,
        admissionDate: json['admission_date'] != null ? DateTime.parse(json['admission_date'] as String) : null,
        registrationDeadline: json['registration_deadline'] != null ? DateTime.parse(json['registration_deadline'] as String) : null,
        registrationCompleted: json['registration_completed'] is bool ? json['registration_completed'] as bool : (json['registration_completed'] as int? ?? 0) == 1,
        studentId: json['student_id'] as String?,
        batchNumber: json['batch_number'] as String?,
        contactPreference: json['contact_preference'] as String?,
        marketingConsent: json['marketing_consent'] is bool ? json['marketing_consent'] as bool : (json['marketing_consent'] as int? ?? 0) == 1,
        dataProcessingConsent: json['data_processing_consent'] is bool ? json['data_processing_consent'] as bool : (json['data_processing_consent'] as int? ?? 0) == 1,
        newsletterSubscription: json['newsletter_subscription'] is bool ? json['newsletter_subscription'] as bool : (json['newsletter_subscription'] as int? ?? 0) == 1,
        ipAddress: json['ip_address'] as String?,
        userAgent: json['user_agent'] as String?,
        deviceType: json['device_type'] as String?,
        browserInfo: json['browser_info'] as String?,
        osInfo: json['os_info'] as String?,
        locationCountry: json['location_country'] as String?,
        locationCity: json['location_city'] as String?,
        notes: json['notes'] as String?,
        adminNotes: json['admin_notes'] as String?,
        internalComments: json['internal_comments'] as String?,
        specialNeeds: json['special_needs'] as String?,
        medicalConditions: json['medical_conditions'] as String?,
        submissionDate: json['submission_date'] != null 
            ? DateTime.parse(json['submission_date'] as String) 
            : DateTime.now(),
        lastUpdated: json['last_updated'] != null 
            ? DateTime.parse(json['last_updated'] as String) 
            : DateTime.now(),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'] as String) 
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'] as String) 
            : DateTime.now(),
        deletedAt: null,
      );
    }
    
    // For complete JSON responses (using generated code)
    return _$PreinscriptionModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PreinscriptionModelToJson(this);

  PreinscriptionModel copyWith({
    int? id,
    String? uuid,
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
    String? birthCertificatePath,
    String? cniPath,
    String? diplomaPath,
    String? transcriptPath,
    String? photoPath,
    String? recommendationLetterPath,
    String? motivationLetterPath,
    String? medicalCertificatePath,
    String? otherDocumentsPath,
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
    String? status,
    String? documentsStatus,
    String? reviewPriority,
    int? reviewedBy,
    DateTime? reviewDate,
    String? reviewComments,
    String? rejectionReason,
    bool? interviewRequired,
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewType,
    String? interviewResult,
    String? interviewNotes,
    String? admissionNumber,
    DateTime? admissionDate,
    DateTime? registrationDeadline,
    bool? registrationCompleted,
    String? studentId,
    String? batchNumber,
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
    DateTime? submissionDate,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PreinscriptionModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
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
      birthCertificatePath: birthCertificatePath ?? this.birthCertificatePath,
      cniPath: cniPath ?? this.cniPath,
      diplomaPath: diplomaPath ?? this.diplomaPath,
      transcriptPath: transcriptPath ?? this.transcriptPath,
      photoPath: photoPath ?? this.photoPath,
      recommendationLetterPath: recommendationLetterPath ?? this.recommendationLetterPath,
      motivationLetterPath: motivationLetterPath ?? this.motivationLetterPath,
      medicalCertificatePath: medicalCertificatePath ?? this.medicalCertificatePath,
      otherDocumentsPath: otherDocumentsPath ?? this.otherDocumentsPath,
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
      status: status ?? this.status,
      documentsStatus: documentsStatus ?? this.documentsStatus,
      reviewPriority: reviewPriority ?? this.reviewPriority,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewComments: reviewComments ?? this.reviewComments,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      interviewRequired: interviewRequired ?? this.interviewRequired,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      interviewType: interviewType ?? this.interviewType,
      interviewResult: interviewResult ?? this.interviewResult,
      interviewNotes: interviewNotes ?? this.interviewNotes,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      admissionDate: admissionDate ?? this.admissionDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      registrationCompleted: registrationCompleted ?? this.registrationCompleted,
      studentId: studentId ?? this.studentId,
      batchNumber: batchNumber ?? this.batchNumber,
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
      submissionDate: submissionDate ?? this.submissionDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreinscriptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uuid == other.uuid &&
          uniqueCode == other.uniqueCode;

  @override
  int get hashCode => id.hashCode ^ uuid.hashCode ^ uniqueCode.hashCode;

  @override
  String toString() {
    return 'PreinscriptionModel{id: $id, uniqueCode: $uniqueCode, firstName: $firstName, lastName: $lastName, email: $email, status: $status}';
  }
}

class PreinscriptionConstants {
  static const List<String> genders = ['MASCULIN', 'FEMININ'];
  static const List<String> maritalStatuses = ['CELIBATAIRE', 'MARIE(E)', 'DIVORCE(E)', 'VEUF(VE)'];
  static const List<String> languages = ['FRANÇAIS', 'ANGLAIS', 'BILINGUE'];
  static const List<String> professionalSituations = ['SANS EMPLOI', 'SALARIE(E)', 'EN AUTO-EMPLOI', 'STAGIAIRE', 'RETRAITE(E)'];
  static const List<String> studyLevels = ['LICENCE', 'MASTER', 'DOCTORAT', 'DUT', 'BTS', 'MASTER_PRO', 'DEUST', 'AUTRE'];
  static const List<String> bacMentions = ['PASSABLE', 'ASSEZ_BIEN', 'BIEN', 'TRES_BIEN', 'EXCELLENT'];
  static const List<String> paymentMethods = ['ORANGE_MONEY', 'MTN_MONEY', 'BANK_TRANSFER', 'CASH', 'MOBILE_MONEY', 'CHEQUE', 'OTHER'];
  static const List<String> paymentStatuses = ['pending', 'paid', 'confirmed', 'refunded', 'partial'];
  static const List<String> statuses = ['pending', 'under_review', 'accepted', 'rejected', 'cancelled', 'deferred', 'waitlisted'];
  static const List<String> documentsStatuses = ['pending', 'submitted', 'verified', 'incomplete', 'rejected'];
  static const List<String> reviewPriorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
  static const List<String> parentRelationships = ['PERE', 'MERE', 'TUTEUR', 'AUTRE'];
  static const List<String> parentIncomeLevels = ['FAIBLE', 'MOYEN', 'ELEVE'];
  static const List<String> interviewTypes = ['PHYSICAL', 'ONLINE', 'PHONE'];
  static const List<String> interviewResults = ['PENDING', 'PASSED', 'FAILED', 'NO_SHOW'];
  static const List<String> contactPreferences = ['EMAIL', 'PHONE', 'SMS', 'WHATSAPP'];
  static const List<String> deviceTypes = ['DESKTOP', 'MOBILE', 'TABLET', 'OTHER'];
  
  // Séries du Baccalauréat Camerounais
  static const List<String> seriesBac = [
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
  
  static const int registrationFee = 10000; // FCFA
}
