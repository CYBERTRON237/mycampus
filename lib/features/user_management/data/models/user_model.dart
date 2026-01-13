class UserModel {
  final int id;
  final String uuid;
  final String email;
  final String firstName;
  final String lastName;
  final String? matricule;
  final String primaryRole;
  final String accountStatus;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? institutionName;
  final String? departmentName;
  final int userLevel;
  final String? roleDisplayName;
  final List<String> userRoles;
  final UserPermissions permissions;

  UserModel({
    required this.id,
    required this.uuid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.matricule,
    required this.primaryRole,
    required this.accountStatus,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.institutionName,
    this.departmentName,
    required this.userLevel,
    this.roleDisplayName,
    required this.userRoles,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      matricule: json['matricule'],
      primaryRole: json['primary_role'] ?? '',
      accountStatus: json['account_status'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null,
      institutionName: json['institution_name'],
      departmentName: json['department_name'],
      userLevel: json['user_level'] ?? 0,
      roleDisplayName: json['role_display_name'],
      userRoles: json['user_roles'] != null 
          ? (json['user_roles'] as String).split(',').map((e) => e.trim()).toList()
          : [],
      permissions: UserPermissions.fromJson(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'matricule': matricule,
      'primary_role': primaryRole,
      'account_status': accountStatus,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'institution_name': institutionName,
      'department_name': departmentName,
      'user_level': userLevel,
      'role_display_name': roleDisplayName,
      'user_roles': userRoles.join(','),
      'permissions': permissions.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
  String get displayName => firstName.isNotEmpty ? firstName : email;
  bool get isOnline => lastLoginAt != null && 
      DateTime.now().difference(lastLoginAt!).inMinutes < 15;
}

class UserPermissions {
  final bool canView;
  final bool canEdit;
  final bool canDelete;

  UserPermissions({
    required this.canView,
    required this.canEdit,
    required this.canDelete,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      canView: json['can_view'] ?? false,
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_view': canView,
      'can_edit': canEdit,
      'can_delete': canDelete,
    };
  }
}

class UserRoleStats {
  final String roleName;
  final String roleDisplayName;
  final int roleLevel;
  final int userCount;
  final int activeCount;
  final int recentLoginCount;

  UserRoleStats({
    required this.roleName,
    required this.roleDisplayName,
    required this.roleLevel,
    required this.userCount,
    required this.activeCount,
    required this.recentLoginCount,
  });

  factory UserRoleStats.fromJson(Map<String, dynamic> json) {
    return UserRoleStats(
      roleName: json['role_name'] ?? '',
      roleDisplayName: json['role_display_name'] ?? '',
      roleLevel: json['role_level'] ?? 0,
      userCount: json['user_count'] ?? 0,
      activeCount: json['active_count'] ?? 0,
      recentLoginCount: json['recent_login_count'] ?? 0,
    );
  }
}

class CurrentUserInfo {
  final UserModel user;
  final List<dynamic> roles;
  final List<dynamic> permissions;
  final int highestLevel;
  final String? primaryRole;

  CurrentUserInfo({
    required this.user,
    required this.roles,
    required this.permissions,
    required this.highestLevel,
    this.primaryRole,
  });

  factory CurrentUserInfo.fromJson(Map<String, dynamic> json) {
    return CurrentUserInfo(
      user: UserModel.fromJson(json['user'] ?? {}),
      roles: json['roles'] ?? [],
      permissions: json['permissions'] ?? [],
      highestLevel: json['highest_level'] ?? 0,
      primaryRole: json['primary_role'],
    );
  }
}

class UserFilters {
  final String? search;
  final String? role;
  final String? status;
  final int? institutionId;
  final String? institutionName;
  final int? departmentId;
  final String? departmentName;
  final String? level;
  final String? region;
  final String? city;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final DateTime? lastLoginAfter;
  final DateTime? lastLoginBefore;
  final bool? isActive;
  final int? minUserLevel;
  final int? maxUserLevel;
  final String? sortBy;
  final String? sortOrder;
  final int page;
  final int limit;

  UserFilters({
    this.search,
    this.role,
    this.status,
    this.institutionId,
    this.institutionName,
    this.departmentId,
    this.departmentName,
    this.level,
    this.region,
    this.city,
    this.createdAfter,
    this.createdBefore,
    this.lastLoginAfter,
    this.lastLoginBefore,
    this.isActive,
    this.minUserLevel,
    this.maxUserLevel,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'role': role,
      'status': status,
      'institution_id': institutionId,
      'institution_name': institutionName,
      'department_id': departmentId,
      'department_name': departmentName,
      'level': level,
      'region': region,
      'city': city,
      'created_after': createdAfter?.toIso8601String(),
      'created_before': createdBefore?.toIso8601String(),
      'last_login_after': lastLoginAfter?.toIso8601String(),
      'last_login_before': lastLoginBefore?.toIso8601String(),
      'is_active': isActive,
      'min_user_level': minUserLevel,
      'max_user_level': maxUserLevel,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page,
      'limit': limit,
    };
  }

  UserFilters copyWith({
    String? search,
    String? role,
    String? status,
    int? institutionId,
    String? institutionName,
    int? departmentId,
    String? departmentName,
    String? level,
    String? region,
    String? city,
    DateTime? createdAfter,
    DateTime? createdBefore,
    DateTime? lastLoginAfter,
    DateTime? lastLoginBefore,
    bool? isActive,
    int? minUserLevel,
    int? maxUserLevel,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) {
    return UserFilters(
      search: search ?? this.search,
      role: role ?? this.role,
      status: status ?? this.status,
      institutionId: institutionId ?? this.institutionId,
      institutionName: institutionName ?? this.institutionName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      level: level ?? this.level,
      region: region ?? this.region,
      city: city ?? this.city,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      lastLoginAfter: lastLoginAfter ?? this.lastLoginAfter,
      lastLoginBefore: lastLoginBefore ?? this.lastLoginBefore,
      isActive: isActive ?? this.isActive,
      minUserLevel: minUserLevel ?? this.minUserLevel,
      maxUserLevel: maxUserLevel ?? this.maxUserLevel,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  UserFilters reset() {
    return UserFilters(
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: 1,
      limit: limit,
    );
  }

  bool get hasActiveFilters =>
      search != null ||
      role != null ||
      status != null ||
      institutionId != null ||
      institutionName != null ||
      departmentId != null ||
      departmentName != null ||
      level != null ||
      region != null ||
      city != null ||
      createdAfter != null ||
      createdBefore != null ||
      lastLoginAfter != null ||
      lastLoginBefore != null ||
      isActive != null ||
      minUserLevel != null ||
      maxUserLevel != null;
}

enum UserManagementAction {
  view,
  edit,
  delete,
  assignRole,
  activate,
  deactivate,
}

class UserManagementResult {
  final bool success;
  final String message;
  final dynamic data;
  final String? error;

  UserManagementResult({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory UserManagementResult.success(String message, {dynamic data}) {
    return UserManagementResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory UserManagementResult.error(String message, {String? error}) {
    return UserManagementResult(
      success: false,
      message: message,
      error: error,
    );
  }

  factory UserManagementResult.fromJson(Map<String, dynamic> json) {
    return UserManagementResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      error: json['error'],
    );
  }
}
