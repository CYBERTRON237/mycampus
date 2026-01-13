import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/announcement_model.dart';
import '../../../../../config/api_config.dart';

class AnnouncementRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AnnouncementRemoteDataSource({
    required this.client,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  // Common headers
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response: ${response.body}');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'HTTP Error ${response.statusCode}';
        throw Exception(message);
      } catch (e) {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    }
  }

  // Helper method to construct proper URIs
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    return Uri.http(
      '127.0.0.1',
      '/mycampus/api$path',
      queryParams ?? {},
    );
  }

  // Get all announcements
  Future<Map<String, dynamic>> getAnnouncements({
    int page = 1,
    int limit = 20,
    int? institutionId,
    AnnouncementScope? scope,
    AnnouncementCategory? category,
    AnnouncementStatus? status,
    AnnouncementPriority? priority,
    String? search,
    int? authorId,
    bool publishedOnly = false,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
    if (scope != null) queryParams['scope'] = scope.name;
    if (category != null) queryParams['category'] = category.name;
    if (status != null) queryParams['status'] = status.name;
    if (priority != null) queryParams['priority'] = priority.name;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (authorId != null) queryParams['author_id'] = authorId.toString();
    if (publishedOnly) queryParams['published_only'] = 'true';

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get announcement by ID
  Future<Map<String, dynamic>> getAnnouncementById(
    int id, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements/$id');

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get announcement by UUID
  Future<Map<String, dynamic>> getAnnouncementByUuid(
    String uuid, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements/uuid/$uuid');

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Create announcement
  Future<Map<String, dynamic>> createAnnouncement(
    Map<String, dynamic> announcementData, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements');

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
      body: json.encode(announcementData),
    );

    return _handleResponse(response);
  }

  // Update announcement
  Future<Map<String, dynamic>> updateAnnouncement(
    int id,
    Map<String, dynamic> announcementData, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements/$id');

    final response = await client.put(
      uri,
      headers: _getHeaders(token: token),
      body: json.encode(announcementData),
    );

    return _handleResponse(response);
  }

  // Delete announcement
  Future<Map<String, dynamic>> deleteAnnouncement(
    int id, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements/$id');

    final response = await client.delete(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get announcements for current user
  Future<Map<String, dynamic>> getAnnouncementsForUser({
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = _buildUri('/announcements/user', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics({
    int? institutionId,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();

    final uri = _buildUri('/announcements/stats', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Acknowledge announcement
  Future<Map<String, dynamic>> acknowledgeAnnouncement(
    int announcementId, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements/$announcementId/acknowledge');

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get pending acknowledgments
  Future<Map<String, dynamic>> getPendingAcknowledgments({
    String? token,
  }) async {
    final uri = _buildUri('/announcements/pending');

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Upload attachment
  Future<Map<String, dynamic>> uploadAttachment(
    String filePath,
    String fileName, {
    String? token,
  }) async {
    final uri = _buildUri('/announcements/upload');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_getHeaders(token: token));

    final file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);
    request.fields['filename'] = fileName;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  // Download attachment
  Future<http.Response> downloadAttachment(
    String attachmentUrl, {
    String? token,
  }) async {
    final uri = Uri.parse(attachmentUrl);
    
    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download attachment: ${response.statusCode}');
    }

    return response;
  }

  // Search announcements
  Future<Map<String, dynamic>> searchAnnouncements({
    required String query,
    int page = 1,
    int limit = 20,
    AnnouncementCategory? category,
    AnnouncementScope? scope,
    AnnouncementPriority? priority,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'search': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category.name;
    if (scope != null) queryParams['scope'] = scope.name;
    if (priority != null) queryParams['priority'] = priority.name;

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get pinned announcements
  Future<Map<String, dynamic>> getPinnedAnnouncements({
    int? institutionId,
    AnnouncementScope? scope,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'is_pinned': 'true',
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
    if (scope != null) queryParams['scope'] = scope.name;

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get featured announcements
  Future<Map<String, dynamic>> getFeaturedAnnouncements({
    int? institutionId,
    int limit = 5,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'is_featured': 'true',
      'limit': limit.toString(),
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get announcements by category
  Future<Map<String, dynamic>> getAnnouncementsByCategory({
    required AnnouncementCategory category,
    int page = 1,
    int limit = 20,
    int? institutionId,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'category': category.name,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get announcements by priority
  Future<Map<String, dynamic>> getAnnouncementsByPriority({
    required AnnouncementPriority priority,
    int page = 1,
    int limit = 20,
    int? institutionId,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'priority': priority.name,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get recent announcements
  Future<Map<String, dynamic>> getRecentAnnouncements({
    int limit = 10,
    int? institutionId,
    AnnouncementScope? scope,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'published_only': 'true',
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
    if (scope != null) queryParams['scope'] = scope.name;

    final uri = _buildUri('/announcements', queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Increment view count
  Future<Map<String, dynamic>> incrementViewCount(
    int announcementId, {
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/view',
    );

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Share announcement
  Future<Map<String, dynamic>> shareAnnouncement({
    required int announcementId,
    required String platform,
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/share',
    );

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
      body: json.encode({'platform': platform}),
    );

    return _handleResponse(response);
  }

  // Export announcements
  Future<Map<String, dynamic>> exportAnnouncements({
    AnnouncementCategory? category,
    AnnouncementScope? scope,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
    String? token,
  }) async {
    final queryParams = <String, String>{
      'format': format,
    };

    if (category != null) queryParams['category'] = category.name;
    if (scope != null) queryParams['scope'] = scope.name;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/export',
      queryParams,
    );

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Bulk operations
  Future<Map<String, dynamic>> bulkUpdateStatus({
    required List<int> announcementIds,
    required AnnouncementStatus status,
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/bulk/status',
    );

    final response = await client.put(
      uri,
      headers: _getHeaders(token: token),
      body: json.encode({
        'announcement_ids': announcementIds,
        'status': status.name,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> bulkDelete({
    required List<int> announcementIds,
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/bulk/delete',
    );

    final response = await client.delete(
      uri,
      headers: _getHeaders(token: token),
      body: json.encode({
        'announcement_ids': announcementIds,
      }),
    );

    return _handleResponse(response);
  }

  // Get announcement analytics
  Future<Map<String, dynamic>> getAnnouncementAnalytics(
    int announcementId, {
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/analytics',
    );

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get user permissions
  Future<Map<String, dynamic>> getUserPermissions({
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/permissions',
    );

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Send notifications for announcement
  Future<Map<String, dynamic>> sendAnnouncementNotifications({
    required int announcementId,
    List<int>? specificUserIds,
    bool forceSend = false,
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/notify',
    );

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
      body: json.encode({
        'specific_user_ids': specificUserIds,
        'force_send': forceSend,
      }),
    );

    return _handleResponse(response);
  }

  // Get notification status
  Future<Map<String, dynamic>> getNotificationStatus(
    int announcementId, {
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/notification-status',
    );

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Archive announcement
  Future<Map<String, dynamic>> archiveAnnouncement(
    int announcementId, {
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/archive',
    );

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Restore announcement
  Future<Map<String, dynamic>> restoreAnnouncement(
    int announcementId, {
    String? token,
  }) async {
    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/$announcementId/restore',
    );

    final response = await client.post(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Get archived announcements
  Future<Map<String, dynamic>> getArchivedAnnouncements({
    int page = 1,
    int limit = 20,
    int? institutionId,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'status': 'archived',
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();

    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements',
      queryParams,
    );

    final response = await client.get(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }

  // Clear cache
  Future<Map<String, dynamic>> clearAnnouncementCache({
    int? announcementId,
    int? institutionId,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (announcementId != null) queryParams['announcement_id'] = announcementId.toString();
    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();

    final uri = Uri.https(
      baseUrl.replaceFirst('https://', ''),
      '/api/announcements/cache/clear',
      queryParams,
    );

    final response = await client.delete(
      uri,
      headers: _getHeaders(token: token),
    );

    return _handleResponse(response);
  }
}
