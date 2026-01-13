class Institution {
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
  final String? type;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? studentCount;
  final int? teacherCount;
  final List<String>? programs;
  final List<String>? facilities;

  const Institution({
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
    this.studentCount,
    this.teacherCount,
    this.programs,
    this.facilities,
  });

  // Créer une copie de l'entité avec des mises à jour optionnelles
  Institution copyWith({
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
    int? studentCount,
    int? teacherCount,
    List<String>? programs,
    List<String>? facilities,
  }) {
    return Institution(
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
      studentCount: studentCount ?? this.studentCount,
      teacherCount: teacherCount ?? this.teacherCount,
      programs: programs ?? this.programs,
      facilities: facilities ?? this.facilities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Institution &&
      other.id == id &&
      other.name == name &&
      other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;

  @override
  String toString() => 'Institution(id: $id, name: $name, type: $type)';
}
