import 'package:equatable/equatable.dart';

enum UniversityType {
  public,
  private,
  confessional;

  String get name {
    switch (this) {
      case UniversityType.public:
        return 'public';
      case UniversityType.private:
        return 'private';
      case UniversityType.confessional:
        return 'confessional';
    }
  }
}

enum UniversityStatus {
  active,
  inactive,
  suspended,
  pending;

  String get name {
    switch (this) {
      case UniversityStatus.active:
        return 'active';
      case UniversityStatus.inactive:
        return 'inactive';
      case UniversityStatus.suspended:
        return 'suspended';
      case UniversityStatus.pending:
        return 'pending';
    }
  }
}

class UniversityModel extends Equatable {
  final String id;
  final String uuid;
  final String code;
  final String name;
  final String shortName;
  final UniversityType type;
  final UniversityStatus status;
  final String country;
  final String region;
  final String city;
  final String? address;
  final String? postalCode;
  final String? phonePrimary;
  final String? phoneSecondary;
  final String? emailOfficial;
  final String? emailAdmin;
  final String? website;
  final String? logoUrl;
  final String? bannerUrl;
  final String? description;
  final int? foundedYear;
  final String? rectorName;
  final int totalStudents;
  final int totalStaff;
  final bool isNationalHub;
  final bool isActive;
  final bool isVerified;
  final bool syncEnabled;
  final DateTime? lastSyncAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UniversityModel({
    required this.id,
    required this.uuid,
    required this.code,
    required this.name,
    required this.shortName,
    required this.type,
    required this.status,
    required this.country,
    required this.region,
    required this.city,
    this.address,
    this.postalCode,
    this.phonePrimary,
    this.phoneSecondary,
    this.emailOfficial,
    this.emailAdmin,
    this.website,
    this.logoUrl,
    this.bannerUrl,
    this.description,
    this.foundedYear,
    this.rectorName,
    this.totalStudents = 0,
    this.totalStaff = 0,
    this.isNationalHub = false,
    this.isActive = true,
    this.isVerified = false,
    this.syncEnabled = true,
    this.lastSyncAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  UniversityModel copyWith({
    String? id,
    String? uuid,
    String? code,
    String? name,
    String? shortName,
    UniversityType? type,
    UniversityStatus? status,
    String? country,
    String? region,
    String? city,
    String? address,
    String? postalCode,
    String? phonePrimary,
    String? phoneSecondary,
    String? emailOfficial,
    String? emailAdmin,
    String? website,
    String? logoUrl,
    String? bannerUrl,
    String? description,
    int? foundedYear,
    String? rectorName,
    int? totalStudents,
    int? totalStaff,
    bool? isNationalHub,
    bool? isActive,
    bool? isVerified,
    bool? syncEnabled,
    DateTime? lastSyncAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UniversityModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      type: type ?? this.type,
      status: status ?? this.status,
      country: country ?? this.country,
      region: region ?? this.region,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      phonePrimary: phonePrimary ?? this.phonePrimary,
      phoneSecondary: phoneSecondary ?? this.phoneSecondary,
      emailOfficial: emailOfficial ?? this.emailOfficial,
      emailAdmin: emailAdmin ?? this.emailAdmin,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      description: description ?? this.description,
      foundedYear: foundedYear ?? this.foundedYear,
      rectorName: rectorName ?? this.rectorName,
      totalStudents: totalStudents ?? this.totalStudents,
      totalStaff: totalStaff ?? this.totalStaff,
      isNationalHub: isNationalHub ?? this.isNationalHub,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'].toString(),
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? json['shortName'] ?? '',
      type: UniversityType.values.firstWhere(
        (type) => type.name == (json['type'] ?? 'university'),
        orElse: () => UniversityType.public,
      ),
      status: UniversityStatus.values.firstWhere(
        (status) => status.name == (json['status'] ?? 'active'),
        orElse: () => UniversityStatus.active,
      ),
      country: json['country'] ?? 'Cameroun',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      address: json['address'],
      postalCode: json['postal_code'],
      phonePrimary: json['phone_primary'],
      phoneSecondary: json['phone_secondary'],
      emailOfficial: json['email_official'],
      emailAdmin: json['email_admin'],
      website: json['website'],
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      description: json['description'],
      foundedYear: json['founded_year'] != null ? int.tryParse(json['founded_year'].toString()) : null,
      rectorName: json['rector_name'],
      totalStudents: json['total_students'] != null ? int.tryParse(json['total_students'].toString()) ?? 0 : 0,
      totalStaff: json['total_staff'] != null ? int.tryParse(json['total_staff'].toString()) ?? 0 : 0,
      isNationalHub: json['is_national_hub'] == 1 || json['isNationalHub'] == true,
      isActive: json['is_active'] == 1 || json['isActive'] == true,
      isVerified: json['is_verified'] == 1 || json['isVerified'] == true,
      syncEnabled: json['sync_enabled'] == 1 || json['syncEnabled'] == true,
      lastSyncAt: json['last_sync_at'] != null ? DateTime.tryParse(json['last_sync_at']) : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'code': code,
      'name': name,
      'short_name': shortName,
      'type': type.name,
      'status': status.name,
      'country': country,
      'region': region,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'phone_primary': phonePrimary,
      'phone_secondary': phoneSecondary,
      'email_official': emailOfficial,
      'email_admin': emailAdmin,
      'website': website,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'description': description,
      'founded_year': foundedYear,
      'rector_name': rectorName,
      'total_students': totalStudents,
      'total_staff': totalStaff,
      'is_national_hub': isNationalHub ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'sync_enabled': syncEnabled ? 1 : 0,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        code,
        name,
        shortName,
        type,
        status,
        country,
        region,
        city,
        address,
        postalCode,
        phonePrimary,
        phoneSecondary,
        emailOfficial,
        emailAdmin,
        website,
        logoUrl,
        bannerUrl,
        description,
        foundedYear,
        rectorName,
        totalStudents,
        totalStaff,
        isNationalHub,
        isActive,
        isVerified,
        syncEnabled,
        lastSyncAt,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UniversityModel(id: $id, name: $name, code: $code)';
  }

  /// Getter pour obtenir une description formatée
  String get formattedDescription {
    switch (type.name) {
      case 'public':
        return 'Université publique d\'excellence';
      case 'private':
        return 'Université privée d\'excellence';
      case 'confessional':
        return 'Université confessionnelle d\'excellence';
      default:
        return description?.isNotEmpty == true ? description! : 'Établissement d\'enseignement';
    }
  }

  /// Getter pour obtenir l'icône appropriée selon le type
  String get iconType {
    switch (type.name) {
      case 'public':
        return 'school';
      case 'private':
        return 'account_balance';
      case 'confessional':
        return 'business';
      default:
        return 'location_city';
    }
  }

  /// Getter pour obtenir la couleur appropriée selon le type
  String get colorType {
    switch (type.name) {
      case 'public':
        return 'blue';
      case 'private':
        return 'purple';
      case 'confessional':
        return 'green';
      default:
        return 'orange';
    }
  }
}
