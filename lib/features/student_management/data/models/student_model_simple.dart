class StudentModelSimple {
  final int id;
  final String uuid;
  final String? matricule;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? country;
  final String primaryRole;
  final String? level;
  final String accountStatus;
  final bool isVerified;
  final bool isActive;
  final int? institutionId;
  final String? createdAt;
  final String? lastLoginAt;
  final String? institutionName;
  final String? institutionShortName;
  final String? levelDisplay;

  StudentModelSimple({
    required this.id,
    required this.uuid,
    this.matricule,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.country,
    required this.primaryRole,
    this.level,
    required this.accountStatus,
    required this.isVerified,
    required this.isActive,
    this.institutionId,
    this.createdAt,
    this.lastLoginAt,
    this.institutionName,
    this.institutionShortName,
    this.levelDisplay,
  });

  factory StudentModelSimple.fromJson(Map<String, dynamic> json) {
    return StudentModelSimple(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      matricule: json['matricule'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      primaryRole: json['primary_role'] ?? '',
      level: json['level'],
      accountStatus: json['account_status'] ?? '',
      isVerified: (json['is_verified'] ?? 0) == 1,
      isActive: (json['is_active'] ?? 0) == 1,
      institutionId: json['institution_id'],
      createdAt: json['created_at'],
      lastLoginAt: json['last_login_at'],
      institutionName: json['institution_name'],
      institutionShortName: json['institution_short_name'],
      levelDisplay: json['level_display'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'matricule': matricule,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'address': address,
      'city': city,
      'country': country,
      'primary_role': primaryRole,
      'level': level,
      'account_status': accountStatus,
      'is_verified': isVerified ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'institution_id': institutionId,
      'created_at': createdAt,
      'last_login_at': lastLoginAt,
      'institution_name': institutionName,
      'institution_short_name': institutionShortName,
      'level_display': levelDisplay,
    };
  }

  String get fullName => '$firstName $lastName';
  
  String get status {
    switch (accountStatus) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      case 'suspended':
        return 'Suspendu';
      case 'banned':
        return 'Banni';
      case 'pending_verification':
        return 'En attente';
      case 'graduated':
        return 'Diplômé';
      default:
        return 'Inconnu';
    }
  }
}
