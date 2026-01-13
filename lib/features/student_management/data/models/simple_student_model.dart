class SimpleStudentModel {
  final int id;
  final int userId;
  final int? programId;
  final int? academicYearId;
  final String currentLevel;
  final String? enrollmentDate;
  final String studentStatus;
  final String? gpa;
  final int totalCreditsEarned;
  final int? totalCreditsRequired;
  final String? classRank;
  final String? honors;
  final String createdAt;
  final String firstName;
  final String lastName;
  final String email;
  final String? matricule;
  final String? phone;
  final String? programName;
  final String? academicYearName;
  final String? academicPerformance;

  SimpleStudentModel({
    required this.id,
    required this.userId,
    this.programId,
    this.academicYearId,
    required this.currentLevel,
    this.enrollmentDate,
    required this.studentStatus,
    this.gpa,
    required this.totalCreditsEarned,
    this.totalCreditsRequired,
    this.classRank,
    this.honors,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.matricule,
    this.phone,
    this.programName,
    this.academicYearName,
    this.academicPerformance,
  });

  factory SimpleStudentModel.fromJson(Map<String, dynamic> json) {
    return SimpleStudentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      programId: json['program_id'],
      academicYearId: json['academic_year_id'],
      currentLevel: json['current_level'] ?? '',
      enrollmentDate: json['enrollment_date'],
      studentStatus: json['student_status'] ?? 'unknown',
      gpa: json['gpa']?.toString(),
      totalCreditsEarned: json['total_credits_earned'] ?? 0,
      totalCreditsRequired: json['total_credits_required'],
      classRank: json['class_rank'],
      honors: json['honors'],
      createdAt: json['created_at'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      matricule: json['matricule'],
      phone: json['phone'],
      programName: json['program_name'],
      academicYearName: json['academic_year_name'],
      academicPerformance: json['academic_performance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'program_id': programId,
      'academic_year_id': academicYearId,
      'current_level': currentLevel,
      'enrollment_date': enrollmentDate,
      'student_status': studentStatus,
      'gpa': gpa,
      'total_credits_earned': totalCreditsEarned,
      'total_credits_required': totalCreditsRequired,
      'class_rank': classRank,
      'honors': honors,
      'created_at': createdAt,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'matricule': matricule,
      'phone': phone,
      'program_name': programName,
      'academic_year_name': academicYearName,
      'academic_performance': academicPerformance,
    };
  }

  // Getters pour l'affichage
  String get fullName => '$firstName $lastName';
  
  String get displayLevel => currentLevel.isEmpty ? 'Non défini' : currentLevel;
  
  String get displayStatus => studentStatus.isEmpty ? 'Inconnu' : studentStatus;
  
  String get displayProgram => programName ?? 'Programme non défini';
  
  String get displayAcademicYear => academicYearName ?? 'Année non définie';
  
  String get displayPhone => phone ?? 'Non renseigné';
  
  String get displayEmail => email;
  
  String get displayMatricule => matricule ?? 'Non défini';
  
  String get displayGpa => gpa ?? 'N/A';
  
  String get displayPerformance => academicPerformance ?? 'Non évalué';
}
