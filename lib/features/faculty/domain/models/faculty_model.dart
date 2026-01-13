enum FacultyStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended');

  const FacultyStatus(this.value);
  final String value;

  static FacultyStatus fromString(String value) {
    return FacultyStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FacultyStatus.active,
    );
  }
}

class FacultyModel {
  final String id;
  final String institutionId;
  final String code;
  final String name;
  final String shortName;
  final String? description;
  final String? deanName;
  final String? contactEmail;
  final String? contactPhone;
  final String? officeLocation;
  final FacultyStatus status;
  final int totalStudents;
  final int totalStaff;
  final int totalDepartments;
  final int totalPrograms;
  final String? website;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  FacultyModel({
    required this.id,
    required this.institutionId,
    required this.code,
    required this.name,
    required this.shortName,
    this.description,
    this.deanName,
    this.contactEmail,
    this.contactPhone,
    this.officeLocation,
    required this.status,
    this.totalStudents = 0,
    this.totalStaff = 0,
    this.totalDepartments = 0,
    this.totalPrograms = 0,
    this.website,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'].toString(),
      institutionId: json['institution_id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      description: json['description'],
      deanName: json['dean_name'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      officeLocation: json['office_location'],
      status: FacultyStatus.fromString(json['status'] ?? 'active'),
      totalStudents: int.tryParse(json['total_students'].toString()) ?? 0,
      totalStaff: int.tryParse(json['total_staff'].toString()) ?? 0,
      totalDepartments: int.tryParse(json['total_departments'].toString()) ?? 0,
      totalPrograms: int.tryParse(json['total_programs'].toString()) ?? 0,
      website: json['website'],
      logoUrl: json['logo_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution_id': institutionId,
      'code': code,
      'name': name,
      'short_name': shortName,
      'description': description,
      'dean_name': deanName,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'office_location': officeLocation,
      'status': status.value,
      'total_students': totalStudents,
      'total_staff': totalStaff,
      'total_departments': totalDepartments,
      'total_programs': totalPrograms,
      'website': website,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FacultyModel copyWith({
    String? id,
    String? institutionId,
    String? code,
    String? name,
    String? shortName,
    String? description,
    String? deanName,
    String? contactEmail,
    String? contactPhone,
    String? officeLocation,
    FacultyStatus? status,
    int? totalStudents,
    int? totalStaff,
    int? totalDepartments,
    int? totalPrograms,
    String? website,
    String? logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FacultyModel(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      deanName: deanName ?? this.deanName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      officeLocation: officeLocation ?? this.officeLocation,
      status: status ?? this.status,
      totalStudents: totalStudents ?? this.totalStudents,
      totalStaff: totalStaff ?? this.totalStaff,
      totalDepartments: totalDepartments ?? this.totalDepartments,
      totalPrograms: totalPrograms ?? this.totalPrograms,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacultyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FacultyModel(id: $id, code: $code, name: $name, shortName: $shortName, status: $status)';
  }
}
