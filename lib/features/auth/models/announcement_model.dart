// lib/models/announcement_model.dart
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final String? authorRole;
  final String? institutionId;
  final String status;
  final bool isPinned;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorRole,
    this.institutionId,
    this.status = 'draft',
    this.isPinned = false,
    DateTime? publishedAt,
    DateTime? createdAt,
    this.updatedAt,
    this.metadata,
  })  : publishedAt = publishedAt,
        createdAt = createdAt ?? DateTime.now();

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Sans titre',
      content: json['content'] ?? '',
      authorId: json['author_id']?.toString() ?? json['authorId']?.toString() ?? '',
      authorName: json['author_name'] ?? json['authorName'],
      authorAvatar: json['author_avatar'] ?? json['authorAvatar'],
      authorRole: json['author_role'] ?? json['authorRole'],
      institutionId: json['institution_id']?.toString() ?? json['institutionId']?.toString(),
      status: json['status']?.toLowerCase() ?? 'draft',
      isPinned: json['is_pinned'] ?? json['isPinned'] ?? false,
      publishedAt: json['published_at'] != null 
          ? DateTime.tryParse(json['published_at'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'])
          : null,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      if (authorName != null) 'author_name': authorName,
      if (authorAvatar != null) 'author_avatar': authorAvatar,
      if (authorRole != null) 'author_role': authorRole,
      if (institutionId != null) 'institution_id': institutionId,
      'status': status,
      'is_pinned': isPinned,
      if (publishedAt != null) 'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  String get timeAgo {
    final date = publishedAt ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(date);
    
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

  bool get isPublished => status.toLowerCase() == 'published';
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isArchived => status.toLowerCase() == 'archived';
}