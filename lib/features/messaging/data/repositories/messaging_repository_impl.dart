import 'package:dartz/dartz.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_remote_datasource.dart';
import '../../services/websocket_service.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;
  final String currentUserId;
  final WebSocketService _webSocketService;

  MessagingRepositoryImpl({
    required this.remoteDataSource,
    required this.currentUserId,
  }) : _webSocketService = WebSocketService(userId: currentUserId);

  @override
  Future<Either<String, List<ConversationModel>>> getConversations() async {
    try {
      final conversations = await remoteDataSource.getConversations();
      return Right(conversations);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ConversationModel>> getConversation(String conversationId) async {
    try {
      final conversation = await remoteDataSource.getConversation(conversationId);
      return Right(conversation);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markConversationAsRead(String conversationId) async {
    try {
      await remoteDataSource.markConversationAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteConversation(String conversationId) async {
    try {
      await remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> blockUser(String userId) async {
    try {
      await remoteDataSource.blockUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> unblockUser(String userId) async {
    try {
      await remoteDataSource.unblockUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> muteConversation(String conversationId) async {
    try {
      await remoteDataSource.muteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> unmuteConversation(String conversationId) async {
    try {
      await remoteDataSource.unmuteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<MessageModel>>> getMessages(
    String conversationId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final messages = await remoteDataSource.getMessages(
        conversationId,
        limit: limit,
        offset: offset,
      );
      
      // Mark messages as from me or not
      final messagesWithDirection = messages.map((message) {
        return message.copyWith(
          // We'll use a different approach since MessageModel doesn't have isFromMe field
        );
      }).toList();
      
      return Right(messagesWithDirection);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MessageModel>> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    try {
      // Sauvegarder via HTTP pour persistance UNIQUEMENT
      final message = await remoteDataSource.sendMessage(
        receiverId: receiverId,
        content: content,
        type: type,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
      );
      
      // print('Message sauvegardé via API: ${message.id}');
      return Right(message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MessageModel>> editMessage(String messageId, String content) async {
    try {
      final message = await remoteDataSource.editMessage(messageId, content);
      return Right(message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteMessage(String messageId, {bool deleteForEveryone = false}) async {
    try {
      if (deleteForEveryone) {
        await remoteDataSource.deleteMessageForEveryone(messageId);
      } else {
        await remoteDataSource.deleteMessageForMe(messageId);
      }
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markMessageAsRead(String messageId) async {
    try {
      await remoteDataSource.markMessageAsRead(messageId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<MessageModel>>> searchMessages(String query) async {
    try {
      final messages = await remoteDataSource.searchMessages(query);
      return Right(messages);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<UserSearchResult>>> searchUsers(String query) async {
    try {
      final users = await remoteDataSource.searchUsers(query);
      return Right(users);
    } catch (e) {
      return Left('Failed to search users: $e');
    }
  }

  @override
  Future<Either<String, List<UserSearchResult>>> searchUsersByPhone(String phone) async {
    try {
      final users = await remoteDataSource.searchUsersByPhone(phone);
      return Right(users);
    } catch (e) {
      return Left('Failed to search users by phone: $e');
    }
  }

  @override
  Future<Either<String, void>> createConversation(String userId) async {
    try {
      await remoteDataSource.createConversation(userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<List<MessageModel>> getMessageStream(String conversationId) {
    // Connecter à la room WebSocket
    _webSocketService.joinRoom(conversationId);
    
    // Retourner le stream de messages WebSocket
    return _webSocketService.messageStream
        .where((message) => message.conversationId == conversationId)
        .map((message) => [message]);
  }

  @override
  Stream<List<ConversationModel>> getConversationStream() {
    // This would typically use WebSocket or Firebase Realtime Database
    // For now, return an empty stream
    return Stream.empty();
  }

  @override
  Stream<Map<String, int>> getUnreadCountStream() {
    // This would typically use WebSocket or Firebase Realtime Database
    // For now, return an empty stream
    return Stream.empty();
  }

  @override
  Future<Either<String, bool>> canEditMessage(String messageId) async {
    try {
      final canEdit = await remoteDataSource.canEditMessage(messageId);
      return Right(canEdit);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> canDeleteForEveryone(String messageId) async {
    try {
      final canDelete = await remoteDataSource.canDeleteForEveryone(messageId);
      return Right(canDelete);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteMessageForMe(String messageId) async {
    try {
      await remoteDataSource.deleteMessageForMe(messageId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteMessageForEveryone(String messageId) async {
    try {
      await remoteDataSource.deleteMessageForEveryone(messageId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateMessageStatus(String messageId, String status) async {
    try {
      await remoteDataSource.updateMessageStatus(messageId, status);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markMessagesAsDelivered(String conversationId) async {
    try {
      await remoteDataSource.markMessagesAsDelivered(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markMessagesAsRead(String conversationId, {List<String>? messageIds}) async {
    try {
      await remoteDataSource.markMessagesAsRead(conversationId, messageIds: messageIds);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
