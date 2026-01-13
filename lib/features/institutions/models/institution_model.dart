class InstitutionModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? website;
  final String? type; // e.g., 'university', 'school', 'training_center'
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final int? studentCount;
  final int? teacherCount;
  final List<String>? programs; // Liste des programmes proposés
  final List<String>? facilities; // Équipements disponibles

  InstitutionModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.phone,
    this.email,
    this.website,
    this.type,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.studentCount,
    this.teacherCount,
    this.programs,
    this.facilities,
  });

  // Méthode pour créer une instance à partir d'un JSON
  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString() ?? json['logoUrl']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postal_code']?.toString() ?? json['postalCode']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      type: json['type']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      studentCount: json['student_count'] ?? json['studentCount'],
      teacherCount: json['teacher_count'] ?? json['teacherCount'],
      programs: json['programs'] is List ? List<String>.from(json['programs']) : null,
      facilities: json['facilities'] is List ? List<String>.from(json['facilities']) : null,
    );
  }

  // Méthode pour convertir l'instance en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'address': address,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'website': website,
      'type': type,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
      'student_count': studentCount,
      'teacher_count': teacherCount,
      'programs': programs,
      'facilities': facilities,
    };
  }

  // Créer une copie de l'instance avec des mises à jour optionnelles
  InstitutionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? phone,
    String? email,
    String? website,
    String? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    int? studentCount,
    int? teacherCount,
    List<String>? programs,
    List<String>? facilities,
  }) {
    return InstitutionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      studentCount: studentCount ?? this.studentCount,
      teacherCount: teacherCount ?? this.teacherCount,
      programs: programs ?? this.programs,
      facilities: facilities ?? this.facilities,
    );
  }

  @override
  String toString() => 'InstitutionModel(id: $id, name: $name, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is InstitutionModel &&
      other.id == id &&
      other.name == name &&
      other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}
