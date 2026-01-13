import 'simple_student_model.dart';

class StudentModel {
  final int id;
  final String uuid;
  final String matricule;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? gender;
  final String? nationality;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  final String? country;
  final String? postalCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final StudentProfile profile;
  final Institution institution;
  final Faculty faculty;
  final Department department;
  final Program program;
  final AcademicYear academicYear;
  final String academicPerformance;

  StudentModel({
    required this.id,
    required this.uuid,
    required this.matricule,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.placeOfBirth,
    this.gender,
    this.nationality,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.bio,
    this.address,
    this.city,
    this.region,
    this.country,
    this.postalCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    required this.accountStatus,
    required this.createdAt,
    this.lastLoginAt,
    required this.profile,
    required this.institution,
    required this.faculty,
    required this.department,
    required this.program,
    required this.academicYear,
    required this.academicPerformance,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      matricule: json['matricule'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      email: json['email'] ?? '',
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      placeOfBirth: json['place_of_birth'],
      gender: json['gender'],
      nationality: json['nationality'],
      profilePhotoUrl: json['profile_photo_url'],
      coverPhotoUrl: json['cover_photo_url'],
      bio: json['bio'],
      address: json['address'],
      city: json['city'],
      region: json['region'],
      country: json['country'],
      postalCode: json['postal_code'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelationship: json['emergency_contact_relationship'],
      accountStatus: json['account_status'] ?? 'unknown',
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      profile: StudentProfile.fromJson(json),
      institution: Institution.fromJson(json),
      faculty: Faculty.fromJson(json),
      department: Department.fromJson(json),
      program: Program.fromJson(json),
      academicYear: AcademicYear.fromJson(json),
      academicPerformance: json['academic_performance'] ?? 'Inconnu',
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
      'account_status': accountStatus,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'profile': profile.toJson(),
      'institution': institution.toJson(),
      'faculty': faculty.toJson(),
      'department': department.toJson(),
      'program': program.toJson(),
      'academic_year': academicYear.toJson(),
      'academic_performance': academicPerformance,
    };
  }

  String get fullName => middleName != null && middleName!.isNotEmpty 
      ? '$firstName $middleName $lastName' 
      : '$firstName $lastName';

  // Factory pour convertir SimpleStudentModel en StudentModel
  factory StudentModel.fromSimpleStudent(SimpleStudentModel simpleStudent) {
    return StudentModel(
      id: simpleStudent.id,
      uuid: '',
      matricule: simpleStudent.matricule ?? '',
      firstName: simpleStudent.firstName,
      lastName: simpleStudent.lastName,
      middleName: null,
      email: simpleStudent.email,
      phone: simpleStudent.phone,
      dateOfBirth: null,
      placeOfBirth: null,
      gender: null,
      nationality: null,
      profilePhotoUrl: null,
      coverPhotoUrl: null,
      bio: null,
      address: null,
      city: null,
      region: null,
      country: null,
      postalCode: null,
      emergencyContactName: null,
      emergencyContactPhone: null,
      emergencyContactRelationship: null,
      accountStatus: simpleStudent.studentStatus,
      createdAt: simpleStudent.createdAt.isNotEmpty 
          ? DateTime.parse(simpleStudent.createdAt) 
          : DateTime.now(),
      lastLoginAt: null,
      profile: StudentProfile(
        id: simpleStudent.id, // Utiliser l'ID du profil étudiant
        currentLevel: simpleStudent.currentLevel,
        enrollmentDate: simpleStudent.createdAt.isNotEmpty 
          ? DateTime.parse(simpleStudent.createdAt) 
          : DateTime.now(),
        studentStatus: simpleStudent.studentStatus,
        admissionType: 'regular',
        totalCreditsEarned: 0,
      ),
      institution: Institution(
        id: 0,
        name: simpleStudent.displayProgram,
        shortName: 'Inst',
        type: 'university',
        country: 'Cameroun',
        region: 'Centre',
        city: 'Yaoundé',
      ),
      faculty: Faculty(
        id: 0,
        name: 'Faculté',
        shortName: 'FAC',
      ),
      department: Department(
        id: 0,
        name: 'Département',
        shortName: 'DEP',
      ),
      program: Program(
        id: 0,
        name: 'Programme',
        shortName: 'PROG',
        degreeLevel: 'licence',
      ),
      academicYear: AcademicYear(
        id: 0,
        yearCode: '2024-2025',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2025, 7, 31),
      ),
      academicPerformance: 'Bon',
    );
  }
}

class StudentProfile {
  final int id;
  final String currentLevel;
  final DateTime enrollmentDate;
  final DateTime? expectedGraduationDate;
  final DateTime? actualGraduationDate;
  final String studentStatus;
  final String admissionType;
  final String? scholarshipStatus;
  final String? scholarshipDetails;
  final double? gpa;
  final int totalCreditsEarned;
  final int? totalCreditsRequired;
  final int? classRank;
  final String? honors;
  final String? disciplinaryRecords;
  final String? graduationThesisTitle;
  final String? thesisSupervisor;
  final DateTime? thesisDefenseDate;

