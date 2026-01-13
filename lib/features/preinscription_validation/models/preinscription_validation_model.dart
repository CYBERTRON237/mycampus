import 'dart:convert';

class PreinscriptionValidationModel {
  final int id;
  final String uuid;
  final String uniqueCode;
  final String faculty;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String dateOfBirth;
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
  final String paymentMethod;
  final String? paymentReference;
  final double? paymentAmount;
  final String paymentCurrency;
  final String? paymentDate;
  final String paymentStatus;
  final String? paymentProofPath;
  final bool scholarshipRequested;
  final String? scholarshipType;
  final double? financialAidAmount;
  final String status;
  final String documentsStatus;
  final String reviewPriority;
  final int? reviewedBy;
  final String? reviewDate;
  final String? reviewComments;
  final String? rejectionReason;
  final bool interviewRequired;
  final String? interviewDate;
  final String? interviewLocation;
  final String? interviewType;
  final String? interviewResult;
  final String? interviewNotes;
  final String? admissionNumber;
  final String? admissionDate;
  final String? registrationDeadline;
  final bool registrationCompleted;
  final int? studentId;
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
  final String submissionDate;
  final String lastUpdated;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? applicantEmail;
  final String? applicantPhone;
  final String relationship;
  final bool isProcessed;
  final String? processedAt;
  
  // Champs additionnels pour la validation
  final int? userId;
  final String? userEmail;
  final String? userRole;
  final bool hasUserAccount;
  final bool canBeValidated;

  PreinscriptionValidationModel({
    required this.id,
    required this.uuid,
    required this.uniqueCode,
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
    required this.paymentMethod,
    this.paymentReference,
    this.paymentAmount,
    required this.paymentCurrency,
    this.paymentDate,
    required this.paymentStatus,
    this.paymentProofPath,
    required this.scholarshipRequested,
    this.scholarshipType,
    this.financialAidAmount,
    required this.status,
    required this.documentsStatus,
    required this.reviewPriority,
    this.reviewedBy,
    this.reviewDate,
    this.reviewComments,
    this.rejectionReason,
    required this.interviewRequired,
    this.interviewDate,
    this.interviewLocation,
    this.interviewType,
    this.interviewResult,
    this.interviewNotes,
    this.admissionNumber,
    this.admissionDate,
    this.registrationDeadline,
    required this.registrationCompleted,
    this.studentId,
    this.batchNumber,
    this.contactPreference,
    required this.marketingConsent,
    required this.dataProcessingConsent,
    required this.newsletterSubscription,
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
    this.applicantEmail,
    this.applicantPhone,
    required this.relationship,
    required this.isProcessed,
    this.processedAt,
    this.userId,
    this.userEmail,
    this.userRole,
    this.hasUserAccount = false,
    this.canBeValidated = false,
  });

