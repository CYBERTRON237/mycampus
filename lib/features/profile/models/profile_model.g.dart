// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      basicInfo: BasicInfo.fromJson(json['basicInfo'] as Map<String, dynamic>),
      academicInfo:
          AcademicInfo.fromJson(json['academicInfo'] as Map<String, dynamic>),
      professionalInfo: ProfessionalInfo.fromJson(
          json['professionalInfo'] as Map<String, dynamic>),
      accountInfo:
          AccountInfo.fromJson(json['accountInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'basicInfo': instance.basicInfo,
      'academicInfo': instance.academicInfo,
      'professionalInfo': instance.professionalInfo,
      'accountInfo': instance.accountInfo,
    };

BasicInfo _$BasicInfoFromJson(Map<String, dynamic> json) => BasicInfo(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      gender: json['gender'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );

Map<String, dynamic> _$BasicInfoToJson(BasicInfo instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'middleName': instance.middleName,
      'phone': instance.phone,
      'dateOfBirth': instance.dateOfBirth,
      'placeOfBirth': instance.placeOfBirth,
      'gender': instance.gender,
      'profilePhotoUrl': instance.profilePhotoUrl,
    };

AcademicInfo _$AcademicInfoFromJson(Map<String, dynamic> json) => AcademicInfo(
      role: json['role'] as String,
      institutionName: json['institutionName'] as String?,
      departmentName: json['departmentName'] as String?,
      matricule: json['matricule'] as String?,
      studentId: json['studentId'] as String?,
      level: json['level'] as String?,
      academicYear: json['academicYear'] as String?,
      preinscriptionCode: json['preinscriptionCode'] as String?,
      preinscriptionStatus: json['preinscriptionStatus'] as String?,
      faculty: json['faculty'] as String?,
      studyLevel: json['studyLevel'] as String?,
      desiredProgram: json['desiredProgram'] as String?,
    );

Map<String, dynamic> _$AcademicInfoToJson(AcademicInfo instance) =>
    <String, dynamic>{
      'role': instance.role,
      'institutionName': instance.institutionName,
      'departmentName': instance.departmentName,
      'matricule': instance.matricule,
      'studentId': instance.studentId,
      'level': instance.level,
      'academicYear': instance.academicYear,
      'preinscriptionCode': instance.preinscriptionCode,
      'preinscriptionStatus': instance.preinscriptionStatus,
      'faculty': instance.faculty,
      'studyLevel': instance.studyLevel,
      'desiredProgram': instance.desiredProgram,
    };

ProfessionalInfo _$ProfessionalInfoFromJson(Map<String, dynamic> json) =>
    ProfessionalInfo(
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      emergencyContact: json['emergencyContact'] == null
          ? null
          : EmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfessionalInfoToJson(ProfessionalInfo instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'address': instance.address,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'emergencyContact': instance.emergencyContact,
    };

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      relationship: json['relationship'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'relationship': instance.relationship,
    };

AccountInfo _$AccountInfoFromJson(Map<String, dynamic> json) => AccountInfo(
      accountStatus: json['accountStatus'] as String,
      isVerified: json['isVerified'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      lastLoginAt: json['lastLoginAt'] as String?,
    );

Map<String, dynamic> _$AccountInfoToJson(AccountInfo instance) =>
    <String, dynamic>{
      'accountStatus': instance.accountStatus,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'lastLoginAt': instance.lastLoginAt,
    };

PreinscriptionDetail _$PreinscriptionDetailFromJson(
        Map<String, dynamic> json) =>
    PreinscriptionDetail(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String?,
      uniqueCode: json['unique_code'] as String,
      faculty: json['faculty'] as String,
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      gender: json['gender'] as String?,
      cniNumber: json['cni_number'] as String?,
      residenceAddress: json['residence_address'] as String?,
      maritalStatus: json['marital_status'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String,
      firstLanguage: json['first_language'] as String?,
      professionalSituation: json['professional_situation'] as String?,
      previousDiploma: json['previous_diploma'] as String?,
      previousInstitution: json['previous_institution'] as String?,
      studyLevel: json['study_level'] as String?,
      desiredProgram: json['desired_program'] as String?,
      status: json['status'] as String,
      submissionDate: json['submission_date'] as String?,
      admissionNumber: json['admission_number'] as String?,
      processedAt: json['processed_at'] as String?,
      isProcessed: PreinscriptionDetail._boolFromInt(json['is_processed']),
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
      parentRelationship: json['parent_relationship'] as String?,
      specialization: json['specialization'] as String?,
      scholarshipRequested:
          PreinscriptionDetail._boolFromInt(json['scholarship_requested']),
      interviewRequired:
          PreinscriptionDetail._boolFromInt(json['interview_required']),
      registrationCompleted:
          PreinscriptionDetail._boolFromInt(json['registration_completed']),
      marketingConsent:
          PreinscriptionDetail._boolFromInt(json['marketing_consent']),
      dataProcessingConsent:
          PreinscriptionDetail._boolFromInt(json['data_processing_consent']),
      newsletterSubscription:
          PreinscriptionDetail._boolFromInt(json['newsletter_subscription']),
      isBirthDateOnCertificate: PreinscriptionDetail._boolFromInt(
          json['is_birth_date_on_certificate']),
    );

Map<String, dynamic> _$PreinscriptionDetailToJson(
        PreinscriptionDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'unique_code': instance.uniqueCode,
      'faculty': instance.faculty,
      'last_name': instance.lastName,
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'date_of_birth': instance.dateOfBirth,
      'is_birth_date_on_certificate':
          PreinscriptionDetail._boolToInt(instance.isBirthDateOnCertificate),
      'place_of_birth': instance.placeOfBirth,
      'gender': instance.gender,
      'cni_number': instance.cniNumber,
      'residence_address': instance.residenceAddress,
      'marital_status': instance.maritalStatus,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'first_language': instance.firstLanguage,
      'professional_situation': instance.professionalSituation,
      'previous_diploma': instance.previousDiploma,
      'previous_institution': instance.previousInstitution,
      'study_level': instance.studyLevel,
      'desired_program': instance.desiredProgram,
      'status': instance.status,
      'submission_date': instance.submissionDate,
      'admission_number': instance.admissionNumber,
      'processed_at': instance.processedAt,
      'is_processed': PreinscriptionDetail._boolToInt(instance.isProcessed),
      'parent_name': instance.parentName,
      'parent_phone': instance.parentPhone,
      'parent_relationship': instance.parentRelationship,
      'specialization': instance.specialization,
      'scholarship_requested':
          PreinscriptionDetail._boolToInt(instance.scholarshipRequested),
      'interview_required':
          PreinscriptionDetail._boolToInt(instance.interviewRequired),
      'registration_completed':
          PreinscriptionDetail._boolToInt(instance.registrationCompleted),
      'marketing_consent':
          PreinscriptionDetail._boolToInt(instance.marketingConsent),
      'data_processing_consent':
          PreinscriptionDetail._boolToInt(instance.dataProcessingConsent),
      'newsletter_subscription':
          PreinscriptionDetail._boolToInt(instance.newsletterSubscription),
    };

AcademicProfile _$AcademicProfileFromJson(Map<String, dynamic> json) =>
    AcademicProfile(
      faculty: json['faculty'] as String?,
      studyLevel: json['studyLevel'] as String?,
      desiredProgram: json['desiredProgram'] as String?,
      previousDiploma: json['previousDiploma'] as String?,
      previousInstitution: json['previousInstitution'] as String?,
      institutionName: json['institutionName'] as String?,
      admissionNumber: json['admissionNumber'] as String?,
      registrationDate: json['registrationDate'] as String?,
      level: json['level'] as String?,
      academicYear: json['academicYear'] as String?,
      matricule: json['matricule'] as String?,
      studentId: json['studentId'] as String?,
      departmentName: json['departmentName'] as String?,
    );

Map<String, dynamic> _$AcademicProfileToJson(AcademicProfile instance) =>
    <String, dynamic>{
      'faculty': instance.faculty,
      'studyLevel': instance.studyLevel,
      'desiredProgram': instance.desiredProgram,
      'previousDiploma': instance.previousDiploma,
      'previousInstitution': instance.previousInstitution,
      'institutionName': instance.institutionName,
      'admissionNumber': instance.admissionNumber,
      'registrationDate': instance.registrationDate,
      'level': instance.level,
      'academicYear': instance.academicYear,
      'matricule': instance.matricule,
      'studentId': instance.studentId,
      'departmentName': instance.departmentName,
    };

ProfessionalProfile _$ProfessionalProfileFromJson(Map<String, dynamic> json) =>
    ProfessionalProfile(
      professionalSituation: json['professionalSituation'] as String?,
      firstLanguage: json['firstLanguage'] as String?,
      residenceAddress: json['residenceAddress'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      emergencyContactRelationship:
          json['emergencyContactRelationship'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ProfessionalProfileToJson(
        ProfessionalProfile instance) =>
    <String, dynamic>{
      'professionalSituation': instance.professionalSituation,
      'firstLanguage': instance.firstLanguage,
      'residenceAddress': instance.residenceAddress,
      'maritalStatus': instance.maritalStatus,
      'phoneNumber': instance.phoneNumber,
      'bio': instance.bio,
      'address': instance.address,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'emergencyContactRelationship': instance.emergencyContactRelationship,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'phone': instance.phone,
    };

ProfileStats _$ProfileStatsFromJson(Map<String, dynamic> json) => ProfileStats(
      accountInfo:
          AccountInfo.fromJson(json['accountInfo'] as Map<String, dynamic>),
      preinscription: json['preinscription'] == null
          ? null
          : PreinscriptionStats.fromJson(
              json['preinscription'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileStatsToJson(ProfileStats instance) =>
    <String, dynamic>{
      'accountInfo': instance.accountInfo,
      'preinscription': instance.preinscription,
    };

PreinscriptionStats _$PreinscriptionStatsFromJson(Map<String, dynamic> json) =>
    PreinscriptionStats(
      status: json['status'] as String,
      submissionDate: json['submissionDate'] as String,
      hasValidPreinscription: json['hasValidPreinscription'] as bool,
    );

Map<String, dynamic> _$PreinscriptionStatsToJson(
        PreinscriptionStats instance) =>
    <String, dynamic>{
      'status': instance.status,
      'submissionDate': instance.submissionDate,
      'hasValidPreinscription': instance.hasValidPreinscription,
    };

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    ProfileUpdateRequest(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      middleName: json['middleName'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      emergencyContactRelationship:
          json['emergencyContactRelationship'] as String?,
    );

Map<String, dynamic> _$ProfileUpdateRequestToJson(
        ProfileUpdateRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'middleName': instance.middleName,
      'phone': instance.phone,
      'bio': instance.bio,
      'address': instance.address,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'emergencyContactRelationship': instance.emergencyContactRelationship,
    };
