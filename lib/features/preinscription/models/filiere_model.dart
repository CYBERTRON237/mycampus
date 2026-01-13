class FiliereModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final String departmentId;
  final String departmentName;
  final String facultyId;
  final String facultyName;
  final String degreeLevel;
  final int duration;
  final String? accreditation;
  final String status;
  final int? capacity;
  final String? prerequisites;
  final String? objectives;
  final String? competencies;
  final String? careerOpportunities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FiliereModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.departmentId,
    required this.departmentName,
    required this.facultyId,
    required this.facultyName,
    required this.degreeLevel,
    required this.duration,
    this.accreditation,
    required this.status,
    this.capacity,
    this.prerequisites,
    this.objectives,
    this.competencies,
    this.careerOpportunities,
    this.createdAt,
    this.updatedAt,
  });

  factory FiliereModel.fromJson(Map<String, dynamic> json) {
    return FiliereModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      departmentName: json['department_name'] ?? '',
      facultyId: json['faculty_id']?.toString() ?? '',
      facultyName: json['faculty_name'] ?? '',
      degreeLevel: json['degree_level'] ?? '',
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration'].toString()) ?? 0,
      accreditation: json['accreditation'],
      status: json['status'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity'].toString()),
      prerequisites: json['prerequisites'],
      objectives: json['objectives'],
      competencies: json['competencies'],
      careerOpportunities: json['career_opportunities'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'department_id': departmentId,
      'department_name': departmentName,
      'faculty_id': facultyId,
      'faculty_name': facultyName,
      'degree_level': degreeLevel,
      'duration': duration,
      'accreditation': accreditation,
      'status': status,
      'capacity': capacity,
      'prerequisites': prerequisites,
      'objectives': objectives,
      'competencies': competencies,
      'career_opportunities': careerOpportunities,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$name ($code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FiliereModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