  factory PreinscriptionValidationModel.fromJson(Map<String, dynamic> json) {
    return PreinscriptionValidationModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      faculty: json['faculty'] ?? '',
      lastName: json['last_name'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      dateOfBirth: json['date_of_birth'] ?? '',
      isBirthDateOnCertificate: json['is_birth_date_on_certificate'] is bool ? json['is_birth_date_on_certificate'] : (json['is_birth_date_on_certificate']?.toString() == '1' || json['is_birth_date_on_certificate']?.toString().toLowerCase() == 'true'),
      placeOfBirth: json['place_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      cniNumber: json['cni_number'],
      residenceAddress: json['residence_address'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      firstLanguage: json['first_language'] ?? '',
      professionalSituation: json['professional_situation'] ?? '',
      previousDiploma: json['previous_diploma'],
      previousInstitution: json['previous_institution'],
      graduationYear: json['graduation_year'] is int ? json['graduation_year'] : (int.tryParse(json['graduation_year']?.toString() ?? '') ?? null),
      graduationMonth: json['graduation_month'],
      desiredProgram: json['desired_program'],
      studyLevel: json['study_level'],
      specialization: json['specialization'],
      seriesBac: json['series_bac'],
      bacYear: json['bac_year'] is int ? json['bac_year'] : (int.tryParse(json['bac_year']?.toString() ?? '') ?? null),
      bacCenter: json['bac_center'],
      bacMention: json['bac_mention'],
      gpaScore: json['gpa_score'] is double ? json['gpa_score'] : (double.tryParse(json['gpa_score']?.toString() ?? '') ?? null),
      rankInClass: json['rank_in_class'] is int ? json['rank_in_class'] : (int.tryParse(json['rank_in_class']?.toString() ?? '') ?? null),
      birthCertificatePath: json['birth_certificate_path'],
      cniPath: json['cni_path'],
      diplomaPath: json['diploma_path'],
      transcriptPath: json['transcript_path'],
      photoPath: json['photo_path'],
      recommendationLetterPath: json['recommendation_letter_path'],
      motivationLetterPath: json['motivation_letter_path'],
      medicalCertificatePath: json['medical_certificate_path'],
      otherDocumentsPath: json['other_documents_path'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      parentOccupation: json['parent_occupation'],
      parentAddress: json['parent_address'],
      parentRelationship: json['parent_relationship'],
      parentIncomeLevel: json['parent_income_level'],
      paymentMethod: json['payment_method'] ?? '',
      paymentReference: json['payment_reference'],
      paymentAmount: json['payment_amount'] is double ? json['payment_amount'] : (double.tryParse(json['payment_amount']?.toString() ?? '') ?? null),
      paymentCurrency: json['payment_currency'] ?? 'XAF',
      paymentDate: json['payment_date'],
      paymentStatus: json['payment_status'] ?? '',
      paymentProofPath: json['payment_proof_path'],
      scholarshipRequested: json['scholarship_requested'] is bool ? json['scholarship_requested'] : (json['scholarship_requested']?.toString() == '1' || json['scholarship_requested']?.toString().toLowerCase() == 'true'),
      scholarshipType: json['scholarship_type'],
      financialAidAmount: json['financial_aid_amount'] is double ? json['financial_aid_amount'] : (double.tryParse(json['financial_aid_amount']?.toString() ?? '') ?? null),
      status: json['status'] ?? '',
      documentsStatus: json['documents_status'] ?? '',
      reviewPriority: json['review_priority'] ?? '',
      reviewedBy: json['reviewed_by'],
      reviewDate: json['review_date'],
      reviewComments: json['review_comments'],
      rejectionReason: json['rejection_reason'],
      interviewRequired: json['interview_required'] is bool ? json['interview_required'] : (json['interview_required']?.toString() == '1' || json['interview_required']?.toString().toLowerCase() == 'true'),
      interviewDate: json['interview_date'],
      interviewLocation: json['interview_location'],
      interviewType: json['interview_type'],
      interviewResult: json['interview_result'],
      interviewNotes: json['interview_notes'],
      admissionNumber: json['admission_number'],
      admissionDate: json['admission_date'],
      registrationDeadline: json['registration_deadline'],
      registrationCompleted: json['registration_completed'] is bool ? json['registration_completed'] : (json['registration_completed']?.toString() == '1' || json['registration_completed']?.toString().toLowerCase() == 'true'),
      studentId: json['student_id'],
      batchNumber: json['batch_number'],
      contactPreference: json['contact_preference'],
      marketingConsent: json['marketing_consent'] is bool ? json['marketing_consent'] : (json['marketing_consent']?.toString() == '1' || json['marketing_consent']?.toString().toLowerCase() == 'true'),
      dataProcessingConsent: json['data_processing_consent'] is bool ? json['data_processing_consent'] : (json['data_processing_consent']?.toString() == '1' || json['data_processing_consent']?.toString().toLowerCase() == 'true'),
      newsletterSubscription: json['newsletter_subscription'] is bool ? json['newsletter_subscription'] : (json['newsletter_subscription']?.toString() == '1' || json['newsletter_subscription']?.toString().toLowerCase() == 'true'),
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      deviceType: json['device_type'],
      browserInfo: json['browser_info'],
      osInfo: json['os_info'],
      locationCountry: json['location_country'],
      locationCity: json['location_city'],
      notes: json['notes'],
      adminNotes: json['admin_notes'],
      internalComments: json['internal_comments'],
      specialNeeds: json['special_needs'],
      medicalConditions: json['medical_conditions'],
      submissionDate: json['submission_date'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      applicantEmail: json['applicant_email'],
      applicantPhone: json['applicant_phone'],
      relationship: json['relationship'] ?? 'self',
      isProcessed: json['is_processed'] is bool ? json['is_processed'] : (json['is_processed']?.toString() == '1' || json['is_processed']?.toString().toLowerCase() == 'true'),
      processedAt: json['processed_at'],
      userId: json['user_id'],
      userEmail: json['user_email'],
      userRole: json['user_role'],
      hasUserAccount: json['has_user_account'] is bool ? json['has_user_account'] : (json['has_user_account']?.toString() == '1' || json['has_user_account']?.toString().toLowerCase() == 'true'),
      canBeValidated: json['can_be_validated'] is bool ? json['can_be_validated'] : (json['can_be_validated']?.toString() == '1' || json['can_be_validated']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'unique_code': uniqueCode,
      'faculty': faculty,
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'date_of_birth': dateOfBirth,
      'is_birth_date_on_certificate': isBirthDateOnCertificate,
      'place_of_birth': placeOfBirth,
      'gender': gender,
      'cni_number': cniNumber,
      'residence_address': residenceAddress,
      'marital_status': maritalStatus,
      'phone_number': phoneNumber,
      'email': email,
      'first_language': firstLanguage,
      'professional_situation': professionalSituation,
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
      'birth_certificate_path': birthCertificatePath,
      'cni_path': cniPath,
      'diploma_path': diplomaPath,
      'transcript_path': transcriptPath,
      'photo_path': photoPath,
      'recommendation_letter_path': recommendationLetterPath,
      'motivation_letter_path': motivationLetterPath,
      'medical_certificate_path': medicalCertificatePath,
      'other_documents_path': otherDocumentsPath,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'parent_occupation': parentOccupation,
      'parent_address': parentAddress,
      'parent_relationship': parentRelationship,
      'parent_income_level': parentIncomeLevel,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_amount': paymentAmount,
      'payment_currency': paymentCurrency,
      'payment_date': paymentDate,
      'payment_status': paymentStatus,
      'payment_proof_path': paymentProofPath,
      'scholarship_requested': scholarshipRequested,
      'scholarship_type': scholarshipType,
      'financial_aid_amount': financialAidAmount,
      'status': status,
      'documents_status': documentsStatus,
      'review_priority': reviewPriority,
      'reviewed_by': reviewedBy,
      'review_date': reviewDate,
      'review_comments': reviewComments,
      'rejection_reason': rejectionReason,
      'interview_required': interviewRequired,
      'interview_date': interviewDate,
      'interview_location': interviewLocation,
      'interview_type': interviewType,
      'interview_result': interviewResult,
      'interview_notes': interviewNotes,
      'admission_number': admissionNumber,
      'admission_date': admissionDate,
      'registration_deadline': registrationDeadline,
      'registration_completed': registrationCompleted,
      'student_id': studentId,
      'batch_number': batchNumber,
      'contact_preference': contactPreference,
      'marketing_consent': marketingConsent,
      'data_processing_consent': dataProcessingConsent,
      'newsletter_subscription': newsletterSubscription,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'device_type': deviceType,
      'browser_info': browserInfo,
      'os_info': osInfo,
      'location_country': locationCountry,
      'location_city': locationCity,
      'notes': notes,
      'admin_notes': adminNotes,
      'internal_comments': internalComments,
      'special_needs': specialNeeds,
      'medical_conditions': medicalConditions,
      'submission_date': submissionDate,
      'last_updated': lastUpdated,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'applicant_email': applicantEmail,
      'applicant_phone': applicantPhone,
      'relationship': relationship,
      'is_processed': isProcessed,
      'processed_at': processedAt,
      'user_id': userId,
      'user_email': userEmail,
      'user_role': userRole,
      'has_user_account': hasUserAccount,
      'can_be_validated': canBeValidated,
    };
  }

  // Getters pour faciliter l'affichage
  String get fullName => '$firstName $lastName';
  
  String get displayName => middleName != null && middleName!.isNotEmpty 
      ? '$firstName $middleName $lastName' 
      : fullName;
      
  bool get isPending => status == 'pending';
  bool get isUnderReview => status == 'under_review';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';
  bool get isPaymentConfirmed => paymentStatus == 'confirmed';
  
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En cours de révision';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Rejetée';
      case 'cancelled':
        return 'Annulée';
      case 'deferred':
        return 'Reportée';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return status;
    }
  }
  
  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'refunded':
        return 'Remboursé';
      case 'partial':
        return 'Partiel';
      default:
        return paymentStatus;
    }
  }
  
  String get facultyDisplay {
    switch (faculty) {
      case 'UY1':
        return 'Université de Yaoundé 1';
      case 'FALSH':
        return 'Faculté des Arts, Lettres et Sciences Humaines';
      case 'FS':
        return 'Faculté des Sciences';
      case 'FSE':
        return 'Faculté des Sciences de l\'Éducation';
      case 'IUT':
        return 'Institut Universitaire de Technologie';
      case 'ENSPY':
        return 'École Nationale Supérieure Polytechnique de Yaoundé';
      default:
        return faculty;
    }
  }
}

// Modèle pour les statistiques de validation
class ValidationStatsModel {
  final Map<String, int> byStatus;
  final int pendingValidation;
  final int withUserAccount;
  final List<Map<String, dynamic>> byFaculty;

