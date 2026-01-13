import 'package:flutter/material.dart';
import 'package:mycampus/features/messaging/services/websocket_service.dart';
import 'package:mycampus/features/messaging/services/notification_service.dart';

void main() {
  runApp(const MultiInstanceMessagingTest());
}

class MultiInstanceMessagingTest extends StatelessWidget {
  const MultiInstanceMessagingTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Multi-Instance Messaging',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  // Simuler deux utilisateurs différents
  final String _user1Id = "1";
  final String _user2Id = "2";
  
  // Services pour chaque utilisateur
  late WebSocketService _wsService1;
  late WebSocketService _wsService2;
  late NotificationService _notificationService1;
  late NotificationService _notificationService2;
  
  bool _isConnected1 = false;
  bool _isConnected2 = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  void _initializeServices() {
    // Créer des services isolés pour chaque utilisateur
    _wsService1 = WebSocketService(userId: _user1Id);
    _wsService2 = WebSocketService(userId: _user2Id);
    
    _notificationService1 = NotificationService(userId: _user1Id);
    _notificationService2 = NotificationService(userId: _user2Id);
    
    // Écouter les états de connexion
    _wsService1.connectionStatusStream.listen((status) {
      setState(() {
        _isConnected1 = status.isConnected;
      });
      print('WebSocket 1 (User $_user1Id): ${status.message}');
    });
    
    _wsService2.connectionStatusStream.listen((status) {
      setState(() {
        _isConnected2 = status.isConnected;
      });
      print('WebSocket 2 (User $_user2Id): ${status.message}');
    });
    
    // Écouter les messages
    _wsService1.messageStream.listen((message) {
      print('Message reçu pour User $_user1Id: ${message.content}');
    });
    
    _wsService2.messageStream.listen((message) {
      print('Message reçu pour User $_user2Id: ${message.content}');
    });
    
    // Écouter les notifications
    _notificationService1.conversationNotificationsStream.listen((notifications) {
      print('Notifications pour User $_user1Id: $notifications');
    });
    
    _notificationService2.conversationNotificationsStream.listen((notifications) {
      print('Notifications pour User $_user2Id: $notifications');
    });
  }
  
  Future<void> _connectUser1() async {
    await _wsService1.connect();
    _notificationService1.initialize();
  }
  
  Future<void> _connectUser2() async {
    await _wsService2.connect();
    _notificationService2.initialize();
  }
  
  Future<void> _disconnectUser1() async {
    _wsService1.disconnect();
  }
  
  Future<void> _disconnectUser2() async {
    _wsService2.disconnect();
  }
  
  Future<void> _sendMessageFrom1To2() async {
    await _wsService1.sendMessage(
      roomId: 'conversation_1_2',
      content: 'Message de User 1 vers User 2',
    );
  }
  
  Future<void> _sendMessageFrom2To1() async {
    await _wsService2.sendMessage(
      roomId: 'conversation_1_2',
      content: 'Message de User 2 vers User 1',
    );
  }
  
  void _testInstanceIsolation() {
    print('\n=== Test d\'Isolation des Instances ===');
    print('WebSocket 1 User ID: ${_wsService1.userId}');
    print('WebSocket 2 User ID: ${_wsService2.userId}');
    print('Notification 1 User ID: ${_notificationService1.userId}');
    print('Notification 2 User ID: ${_notificationService2.userId}');
    print('WebSocket 1 == WebSocket 2: ${_wsService1 == _wsService2}');
    print('Notification 1 == Notification 2: ${_notificationService1 == _notificationService2}');
    print('=====================================\n');
  }
  
  @override
  void dispose() {
    _wsService1.dispose();
    _wsService2.dispose();
    _notificationService1.dispose();
    _notificationService2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Multi-Instance Messaging'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section User 1
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Utilisateur 1 (ID: $_user1Id)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isConnected1 ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _connectUser1,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Connecter'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _disconnectUser1,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Déconnecter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Section User 2
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Utilisateur 2 (ID: $_user2Id)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isConnected2 ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _connectUser2,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Connecter'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _disconnectUser2,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Déconnecter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tests d\'Isolation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _testInstanceIsolation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Vérifier l\'Isolation'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _sendMessageFrom1To2,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Message 1 → 2'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _sendMessageFrom2To1,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Message 2 → 1'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions de Test:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Connectez les deux utilisateurs\n'
                      '2. Vérifiez l\'isolation des instances\n'
                      '3. Envoyez des messages entre utilisateurs\n'
                      '4. Vérifiez que chaque utilisateur reçoit seulement ses messages\n'
                      '5. Ouvrez une deuxième instance de l\'application avec un autre compte\n'
                      '6. Confirmez qu\'il n\'y a pas de conflit d\'état',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
