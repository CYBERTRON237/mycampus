import 'package:mycampus/features/notifications/domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    super.id,
    required super.userId,
    required super.type,
    required super.notificationType,
    required super.category,
    required super.title,
    super.body,
    required super.content,
    super.icon,
    super.imageUrl,
    super.actionUrl,
    super.actionType,
    super.relatedId,
    super.relatedType,
    super.actorId,
    super.actorName,
    super.priority,
    super.isRead,
    super.readAt,
    super.isSentPush,
    super.sentPushAt,
    super.isSentEmail,
    super.sentEmailAt,
    super.metadata,
    super.expiresAt,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      type: json['type'] ?? 'system',
      notificationType: _mapNotificationType(json['notification_type'] ?? 'system'),
      category: _mapCategory(json['category'] ?? 'system'),
      title: json['title'] ?? '',
      body: json['body'],
      content: json['content'] ?? '',
      icon: json['icon'],
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
      actionType: json['action_type'],
      relatedId: json['related_id']?.toString(),
      relatedType: json['related_type'],
      actorId: json['actor_id']?.toString(),
      actorName: json['actor_name'],
      priority: _mapPriority(json['priority'] ?? 'normal'),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      isSentPush: json['is_sent_push'] ?? false,
      sentPushAt: json['sent_push_at'] != null ? DateTime.parse(json['sent_push_at']) : null,
      isSentEmail: json['is_sent_email'] ?? false,
      sentEmailAt: json['sent_email_at'] != null ? DateTime.parse(json['sent_email_at']) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'notification_type': notificationType.name,
      'category': category.name,
      'title': title,
      'body': body,
      'content': content,
      'icon': icon,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'action_type': actionType,
      'related_id': relatedId,
      'related_type': relatedType,
      'actor_id': actorId,
      'priority': priority.name,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'is_sent_push': isSentPush,
      'sent_push_at': sentPushAt?.toIso8601String(),
      'is_sent_email': isSentEmail,
      'sent_email_at': sentEmailAt?.toIso8601String(),
      'metadata': metadata,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static NotificationType _mapNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'announcement':
        return NotificationType.announcement;
      case 'message':
        return NotificationType.message;
      case 'offer':
        return NotificationType.offer;
      case 'group':
        return NotificationType.group;
      case 'system':
        return NotificationType.system;
      case 'mention':
        return NotificationType.mention;
      case 'post':
        return NotificationType.post;
      case 'comment':
        return NotificationType.comment;
      case 'reaction':
        return NotificationType.reaction;
      case 'opportunity':
        return NotificationType.opportunity;
      case 'academic':
        return NotificationType.academic;
      case 'security':
        return NotificationType.security;
      default:
        return NotificationType.system;
    }
  }

  static NotificationCategory _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'message':
        return NotificationCategory.message;
      case 'group':
        return NotificationCategory.group;
      case 'post':
        return NotificationCategory.post;
      case 'comment':
        return NotificationCategory.comment;
      case 'reaction':
        return NotificationCategory.reaction;
      case 'announcement':
        return NotificationCategory.announcement;
      case 'opportunity':
        return NotificationCategory.opportunity;
      case 'system':
        return NotificationCategory.system;
      case 'academic':
        return NotificationCategory.academic;
      case 'security':
        return NotificationCategory.security;
      default:
        return NotificationCategory.system;
    }
  }

  static NotificationPriority _mapPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  NotificationModel copyWithModel({
    String? id,
    String? userId,
    String? type,
    NotificationType? notificationType,
    NotificationCategory? category,
    String? title,
    String? body,
    String? content,
    String? icon,
    String? imageUrl,
    String? actionUrl,
    String? actionType,
    String? relatedId,
    String? relatedType,
    String? actorId,
    String? actorName,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? readAt,
    bool? isSentPush,
    DateTime? sentPushAt,
    bool? isSentEmail,
    DateTime? sentEmailAt,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      notificationType: notificationType ?? this.notificationType,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      actionType: actionType ?? this.actionType,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isSentPush: isSentPush ?? this.isSentPush,
      sentPushAt: sentPushAt ?? this.sentPushAt,
      isSentEmail: isSentEmail ?? this.isSentEmail,
      sentEmailAt: sentEmailAt ?? this.sentEmailAt,
      metadata: metadata ?? this.metadata,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