  ValidationStatsModel({
    required this.byStatus,
    required this.pendingValidation,
    required this.withUserAccount,
    required this.byFaculty,
  });

  factory ValidationStatsModel.fromJson(Map<String, dynamic> json) {
    return ValidationStatsModel(
      byStatus: Map<String, int>.from(json['byStatus'] ?? {}),
      pendingValidation: json['pendingValidation'] ?? 0,
      withUserAccount: json['withUserAccount'] ?? 0,
      byFaculty: List<Map<String, dynamic>>.from(json['byFaculty'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'byStatus': byStatus,
      'pendingValidation': pendingValidation,
      'withUserAccount': withUserAccount,
      'byFaculty': byFaculty,
    };
  }
}

// Modèle pour les actions de validation
class ValidationActionModel {
  final int preinscriptionId;
  final String action; // 'validate' ou 'reject'
  final String? comments;
  final String? rejectionReason;

  ValidationActionModel({
    required this.preinscriptionId,
    required this.action,
    this.comments,
    this.rejectionReason,
  });

  factory ValidationActionModel.fromJson(Map<String, dynamic> json) {
    return ValidationActionModel(
      preinscriptionId: json['preinscriptionId'] ?? 0,
      action: json['action'] ?? '',
      comments: json['comments'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preinscriptionId': preinscriptionId,
      'action': action,
      'comments': comments,
      'rejectionReason': rejectionReason,
    };
  }
}
