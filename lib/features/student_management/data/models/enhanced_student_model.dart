enum StudentStatus {
  enrolled('enrolled', 'Inscrit'),
  graduated('graduated', 'Diplômé'),
  suspended('suspended', 'Suspendu'),
  withdrawn('withdrawn', 'Retiré'),
  deferred('deferred', 'Ajourné'),
  onLeave('on_leave', 'En congé'),
  expelled('expelled', 'Exclu'),
  deceased('deceased', 'Décédé');

  const StudentStatus(this.value, this.label);
  final String value;
  final String label;

  static StudentStatus fromString(String value) {
    return StudentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => StudentStatus.enrolled,
    );
  }
}

enum AcademicLevel {
  licence1('licence1', 'Licence 1'),
  licence2('licence2', 'Licence 2'),
  licence3('licence3', 'Licence 3'),
  master1('master1', 'Master 1'),
  master2('master2', 'Master 2'),
  doctorat1('doctorat1', 'Doctorat 1'),
  doctorat2('doctorat2', 'Doctorat 2'),
  doctorat3('doctorat3', 'Doctorat 3'),
  ingenieur1('ingenieur1', 'Ingénieur 1'),
  ingenieur2('ingenieur2', 'Ingénieur 2'),
  ingenieur3('ingenieur3', 'Ingénieur 3'),
  ingenieur4('ingenieur4', 'Ingénieur 4'),
  ingenieur5('ingenieur5', 'Ingénieur 5'),
  bts1('bts1', 'BTS 1'),
  bts2('bts2', 'BTS 2');

  const AcademicLevel(this.value, this.label);
  final String value;
  final String label;

  static AcademicLevel fromString(String value) {
    if (value.isEmpty) return AcademicLevel.licence1;
    return AcademicLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => AcademicLevel.licence1,
    );
  }

  String get degreeType {
    switch (value) {
      case 'licence1':
      case 'licence2':
      case 'licence3':
        return 'Licence';
      case 'master1':
      case 'master2':
        return 'Master';
      case 'doctorat1':
      case 'doctorat2':
      case 'doctorat3':
        return 'Doctorat';
      case 'ingenieur1':
      case 'ingenieur2':
      case 'ingenieur3':
      case 'ingenieur4':
      case 'ingenieur5':
        return 'Ingénieur';
      case 'bts1':
      case 'bts2':
        return 'BTS';
      default:
        return 'Autre';
    }
  }
}

enum AdmissionType {
  regular('regular', 'Admission régulière'),
  transfer('transfer', 'Transfert'),
  equivalence('equivalence', 'Équivalence'),
  continuing('continuing', 'Formation continue'),
  exchange('exchange', 'Programme d\'échange'),
  special('special', 'Admission spéciale');

  const AdmissionType(this.value, this.label);
  final String value;
  final String label;

  static AdmissionType fromString(String value) {
    return AdmissionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AdmissionType.regular,
    );
  }
}

enum ScholarshipStatus {
  none('none', 'Aucune'),
  partial('partial', 'Partielle'),
  full('full', 'Complète'),
  merit('merit', 'Au mérite'),
  need('need', 'Besoins'),
  athletic('athletic', 'Sportive'),
  research('research', 'Recherche');

  const ScholarshipStatus(this.value, this.label);
  final String value;
  final String label;

  static ScholarshipStatus fromString(String value) {
    return ScholarshipStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ScholarshipStatus.none,
    );
  }
}

class EnhancedStudentModel {
  final int id;
  final String uuid;
  final String matricule;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String? phone;
  final String? alternativePhone;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String gender;
  final String nationality;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final String? bio;
  final String address;
  final String city;
  final String region;
  final String country;
  final String? postalCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String? emergencyContactEmail;
  final StudentStatus status;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? deletedAt;

  // Academic Information
  final AcademicLevel currentLevel;
  final AdmissionType admissionType;
  final DateTime enrollmentDate;
  final DateTime? expectedGraduationDate;
  final DateTime? actualGraduationDate;
  final double? gpa;
  final int totalCreditsEarned;
  final int? totalCreditsRequired;
  final int? classRank;
  final String? honors;
  final String? disciplinaryRecords;
  final String? graduationThesisTitle;
  final String? thesisSupervisor;
  final DateTime? thesisDefenseDate;

