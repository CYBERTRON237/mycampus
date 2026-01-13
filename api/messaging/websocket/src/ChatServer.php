<?php

namespace MyCampus\WebSocket;

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

class ChatServer implements MessageComponentInterface {
    protected $clients;
    protected $users;
    protected $rooms;
    
    public function __construct() {
        $this->clients = new \SplObjectStorage;
        $this->users = [];
        $this->rooms = [];
    }
    
    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
        echo "Nouvelle connexion ({$conn->resourceId})\n";
        
        // Envoyer message de bienvenue
        $conn->send(json_encode([
            'type' => 'connection',
            'message' => 'Connecté au serveur WebSocket',
            'connection_id' => $conn->resourceId
        ]));
    }
    
    public function onMessage(ConnectionInterface $from, $msg) {
        $data = json_decode($msg, true);
        
        if (!$data || !isset($data['type'])) {
            return;
        }
        
        switch ($data['type']) {
            case 'authenticate':
                $this->authenticateUser($from, $data);
                break;
                
            case 'join_room':
                $this->joinRoom($from, $data);
                break;
                
            case 'message':
                $this->handleMessage($from, $data);
                break;
                
            case 'typing':
                $this->handleTyping($from, $data);
                break;
                
            case 'read':
                $this->handleRead($from, $data);
                break;
        }
    }
    
    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);
        
        // Retirer utilisateur des rooms
        if (isset($this->users[$conn->resourceId])) {
            $userId = $this->users[$conn->resourceId]['user_id'];
            
            foreach ($this->rooms as $roomId => $roomUsers) {
                if (isset($roomUsers[$userId])) {
                    unset($this->rooms[$roomId][$userId]);
                    
                    // Notifier autres utilisateurs
                    $this->broadcastToRoom($roomId, [
                        'type' => 'user_left',
                        'user_id' => $userId,
                        'timestamp' => time()
                    ]);
                }
            }
            
            unset($this->users[$conn->resourceId]);
        }
        
        echo "Connexion fermée ({$conn->resourceId})\n";
    }
    
    public function onError(ConnectionInterface $conn, \Exception $e) {
        echo "Erreur: {$e->getMessage()}\n";
        $conn->close();
    }
    
    private function authenticateUser(ConnectionInterface $conn, $data) {
        // Valider token JWT ici
        $token = $data['token'] ?? '';
        
        // Simulation d'authentification
        $userData = [
            'user_id' => $data['user_id'] ?? rand(1, 1000),
            'name' => $data['name'] ?? 'User',
            'email' => $data['email'] ?? 'user@example.com'
        ];
        
        $this->users[$conn->resourceId] = $userData;
        
        $conn->send(json_encode([
            'type' => 'authenticated',
            'user' => $userData,
            'timestamp' => time()
        ]));
        
        echo "Utilisateur authentifié: {$userData['name']} ({$userData['user_id']})\n";
    }
    
    private function joinRoom(ConnectionInterface $conn, $data) {
        if (!isset($this->users[$conn->resourceId])) {
            return;
        }
        
        $userId = $this->users[$conn->resourceId]['user_id'];
        $roomId = $data['room_id'] ?? 'default';
        
        if (!isset($this->rooms[$roomId])) {
            $this->rooms[$roomId] = [];
        }
        
        $this->rooms[$roomId][$userId] = $conn;
        
        $conn->send(json_encode([
            'type' => 'joined_room',
            'room_id' => $roomId,
            'timestamp' => time()
        ]));
        
        // Notifier autres utilisateurs
        $this->broadcastToRoom($roomId, [
            'type' => 'user_joined',
            'user_id' => $userId,
            'user_name' => $this->users[$conn->resourceId]['name'],
            'timestamp' => time()
        ], $conn);
    }
    
    private function handleMessage(ConnectionInterface $from, $data) {
        if (!isset($this->users[$from->resourceId])) {
            return;
        }
        
        $userId = $this->users[$from->resourceId]['user_id'];
        $roomId = $data['room_id'] ?? 'default';
        $content = $data['content'] ?? '';
        
        $message = [
            'type' => 'message',
            'message_id' => uniqid(),
            'user_id' => $userId,
            'user_name' => $this->users[$from->resourceId]['name'],
            'content' => $content,
            'timestamp' => time(),
            'room_id' => $roomId
        ];
        
        // Diffuser message à tous dans la room
        $this->broadcastToRoom($roomId, $message);
        
        // Sauvegarder en base de données
        $this->saveMessage($message);
    }
    
    private function handleTyping(ConnectionInterface $from, $data) {
        if (!isset($this->users[$from->resourceId])) {
            return;
        }
        
        $userId = $this->users[$from->resourceId]['user_id'];
        $roomId = $data['room_id'] ?? 'default';
        $isTyping = $data['is_typing'] ?? false;
        
        $this->broadcastToRoom($roomId, [
            'type' => 'typing',
            'user_id' => $userId,
            'user_name' => $this->users[$from->resourceId]['name'],
            'is_typing' => $isTyping,
            'timestamp' => time()
        ], $from);
    }
    
    private function handleRead(ConnectionInterface $from, $data) {
        if (!isset($this->users[$from->resourceId])) {
            return;
        }
        
        $userId = $this->users[$from->resourceId]['user_id'];
        $roomId = $data['room_id'] ?? 'default';
        $messageId = $data['message_id'] ?? null;
        
        $this->broadcastToRoom($roomId, [
            'type' => 'message_read',
            'message_id' => $messageId,
            'user_id' => $userId,
            'timestamp' => time()
        ], $from);
        
        // Marquer comme lu en base
        $this->markAsRead($messageId, $userId);
    }
    
    private function broadcastToRoom($roomId, $message, $exclude = null) {
        if (!isset($this->rooms[$roomId])) {
            return;
        }
        
        foreach ($this->rooms[$roomId] as $userId => $conn) {
            if ($exclude && $conn === $exclude) {
                continue;
            }
            
            $conn->send(json_encode($message));
        }
    }
    
    private function saveMessage($message) {
        // Connexion à la base de données et sauvegarde
        try {
            $pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", "root", "");
            $stmt = $pdo->prepare("
                INSERT INTO messages (conversation_id, sender_id, content, created_at) 
                VALUES (?, ?, ?, FROM_UNIXTIME(?))
            ");
            $stmt->execute([
                $message['room_id'],
                $message['user_id'],
                $message['content'],
                $message['timestamp']
            ]);
        } catch (Exception $e) {
            echo "Erreur sauvegarde message: " . $e->getMessage() . "\n";
        }
    }
    
    private function markAsRead($messageId, $userId) {
        try {
            $pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", "root", "");
            $stmt = $pdo->prepare("
                UPDATE message_reads SET read_at = NOW() 
                WHERE message_id = ? AND user_id = ?
            ");
            $stmt->execute([$messageId, $userId]);
        } catch (Exception $e) {
            echo "Erreur marquer comme lu: " . $e->getMessage() . "\n";
        }
    }
}

// Démarrage du serveur
$server = IoServer::factory(
    new HttpServer(
        new WsServer(
            new ChatServer()
        )
    ),
    8080
);

echo "Serveur WebSocket démarré sur ws://127.0.0.1:8080\n";
$server->run();
