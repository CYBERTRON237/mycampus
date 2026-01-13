import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../auth/services/auth_service.dart';
import '../domain/models/message_model.dart';

class WebSocketService {
  // Map pour stocker les instances par ID d'utilisateur pour éviter les conflits
  static final Map<String, WebSocketService> _instances = {};
  
  // Instance unique par utilisateur
  final String _userId;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  final AuthService _authService = AuthService();
  
  // Streams pour les différents types d'événements
  final StreamController<MessageModel> _messageStreamController = StreamController<MessageModel>.broadcast();
  final StreamController<TypingEvent> _typingStreamController = StreamController<TypingEvent>.broadcast();
  final StreamController<UserStatusEvent> _userStatusStreamController = StreamController<UserStatusEvent>.broadcast();
  final StreamController<ConnectionStatusEvent> _connectionStatusStreamController = StreamController<ConnectionStatusEvent>.broadcast();

  // Factory pour obtenir ou créer une instance par utilisateur
  factory WebSocketService({required String userId}) {
    if (_instances.containsKey(userId)) {
      return _instances[userId]!;
    }
    final instance = WebSocketService._internal(userId);
    _instances[userId] = instance;
    return instance;
  }
  
  // Constructeur interne
  WebSocketService._internal(this._userId);
  
  // Getter pour l'ID utilisateur
  String get userId => _userId;

  // Getters pour les streams
  Stream<MessageModel> get messageStream => _messageStreamController.stream;
  Stream<TypingEvent> get typingStream => _typingStreamController.stream;
  Stream<UserStatusEvent> get userStatusStream => _userStatusStreamController.stream;
  Stream<ConnectionStatusEvent> get connectionStatusStream => _connectionStatusStreamController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Essayer de démarrer le serveur WebSocket s'il n'est pas déjà démarré
      await _startWebSocketServer();
      
      // Attendre un peu que le serveur démarre
      await Future.delayed(Duration(seconds: 2));
      
      // Récupérer le token JWT
      final token = await _authService.getToken();
      if (token == null) {
        print('Token non trouvé, connexion WebSocket impossible');
        return;
      }

      // Connexion WebSocket avec gestion d'erreur améliorée
      try {
        _channel = WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:8080')
        );
        
