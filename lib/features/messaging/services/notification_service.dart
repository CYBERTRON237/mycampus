import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mycampus/features/messaging/domain/models/message_model.dart';
import 'package:mycampus/constants/app_colors.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  // Map pour stocker les instances par ID d'utilisateur pour éviter les conflits
  static final Map<String, NotificationService> _instances = {};
  
  // Instance unique par utilisateur
  final String _userId;
  
  final StreamController<MessageModel> _newMessageController = StreamController<MessageModel>.broadcast();
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  final StreamController<Map<String, int>> _conversationNotificationsController = StreamController<Map<String, int>>.broadcast();
  
  Stream<MessageModel> get newMessageStream => _newMessageController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  Stream<Map<String, int>> get conversationNotificationsStream => _conversationNotificationsController.stream;

  Timer? _notificationTimer;
  Set<String> _processedMessageIds = {};
  Map<String, int> _conversationUnreadCounts = {};
  Map<String, Color> _conversationNotificationColors = {};

  // Factory pour obtenir ou créer une instance par utilisateur
  factory NotificationService({required String userId}) {
    if (_instances.containsKey(userId)) {
      return _instances[userId]!;
    }
    final instance = NotificationService._internal(userId);
    _instances[userId] = instance;
    return instance;
  }
  
  // Constructeur interne
  NotificationService._internal(this._userId);
  
  // Getter pour l'ID utilisateur
  String get userId => _userId;

  void initialize() {
    _startNotificationListener();
  }

  void _startNotificationListener() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _checkForNewMessages();
    });
  }

  Future<void> _checkForNewMessages() async {
    // Utiliser l'ID utilisateur de l'instance
    print('Vérification des notifications pour utilisateur: $_userId');

    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('http://127.0.0.1/mycampus/api/messaging/messages/conversations.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Pour l'instant, nous allons simuler la vérification des messages non lus
        // Dans une vraie implémentation, l'API devrait retourner les messages non lus
        await _checkUnreadMessages();
      }
    } catch (e) {
      print('Erreur vérification notifications: $e');
    }
  }

  Future<void> _checkUnreadMessages() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('http://127.0.0.1/mycampus/api/messaging/messages/check_unread.php'),
        headers: {'X-User-Id': _userId, 'X-Instance-Id': _userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final unreadCount = data['unread_count'] ?? 0;
          final unreadMessages = data['unread_messages'] ?? [];
          
          // Mettre à jour le compteur de messages non lus
          updateUnreadCount(unreadCount);
          
          // Notifier les nouveaux messages
          for (final messageData in unreadMessages) {
            final message = MessageModel.fromJson(messageData);
            notifyNewMessage(message);
          }
        }
      }
    } catch (e) {
      print('Erreur vérification messages non lus: $e');
    }
  }

  void notifyNewMessage(MessageModel message) {
    if (!_processedMessageIds.contains(message.id)) {
      _processedMessageIds.add(message.id);
      
      // Mettre à jour le compteur de messages non lus pour la conversation
      final conversationId = message.senderId == _userId ? message.receiverId : message.senderId;
      _conversationUnreadCounts[conversationId] = (_conversationUnreadCounts[conversationId] ?? 0) + 1;
      
      // Attribuer une couleur de notification basée sur l'expéditeur
      _conversationNotificationColors.putIfAbsent(conversationId, () => _generateNotificationColor(conversationId));
      
      // Notifier les abonnés
      _newMessageController.add(message);
      _conversationNotificationsController.add(Map.from(_conversationUnreadCounts));
      
      print('Notification pour utilisateur $_userId: message de ${message.senderId} vers ${message.receiverId}');
      _showNotification(message);
    }
  }

  Color _generateNotificationColor(String conversationId) {
    final colors = [
      const Color(0xFF25D366), // Vert WhatsApp
      const Color(0xFF34B7F1), // Bleu
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEF4444), // Rouge
      const Color(0xFF10B981), // Émeraude
      const Color(0xFFF97316), // Orange vif
      const Color(0xFF6366F1), // Indigo
    ];
    
    final hash = conversationId.hashCode;
    final index = hash.abs() % colors.length;
    return colors[index];
  }

  Color? getConversationNotificationColor(String conversationId) {
    return _conversationNotificationColors[conversationId];
  }

  int getConversationUnreadCount(String conversationId) {
    return _conversationUnreadCounts[conversationId] ?? 0;
  }

  void markConversationAsRead(String conversationId) {
    _conversationUnreadCounts.remove(conversationId);
    _conversationNotificationColors.remove(conversationId);
    _conversationNotificationsController.add(Map.from(_conversationUnreadCounts));
  }

  void _showNotification(MessageModel message) {
    // Utiliser un SnackBar pour simuler une notification WhatsApp
    final context = _getCurrentContext();
    if (context != null && message.senderId != _userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  message.sender?.fullName.isNotEmpty == true 
                      ? message.sender!.fullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender?.fullName ?? 'Nouveau message',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      message.content,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF075E54),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: () {
              // Naviguer vers la conversation
              _navigateToConversation(message.senderId);
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  BuildContext? _getCurrentContext() {
    // Cette méthode devrait être implémentée pour obtenir le contexte actuel
    // Pour l'instant, retourne null
    return null;
  }

  void _navigateToConversation(String userId) {
    // Implémenter la navigation vers la conversation
    // Navigator.of(_getCurrentContext()).pushNamed('/conversation', arguments: {...});
  }

  void updateUnreadCount(int count) {
    _unreadCountController.add(count);
  }

  void dispose() {
    _notificationTimer?.cancel();
    _newMessageController.close();
    _unreadCountController.close();
    _conversationNotificationsController.close();
    _conversationUnreadCounts.clear();
    _conversationNotificationColors.clear();
    
    // Retirer l'instance de la map statique
    _instances.remove(_userId);
  }
  
  // Méthode statique pour nettoyer toutes les instances
  static void disposeAll() {
    for (final instance in _instances.values) {
      instance.dispose();
    }
    _instances.clear();
  }
}
