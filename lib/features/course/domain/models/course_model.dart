import 'package:equatable/equatable.dart';

enum CourseStatus {
  active('active', 'Actif'),
  inactive('inactive', 'Inactif'),
  suspended('suspended', 'Suspendu');

  const CourseStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static CourseStatus fromString(String value) {
    return CourseStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CourseStatus.active,
    );
  }

  String toJson() => value;
}

enum CourseLevel {
  undergraduate('undergraduate', 'Licence'),
  graduate('graduate', 'Master'),
  postgraduate('postgraduate', 'Doctorat');

  const CourseLevel(this.value, this.displayName);
  final String value;
  final String displayName;

  static CourseLevel fromString(String value) {
    return CourseLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => CourseLevel.undergraduate,
    );
  }

  String toJson() => value;
}

enum CourseSemester {
  S1('S1', 'Semestre 1'),
  S2('S2', 'Semestre 2'),
  S3('S3', 'Semestre 3'),
  S4('S4', 'Semestre 4'),
  S5('S5', 'Semestre 5'),
  S6('S6', 'Semestre 6');

  const CourseSemester(this.value, this.displayName);
  final String value;
  final String displayName;

  static CourseSemester fromString(String value) {
    return CourseSemester.values.firstWhere(
      (semester) => semester.value == value,
      orElse: () => CourseSemester.S1,
    );
  }

  String toJson() => value;
}

class CourseModel extends Equatable {
  final String id;
  final String uuid;
  final String programId;
  final String code;
  final String name;
  final String shortName;
  final String? description;
  final int credits;
  final CourseSemester semester;
  final CourseLevel level;
  final String? instructor;
  final String? instructorEmail;
  final String? instructorPhone;
  final CourseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.uuid,
    required this.programId,
    required this.code,
    required this.name,
    required this.shortName,
    this.description,
    required this.credits,
    required this.semester,
    required this.level,
    this.instructor,
    this.instructorEmail,
    this.instructorPhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  CourseModel copyWith({
    String? id,
    String? uuid,
    String? programId,
    String? code,
    String? name,
    String? shortName,
    String? description,
    int? credits,
    CourseSemester? semester,
    CourseLevel? level,
    String? instructor,
    String? instructorEmail,
    String? instructorPhone,
    CourseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      programId: programId ?? this.programId,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      level: level ?? this.level,
      instructor: instructor ?? this.instructor,
      instructorEmail: instructorEmail ?? this.instructorEmail,
      instructorPhone: instructorPhone ?? this.instructorPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      programId: json['program_id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      description: json['description'],
      credits: json['credits'] ?? 3,
      semester: CourseSemester.fromString(json['semester'] ?? 'S1'),
      level: CourseLevel.fromString(json['level'] ?? 'undergraduate'),
      instructor: json['instructor'],
      instructorEmail: json['instructor_email'],
      instructorPhone: json['instructor_phone'],
      status: CourseStatus.fromString(json['status'] ?? 'active'),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'program_id': programId,
      'code': code,
      'name': name,
      'short_name': shortName,
      'description': description,
      'credits': credits,
      'semester': semester.toJson(),
      'level': level.toJson(),
      'instructor': instructor,
      'instructor_email': instructorEmail,
      'instructor_phone': instructorPhone,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        programId,
        code,
        name,
        shortName,
        description,
        credits,
        semester,
        level,
        instructor,
        instructorEmail,
        instructorPhone,
        status,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CourseModel(id: $id, code: $code, name: $name, shortName: $shortName, status: $status)';
  }
}