        // Test de connexion avec timeout
        await _channel!.ready.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('WebSocket connection timeout', const Duration(seconds: 5));
          },
        );
      } catch (e) {
        print('Erreur de connexion WebSocket au port 8080: $e');
        // Ne pas lever d'exception, juste continuer sans WebSocket
        _connectionStatusStreamController.add(ConnectionStatusEvent(false, 'Serveur WebSocket indisponible'));
        return;
      }

      // Écouter les messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      // Envoyer l'authentification
      await _sendAuthentication(token);

      _isConnected = true;
      _connectionStatusStreamController.add(ConnectionStatusEvent(true, 'Connecté'));
      print('WebSocket connecté avec succès');

    } catch (e) {
      print('Erreur de connexion WebSocket: $e');
      _handleConnectionError();
    }
  }

  Future<void> _startWebSocketServer() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1/mycampus/start_websocket.php')
      );
      print('Tentative de démarrage du serveur WebSocket: ${response.body}');
    } catch (e) {
      print('Impossible de démarrer le serveur WebSocket: $e');
      // Ne pas lever d'exception - le WebSocket est optionnel
    }
  }

  Future<void> _sendAuthentication(String token) async {
    try {
      // Utiliser l'ID utilisateur de l'instance au lieu de celui d'AuthService
      final authMessage = {
        'type': 'authenticate',
        'token': token,
        'user_id': _userId,
        'instance_id': _userId, // Ajouter un identifiant d'instance
        'name': 'User $_userId',
        'email': 'user_$_userId@example.com',
      };

      _channel!.sink.add(jsonEncode(authMessage));
      print('WebSocket authentifié pour utilisateur: $_userId (instance: $_userId)');
    } catch (e) {
      print('Erreur authentification WebSocket: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];

      switch (type) {
        case 'message':
          _handleNewMessage(data);
          break;
        case 'typing':
          _handleTypingEvent(data);
          break;
        case 'user_joined':
        case 'user_left':
          _handleUserStatusEvent(data);
          break;
        case 'message_read':
          _handleMessageRead(data);
          break;
        case 'authenticated':
          // print('Authentification WebSocket réussie');
          break;
        default:
          // print('Message WebSocket non géré: $type');
      }
    } catch (e) {
      // print('Erreur traitement message WebSocket: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = MessageModel.fromJson(data);
      _messageStreamController.add(message);
    } catch (e) {
      // print('Erreur conversion message: $e');
    }
  }

  void _handleTypingEvent(Map<String, dynamic> data) {
    final event = TypingEvent(
      userId: data['user_id'],
      userName: data['user_name'],
      isTyping: data['is_typing'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 1000),
    );
    _typingStreamController.add(event);
  }

  void _handleUserStatusEvent(Map<String, dynamic> data) {
    final event = UserStatusEvent(
      userId: data['user_id'],
      userName: data['user_name'] ?? '',
      isOnline: data['type'] == 'user_joined',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 1000),
    );
    _userStatusStreamController.add(event);
  }

  void _handleMessageRead(Map<String, dynamic> data) {
    // Émettre un événement de message lu pour mettre à jour l'UI
    final event = MessageReadEvent(
      messageId: data['message_id'],
      userId: data['user_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 1000),
    );
    
    // Vous pouvez créer un stream séparé pour les événements de lecture
    // print('Message lu: ${event.messageId} par ${event.userId}');
  }

  void _handleError(dynamic error) {
    // print('Erreur WebSocket: $error');
    _handleConnectionError();
  }

  void _handleDisconnection() {
    // print('WebSocket déconnecté');
    _isConnected = false;
    _connectionStatusStreamController.add(ConnectionStatusEvent(false, 'Déconnecté'));
    _scheduleReconnect();
  }

  void _handleConnectionError() {
    _isConnected = false;
    _connectionStatusStreamController.add(ConnectionStatusEvent(false, 'Erreur de connexion'));
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      // print('Tentative reconnexion WebSocket...');
      connect();
    });
  }

  // Méthodes pour envoyer des messages
  Future<void> joinRoom(String roomId) async {
    if (!_isConnected) return;

    final message = {
      'type': 'join_room',
      'room_id': roomId,
    };
    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
    String? messageType = 'text',
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': 'message',
      'room_id': roomId,
      'content': content,
      'message_type': messageType,
    };
    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> sendTyping({
    required String roomId,
    required bool isTyping,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': 'typing',
      'room_id': roomId,
      'is_typing': isTyping,
    };
    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> markAsRead({
    required String roomId,
    required String messageId,
  }) async {
    if (!_isConnected) return;

    final message = {
      'type': 'read',
      'room_id': roomId,
      'message_id': messageId,
    };
    _channel!.sink.add(jsonEncode(message));
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    // print('WebSocket déconnecté manuellement');
  }

  void dispose() {
    disconnect();
    _messageStreamController.close();
    _typingStreamController.close();
    _userStatusStreamController.close();
    _connectionStatusStreamController.close();
    
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

// Classes pour les événements
class TypingEvent {
  final String userId;
  final String userName;
  final bool isTyping;
  final DateTime timestamp;

  TypingEvent({
    required this.userId,
    required this.userName,
    required this.isTyping,
    required this.timestamp,
  });
}

class UserStatusEvent {
  final String userId;
  final String userName;
  final bool isOnline;
  final DateTime timestamp;

  UserStatusEvent({
    required this.userId,
    required this.userName,
    required this.isOnline,
    required this.timestamp,
  });
}

class ConnectionStatusEvent {
  final bool isConnected;
  final String message;

  ConnectionStatusEvent(this.isConnected, this.message);
}

class MessageReadEvent {
  final String messageId;
  final String userId;
  final DateTime timestamp;

  MessageReadEvent({
    required this.messageId,
    required this.userId,
    required this.timestamp,
  });
}
