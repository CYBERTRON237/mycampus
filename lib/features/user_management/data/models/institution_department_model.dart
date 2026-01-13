import 'user_model.dart';

class InstitutionModel {
  final int id;
  final String uuid;
  final String name;
  final String shortName;
  final String type;
  final String status;
  final String region;
  final String city;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  InstitutionModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.shortName,
    required this.type,
    required this.status,
    required this.region,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'short_name': shortName,
      'type': type,
      'status': status,
      'region': region,
      'city': city,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DepartmentModel {
  final int id;
  final String uuid;
  final String name;
  final String shortName;
  final String code;
  final String description;
  final String headOfDepartment;
  final String hodEmail;
  final String hodPhone;
  final String level;
  final String status;
  final bool isActive;
  final int facultyId;
  final String facultyName;
  final int? institutionId;
  final String? institutionName;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepartmentModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.shortName,
    required this.code,
    required this.description,
    required this.headOfDepartment,
    required this.hodEmail,
    required this.hodPhone,
    required this.level,
    required this.status,
    required this.isActive,
    required this.facultyId,
    required this.facultyName,
    this.institutionId,
    this.institutionName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      headOfDepartment: json['head_of_department'] ?? '',
      hodEmail: json['hod_email'] ?? '',
      hodPhone: json['hod_phone'] ?? '',
      level: json['level'] ?? '',
      status: json['status'] ?? '',
      isActive: json['is_active'] ?? false,
      facultyId: json['faculty_id'] ?? 0,
      facultyName: json['faculty_name'] ?? '',
      institutionId: json['institution_id'],
      institutionName: json['institution_name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'short_name': shortName,
      'code': code,
      'description': description,
      'head_of_department': headOfDepartment,
      'hod_email': hodEmail,
      'hod_phone': hodPhone,
      'level': level,
      'status': status,
      'is_active': isActive,
      'faculty_id': facultyId,
      'faculty_name': facultyName,
      'institution_id': institutionId,
      'institution_name': institutionName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int pendingUsers;
  final Map<String, int> usersByRole;
  final Map<String, int> usersByInstitution;
  final Map<String, int> usersByDepartment;
  final Map<String, int> usersByRegion;
  final List<UserRoleStats> roleStats;
  final List<InstitutionUserStats> institutionStats;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.pendingUsers,
    required this.usersByRole,
    required this.usersByInstitution,
    required this.usersByDepartment,
    required this.usersByRegion,
    required this.roleStats,
    required this.institutionStats,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      inactiveUsers: json['inactive_users'] ?? 0,
      pendingUsers: json['pending_users'] ?? 0,
      usersByRole: Map<String, int>.from(json['users_by_role'] ?? {}),
      usersByInstitution: Map<String, int>.from(json['users_by_institution'] ?? {}),
      usersByDepartment: Map<String, int>.from(json['users_by_department'] ?? {}),
      usersByRegion: Map<String, int>.from(json['users_by_region'] ?? {}),
      roleStats: (json['role_stats'] as List?)
          ?.map((e) => UserRoleStats.fromJson(e))
          .toList() ?? [],
      institutionStats: (json['institution_stats'] as List?)
          ?.map((e) => InstitutionUserStats.fromJson(e))
          .toList() ?? [],
    );
  }
}

class InstitutionUserStats {
  final int institutionId;
  final String institutionName;
  final String institutionShortName;
  final String region;
  final String city;
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int studentCount;
  final int teacherCount;
  final int staffCount;

  InstitutionUserStats({
    required this.institutionId,
    required this.institutionName,
    required this.institutionShortName,
    required this.region,
    required this.city,
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.studentCount,
    required this.teacherCount,
    required this.staffCount,
  });

  factory InstitutionUserStats.fromJson(Map<String, dynamic> json) {
    return InstitutionUserStats(
      institutionId: json['institution_id'] ?? 0,
      institutionName: json['institution_name'] ?? '',
      institutionShortName: json['institution_short_name'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      inactiveUsers: json['inactive_users'] ?? 0,
      studentCount: json['student_count'] ?? 0,
      teacherCount: json['teacher_count'] ?? 0,
      staffCount: json['staff_count'] ?? 0,
    );
  }
}

class DepartmentUserStats {
  final int departmentId;
  final String departmentName;
  final String departmentCode;
  final String level;
  final int facultyId;
  final String facultyName;
  final int? institutionId;
  final String? institutionName;
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int studentCount;
  final int teacherCount;

  DepartmentUserStats({
    required this.departmentId,
    required this.departmentName,
    required this.departmentCode,
    required this.level,
    required this.facultyId,
    required this.facultyName,
    this.institutionId,
    this.institutionName,
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.studentCount,
    required this.teacherCount,
  });

  factory DepartmentUserStats.fromJson(Map<String, dynamic> json) {
    return DepartmentUserStats(
      departmentId: json['department_id'] ?? 0,
      departmentName: json['department_name'] ?? '',
      departmentCode: json['department_code'] ?? '',
      level: json['level'] ?? '',
      facultyId: json['faculty_id'] ?? 0,
      facultyName: json['faculty_name'] ?? '',
      institutionId: json['institution_id'],
      institutionName: json['institution_name'],
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      inactiveUsers: json['inactive_users'] ?? 0,
      studentCount: json['student_count'] ?? 0,
      teacherCount: json['teacher_count'] ?? 0,
    );
  }
}
