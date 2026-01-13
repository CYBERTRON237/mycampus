class UniversityModel {
  final int id;
  final String name;
  final String? shortName;
  final String? description;
  final String? type;
  final String? address;
  final String? city;
  final String? country;
  final String? website;
  final String? email;
  final String? phone;
  final String? logo;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  UniversityModel({
    required this.id,
    required this.name,
    this.shortName,
    this.description,
    this.type,
    this.address,
    this.city,
    this.country,
    this.website,
    this.email,
    this.phone,
    this.logo,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['short_name'],
      description: json['description'],
      type: json['type'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      website: json['website'],
      email: json['email_official'] ?? json['email'], // Handle both email fields
      phone: json['phone_primary'] ?? json['phone'], // Handle both phone fields
      logo: json['logo_url'] ?? json['logo'], // Handle both logo fields
      isActive: (json['is_active'] is int) ? (json['is_active'] == 1) : (json['is_active'] ?? true),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'description': description,
      'type': type,
      'address': address,
      'city': city,
      'country': country,
      'website': website,
      'email': email,
      'phone': phone,
      'logo': logo,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get displayName => shortName?.isNotEmpty == true ? shortName! : name;
}