  StudentProfile({
    required this.id,
    required this.currentLevel,
    required this.enrollmentDate,
    this.expectedGraduationDate,
    this.actualGraduationDate,
    required this.studentStatus,
    required this.admissionType,
    this.scholarshipStatus,
    this.scholarshipDetails,
    this.gpa,
    required this.totalCreditsEarned,
    this.totalCreditsRequired,
    this.classRank,
    this.honors,
    this.disciplinaryRecords,
    this.graduationThesisTitle,
    this.thesisSupervisor,
    this.thesisDefenseDate,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['profile_id'] ?? 0,
      currentLevel: json['current_level'] ?? '',
      enrollmentDate: DateTime.parse(json['enrollment_date']),
      expectedGraduationDate: json['expected_graduation_date'] != null 
          ? DateTime.parse(json['expected_graduation_date']) 
          : null,
      actualGraduationDate: json['actual_graduation_date'] != null 
          ? DateTime.parse(json['actual_graduation_date']) 
          : null,
      studentStatus: json['student_status'] ?? '',
      admissionType: json['admission_type'] ?? '',
      scholarshipStatus: json['scholarship_status'],
      scholarshipDetails: json['scholarship_details'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'current_level': currentLevel,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'expected_graduation_date': expectedGraduationDate?.toIso8601String(),
      'actual_graduation_date': actualGraduationDate?.toIso8601String(),
      'student_status': studentStatus,
      'admission_type': admissionType,
      'scholarship_status': scholarshipStatus,
      'scholarship_details': scholarshipDetails,
      'gpa': gpa,
      'total_credits_earned': totalCreditsEarned,
      'total_credits_required': totalCreditsRequired,
      'class_rank': classRank,
      'honors': honors,
      'disciplinary_records': disciplinaryRecords,
      'graduation_thesis_title': graduationThesisTitle,
      'thesis_supervisor': thesisSupervisor,
      'thesis_defense_date': thesisDefenseDate?.toIso8601String(),
    };
  }

  String get displayLevel {
    switch (currentLevel) {
      case 'licence1': return 'Licence 1';
      case 'licence2': return 'Licence 2';
      case 'licence3': return 'Licence 3';
      case 'master1': return 'Master 1';
      case 'master2': return 'Master 2';
      case 'doctorat1': return 'Doctorat 1';
      case 'doctorat2': return 'Doctorat 2';
      case 'doctorat3': return 'Doctorat 3';
      default: return currentLevel;
    }
  }

  String get gpaDisplay {
    if (gpa == null) return 'N/A';
    return gpa!.toStringAsFixed(2);
  }

  double get progressPercentage {
    if (totalCreditsRequired == null || totalCreditsRequired == 0) return 0.0;
    return (totalCreditsEarned / totalCreditsRequired!) * 100;
  }
}

class Institution {
  final int id;
  final String name;
  final String shortName;
  final String type;
  final String country;
  final String region;
  final String city;

  Institution({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.country,
    required this.region,
    required this.city,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['institution_id'] ?? 0,
      name: json['institution_name'] ?? '',
      shortName: json['institution_short_name'] ?? '',
      type: json['institution_type'] ?? '',
      country: json['country'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'type': type,
      'country': country,
      'region': region,
      'city': city,
    };
  }

  String get fullName => '$name ($shortName)';
}

class Faculty {
  final int id;
  final String name;
  final String shortName;

  Faculty({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: 0, // ID non disponible dans le JSON actuel
      name: json['faculty_name'] ?? '',
      shortName: json['faculty_short_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
    };
  }
}

class Department {
  final int id;
  final String name;
  final String shortName;

  Department({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: 0, // ID non disponible dans le JSON actuel
      name: json['department_name'] ?? '',
      shortName: json['department_short_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
    };
  }
}

class Program {
  final int id;
  final String name;
  final String shortName;
  final String degreeLevel;
  final int? durationYears;

  Program({
    required this.id,
    required this.name,
    required this.shortName,
    required this.degreeLevel,
    this.durationYears,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: 0, // ID non disponible dans le JSON actuel
      name: json['program_name'] ?? '',
      shortName: json['program_short_name'] ?? '',
      degreeLevel: json['degree_level'] ?? '',
      durationYears: json['duration_years'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'degree_level': degreeLevel,
      'duration_years': durationYears,
    };
  }

  String get displayDegreeLevel {
    switch (degreeLevel) {
      case 'licence1': return 'Licence 1';
      case 'licence2': return 'Licence 2';
      case 'licence3': return 'Licence 3';
      case 'master1': return 'Master 1';
      case 'master2': return 'Master 2';
      case 'doctorat': return 'Doctorat';
      case 'ingenieur': return 'Ingénieur';
      case 'bts': return 'BTS';
      case 'professional': return 'Professionnel';
      default: return degreeLevel;
    }
  }
}

class AcademicYear {
  final int id;
  final String yearCode;
  final DateTime? startDate;
  final DateTime? endDate;

