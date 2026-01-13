enum ProgramStatus {
  active,
  inactive,
  suspended;

  static ProgramStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ProgramStatus.active;
      case 'inactive':
        return ProgramStatus.inactive;
      case 'suspended':
        return ProgramStatus.suspended;
      default:
        return ProgramStatus.active;
    }
  }

  String toJson() {
    switch (this) {
      case ProgramStatus.active:
        return 'active';
      case ProgramStatus.inactive:
        return 'inactive';
      case ProgramStatus.suspended:
        return 'suspended';
    }
  }

  String get displayName {
    switch (this) {
      case ProgramStatus.active:
        return 'Actif';
      case ProgramStatus.inactive:
        return 'Inactif';
      case ProgramStatus.suspended:
        return 'Suspendu';
    }
  }
}

enum DegreeLevel {
  licence1,
  licence2,
  licence3,
  master1,
  master2,
  doctorat,
  ingenieur,
  bts,
  professional;

  static DegreeLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'licence1':
        return DegreeLevel.licence1;
      case 'licence2':
        return DegreeLevel.licence2;
      case 'licence3':
        return DegreeLevel.licence3;
      case 'master1':
        return DegreeLevel.master1;
      case 'master2':
        return DegreeLevel.master2;
      case 'doctorat':
        return DegreeLevel.doctorat;
      case 'ingenieur':
        return DegreeLevel.ingenieur;
      case 'bts':
        return DegreeLevel.bts;
      case 'professional':
        return DegreeLevel.professional;
      default:
        return DegreeLevel.licence1;
    }
  }

  String toJson() {
    switch (this) {
      case DegreeLevel.licence1:
        return 'licence1';
      case DegreeLevel.licence2:
        return 'licence2';
      case DegreeLevel.licence3:
        return 'licence3';
      case DegreeLevel.master1:
        return 'master1';
      case DegreeLevel.master2:
        return 'master2';
      case DegreeLevel.doctorat:
        return 'doctorat';
      case DegreeLevel.ingenieur:
        return 'ingenieur';
      case DegreeLevel.bts:
        return 'bts';
      case DegreeLevel.professional:
        return 'professional';
    }
  }

  String get displayName {
    switch (this) {
      case DegreeLevel.licence1:
        return 'Licence 1';
      case DegreeLevel.licence2:
        return 'Licence 2';
      case DegreeLevel.licence3:
        return 'Licence 3';
      case DegreeLevel.master1:
        return 'Master 1';
      case DegreeLevel.master2:
        return 'Master 2';
      case DegreeLevel.doctorat:
        return 'Doctorat';
      case DegreeLevel.ingenieur:
        return 'Ingénieur';
      case DegreeLevel.bts:
        return 'BTS';
      case DegreeLevel.professional:
        return 'Professionnel';
    }
  }
}

class ProgramModel {
  final String id;
  final String departmentId;
  final String code;
  final String name;
  final String shortName;
  final DegreeLevel degreeLevel;
  final int durationYears;
  final String? description;
  final String? admissionRequirements;
  final String? careerProspects;
  final ProgramStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgramModel({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    required this.shortName,
    required this.degreeLevel,
    required this.durationYears,
    this.description,
    this.admissionRequirements,
    this.careerProspects,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id']?.toString() ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      degreeLevel: DegreeLevel.fromString(json['degree_level'] ?? 'licence1'),
      durationYears: json['duration_years'] ?? 3,
      description: json['description'],
      admissionRequirements: json['admission_requirements'],
      careerProspects: json['career_prospects'],
      status: ProgramStatus.fromString(json['status'] ?? 'active'),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department_id': departmentId,
      'code': code,
      'name': name,
      'short_name': shortName,
      'degree_level': degreeLevel.toJson(),
      'duration_years': durationYears,
      'description': description,
      'admission_requirements': admissionRequirements,
      'career_prospects': careerProspects,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProgramModel copyWith({
    String? id,
    String? departmentId,
    String? code,
    String? name,
    String? shortName,
    DegreeLevel? degreeLevel,
    int? durationYears,
    String? description,
    String? admissionRequirements,
    String? careerProspects,
    ProgramStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      degreeLevel: degreeLevel ?? this.degreeLevel,
      durationYears: durationYears ?? this.durationYears,
      description: description ?? this.description,
      admissionRequirements: admissionRequirements ?? this.admissionRequirements,
      careerProspects: careerProspects ?? this.careerProspects,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgramModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  get studentCount => null;

  @override
  String toString() {
    return 'ProgramModel{id: $id, name: $name, shortName: $shortName, degreeLevel: $degreeLevel}';
  }
}
