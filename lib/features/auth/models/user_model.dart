class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final String? institutionId;
  final String? institutionName;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;
  final String? phone;
  final String? address;
  final String? bio;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.institutionId,
    this.institutionName,
    this.lastLogin,
    this.preferences,
    this.phone,
    this.address,
    this.bio,
  });

  String get fullName => '$firstName $lastName';

  bool get isAdmin => ['admin', 'superadmin', 'admin_local', 'admin_national'].contains(role.toLowerCase());
  bool get isTeacher => ['teacher', 'professor', 'professor_titular'].contains(role.toLowerCase());
  bool get isStudent => role.toLowerCase() == 'student';
  bool get isInvite => role.toLowerCase() == 'invite';
  bool get isSuperAdmin => role.toLowerCase() == 'superadmin';
  bool get isAdminLocal => role.toLowerCase() == 'admin_local';
  bool get isAdminNational => role.toLowerCase() == 'admin_national';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Gestion des champs avec des noms différents ou des valeurs par défaut
    final institution = json['institution'] is Map 
        ? json['institution']
        : {'id': null, 'name': json['institution']?.toString()};
        
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      avatarUrl: json['profile_photo_url'] ?? json['avatar'] ?? json['avatar_url'], 
      role: (json['primary_role']?.toString().toLowerCase() ?? json['role']?.toString().toLowerCase() ?? 'student'),
      isActive: true, 
      institutionId: institution is Map 
          ? institution['id']?.toString() 
          : institution.toString(),
      institutionName: institution is Map
          ? institution['name']?.toString()
          : institution?.toString(),
      lastLogin: null, 
      preferences: {}, 
      phone: json['phone']?.toString(),
      address: null, 
      bio: null, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'role': role,
      'is_active': isActive,
      'institution_id': institutionId,
      'institution_name': institutionName,
      'last_login': lastLogin?.toIso8601String(),
      'preferences': preferences,
      'phone': phone,
      'address': address,
      'bio': bio,
    }..removeWhere((key, value) => value == null);
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? role,
    bool? isActive,
    String? institutionId,
    String? institutionName,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    String? phone,
    String? address,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      institutionId: institutionId ?? this.institutionId,
      institutionName: institutionName ?? this.institutionName,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bio: bio ?? this.bio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, fullName: $fullName, role: $role}';
  }
}