  // Scholarship Information
  final ScholarshipStatus scholarshipStatus;
  final String? scholarshipDetails;
  final double? scholarshipAmount;

  // Institution Information
  final int institutionId;
  final int? facultyId;
  final int? departmentId;
  final int? programId;
  final int? academicYearId;
  final String? institutionName;
  final String? facultyName;
  final String? departmentName;
  final String? programName;
  final String? academicYear;

  // Additional Information
  final String? bloodGroup;
  final String? medicalConditions;
  final String? allergies;
  final String? dietaryRestrictions;
  final String? physicalDisabilities;
  final bool? needsSpecialAccommodation;
  final String? languages;
  final String? hobbies;
  final String? skills;
  final String? previousEducation;
  final String? workExperience;
  final String? references;

  EnhancedStudentModel({
    required this.id,
    required this.uuid,
    required this.matricule,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    this.phone,
    this.alternativePhone,
    this.dateOfBirth,
    this.placeOfBirth,
    required this.gender,
    required this.nationality,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.bio,
    required this.address,
    required this.city,
    required this.region,
    required this.country,
    this.postalCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.emergencyContactEmail,
    required this.status,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.deletedAt,
    required this.currentLevel,
    required this.admissionType,
    required this.enrollmentDate,
    this.expectedGraduationDate,
    this.actualGraduationDate,
    this.gpa,
    required this.totalCreditsEarned,
    this.totalCreditsRequired,
    this.classRank,
    this.honors,
    this.disciplinaryRecords,
    this.graduationThesisTitle,
    this.thesisSupervisor,
    this.thesisDefenseDate,
    required this.scholarshipStatus,
    this.scholarshipDetails,
    this.scholarshipAmount,
    required this.institutionId,
    this.facultyId,
    this.departmentId,
    this.programId,
    this.academicYearId,
    this.institutionName,
    this.facultyName,
    this.departmentName,
    this.programName,
    this.academicYear,
    this.bloodGroup,
    this.medicalConditions,
    this.allergies,
    this.dietaryRestrictions,
    this.physicalDisabilities,
    this.needsSpecialAccommodation,
    this.languages,
    this.hobbies,
    this.skills,
    this.previousEducation,
    this.workExperience,
    this.references,
  });

