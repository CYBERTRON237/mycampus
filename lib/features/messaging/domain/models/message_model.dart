class SenderInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  SenderInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['profile_photo_url']?.toString() ?? json['profile_picture']?.toString() ?? json['avatar']?.toString(),
    );
  }

  String get fullName => '$firstName $lastName';
}

class MessageModel {
  final String id;
  final String? conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? readAt;
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isDeleted;
  final Map<String, dynamic>? metadata;
  final SenderInfo? sender;
  final SenderInfo? receiver;
  
  // WhatsApp-like properties
  final bool isEdited;
  final DateTime? editedAt;
  final bool deletedForEveryone;
  final String? deleteType; // 'me' or 'everyone'
  final String? deletedBy;
  final DateTime? deletedAt;

  MessageModel({
    required this.id,
    this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.updatedAt,
    this.readAt,
    this.attachmentUrl,
    this.attachmentName,
    this.isDeleted = false,
    this.metadata,
    this.sender,
    this.receiver,
    this.isEdited = false,
    this.editedAt,
    this.deletedForEveryone = false,
    this.deleteType,
    this.deletedBy,
    this.deletedAt,
  });

  bool get isRead => readAt != null;
  bool get isFromMe => false; // Will be set based on current user
  bool get hasAttachment => attachmentUrl != null;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString(),
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? json['delivery_status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? json['sent_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      attachmentUrl: json['attachment_url']?.toString(),
      attachmentName: json['attachment_name']?.toString(),
      isDeleted: (json['is_deleted'] is bool) ? json['is_deleted'] : (json['is_deleted'] == 1 || json['is_deleted'] == '1'),
      metadata: metadata,
      sender: json['sender'] != null ? SenderInfo.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? SenderInfo.fromJson(json['receiver']) : null,
      
      // WhatsApp-like properties from metadata or direct fields
      isEdited: json['is_edited'] is bool ? json['is_edited'] : (metadata?['edited'] == true),
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at']) : 
                (metadata?['edited_at'] != null ? DateTime.parse(metadata!['edited_at']) : null),
      deletedForEveryone: json['deleted_for_everyone'] is bool ? json['deleted_for_everyone'] : 
                         (metadata?['deleted_for_everyone'] == true),
      deleteType: json['delete_type']?.toString() ?? metadata?['delete_type']?.toString(),
      deletedBy: json['deleted_by']?.toString(),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'is_deleted': isDeleted,
      'metadata': metadata,
    }..removeWhere((key, value) => value == null);
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    String? attachmentUrl,
    String? attachmentName,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
    SenderInfo? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readAt: readAt ?? this.readAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
      sender: sender ?? this.sender,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel{id: $id, senderId: $senderId, receiverId: $receiverId, content: ${content.length > 50 ? content.substring(0, 50) + '...' : content}}';
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  system,
  sticker,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ConversationModel {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final bool isOnline;
  final bool isBlocked;
  final bool isMuted;

  ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
    this.isOnline = false,
    this.isBlocked = false,
    this.isMuted = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ConversationModel(
        id: json['id']?.toString() ?? '',
        participantId: json['participant_id']?.toString() ?? '',
        participantName: json['participant_name']?.toString() ?? '',
        participantAvatar: json['participant_avatar']?.toString(),
        lastMessage: json['last_message'] != null 
            ? MessageModel.fromJson(json['last_message'])
            : null,
        unreadCount: json['unread_count'] ?? 0,
        lastActivity: json['last_activity'] != null 
            ? DateTime.parse(json['last_activity']) 
            : DateTime.now(),
        isOnline: json['is_online'] ?? false,
        isBlocked: json['is_blocked'] ?? false,
        isMuted: json['is_muted'] ?? false,
      );
    } catch (e) {
      print('Error parsing ConversationModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'participant_name': participantName,
      'participant_avatar': participantAvatar,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'last_activity': lastActivity.toIso8601String(),
      'is_online': isOnline,
      'is_blocked': isBlocked,
      'is_muted': isMuted,
    }..removeWhere((key, value) => value == null);
  }

  ConversationModel copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    MessageModel? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    bool? isOnline,
    bool? isBlocked,
    bool? isMuted,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversationModel{id: $id, participantName: $participantName, unreadCount: $unreadCount}';
  }
}
