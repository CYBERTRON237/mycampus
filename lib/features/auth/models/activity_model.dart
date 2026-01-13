// lib/models/activity_model.dart
class ActivityModel {
  final String id;
  final String type;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final String userId;
  final String? institutionId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ActivityModel({
    required this.id,
    required this.type,
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.userId,
    this.institutionId,
    DateTime? createdAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      referenceId: json['reference_id']?.toString() ?? json['referenceId']?.toString(),
      referenceType: json['reference_type']?.toString() ?? json['referenceType']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      institutionId: json['institution_id']?.toString() ?? json['institutionId']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'user_id': userId,
      'institution_id': institutionId,
      'created_at': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return 'Il y a ${(difference.inDays / 30).floor()} mois';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heures';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else {
      return 'À l\'instant';
    }
  }
}