import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../../auth/services/auth_service.dart';

abstract class MessagingRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel> getConversation(String conversationId);
  Future<void> markConversationAsRead(String conversationId);
  Future<void> deleteConversation(String conversationId);
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<void> muteConversation(String conversationId);
  Future<void> unmuteConversation(String conversationId);

  Future<List<MessageModel>> getMessages(String conversationId, {int? limit, int? offset});
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  });
  Future<MessageModel> editMessage(String messageId, String content);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessageAsRead(String messageId);
  Future<List<MessageModel>> searchMessages(String query);

  // Message status operations
  Future<void> updateMessageStatus(String messageId, String status);
  Future<void> markMessagesAsDelivered(String conversationId);
  Future<void> markMessagesAsRead(String conversationId, {List<String>? messageIds});

  Future<List<UserSearchResult>> searchUsers(String query);
  Future<List<UserSearchResult>> searchUsersByPhone(String phone);
  Future<void> createConversation(String userId);

  // WhatsApp-like message operations
  Future<bool> canEditMessage(String messageId);
  Future<bool> canDeleteForEveryone(String messageId);
  Future<void> deleteMessageForMe(String messageId);
  Future<void> deleteMessageForEveryone(String messageId);
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String? authToken;
  final AuthService _authService = AuthService();

  MessagingRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    this.authToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  @override
  Future<List<ConversationModel>> getConversations() async {
    // Récupérer l'ID utilisateur actuel depuis AuthService
    final authUser = await _authService.getCurrentUser();
    final currentUserId = authUser?.id;
    
    // print('Current user: $currentUser');
    // print('Current user ID: $currentUserId (${currentUserId.runtimeType})');
    
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Utiliser une URL compatible avec le web
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/messages/conversations.php'
        : 'http://127.0.0.1/mycampus/api/messaging/messages/conversations.php';

    final requestHeaders = {
        ..._headers,
        'X-User-Id': currentUserId, // Envoyer l'ID utilisateur dans les headers
      };
      
    // print('Request headers: $requestHeaders');
    // print('Current user ID: $currentUserId (${currentUserId.runtimeType})');

    final response = await client.get(
      Uri.parse(url),
      headers: requestHeaders,
    );

    // print('Get conversations URL: $url');
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = json.decode(response.body);
        // print('JSON decoded successfully, items: ${jsonData.length}');
        return jsonData.map((json) {
          try {
            return ConversationModel.fromJson(json);
          } catch (e) {
            // print('Error parsing conversation: $e');
            // print('JSON data: $json');
            rethrow;
          }
        }).toList();
      } catch (e) {
        // print('Error decoding JSON: $e');
        rethrow;
      }
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return ConversationModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load conversation: ${response.statusCode}');
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId/read'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark conversation as read: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation: ${response.statusCode}');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/messages/users/$userId/block'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to block user: ${response.statusCode}');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/messages/users/$userId/unblock'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unblock user: ${response.statusCode}');
    }
  }

  @override
  Future<void> muteConversation(String conversationId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId/mute'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mute conversation: ${response.statusCode}');
    }
  }

  @override
  Future<void> unmuteConversation(String conversationId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId/unmute'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unmute conversation: ${response.statusCode}');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    // Récupérer l'ID utilisateur actuel depuis AuthService
    final authUser = await _authService.getCurrentUser();
    final currentUserId = authUser?.id;
    
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Utiliser une URL compatible avec le web
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/messages/send_message.php'
        : 'http://127.0.0.1/mycampus/api/messaging/messages/send_message.php';

    final response = await client.post(
      Uri.parse(url),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
        'X-User-Id': currentUserId, // Envoyer l'ID utilisateur dans les headers
      },
      body: json.encode({
        'receiver_id': receiverId,
        'content': content,
        'type': type.name,
        'attachment_url': attachmentUrl,
        'attachment_name': attachmentName,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Request timeout: L\'API met trop de temps à répondre');
      },
    );

    // print('Send message URL: $url');
    // print('Send message response status: ${response.statusCode}');
    // print('Send message response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        return MessageModel.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to send message');
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId, {int? limit, int? offset}) async {
    // Récupérer l'ID utilisateur actuel depuis AuthService
    final authUser = await _authService.getCurrentUser();
    final currentUserId = authUser?.id;
    
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Utiliser une URL compatible avec le web
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/messages/get_messages.php'
        : 'http://127.0.0.1/mycampus/api/messaging/messages/get_messages.php';

    final response = await client.get(
      Uri.parse('$url?id=$conversationId'),
      headers: {
        ..._headers,
        'X-User-Id': currentUserId, // Envoyer l'ID utilisateur dans les headers
      },
    );

    // print('Get messages URL: $url');
    // print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => MessageModel.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized access to conversation');
    } else {
      throw Exception('Failed to load messages: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<MessageModel> editMessage(String messageId, String content) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/messages/$messageId'),
      headers: _headers,
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return MessageModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to edit message: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/messages/$messageId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message: ${response.statusCode}');
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/messages/$messageId/read'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as read: ${response.statusCode}');
    }
  }

  @override
  Future<List<MessageModel>> searchMessages(String query) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/messages/search').replace(queryParameters: {'q': query}),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search messages: ${response.statusCode}');
    }
  }

  @override
  Future<List<UserSearchResult>> searchUsers(String query) async {
    // Utiliser une URL compatible avec le web
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/users/search.php'
        : 'http://127.0.0.1/mycampus/api/messaging/users/search.php';

    final response = await client.get(
      Uri.parse(url).replace(queryParameters: {'q': query}),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> usersJson = data['data'];
        return usersJson.map((json) => UserSearchResult.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to search users: ${response.statusCode} - ${response.body}');
  }

  Future<List<UserSearchResult>> searchUsersByPhone(String phone) async {
    // Utiliser une URL compatible avec le web
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/users/search/phone.php'
        : 'http://127.0.0.1/mycampus/api/messaging/users/search/phone.php';
    
    final response = await client.get(
      Uri.parse(url).replace(queryParameters: {'phone': phone}),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> usersJson = data['data'];
        return usersJson.map((json) => UserSearchResult.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to search users by phone: ${response.statusCode} - ${response.body}');
  }

  @override
  Future<void> createConversation(String userId) async {
    // TODO: Implement createConversation API call
    throw UnimplementedError('createConversation not implemented');
  }

  @override
  Future<bool> canEditMessage(String messageId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/messages/$messageId/can-edit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['can_edit'] ?? false;
    } else {
      return false;
    }
  }

  @override
  Future<bool> canDeleteForEveryone(String messageId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/messages/$messageId/can-delete-for-everyone'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['can_delete_for_everyone'] ?? false;
    } else {
      return false;
    }
  }

  @override
  Future<void> deleteMessageForMe(String messageId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/messages/$messageId/for-me'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message for me: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteMessageForEveryone(String messageId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/messages/$messageId/for-everyone'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message for everyone: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    final response = await client.post(
      Uri.parse('$baseUrl/messages/update_message_status.php'),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'message_id': messageId,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to update message status');
    }
  }

  @override
  Future<void> markMessagesAsDelivered(String conversationId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/messages/mark_messages_delivered.php'),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'conversation_id': conversationId,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to mark messages as delivered');
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, {List<String>? messageIds}) async {
    final response = await client.post(
      Uri.parse('$baseUrl/messages/mark_messages_read.php'),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'conversation_id': conversationId,
        if (messageIds != null) 'message_ids': messageIds,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to mark messages as read');
    }
  }
}
