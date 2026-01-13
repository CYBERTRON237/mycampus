import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String? summary;
  final String? content;
  final String? universityCode;
  final String? universityName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>>? attachments;
  final bool isPinned;
  final String? authorName;
  final String? authorAvatar;
  final String? category;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    this.summary,
    this.content,
    this.universityCode,
    this.universityName,
    this.createdAt,
    this.updatedAt,
    this.attachments,
    this.isPinned = false,
    this.authorName,
    this.authorAvatar,
    this.category,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        content,
        universityCode,
        universityName,
        createdAt,
        updatedAt,
        attachments,
        isPinned,
        authorName,
        authorAvatar,
        category,
      ];

  factory AnnouncementEntity.fromJson(Map<String, dynamic> json) {
    return AnnouncementEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      summary: json['summary'],
      content: json['content'],
      universityCode: json['university_code'],
      universityName: json['university_name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      attachments: json['attachments'] != null ? List<Map<String, dynamic>>.from(json['attachments']) : null,
      isPinned: json['is_pinned'] ?? false,
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'university_code': universityCode,
      'university_name': universityName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'attachments': attachments,
      'is_pinned': isPinned,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'category': category,
    };
  }
}