  factory EnhancedStudentModel.fromJson(Map<String, dynamic> json) {
    return EnhancedStudentModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      matricule: json['matricule'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      email: json['email'] ?? '',
      phone: json['phone'],
      alternativePhone: json['alternative_phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      placeOfBirth: json['place_of_birth'],
      gender: json['gender'] ?? 'other',
      nationality: json['nationality'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      coverPhotoUrl: json['cover_photo_url'],
      bio: json['bio'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelationship: json['emergency_contact_relationship'],
      emergencyContactEmail: json['emergency_contact_email'],
      status: json['account_status'] == 'active' ? StudentStatus.enrolled : StudentStatus.fromString(json['status'] ?? 'enrolled'),
      isActive: (json['is_active'] ?? 0) == 1,
      isVerified: (json['is_verified'] ?? 0) == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      currentLevel: AcademicLevel.fromString(json['level'] ?? 'licence1'),
      admissionType: AdmissionType.fromString(json['admission_type'] ?? 'regular'),
      enrollmentDate: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      expectedGraduationDate: json['expected_graduation_date'] != null
          ? DateTime.parse(json['expected_graduation_date'])
          : null,
      actualGraduationDate: json['actual_graduation_date'] != null
          ? DateTime.parse(json['actual_graduation_date'])
          : null,
      gpa: json['gpa']?.toDouble(),
      totalCreditsEarned: json['total_credits_earned'] ?? 0,
      totalCreditsRequired: json['total_credits_required'],
      classRank: json['class_rank'],
      honors: json['honors'],
      disciplinaryRecords: json['disciplinary_records'],
      graduationThesisTitle: json['graduation_thesis_title'],
      thesisSupervisor: json['thesis_supervisor'],
      thesisDefenseDate: json['thesis_defense_date'] != null
          ? DateTime.parse(json['thesis_defense_date'])
          : null,
      scholarshipStatus: ScholarshipStatus.fromString(json['scholarship_status'] ?? 'none'),
      scholarshipDetails: json['scholarship_details'],
      scholarshipAmount: json['scholarship_amount']?.toDouble(),
      institutionId: json['institution_id'] ?? 0,
      facultyId: json['faculty_id'],
      departmentId: json['department_id'],
      programId: json['program_id'],
      academicYearId: json['academic_year_id'],
      institutionName: json['institution_name'],
      facultyName: json['faculty_name'],
      departmentName: json['department_name'],
      programName: json['program_name'],
      academicYear: json['academic_year'],
      bloodGroup: json['blood_group'],
      medicalConditions: json['medical_conditions'],
      allergies: json['allergies'],
      dietaryRestrictions: json['dietary_restrictions'],
      physicalDisabilities: json['physical_disabilities'],
      needsSpecialAccommodation: json['needs_special_accommodation'] == 1,
      languages: json['languages'],
      hobbies: json['hobbies'],
      skills: json['skills'],
      previousEducation: json['previous_education'],
      workExperience: json['work_experience'],
      references: json['references'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'matricule': matricule,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'email': email,
      'phone': phone,
      'alternative_phone': alternativePhone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'place_of_birth': placeOfBirth,
      'gender': gender,
      'nationality': nationality,
      'profile_photo_url': profilePhotoUrl,
      'cover_photo_url': coverPhotoUrl,
      'bio': bio,
      'address': address,
      'city': city,
      'region': region,
      'country': country,
      'postal_code': postalCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relationship': emergencyContactRelationship,
      'emergency_contact_email': emergencyContactEmail,
      'status': status.value,
      'is_active': isActive ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'current_level': currentLevel.value,
      'admission_type': admissionType.value,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'expected_graduation_date': expectedGraduationDate?.toIso8601String(),
      'actual_graduation_date': actualGraduationDate?.toIso8601String(),
      'gpa': gpa,
      'total_credits_earned': totalCreditsEarned,
      'total_credits_required': totalCreditsRequired,
      'class_rank': classRank,
      'honors': honors,
      'disciplinary_records': disciplinaryRecords,
      'graduation_thesis_title': graduationThesisTitle,
      'thesis_supervisor': thesisSupervisor,
      'thesis_defense_date': thesisDefenseDate?.toIso8601String(),
      'scholarship_status': scholarshipStatus.value,
      'scholarship_details': scholarshipDetails,
      'scholarship_amount': scholarshipAmount,
      'institution_id': institutionId,
      'faculty_id': facultyId,
      'department_id': departmentId,
      'program_id': programId,
      'academic_year_id': academicYearId,
      'institution_name': institutionName,
      'faculty_name': facultyName,
      'department_name': departmentName,
      'program_name': programName,
      'academic_year': academicYear,
      'blood_group': bloodGroup,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'dietary_restrictions': dietaryRestrictions,
      'physical_disabilities': physicalDisabilities,
      'needs_special_accommodation': needsSpecialAccommodation == true ? 1 : 0,
      'languages': languages,
      'hobbies': hobbies,
      'skills': skills,
      'previous_education': previousEducation,
      'work_experience': workExperience,
      'references': references,
    };
  }

  EnhancedStudentModel copyWith({
    int? id,
    String? uuid,
    String? matricule,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phone,
    String? alternativePhone,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? gender,
    String? nationality,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    String? bio,
    String? address,
    String? city,
    String? region,
    String? country,
    String? postalCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
    String? emergencyContactEmail,
    StudentStatus? status,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? deletedAt,
    AcademicLevel? currentLevel,
    AdmissionType? admissionType,
    DateTime? enrollmentDate,
    DateTime? expectedGraduationDate,
    DateTime? actualGraduationDate,
    double? gpa,
    int? totalCreditsEarned,
    int? totalCreditsRequired,
    int? classRank,
    String? honors,
    String? disciplinaryRecords,
    String? graduationThesisTitle,
    String? thesisSupervisor,
    DateTime? thesisDefenseDate,
    ScholarshipStatus? scholarshipStatus,
    String? scholarshipDetails,
    double? scholarshipAmount,
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    int? academicYearId,
    String? institutionName,
    String? facultyName,
    String? departmentName,
    String? programName,
    String? academicYear,
    String? bloodGroup,
    String? medicalConditions,
    String? allergies,
    String? dietaryRestrictions,
    String? physicalDisabilities,
    bool? needsSpecialAccommodation,
    String? languages,
    String? hobbies,
    String? skills,
    String? previousEducation,
    String? workExperience,
    String? references,
  }) {
    return EnhancedStudentModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      matricule: matricule ?? this.matricule,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelationship: emergencyContactRelationship ?? this.emergencyContactRelationship,
      emergencyContactEmail: emergencyContactEmail ?? this.emergencyContactEmail,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deletedAt: deletedAt ?? this.deletedAt,
      currentLevel: currentLevel ?? this.currentLevel,
      admissionType: admissionType ?? this.admissionType,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      expectedGraduationDate: expectedGraduationDate ?? this.expectedGraduationDate,
      actualGraduationDate: actualGraduationDate ?? this.actualGraduationDate,
      gpa: gpa ?? this.gpa,
      totalCreditsEarned: totalCreditsEarned ?? this.totalCreditsEarned,
      totalCreditsRequired: totalCreditsRequired ?? this.totalCreditsRequired,
      classRank: classRank ?? this.classRank,
      honors: honors ?? this.honors,
      disciplinaryRecords: disciplinaryRecords ?? this.disciplinaryRecords,
      graduationThesisTitle: graduationThesisTitle ?? this.graduationThesisTitle,
      thesisSupervisor: thesisSupervisor ?? this.thesisSupervisor,
      thesisDefenseDate: thesisDefenseDate ?? this.thesisDefenseDate,
      scholarshipStatus: scholarshipStatus ?? this.scholarshipStatus,
      scholarshipDetails: scholarshipDetails ?? this.scholarshipDetails,
      scholarshipAmount: scholarshipAmount ?? this.scholarshipAmount,
      institutionId: institutionId ?? this.institutionId,
      facultyId: facultyId ?? this.facultyId,
      departmentId: departmentId ?? this.departmentId,
      programId: programId ?? this.programId,
      academicYearId: academicYearId ?? this.academicYearId,
      institutionName: institutionName ?? this.institutionName,
      facultyName: facultyName ?? this.facultyName,
      departmentName: departmentName ?? this.departmentName,
      programName: programName ?? this.programName,
      academicYear: academicYear ?? this.academicYear,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      physicalDisabilities: physicalDisabilities ?? this.physicalDisabilities,
      needsSpecialAccommodation: needsSpecialAccommodation ?? this.needsSpecialAccommodation,
      languages: languages ?? this.languages,
      hobbies: hobbies ?? this.hobbies,
      skills: skills ?? this.skills,
      previousEducation: previousEducation ?? this.previousEducation,
      workExperience: workExperience ?? this.workExperience,
      references: references ?? this.references,
    );
  }

  // Getters
  String get fullName => middleName != null && middleName!.isNotEmpty
      ? '$firstName $middleName $lastName'
      : '$firstName $lastName';

  String get displayName => '$lastName $firstName';

  String get statusLabel => status.label;

  String get levelLabel => currentLevel.label;

  String get admissionTypeLabel => admissionType.label;

  String get scholarshipStatusLabel => scholarshipStatus.label;

  String get gpaDisplay {
    if (gpa == null) return 'N/A';
    return gpa!.toStringAsFixed(2);
  }

  String get classRankDisplay {
    if (classRank == null) return 'N/A';
    return '$classRank${_getOrdinalSuffix(classRank!)}';
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  double get progressPercentage {
    if (totalCreditsRequired == null || totalCreditsRequired == 0) return 0.0;
    return (totalCreditsEarned / totalCreditsRequired!) * 100;
  }

  bool get isGraduated => status == StudentStatus.graduated;

  bool get isActiveStudent => isActive && status == StudentStatus.enrolled;

  bool get hasScholarship => scholarshipStatus != ScholarshipStatus.none;

  bool get hasThesis => graduationThesisTitle != null && graduationThesisTitle!.isNotEmpty;

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (region.isNotEmpty) parts.add(region);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  String get institutionDisplay {
    if (institutionName != null) return institutionName!;
    return 'Institution $institutionId';
  }

  String get programDisplay {
    if (programName != null) return programName!;
    if (departmentName != null) return departmentName!;
    return 'Programme';
  }

  // Static methods for creating from simple models
  static EnhancedStudentModel fromSimpleStudent(Map<String, dynamic> simpleStudent) {
    return EnhancedStudentModel(
      id: simpleStudent['id'] ?? 0,
      uuid: simpleStudent['uuid'] ?? '',
      matricule: simpleStudent['matricule'] ?? '',
      firstName: simpleStudent['first_name'] ?? '',
      lastName: simpleStudent['last_name'] ?? '',
      email: simpleStudent['email'] ?? '',
      phone: simpleStudent['phone'],
      gender: simpleStudent['gender'] ?? 'other',
      nationality: 'Camerounaise',
      address: simpleStudent['address'] ?? '',
      city: simpleStudent['city'] ?? '',
      region: simpleStudent['region'] ?? '',
      country: simpleStudent['country'] ?? 'Cameroun',
      status: StudentStatus.fromString(simpleStudent['status'] ?? 'enrolled'),
      isActive: (simpleStudent['is_active'] ?? 0) == 1,
      isVerified: (simpleStudent['is_verified'] ?? 0) == 1,
      createdAt: DateTime.parse(simpleStudent['created_at'] ?? DateTime.now().toIso8601String()),
      currentLevel: AcademicLevel.fromString(simpleStudent['level'] ?? 'licence1'),
      admissionType: AdmissionType.regular,
      enrollmentDate: DateTime.parse(simpleStudent['created_at'] ?? DateTime.now().toIso8601String()),
      totalCreditsEarned: 0,
      scholarshipStatus: ScholarshipStatus.none,
      institutionId: simpleStudent['institution_id'] ?? 0,
      institutionName: simpleStudent['institution_name'],
      facultyName: simpleStudent['faculty_name'],
      departmentName: simpleStudent['department_name'],
      programName: simpleStudent['program_name'],
      academicYear: simpleStudent['academic_year'],
    );
  }
}

// Filters for student search
class StudentFilters {
  final String? search;
  final StudentStatus? status;
  final AcademicLevel? level;
  final AdmissionType? admissionType;
  final ScholarshipStatus? scholarshipStatus;
  final int? institutionId;
  final int? facultyId;
  final int? departmentId;
  final int? programId;
  final String? institution;
  final String? faculty;
  final String? department;
  final String? program;
  final String? region;
  final String? city;
  final String? country;
  final String? gender;
  final DateTime? dateOfBirthFrom;
  final DateTime? dateOfBirthTo;
  final DateTime? enrollmentDateFrom;
  final DateTime? enrollmentDateTo;
  final double? gpaMin;
  final double? gpaMax;
  final bool? hasScholarship;
  final bool? needsSpecialAccommodation;
  final bool? isActive;
  final bool? isVerified;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const StudentFilters({
    this.search,
    this.status,
    this.level,
    this.admissionType,
    this.scholarshipStatus,
    this.institutionId,
    this.facultyId,
    this.departmentId,
    this.programId,
    this.institution,
    this.faculty,
    this.department,
    this.program,
    this.region,
    this.city,
    this.country,
    this.gender,
    this.dateOfBirthFrom,
    this.dateOfBirthTo,
    this.enrollmentDateFrom,
    this.enrollmentDateTo,
    this.gpaMin,
    this.gpaMax,
    this.hasScholarship,
    this.needsSpecialAccommodation,
    this.isActive,
    this.isVerified,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'status': status?.value,
      'level': level?.value,
      'admission_type': admissionType?.value,
      'scholarship_status': scholarshipStatus?.value,
      'institution_id': institutionId,
      'faculty_id': facultyId,
      'department_id': departmentId,
      'program_id': programId,
      'institution': institution,
      'faculty': faculty,
      'department': department,
      'program': program,
      'region': region,
      'city': city,
      'country': country,
      'gender': gender,
      'date_of_birth_from': dateOfBirthFrom?.toIso8601String(),
      'date_of_birth_to': dateOfBirthTo?.toIso8601String(),
      'enrollment_date_from': enrollmentDateFrom?.toIso8601String(),
      'enrollment_date_to': enrollmentDateTo?.toIso8601String(),
      'gpa_min': gpaMin,
      'gpa_max': gpaMax,
      'has_scholarship': hasScholarship == true ? 1 : (hasScholarship == false ? 0 : null),
      'needs_special_accommodation': needsSpecialAccommodation == true ? 1 : (needsSpecialAccommodation == false ? 0 : null),
      'is_active': isActive == true ? 1 : (isActive == false ? 0 : null),
      'is_verified': isVerified == true ? 1 : (isVerified == false ? 0 : null),
      'page': page,
      'limit': limit,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }

  StudentFilters copyWith({
    String? search,
    StudentStatus? status,
    AcademicLevel? level,
    AdmissionType? admissionType,
    ScholarshipStatus? scholarshipStatus,
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    String? institution,
    String? faculty,
    String? department,
    String? program,
    String? region,
    String? city,
    String? country,
    String? gender,
    DateTime? dateOfBirthFrom,
    DateTime? dateOfBirthTo,
    DateTime? enrollmentDateFrom,
    DateTime? enrollmentDateTo,
    double? gpaMin,
    double? gpaMax,
    bool? hasScholarship,
    bool? needsSpecialAccommodation,
    bool? isActive,
    bool? isVerified,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return StudentFilters(
      search: search ?? this.search,
      status: status ?? this.status,
      level: level ?? this.level,
      admissionType: admissionType ?? this.admissionType,
      scholarshipStatus: scholarshipStatus ?? this.scholarshipStatus,
      institutionId: institutionId ?? this.institutionId,
      facultyId: facultyId ?? this.facultyId,
      departmentId: departmentId ?? this.departmentId,
      programId: programId ?? this.programId,
      institution: institution ?? this.institution,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      program: program ?? this.program,
      region: region ?? this.region,
      city: city ?? this.city,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      dateOfBirthFrom: dateOfBirthFrom ?? this.dateOfBirthFrom,
      dateOfBirthTo: dateOfBirthTo ?? this.dateOfBirthTo,
      enrollmentDateFrom: enrollmentDateFrom ?? this.enrollmentDateFrom,
      enrollmentDateTo: enrollmentDateTo ?? this.enrollmentDateTo,
      gpaMin: gpaMin ?? this.gpaMin,
      gpaMax: gpaMax ?? this.gpaMax,
      hasScholarship: hasScholarship ?? this.hasScholarship,
      needsSpecialAccommodation: needsSpecialAccommodation ?? this.needsSpecialAccommodation,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  StudentFilters reset() {
    return const StudentFilters(
      page: 1,
      limit: 20,
      sortBy: 'created_at',
      sortOrder: 'desc',
    );
  }
}

// Statistics model
class StudentStatistics {
  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents;
  final int verifiedStudents;
  final int unverifiedStudents;
  final Map<StudentStatus, int> studentsByStatus;
  final Map<AcademicLevel, int> studentsByLevel;
  final Map<AdmissionType, int> studentsByAdmissionType;
  final Map<ScholarshipStatus, int> studentsByScholarshipStatus;
  final Map<String, int> studentsByInstitution;
  final Map<String, int> studentsByFaculty;
  final Map<String, int> studentsByDepartment;
  final Map<String, int> studentsByProgram;
  final Map<String, int> studentsByRegion;
  final Map<String, int> studentsByGender;
  final double? averageGpa;
  final double? medianGpa;
  final double? minGpa;
  final double? maxGpa;
  final int? averageAge;
  final int scholarshipRecipients;
  final double scholarshipRate;
  final int studentsWithThesis;
  final double thesisRate;
  final DateTime? lastUpdated;

  const StudentStatistics({
    required this.totalStudents,
    required this.activeStudents,
    required this.inactiveStudents,
    required this.verifiedStudents,
    required this.unverifiedStudents,
    required this.studentsByStatus,
    required this.studentsByLevel,
    required this.studentsByAdmissionType,
    required this.studentsByScholarshipStatus,
    required this.studentsByInstitution,
    required this.studentsByFaculty,
    required this.studentsByDepartment,
    required this.studentsByProgram,
    required this.studentsByRegion,
    required this.studentsByGender,
    this.averageGpa,
    this.medianGpa,
    this.minGpa,
    this.maxGpa,
    this.averageAge,
    required this.scholarshipRecipients,
    required this.scholarshipRate,
    required this.studentsWithThesis,
    required this.thesisRate,
    this.lastUpdated,
  });

  factory StudentStatistics.fromJson(Map<String, dynamic> json) {
    return StudentStatistics(
      totalStudents: json['total_students'] ?? 0,
      activeStudents: json['active_students'] ?? 0,
      inactiveStudents: json['inactive_students'] ?? 0,
      verifiedStudents: json['verified_students'] ?? 0,
      unverifiedStudents: json['unverified_students'] ?? 0,
      studentsByStatus: _parseStatusMap(json['students_by_status'] ?? {}),
      studentsByLevel: _parseLevelMap(json['students_by_level'] ?? {}),
      studentsByAdmissionType: _parseAdmissionTypeMap(json['students_by_admission_type'] ?? {}),
      studentsByScholarshipStatus: _parseScholarshipStatusMap(json['students_by_scholarship_status'] ?? {}),
      studentsByInstitution: Map<String, int>.from(json['students_by_institution'] ?? {}),
      studentsByFaculty: Map<String, int>.from(json['students_by_faculty'] ?? {}),
      studentsByDepartment: Map<String, int>.from(json['students_by_department'] ?? {}),
      studentsByProgram: Map<String, int>.from(json['students_by_program'] ?? {}),
      studentsByRegion: Map<String, int>.from(json['students_by_region'] ?? {}),
      studentsByGender: Map<String, int>.from(json['students_by_gender'] ?? {}),
      averageGpa: json['average_gpa']?.toDouble(),
      medianGpa: json['median_gpa']?.toDouble(),
      minGpa: json['min_gpa']?.toDouble(),
      maxGpa: json['max_gpa']?.toDouble(),
      averageAge: json['average_age'],
      scholarshipRecipients: json['scholarship_recipients'] ?? 0,
      scholarshipRate: (json['scholarship_rate'] ?? 0).toDouble(),
      studentsWithThesis: json['students_with_thesis'] ?? 0,
      thesisRate: (json['thesis_rate'] ?? 0).toDouble(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  static Map<StudentStatus, int> _parseStatusMap(Map<String, dynamic> map) {
    final result = <StudentStatus, int>{};
    for (final entry in map.entries) {
      final status = StudentStatus.values
          .where((s) => s.value == entry.key)
          .firstOrNull;
      if (status != null) {
        result[status] = entry.value as int;
      }
    }
    return result;
  }

  static Map<AcademicLevel, int> _parseLevelMap(Map<String, dynamic> map) {
    final result = <AcademicLevel, int>{};
    for (final entry in map.entries) {
      final level = AcademicLevel.values
          .where((l) => l.value == entry.key)
          .firstOrNull;
      if (level != null) {
        result[level] = entry.value as int;
      }
    }
    return result;
  }

  static Map<AdmissionType, int> _parseAdmissionTypeMap(Map<String, dynamic> map) {
    final result = <AdmissionType, int>{};
    for (final entry in map.entries) {
      final type = AdmissionType.values
          .where((t) => t.value == entry.key)
          .firstOrNull;
      if (type != null) {
        result[type] = entry.value as int;
      }
    }
    return result;
  }

  static Map<ScholarshipStatus, int> _parseScholarshipStatusMap(Map<String, dynamic> map) {
    final result = <ScholarshipStatus, int>{};
    for (final entry in map.entries) {
      final status = ScholarshipStatus.values
          .where((s) => s.value == entry.key)
          .firstOrNull;
      if (status != null) {
        result[status] = entry.value as int;
      }
    }
    return result;
  }

  double get activeRate {
    if (totalStudents == 0) return 0.0;
    return (activeStudents / totalStudents) * 100;
  }

  double get verifiedRate {
    if (totalStudents == 0) return 0.0;
    return (verifiedStudents / totalStudents) * 100;
  }

  double get graduationRate {
    final graduatedCount = studentsByStatus[StudentStatus.graduated] ?? 0;
    if (totalStudents == 0) return 0.0;
    return (graduatedCount / totalStudents) * 100;
  }
}
