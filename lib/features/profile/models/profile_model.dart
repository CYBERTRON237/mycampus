import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final BasicInfo basicInfo;
  final AcademicInfo academicInfo;
  final ProfessionalInfo professionalInfo;
  final AccountInfo accountInfo;

  ProfileModel({
    required this.basicInfo,
    required this.academicInfo,
    required this.professionalInfo,
    required this.accountInfo,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  // Helper getters for common use cases
  bool get isStudent => academicInfo.role == 'student';
  bool get hasValidPreinscription => 
      academicInfo.preinscriptionStatus != null && 
      ['accepted', 'confirmed'].contains(academicInfo.preinscriptionStatus);
  bool get isInvite => academicInfo.role == 'invite';
  String get fullName => '${basicInfo.firstName} ${basicInfo.lastName}'.trim();
  String get displayName => basicInfo.middleName != null && basicInfo.middleName!.isNotEmpty 
      ? '$fullName ${basicInfo.middleName}' 
      : fullName;
}

@JsonSerializable()
class BasicInfo {
  final int id;
  final String uuid;
  final String email;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phone;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? gender;
  final String? profilePhotoUrl;

  BasicInfo({
    required this.id,
    required this.uuid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    this.dateOfBirth,
    this.placeOfBirth,
    this.gender,
    this.profilePhotoUrl,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) => _$BasicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BasicInfoToJson(this);

  String get fullName => middleName != null && middleName!.isNotEmpty 
      ? '$firstName $middleName $lastName' 
      : '$firstName $lastName';
}

@JsonSerializable()
class AcademicInfo {
  final String role;
  final String? institutionName;
  final String? departmentName;
  final String? matricule;
  final String? studentId;
  final String? level;
  final String? academicYear;
  final String? preinscriptionCode;
  final String? preinscriptionStatus;
  final String? faculty;
  final String? studyLevel;
  final String? desiredProgram;

  AcademicInfo({
    required this.role,
    this.institutionName,
    this.departmentName,
    this.matricule,
    this.studentId,
    this.level,
    this.academicYear,
    this.preinscriptionCode,
    this.preinscriptionStatus,
    this.faculty,
    this.studyLevel,
    this.desiredProgram,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => _$AcademicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AcademicInfoToJson(this);

  bool get hasPreinscription => preinscriptionCode != null;
  bool get isPreinscriptionPending => preinscriptionStatus == 'pending';
  bool get isPreinscriptionAccepted => ['accepted', 'confirmed'].contains(preinscriptionStatus);
  bool get isPreinscriptionRejected => preinscriptionStatus == 'rejected';
}

@JsonSerializable()
class ProfessionalInfo {
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  final String? country;
  final String? postalCode;
  final EmergencyContact? emergencyContact;

  ProfessionalInfo({
    this.bio,
    this.address,
    this.city,
    this.region,
    this.country,
    this.postalCode,
    this.emergencyContact,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) => _$ProfessionalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ProfessionalInfoToJson(this);

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (region != null && region!.isNotEmpty) parts.add(region!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }
}

@JsonSerializable()
class EmergencyContact {
  final String? name;
  final String? phone;
  final String? relationship;

  EmergencyContact({
    this.name,
    this.phone,
    this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}

@JsonSerializable()
class AccountInfo {
  final String accountStatus;
  final bool isVerified;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? lastLoginAt;

  AccountInfo({
    required this.accountStatus,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) => _$AccountInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountInfoToJson(this);

  bool get isAccountActive => accountStatus == 'active' && isActive;
  String get statusDisplay {
    switch (accountStatus) {
      case 'active':
        return 'Actif';
      case 'pending_verification':
        return 'En attente de vérification';
      case 'suspended':
        return 'Suspendu';
      case 'banned':
        return 'Banni';
      case 'graduated':
        return 'Diplômé';
      case 'withdrawn':
        return 'Retiré';
      default:
        return accountStatus;
    }
  }
}

// Preinscription model for detailed preinscription data
@JsonSerializable()
class PreinscriptionDetail {
  // Helper methods for converting tinyint(1) to bool
  static bool? _boolFromInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value == 1;
    if (value is bool) return value;
    if (value is String) {
      final val = int.tryParse(value);
      return val != null ? val == 1 : null;
    }
    return null;
  }
  
  static int? _boolToInt(bool? value) {
    return value == null ? null : (value ? 1 : 0);
  }

  final int id;
  final String? uuid;
  @JsonKey(name: 'unique_code')
  final String uniqueCode;
  final String faculty;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'is_birth_date_on_certificate', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? isBirthDateOnCertificate;
  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;
  final String? gender;
  @JsonKey(name: 'cni_number')
  final String? cniNumber;
  @JsonKey(name: 'residence_address')
  final String? residenceAddress;
  @JsonKey(name: 'marital_status')
  final String? maritalStatus;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String email;
  @JsonKey(name: 'first_language')
  final String? firstLanguage;
  @JsonKey(name: 'professional_situation')
  final String? professionalSituation;
  @JsonKey(name: 'previous_diploma')
  final String? previousDiploma;
  @JsonKey(name: 'previous_institution')
  final String? previousInstitution;
  @JsonKey(name: 'study_level')
  final String? studyLevel;
  @JsonKey(name: 'desired_program')
  final String? desiredProgram;
  final String status;
  @JsonKey(name: 'submission_date')
  final String? submissionDate;
  @JsonKey(name: 'admission_number')
  final String? admissionNumber;
  @JsonKey(name: 'processed_at')
  final String? processedAt;
  @JsonKey(name: 'is_processed', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? isProcessed;
  @JsonKey(name: 'parent_name')
  final String? parentName;
  @JsonKey(name: 'parent_phone')
  final String? parentPhone;
  @JsonKey(name: 'parent_relationship')
  final String? parentRelationship;
  final String? specialization;
  @JsonKey(name: 'scholarship_requested', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? scholarshipRequested;
  @JsonKey(name: 'interview_required', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? interviewRequired;
  @JsonKey(name: 'registration_completed', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? registrationCompleted;
  @JsonKey(name: 'marketing_consent', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? marketingConsent;
  @JsonKey(name: 'data_processing_consent', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? dataProcessingConsent;
  @JsonKey(name: 'newsletter_subscription', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool? newsletterSubscription;

  PreinscriptionDetail({
    required this.id,
    this.uuid,
    required this.uniqueCode,
    required this.faculty,
    required this.lastName,
    required this.firstName,
    this.middleName,
    this.dateOfBirth,
    this.placeOfBirth,
    this.gender,
    this.cniNumber,
    this.residenceAddress,
    this.maritalStatus,
    this.phoneNumber,
    required this.email,
    this.firstLanguage,
    this.professionalSituation,
    this.previousDiploma,
    this.previousInstitution,
    this.studyLevel,
    this.desiredProgram,
    required this.status,
    this.submissionDate,
    this.admissionNumber,
    this.processedAt,
    this.isProcessed,
    this.parentName,
    this.parentPhone,
    this.parentRelationship,
    this.specialization,
    this.scholarshipRequested,
    this.interviewRequired,
    this.registrationCompleted,
    this.marketingConsent,
    this.dataProcessingConsent,
    this.newsletterSubscription,
    this.isBirthDateOnCertificate,
  });

  factory PreinscriptionDetail.fromJson(Map<String, dynamic> json) => _$PreinscriptionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PreinscriptionDetailToJson(this);

  bool get isPending => status == 'pending';
  bool get isAccepted => ['accepted', 'confirmed'].contains(status);
  bool get isRejected => status == 'rejected';
  bool get isUnderReview => status == 'under_review';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En cours de révision';
      case 'accepted':
        return 'Acceptée';
      case 'confirmed':
        return 'Confirmée';
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

  String get fullName => middleName != null && middleName!.isNotEmpty 
      ? '$firstName $middleName $lastName' 
      : '$firstName $lastName';
}

// Academic profile model
@JsonSerializable()
class AcademicProfile {
  final String? faculty;
  final String? studyLevel;
  final String? desiredProgram;
  final String? previousDiploma;
  final String? previousInstitution;
  final String? institutionName;
  final String? admissionNumber;
  final String? registrationDate;
  final String? level;
  final String? academicYear;
  final String? matricule;
  final String? studentId;
  final String? departmentName;

  AcademicProfile({
    this.faculty,
    this.studyLevel,
    this.desiredProgram,
    this.previousDiploma,
    this.previousInstitution,
    this.institutionName,
    this.admissionNumber,
    this.registrationDate,
    this.level,
    this.academicYear,
    this.matricule,
    this.studentId,
    this.departmentName,
  });

  factory AcademicProfile.fromPreinscription(PreinscriptionDetail preinscription) {
    return AcademicProfile(
      faculty: preinscription.faculty,
      studyLevel: preinscription.studyLevel,
      desiredProgram: preinscription.desiredProgram,
      previousDiploma: preinscription.previousDiploma,
      previousInstitution: preinscription.previousInstitution,
      admissionNumber: preinscription.admissionNumber,
      registrationDate: null, // admission_date field doesn't exist in PreinscriptionDetail
      institutionName: 'Université de Yaoundé I', // Default value
      level: preinscription.studyLevel,
      academicYear: '2024-2025', // Default value
      studentId: null, // student_id field doesn't exist in PreinscriptionDetail
    );
  }

  factory AcademicProfile.fromJson(Map<String, dynamic> json) => _$AcademicProfileFromJson(json);
  Map<String, dynamic> toJson() => _$AcademicProfileToJson(this);
}

// Professional profile model
@JsonSerializable()
class ProfessionalProfile {
  final String? professionalSituation;
  final String? firstLanguage;
  final String? residenceAddress;
  final String? maritalStatus;
  final String? phoneNumber;
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  final String? country;
  final String? postalCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String? profilePhotoUrl;
  final String? phone;

  ProfessionalProfile({
    this.professionalSituation,
    this.firstLanguage,
    this.residenceAddress,
    this.maritalStatus,
    this.phoneNumber,
    this.bio,
    this.address,
    this.city,
    this.region,
    this.country,
    this.postalCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.profilePhotoUrl,
    this.phone,
  });

  factory ProfessionalProfile.fromPreinscription(PreinscriptionDetail preinscription) {
    return ProfessionalProfile(
      professionalSituation: preinscription.professionalSituation,
      firstLanguage: preinscription.firstLanguage,
      residenceAddress: preinscription.residenceAddress,
      maritalStatus: preinscription.maritalStatus,
      phoneNumber: preinscription.phoneNumber,
      bio: 'Étudiant en ${preinscription.studyLevel ?? "cycle supérieur"}', // Generated bio
      address: preinscription.residenceAddress,
      emergencyContactName: preinscription.parentName,
      emergencyContactPhone: preinscription.parentPhone,
      emergencyContactRelationship: preinscription.parentRelationship,
      phone: preinscription.phoneNumber,
    );
  }

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) => _$ProfessionalProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfessionalProfileToJson(this);

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (region != null && region!.isNotEmpty) parts.add(region!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }

  String get emergencyContactInfo {
    if (emergencyContactName == null) return '';
    final parts = <String>[emergencyContactName!];
    if (emergencyContactPhone != null) parts.add(emergencyContactPhone!);
    if (emergencyContactRelationship != null) parts.add('(${emergencyContactRelationship})');
    return parts.join(' ');
  }
}

// Profile stats model
@JsonSerializable()
class ProfileStats {
  final AccountInfo accountInfo;
  final PreinscriptionStats? preinscription;

  ProfileStats({
    required this.accountInfo,
    this.preinscription,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) => _$ProfileStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileStatsToJson(this);
}

@JsonSerializable()
class PreinscriptionStats {
  final String status;
  final String submissionDate;
  final bool hasValidPreinscription;

  PreinscriptionStats({
    required this.status,
    required this.submissionDate,
    required this.hasValidPreinscription,
  });

  factory PreinscriptionStats.fromJson(Map<String, dynamic> json) => _$PreinscriptionStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PreinscriptionStatsToJson(this);
}

// Profile update model
@JsonSerializable()
class ProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  final String? country;
  final String? postalCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;

  ProfileUpdateRequest({
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.bio,
    this.address,
    this.city,
    this.region,
    this.country,
    this.postalCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
  });

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) => _$ProfileUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);

  bool get hasChanges {
    return firstName != null || lastName != null || middleName != null ||
           phone != null || bio != null || address != null || city != null ||
           region != null || country != null || postalCode != null ||
           emergencyContactName != null || emergencyContactPhone != null ||
           emergencyContactRelationship != null;
  }
}
