import 'package:equatable/equatable.dart';

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum NotificationCategory {
  message,
  group,
  post,
  comment,
  reaction,
  announcement,
  opportunity,
  system,
  academic,
  security,
}

enum NotificationType {
  announcement,
  message,
  offer,
  group,
  system,
  mention,
  post,
  comment,
  reaction,
  opportunity,
  academic,
  security,
}

class Notification extends Equatable {
  final String? id;
  final String userId;
  final String type;
  final NotificationType notificationType;
  final NotificationCategory category;
  final String title;
  final String? body;
  final String content;
  final String? icon;
  final String? imageUrl;
  final String? actionUrl;
  final String? actionType;
  final String? relatedId;
  final String? relatedType;
  final String? actorId;
  final String? actorName;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime? readAt;
  final bool isSentPush;
  final DateTime? sentPushAt;
  final bool isSentEmail;
  final DateTime? sentEmailAt;
  final Map<String, dynamic>? metadata;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const Notification({
    this.id,
    required this.userId,
    required this.type,
    required this.notificationType,
    required this.category,
    required this.title,
    this.body,
    required this.content,
    this.icon,
    this.imageUrl,
    this.actionUrl,
    this.actionType,
    this.relatedId,
    this.relatedType,
    this.actorId,
    this.actorName,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.readAt,
    this.isSentPush = false,
    this.sentPushAt,
    this.isSentEmail = false,
    this.sentEmailAt,
    this.metadata,
    this.expiresAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        notificationType,
        category,
        title,
        body,
        content,
        icon,
        imageUrl,
        actionUrl,
        actionType,
        relatedId,
        relatedType,
        actorId,
        actorName,
        priority,
        isRead,
        readAt,
        isSentPush,
        sentPushAt,
        isSentEmail,
        sentEmailAt,
        metadata,
        expiresAt,
        createdAt,
      ];

  Notification copyWith({
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
    return Notification(
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
