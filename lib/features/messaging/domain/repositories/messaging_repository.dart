import 'package:dartz/dartz.dart';
import '../models/message_model.dart';

abstract class MessagingRepository {
  // Conversation operations
  Future<Either<String, List<ConversationModel>>> getConversations();
  Future<Either<String, ConversationModel>> getConversation(String conversationId);
  Future<Either<String, void>> markConversationAsRead(String conversationId);
  Future<Either<String, void>> deleteConversation(String conversationId);
  Future<Either<String, void>> blockUser(String userId);
  Future<Either<String, void>> unblockUser(String userId);
  Future<Either<String, void>> muteConversation(String conversationId);
  Future<Either<String, void>> unmuteConversation(String conversationId);

  // Message operations
  Future<Either<String, List<MessageModel>>> getMessages(String conversationId, {int? limit, int? offset});
  Future<Either<String, MessageModel>> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  });
  Future<Either<String, MessageModel>> editMessage(String messageId, String content);
  Future<Either<String, void>> deleteMessage(String messageId, {bool deleteForEveryone = false});
  Future<Either<String, void>> markMessageAsRead(String messageId);
  Future<Either<String, List<MessageModel>>> searchMessages(String query);
  
  // Message status operations
  Future<Either<String, void>> updateMessageStatus(String messageId, String status);
  Future<Either<String, void>> markMessagesAsDelivered(String conversationId);
  Future<Either<String, void>> markMessagesAsRead(String conversationId, {List<String>? messageIds});
  
  // WhatsApp-like message operations
  Future<Either<String, void>> deleteMessageForMe(String messageId);
  Future<Either<String, void>> deleteMessageForEveryone(String messageId);
  Future<Either<String, bool>> canEditMessage(String messageId);
  Future<Either<String, bool>> canDeleteForEveryone(String messageId);

  // User search for new conversations
  Future<Either<String, List<UserSearchResult>>> searchUsers(String query);
  Future<Either<String, List<UserSearchResult>>> searchUsersByPhone(String phone);
  Future<Either<String, void>> createConversation(String userId);

  // Real-time updates
  Stream<List<MessageModel>> getMessageStream(String conversationId);
  Stream<List<ConversationModel>> getConversationStream();
  Stream<Map<String, int>> getUnreadCountStream();
}

class UserSearchResult {
  final String id;
  final String name;
  final String? avatar;
  final String role;
  final String? institution;
  final String? phone;

  UserSearchResult({
    required this.id,
    required this.name,
    this.avatar,
    required this.role,
    this.institution,
    this.phone,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id']?.toString() ?? '',
      name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      avatar: json['profile_photo_url']?.toString() ?? json['profile_picture']?.toString(),
      role: json['primary_role']?.toString() ?? 'student',
      institution: 'MyCampus',
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'role': role,
      'institution': institution,
    }..removeWhere((key, value) => value == null);
  }
}
