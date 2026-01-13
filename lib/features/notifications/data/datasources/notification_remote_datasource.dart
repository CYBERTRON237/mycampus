import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycampus/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? isRead,
    String? category,
    String? type,
  });

  Future<NotificationModel> getNotificationById(String id);
  Future<NotificationModel> createNotification(Map<String, dynamic> notificationData);
  Future<bool> markAsRead(String id);
  Future<int> markAllAsRead();
  Future<bool> deleteNotification(String id);
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  NotificationRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://127.0.0.1/mycampus/api/notifications',
  });

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? isRead,
    String? category,
    String? type,
  }) async {
    print('DEBUG: NotificationRemoteDataSource.getNotifications - Début');
    
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (isRead != null && isRead.isNotEmpty) {
        queryParams['is_read'] = isRead;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: queryParams);
      print('DEBUG: NotificationRemoteDataSource.getNotifications - URL: $uri');
      
      final response = await client.get(uri, headers: await _getHeaders());
      print('DEBUG: NotificationRemoteDataSource.getNotifications - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          print('DEBUG: NotificationRemoteDataSource.getNotifications - Erreur PHP détectée');
          throw Exception('Erreur serveur PHP');
        }
        
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final notificationsData = jsonData['data'] as List;
          final result = notificationsData.map((notif) => NotificationModel.fromJson(notif)).toList();
          print('DEBUG: NotificationRemoteDataSource.getNotifications - ${result.length} notifications parsées');
          return result;
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load notifications');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.getNotifications - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    print('DEBUG: NotificationRemoteDataSource.getNotificationById - Début pour ID: $id');
    
    try {
      final uri = Uri.parse('$baseUrl/notifications/$id');
      print('DEBUG: NotificationRemoteDataSource.getNotificationById - URL: $uri');
      
      final response = await client.get(uri, headers: await _getHeaders());
      print('DEBUG: NotificationRemoteDataSource.getNotificationById - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return NotificationModel.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Notification not found');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.getNotificationById - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<NotificationModel> createNotification(Map<String, dynamic> notificationData) async {
    print('DEBUG: NotificationRemoteDataSource.createNotification - Début');
    
    try {
      final uri = Uri.parse('$baseUrl/notifications');
      print('DEBUG: NotificationRemoteDataSource.createNotification - URL: $uri');
      
      final response = await client.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode(notificationData),
      );
      print('DEBUG: NotificationRemoteDataSource.createNotification - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          // Retourner la notification créée avec son ID
          final createdData = Map<String, dynamic>.from(notificationData);
          createdData['id'] = jsonData['data']['id'].toString();
          return NotificationModel.fromJson(createdData);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to create notification');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.createNotification - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<bool> markAsRead(String id) async {
    print('DEBUG: NotificationRemoteDataSource.markAsRead - Début pour ID: $id');
    
    try {
      final uri = Uri.parse('$baseUrl/notifications/$id/read');
      print('DEBUG: NotificationRemoteDataSource.markAsRead - URL: $uri');
      
      final response = await client.put(uri, headers: await _getHeaders());
      print('DEBUG: NotificationRemoteDataSource.markAsRead - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.markAsRead - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<int> markAllAsRead() async {
    print('DEBUG: NotificationRemoteDataSource.markAllAsRead - Début');
    
    try {
      final uri = Uri.parse('$baseUrl/notifications/read-all');
      print('DEBUG: NotificationRemoteDataSource.markAllAsRead - URL: $uri');
      
      final response = await client.put(uri, headers: await _getHeaders());
      print('DEBUG: NotificationRemoteDataSource.markAllAsRead - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['updated_count'] ?? 0;
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to mark all as read');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.markAllAsRead - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<bool> deleteNotification(String id) async {
    print('DEBUG: NotificationRemoteDataSource.deleteNotification - Début pour ID: $id');
    
    try {
      final uri = Uri.parse('$baseUrl/notifications/$id');
      print('DEBUG: NotificationRemoteDataSource.deleteNotification - URL: $uri');
      
      final response = await client.delete(uri, headers: await _getHeaders());
      print('DEBUG: NotificationRemoteDataSource.deleteNotification - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.deleteNotification - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    print('DEBUG: NotificationRemoteDataSource.getUnreadCount - Début');
    
    try {
      final uri = Uri.parse('$baseUrl/notifications/unread-count');
      print('DEBUG: NotificationRemoteDataSource.getUnreadCount - URL: $uri');
      
      final response = await client.get(uri, headers: await _getHeaders());
      print('DEBUG: NotificationRemoteDataSource.getUnreadCount - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['unread_count'] ?? 0;
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to get unread count');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('DEBUG: NotificationRemoteDataSource.getUnreadCount - ERREUR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    // TODO: Implement proper authentication
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Temporarily skip auth token for testing
    // final token = await authService.getToken();
    // if (token != null && token.isNotEmpty) {
    //   headers['Authorization'] = 'Bearer $token';
    // }
    
    return headers;
  }
}
