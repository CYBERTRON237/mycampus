import 'package:equatable/equatable.dart';

class OpportunityEntity extends Equatable {
  final String id;
  final String title;
  final String type; // 'Stage', 'Emploi', 'Bourse', etc.
  final String company;
  final String location;
  final DateTime? deadline;
  final String? description;
  final List<String>? requirements;
  final bool isUrgent;
  final bool isFavorite;
  final String? imageUrl;
  final DateTime? postedAt;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final String? salary;
  final String? duration;
  final String? workMode; // 'Présentiel', 'Distanciel', 'Hybride'
  final String? experienceLevel; // 'Débutant', 'Intermédiaire', 'Expérimenté'

  const OpportunityEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.company,
    required this.location,
    this.deadline,
    this.description,
    this.requirements,
    this.isUrgent = false,
    this.isFavorite = false,
    this.imageUrl,
    this.postedAt,
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.salary,
    this.duration,
    this.workMode,
    this.experienceLevel,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        company,
        location,
        deadline,
        isUrgent,
        isFavorite,
      ];

  factory OpportunityEntity.fromJson(Map<String, dynamic> json) {
    return OpportunityEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'Autre',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      description: json['description'],
      requirements: json['requirements'] != null ? List<String>.from(json['requirements']) : null,
      isUrgent: json['is_urgent'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      imageUrl: json['image_url'],
      postedAt: json['posted_at'] != null ? DateTime.parse(json['posted_at']) : null,
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      website: json['website'],
      salary: json['salary'],
      duration: json['duration'],
      workMode: json['work_mode'],
      experienceLevel: json['experience_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'company': company,
      'location': location,
      'deadline': deadline?.toIso8601String(),
      'description': description,
      'requirements': requirements,
      'is_urgent': isUrgent,
      'is_favorite': isFavorite,
      'image_url': imageUrl,
      'posted_at': postedAt?.toIso8601String(),
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'website': website,
      'salary': salary,
      'duration': duration,
      'work_mode': workMode,
      'experience_level': experienceLevel,
    };
  }

  OpportunityEntity copyWith({
    String? id,
    String? title,
    String? type,
    String? company,
    String? location,
    DateTime? deadline,
    String? description,
    List<String>? requirements,
    bool? isUrgent,
    bool? isFavorite,
    String? imageUrl,
    DateTime? postedAt,
    String? contactEmail,
    String? contactPhone,
    String? website,
    String? salary,
    String? duration,
    String? workMode,
    String? experienceLevel,
  }) {
    return OpportunityEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      company: company ?? this.company,
      location: location ?? this.location,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      isUrgent: isUrgent ?? this.isUrgent,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
      postedAt: postedAt ?? this.postedAt,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      salary: salary ?? this.salary,
      duration: duration ?? this.duration,
      workMode: workMode ?? this.workMode,
      experienceLevel: experienceLevel ?? this.experienceLevel,
    );
  }
}