  AcademicYear({
    required this.id,
    required this.yearCode,
    this.startDate,
    this.endDate,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: 0, // ID non disponible dans le JSON actuel
      yearCode: json['academic_year'] ?? '',
      startDate: json['academic_year_start'] != null 
          ? DateTime.parse(json['academic_year_start']) 
          : null,
      endDate: json['academic_year_end'] != null 
          ? DateTime.parse(json['academic_year_end']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year_code': yearCode,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

// Modèles pour les filtres
class StudentFilters {
  final int? institutionId;
  final int? facultyId;
  final int? departmentId;
  final int? programId;
  final String? level;
  final String? status;
  final String? search;
  final String? institution;
  final String? faculty;
  final String? department;
  final String? program;
  final String? region;
  final String? group;
  final int page;
  final int limit;

  StudentFilters({
    this.institutionId,
    this.facultyId,
    this.departmentId,
    this.programId,
    this.level,
    this.status,
    this.search,
    this.institution,
    this.faculty,
    this.department,
    this.program,
    this.region,
    this.group,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'institution_id': institutionId,
      'faculty_id': facultyId,
      'department_id': departmentId,
      'program_id': programId,
      'level': level,
      'status': status,
      'search': search,
      'institution': institution,
      'faculty': faculty,
      'department': department,
      'program': program,
      'region': region,
      'group': group,
      'page': page,
      'limit': limit,
    };
  }

  StudentFilters copyWith({
    int? institutionId,
    int? facultyId,
    int? departmentId,
    int? programId,
    String? level,
    String? status,
    String? search,
    String? institution,
    String? faculty,
    String? department,
    String? program,
    String? region,
    String? group,
    int? page,
    int? limit,
  }) {
    return StudentFilters(
      institutionId: institutionId ?? this.institutionId,
      facultyId: facultyId ?? this.facultyId,
      departmentId: departmentId ?? this.departmentId,
      programId: programId ?? this.programId,
      level: level ?? this.level,
      status: status ?? this.status,
      search: search ?? this.search,
      institution: institution ?? this.institution,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      program: program ?? this.program,
      region: region ?? this.region,
      group: group ?? this.group,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

// Modèle pour les statistiques
class StudentStats {
  final int totalStudents;
  final int enrolledStudents;
  final int graduatedStudents;
  final int withdrawnStudents;
  final int suspendedStudents;
  final int deferredStudents;
  final double? averageGpa;
  final int excellentStudents;
  final int goodStudents;
  final int averageStudents;
  final int poorStudents;
  final int maleStudents;
  final int femaleStudents;
  final int scholarshipStudents;
  final int undergraduateStudents;
  final int graduateStudents;
  final int doctoralStudents;

  StudentStats({
    required this.totalStudents,
    required this.enrolledStudents,
    required this.graduatedStudents,
    required this.withdrawnStudents,
    required this.suspendedStudents,
    required this.deferredStudents,
    this.averageGpa,
    required this.excellentStudents,
    required this.goodStudents,
    required this.averageStudents,
    required this.poorStudents,
    required this.maleStudents,
    required this.femaleStudents,
    required this.scholarshipStudents,
    required this.undergraduateStudents,
    required this.graduateStudents,
    required this.doctoralStudents,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      totalStudents: json['total_students'] ?? 0,
      enrolledStudents: json['enrolled_students'] ?? 0,
      graduatedStudents: json['graduated_students'] ?? 0,
      withdrawnStudents: json['withdrawn_students'] ?? 0,
      suspendedStudents: json['suspended_students'] ?? 0,
      deferredStudents: json['deferred_students'] ?? 0,
      averageGpa: json['average_gpa']?.toDouble(),
      excellentStudents: json['excellent_students'] ?? 0,
      goodStudents: json['good_students'] ?? 0,
      averageStudents: json['average_students'] ?? 0,
      poorStudents: json['poor_students'] ?? 0,
      maleStudents: json['male_students'] ?? 0,
      femaleStudents: json['female_students'] ?? 0,
      scholarshipStudents: json['scholarship_students'] ?? 0,
      undergraduateStudents: json['undergraduate_students'] ?? 0,
      graduateStudents: json['graduate_students'] ?? 0,
      doctoralStudents: json['doctoral_students'] ?? 0,
    );
  }

  double get graduationRate {
    if (totalStudents == 0) return 0.0;
    return (graduatedStudents / totalStudents) * 100;
  }

  double get activeRate {
    if (totalStudents == 0) return 0.0;
    return (enrolledStudents / totalStudents) * 100;
  }

  double get scholarshipRate {
    if (totalStudents == 0) return 0.0;
    return (scholarshipStudents / totalStudents) * 100;
  }
}

// Modèle pour la pagination
class StudentPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;

  StudentPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory StudentPagination.fromJson(Map<String, dynamic> json) {
    return StudentPagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

// Modèle pour la réponse API
class StudentResponse {
  final bool success;
  final List<SimpleStudentModel> data;
  final StudentPagination? pagination;
  final String? error;

  StudentResponse({
    required this.success,
    required this.data,
    this.pagination,
    this.error,
  });

  factory StudentResponse.fromJson(Map<String, dynamic> json) {
    return StudentResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => SimpleStudentModel.fromJson(item))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? StudentPagination.fromJson(json['pagination'])
          : null,
      error: json['error'],
    );
  }
}
