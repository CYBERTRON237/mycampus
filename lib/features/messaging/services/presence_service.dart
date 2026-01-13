import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final AuthService _authService = AuthService();
  Timer? _heartbeatTimer;
  Timer? _cleanupTimer;
  bool _isTracking = false;
  String? _currentUserId;

  // Stream pour les mises à jour de présence
  final StreamController<PresenceUpdate> _presenceStreamController = 
      StreamController<PresenceUpdate>.broadcast();
  
  Stream<PresenceUpdate> get presenceStream => _presenceStreamController.stream;

  // Démarrer le suivi de présence
  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      final authUser = await _authService.getCurrentUser();
      _currentUserId = authUser?.id.toString();

      if (_currentUserId == null) {
        print('User not authenticated, cannot start presence tracking');
        return;
      }

      _isTracking = true;

      // Envoyer le statut en ligne immédiatement
      await _updatePresence(isOnline: true, status: 'online');

      // Démarrer le heartbeat (toutes les 2 minutes)
      _heartbeatTimer = Timer.periodic(Duration(minutes: 2), (_) {
        _sendHeartbeat();
      });

      // Démarrer le cleanup (toutes les 10 minutes)
      _cleanupTimer = Timer.periodic(Duration(minutes: 10), (_) {
        _cleanupOldPresence();
      });

      print('Presence tracking started for user $_currentUserId');
    } catch (e) {
      print('Error starting presence tracking: $e');
    }
  }

  // Arrêter le suivi de présence
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _isTracking = false;

    // Annuler les timers
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();

    // Envoyer le statut hors ligne
    await _updatePresence(isOnline: false, status: 'offline');

    print('Presence tracking stopped');
  }

  // Envoyer un heartbeat pour maintenir le statut en ligne
  Future<void> _sendHeartbeat() async {
    if (!_isTracking) return;

    try {
      await _updatePresence(isOnline: true, status: 'online');
      print('Presence heartbeat sent');
    } catch (e) {
      print('Error sending heartbeat: $e');
    }
  }

  // Mettre à jour le statut de présence
  Future<void> _updatePresence({
    required bool isOnline,
    String status = 'online',
    String deviceType = 'web',
  }) async {
    try {
      final token = await _authService.getToken();
      
      String url = kIsWeb 
          ? 'http://localhost/mycampus/api/messaging/presence/update_presence.php'
          : 'http://127.0.0.1/mycampus/api/messaging/presence/update_presence.php';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-User-Id': _currentUserId!,
        },
        body: json.encode({
          'is_online': isOnline,
          'status': status,
          'device_type': deviceType,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Émettre l'événement de mise à jour
          _presenceStreamController.add(PresenceUpdate(
            userId: int.parse(_currentUserId!),
            isOnline: isOnline,
            status: status,
            lastSeen: data['data']['last_seen'],
          ));
        }
      } else {
        print('Failed to update presence: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating presence: $e');
    }
  }

  // Obtenir le statut de présence d'un utilisateur
  Future<UserPresence?> getUserPresence(int userId) async {
    try {
      final token = await _authService.getToken();
      
      String url = kIsWeb 
          ? 'http://localhost/mycampus/api/messaging/presence/get_user_presence.php'
          : 'http://127.0.0.1/mycampus/api/messaging/presence/get_user_presence.php';

      final response = await http.get(
        Uri.parse('$url?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-User-Id': _currentUserId!,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return UserPresence.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error getting user presence: $e');
    }
    return null;
  }

  // Obtenir la liste des utilisateurs en ligne
  Future<List<OnlineUser>> getOnlineUsers({int limit = 50, int offset = 0}) async {
    try {
      final token = await _authService.getToken();
      
      String url = kIsWeb 
          ? 'http://localhost/mycampus/api/messaging/presence/get_online_users.php'
          : 'http://127.0.0.1/mycampus/api/messaging/presence/get_online_users.php';

      final response = await http.get(
        Uri.parse('$url?limit=$limit&offset=$offset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-User-Id': _currentUserId!,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersJson = data['data'];
          return usersJson.map((json) => OnlineUser.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error getting online users: $e');
    }
    return [];
  }

  // Nettoyer les anciennes présences (appel serveur)
  Future<void> _cleanupOldPresence() async {
    try {
      String url = kIsWeb 
          ? 'http://localhost/mycampus/api/messaging/presence/cleanup.php'
          : 'http://127.0.0.1/mycampus/api/messaging/presence/cleanup.php';

      await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': _currentUserId!,
        },
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Ignorer les erreurs de cleanup
      print('Cleanup error (ignored): $e');
    }
  }

  // Changer manuellement le statut
  Future<void> setStatus(String status) async {
    await _updatePresence(isOnline: true, status: status);
  }

  void dispose() {
    stopTracking();
    _presenceStreamController.close();
  }
}

// Modèles de données
class PresenceUpdate {
  final int userId;
  final bool isOnline;
  final String status;
  final String? lastSeen;

  PresenceUpdate({
    required this.userId,
    required this.isOnline,
    required this.status,
    this.lastSeen,
  });
}

class UserPresence {
  final int userId;
  final bool isOnline;
  final String status;
  final String? lastSeen;
  final String? lastActivity;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;
  final int? minutesAgo;

  UserPresence({
    required this.userId,
    required this.isOnline,
    required this.status,
    this.lastSeen,
    this.lastActivity,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
    this.minutesAgo,
  });

  factory UserPresence.fromJson(Map<String, dynamic> json) {
    return UserPresence(
      userId: json['user_id'],
      isOnline: json['is_online'],
      status: json['status'],
      lastSeen: json['last_seen'],
      lastActivity: json['last_activity'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePhotoUrl: json['profile_photo_url'],
      minutesAgo: json['minutes_ago'],
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

class OnlineUser {
  final int userId;
  final bool isOnline;
  final String status;
  final String? lastSeen;
  final String? lastActivity;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? profilePhotoUrl;

  OnlineUser({
    required this.userId,
    required this.isOnline,
    required this.status,
    this.lastSeen,
    this.lastActivity,
    this.firstName,
    this.lastName,
    this.fullName,
    this.profilePhotoUrl,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      userId: json['user_id'],
      isOnline: json['is_online'],
      status: json['status'],
      lastSeen: json['last_seen'],
      lastActivity: json['last_activity'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
