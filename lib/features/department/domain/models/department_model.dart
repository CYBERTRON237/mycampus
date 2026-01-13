enum DepartmentStatus {
  active,
  inactive, archived;

  static DepartmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return DepartmentStatus.active;
      case 'inactive':
        return DepartmentStatus.inactive;
      default:
        return DepartmentStatus.active;
    }
  }

  String toJson() {
    switch (this) {
      case DepartmentStatus.active:
        return 'active';
      case DepartmentStatus.inactive:
        return 'inactive';
      case DepartmentStatus.archived:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String get displayName {
    switch (this) {
      case DepartmentStatus.active:
        return 'Actif';
      case DepartmentStatus.inactive:
        return 'Inactif';
      case DepartmentStatus.archived:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

enum DepartmentLevel {
  undergraduate,
  graduate,
  postgraduate;

  static DepartmentLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'undergraduate':
        return DepartmentLevel.undergraduate;
      case 'graduate':
        return DepartmentLevel.graduate;
      case 'postgraduate':
        return DepartmentLevel.postgraduate;
      default:
        return DepartmentLevel.undergraduate;
    }
  }

  String toJson() {
    switch (this) {
      case DepartmentLevel.undergraduate:
        return 'undergraduate';
      case DepartmentLevel.graduate:
        return 'graduate';
      case DepartmentLevel.postgraduate:
        return 'postgraduate';
    }
  }

  String get displayName {
    switch (this) {
      case DepartmentLevel.undergraduate:
        return 'Licence';
      case DepartmentLevel.graduate:
        return 'Master';
      case DepartmentLevel.postgraduate:
        return 'Doctorat';
    }
  }
}

class DepartmentModel {
  final String id;
  final String uuid;
  final String facultyId;
  final String code;
  final String name;
  final String shortName;
  final String? description;
  final String? headOfDepartment;
  final String? hodEmail;
  final String? hodPhone;
  final DepartmentLevel level;
  final DepartmentStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  var staffCount;

  DepartmentModel({
    required this.id,
    required this.uuid,
    required this.facultyId,
    required this.code,
    required this.name,
    required this.shortName,
    this.description,
    this.headOfDepartment,
    this.hodEmail,
    this.hodPhone,
    required this.level,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      facultyId: json['faculty_id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      description: json['description'],
      headOfDepartment: json['head_of_department'],
      hodEmail: json['hod_email'],
      hodPhone: json['hod_phone'],
      level: DepartmentLevel.fromString(json['level'] ?? 'undergraduate'),
      status: DepartmentStatus.fromString(json['status'] ?? 'active'),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'faculty_id': facultyId,
      'code': code,
      'name': name,
      'short_name': shortName,
      'description': description,
      'head_of_department': headOfDepartment,
      'hod_email': hodEmail,
      'hod_phone': hodPhone,
      'level': level.toJson(),
      'status': status.toJson(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DepartmentModel copyWith({
    String? id,
    String? uuid,
    String? facultyId,
    String? code,
    String? name,
    String? shortName,
    String? description,
    String? headOfDepartment,
    String? hodEmail,
    String? hodPhone,
    DepartmentLevel? level,
    DepartmentStatus? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      facultyId: facultyId ?? this.facultyId,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      headOfDepartment: headOfDepartment ?? this.headOfDepartment,
      hodEmail: hodEmail ?? this.hodEmail,
      hodPhone: hodPhone ?? this.hodPhone,
      level: level ?? this.level,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepartmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  get studentCount => null;

  get programCount => null;

  @override
  String toString() {
    return 'DepartmentModel{id: $id, name: $name, shortName: $shortName, level: $level}';
  }
}
