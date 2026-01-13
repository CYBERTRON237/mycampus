<?php

class SimpleMessageController
{
    private function getConnection()
    {
        try {
            $conn = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $conn;
        } catch(PDOException $e) {
            return null;
        }
    }

    private function sendResponse($data, $statusCode = 200)
    {
        // Nettoyer les buffers de sortie pour éviter les warnings
        while (ob_get_level()) {
            ob_end_clean();
        }
        
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit();
    }

    private function getCurrentUser()
    {
        // Récupérer l'ID utilisateur depuis les headers (envoyés par Flutter)
        $headers = getallheaders();
        error_log("All headers: " . print_r($headers, true));
        
        $userId = $headers['X-User-Id'] ?? $headers['x-user-id'] ?? $headers['X-User-id'] ?? null;
        
        error_log("User ID from headers: " . $userId);
        
        if ($userId && (is_numeric($userId) || is_string($userId))) {
            error_log("Using user ID from headers: " . $userId);
            return (object) ['id' => (int)$userId];
        }
        
        // Fallback : utiliser une session si disponible
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        if (isset($_SESSION['user_id'])) {
            error_log("Using user ID from session: " . $_SESSION['user_id']);
            return (object) ['id' => $_SESSION['user_id']];
        }
        
        // Fallback simple pour les tests
        error_log("No valid user ID found - using fallback user ID 1");
        return (object) ['id' => 1];
    }

    public function getMessages($conversationId)
    {
        try {
            $user = $this->getCurrentUser();
            error_log("getMessages: conversationId=$conversationId, currentUserId=" . $user->id);
            
            // Pas de limite pour charger tous les messages comme WhatsApp
            $limit = 1000;
            $offset = 0;

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Pas de vérification d'autorisation pour le moment - autoriser tout le monde

            // Récupérer les messages de la conversation (ordre WhatsApp: plus anciens en haut, plus récents en bas)
            $sql = "SELECT m.*, u.first_name, u.last_name, u.email, u.profile_photo_url, u.profile_picture
                    FROM messages m
                    LEFT JOIN users u ON m.sender_id = u.id
                    WHERE m.conversation_id = :conversationId AND m.is_deleted = 0
                    ORDER BY m.sent_at ASC
                    LIMIT :limit OFFSET :offset";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':conversationId', $conversationId);
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
            $stmt->execute();

            $messages = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $messages[] = [
                    'id' => $row['id'],
                    'uuid' => $row['uuid'],
                    'sender_id' => $row['sender_id'],
                    'receiver_id' => $row['receiver_id'],
                    'conversation_id' => $row['conversation_id'],
                    'content' => $row['content'],
                    'type' => $row['type'],
                    'message_type' => $row['message_type'],
                    'delivery_status' => $row['delivery_status'],
                    'status' => $row['status'],
                    'is_deleted' => $row['is_deleted'],
                    'read_at' => $row['read_at'],
                    'sent_at' => $row['sent_at'],
                    'created_at' => $row['created_at'],
                    'sender' => [
                        'id' => $row['sender_id'],
                        'first_name' => $row['first_name'],
                        'last_name' => $row['last_name'],
                        'email' => $row['email'],
                        'profile_photo_url' => $row['profile_photo_url'],
                        'profile_picture' => $row['profile_picture']
                    ]
                ];
            }

            $this->sendResponse($messages);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to fetch messages: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getConversations()
    {
        error_log("getConversations called");
        try {
            $user = $this->getCurrentUser();
            error_log("Current user ID: " . $user->id);
            $limit = $_GET['limit'] ?? 50;
            $offset = $_GET['offset'] ?? 0;

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            error_log("Using main conversation tables query");
            // Utiliser les tables conversations et conversation_participants pour une meilleure performance
            $sql = "SELECT DISTINCT 
                        c.id as conversation_id,
                        c.uuid,
                        c.last_message_at,
                        c.last_message_preview,
                        c.total_messages,
                        c.updated_at,
                        cp_other.user_id as participant_id,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.profile_photo_url,
                        u.profile_picture,
                        cp_other.unread_count,
                        cp_other.is_muted,
                        cp_other.is_archived,
                        cp_other.is_pinned,
                        cp_other.last_read_at
                    FROM conversations c
                    INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
                    INNER JOIN conversation_participants cp_other ON c.id = cp_other.conversation_id 
                        AND cp.user_id != cp_other.user_id
                    LEFT JOIN users u ON cp_other.user_id = u.id
                    WHERE c.type = 'private'
                    AND cp.user_id = :userId
                    AND cp.left_at IS NULL
                    AND cp_other.left_at IS NULL
                    ORDER BY c.last_message_at DESC, c.updated_at DESC
                    LIMIT :limit OFFSET :offset";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $user->id);
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
            $stmt->execute();

            $conversations = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                error_log("=== MAIN CONVERSATION DEBUG ===");
                error_log("Conversation ID: " . $row['conversation_id']);
                error_log("Current user ID: " . $user->id);
                error_log("Participant ID: " . $row['participant_id']);
                error_log("Participant name: " . ($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? ''));
                
                if ($row['participant_id']) {
                    $conversations[] = [
                        'id' => $row['conversation_id'],
                        'uuid' => $row['uuid'],
                        'participant_id' => $row['participant_id'],
                        'participant_name' => trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? '')) ?: 'Utilisateur ' . $row['participant_id'],
                        'participant_email' => $row['email'],
                        'participant_avatar' => $row['profile_photo_url'] ?? $row['profile_picture'],
                        'last_message' => [
                            'content' => $row['last_message_preview'] ?? 'Nouveau message',
                            'created_at' => $row['last_message_at'],
                            'type' => 'text',
                            'status' => 'sent'
                        ],
                        'unread_count' => (int)($row['unread_count'] ?? 0),
                        'last_activity' => $row['last_message_at'] ?? $row['updated_at'],
                        'is_online' => false,
                        'is_muted' => (bool)$row['is_muted'],
                        'is_archived' => (bool)$row['is_archived'],
                        'is_pinned' => (bool)$row['is_pinned'],
                        'total_messages' => (int)($row['total_messages'] ?? 0),
                        'last_read_at' => $row['last_read_at']
                    ];
                }
            }

            error_log("Found " . count($conversations) . " conversations in main tables");
            // Si aucune conversation trouvée dans les nouvelles tables, utiliser l'ancienne méthode comme fallback
            if (empty($conversations)) {
                error_log("No conversations found in new tables, using fallback method");
                $conversations = $this->getConversationsFallback($conn, $user->id, $limit, $offset);
            } else {
                error_log("Using conversations from main tables");
            }

            $this->sendResponse($conversations);
        } catch (Exception $e) {
            error_log("Error in getConversations: " . $e->getMessage());
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to fetch conversations: ' . $e->getMessage()
            ], 500);
        }
    }

    private function getConversationsFallback($conn, $userId, $limit, $offset)
    {
        try {
            // Approche simplifiée : trouver d'abord tous les contacts uniques avec qui l'utilisateur a communiqué
            $sql = "SELECT DISTINCT
                    CASE 
                        WHEN m.sender_id = :userId THEN m.receiver_id 
                        ELSE m.sender_id 
                    END as participant_id,
                    LEAST(m.sender_id, m.receiver_id) * 1000000 + GREATEST(m.sender_id, m.receiver_id) as conversation_id
                FROM messages m
                WHERE (m.sender_id = :userId OR m.receiver_id = :userId)
                AND m.is_deleted = 0
                AND m.sender_id != m.receiver_id
                ORDER BY conversation_id
                LIMIT :limit OFFSET :offset";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $userId);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            
            $conversationParticipants = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            if (empty($conversationParticipants)) {
                return [];
            }

            $conversations = [];
            
            // Pour chaque participant, récupérer les informations détaillées
            foreach ($conversationParticipants as $conv) {
                $participantId = $conv['participant_id'];
                $conversationId = $conv['conversation_id'];
                
                // Récupérer les infos du participant
                $userSql = "SELECT id, first_name, last_name, email, profile_photo_url, profile_picture, phone 
                           FROM users 
                           WHERE id = :participantId";
                
                $userStmt = $conn->prepare($userSql);
                $userStmt->bindValue(':participantId', $participantId);
                $userStmt->execute();
                $userData = $userStmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$userData) {
                    continue;
                }
                
                // Récupérer le dernier message pour cette conversation
                $lastMessageSql = "SELECT content, created_at, type 
                                   FROM messages 
                                   WHERE ((sender_id = :userId AND receiver_id = :participantId) 
                                         OR (sender_id = :participantId AND receiver_id = :userId))
                                   AND is_deleted = 0
                                   ORDER BY created_at DESC 
                                   LIMIT 1";
                
                $lastMsgStmt = $conn->prepare($lastMessageSql);
                $lastMsgStmt->bindValue(':userId', $userId);
                $lastMsgStmt->bindValue(':participantId', $participantId);
                $lastMsgStmt->execute();
                $lastMessage = $lastMsgStmt->fetch(PDO::FETCH_ASSOC);
                
                // Compter les messages non lus
                $unreadSql = "SELECT COUNT(*) as count 
                             FROM messages 
                             WHERE sender_id = :participantId 
                             AND receiver_id = :userId 
                             AND read_at IS NULL 
                             AND is_deleted = 0";
                
                $unreadStmt = $conn->prepare($unreadSql);
                $unreadStmt->bindValue(':participantId', $participantId);
                $unreadStmt->bindValue(':userId', $userId);
                $unreadStmt->execute();
                $unreadCount = $unreadStmt->fetchColumn();
                
                $conversations[] = [
                    'id' => $conversationId,
                    'uuid' => null,
                    'participant_id' => $userData['id'],
                    'participant_name' => trim(($userData['first_name'] ?? '') . ' ' . ($userData['last_name'] ?? '')) ?: 'Utilisateur ' . $userData['id'],
                    'participant_email' => $userData['email'],
                    'participant_avatar' => $userData['profile_photo_url'] ?? $userData['profile_picture'],
                    'last_message' => [
                        'content' => $lastMessage['content'] ?? 'Nouveau message',
                        'created_at' => $lastMessage['created_at'] ?? date('Y-m-d H:i:s'),
                        'type' => $lastMessage['type'] ?? 'text',
                        'status' => 'sent'
                    ],
                    'unread_count' => (int)$unreadCount,
                    'last_activity' => $lastMessage['created_at'] ?? date('Y-m-d H:i:s'),
                    'is_online' => false,
                    'is_muted' => false,
                    'is_archived' => false,
                    'is_pinned' => false,
                    'total_messages' => 0,
                    'last_read_at' => null
                ];
            }
            
            // Trier par date du dernier message
            usort($conversations, function($a, $b) {
                $timeA = strtotime($a['last_message']['created_at']);
                $timeB = strtotime($b['last_message']['created_at']);
                return $timeB - $timeA;
            });
            
            return $conversations;
        } catch (Exception $e) {
            error_log("Error in getConversationsFallback: " . $e->getMessage());
            return [];
        }
    }

    public function searchUsers()
    {
        try {
            $user = $this->getCurrentUser();
            $query = $_GET['q'] ?? '';

            if (empty($query)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Search query is required'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            $sql = "SELECT id, first_name, last_name, email, profile_photo_url, profile_picture, phone, primary_role 
                     FROM users 
                     WHERE id != :user_id 
                     AND (first_name LIKE :query OR last_name LIKE :query OR email LIKE :query OR CONCAT(first_name, ' ', last_name) LIKE :query)
                     LIMIT 20";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':user_id', $user->id);
            $stmt->bindValue(':query', "%{$query}%");
            $stmt->execute();
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $this->sendResponse([
                'success' => true,
                'data' => $users
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to search users: ' . $e->getMessage()
            ], 500);
        }
    }

    public function checkUnreadMessages()
    {
        try {
            $user = $this->getCurrentUser();
            $userId = $user->id;

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Compter les messages non lus dans toutes les conversations de l'utilisateur
            $sql = "SELECT COUNT(*) as unread_count,
                           MAX(m.created_at) as last_message_time
                    FROM messages m
                    INNER JOIN conversation_participants cp ON m.conversation_id = cp.conversation_id
                    WHERE cp.user_id = :userId 
                    AND m.sender_id != :userId
                    AND m.read_at IS NULL
                    AND cp.left_at IS NULL
                    AND m.is_deleted = 0";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $userId);
            $stmt->execute();
            
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Récupérer les messages non lus récents pour les notifications
            $unreadMessagesSql = "SELECT m.*, u.first_name, u.last_name
                                  FROM messages m
                                  LEFT JOIN users u ON m.sender_id = u.id
                                  INNER JOIN conversation_participants cp ON m.conversation_id = cp.conversation_id
                                  WHERE cp.user_id = :userId 
                                  AND m.sender_id != :userId
                                  AND m.read_at IS NULL
                                  AND cp.left_at IS NULL
                                  AND m.is_deleted = 0
                                  ORDER BY m.created_at DESC
                                  LIMIT 5";

            $unreadStmt = $conn->prepare($unreadMessagesSql);
            $unreadStmt->bindValue(':userId', $userId);
            $unreadStmt->execute();
            
            $unreadMessages = [];
            while ($row = $unreadStmt->fetch(PDO::FETCH_ASSOC)) {
                $unreadMessages[] = [
                    'id' => $row['id'],
                    'sender_id' => $row['sender_id'],
                    'receiver_id' => $row['receiver_id'],
                    'content' => $row['content'],
                    'type' => $row['type'],
                    'created_at' => $row['created_at'],
                    'sender' => [
                        'id' => $row['sender_id'],
                        'first_name' => $row['first_name'],
                        'last_name' => $row['last_name'],
                        'full_name' => trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? ''))
                    ]
                ];
            }

            $this->sendResponse([
                'success' => true,
                'unread_count' => (int)$result['unread_count'],
                'last_message_time' => $result['last_message_time'],
                'unread_messages' => $unreadMessages
            ]);

        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to check unread messages: ' . $e->getMessage()
            ], 500);
        }
    }

    public function sendMessage()
    {
        try {
            $user = $this->getCurrentUser();
            $rawInput = file_get_contents('php://input');
            
            error_log("Raw input received: " . $rawInput);
            
            if (empty($rawInput)) {
                error_log("No input data received");
                $this->sendResponse([
                    'success' => false,
                    'message' => 'No input data received'
                ], 400);
            }
            
            $input = json_decode($rawInput, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                error_log("JSON decode error: " . json_last_error_msg());
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Invalid JSON data: ' . json_last_error_msg()
                ], 400);
            }
            
            error_log("Parsed input: " . print_r($input, true));
            
            $receiverId = $input['receiver_id'] ?? '';
            $content = $input['content'] ?? '';
            $type = $input['type'] ?? 'text';
            $attachmentUrl = $input['attachment_url'] ?? '';
            $attachmentName = $input['attachment_name'] ?? '';
            
            error_log("Parsed - receiverId: $receiverId, content: $content, type: $type, attachmentUrl: $attachmentUrl");
            
            if (empty($receiverId)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Receiver ID is required'
                ], 400);
            }
            
            if (empty($content) && $type !== 'sticker') {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Content is required'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            try {
                $conn->beginTransaction();

                // Créer ou récupérer la conversation
                $conversationId = $this->getOrCreateConversation($conn, $user->id, $receiverId);
                
                // Insérer le message avec la structure exacte de votre BDD
                $uuid = $this->generateUUID();
                $sql = "INSERT INTO messages (uuid, conversation_id, sender_id, receiver_id, type, message_type, content, attachments, metadata, delivery_status, status, sent_at, created_at) 
                        VALUES (:uuid, :conversation_id, :sender_id, :receiver_id, :type, 'private', :content, :attachments, :metadata, 'sent', 'sent', NOW(), NOW())";
                
                $stmt = $conn->prepare($sql);
                $stmt->bindValue(':uuid', $uuid);
                $stmt->bindValue(':conversation_id', $conversationId);
                $stmt->bindValue(':sender_id', $user->id);
                $stmt->bindValue(':receiver_id', $receiverId);
                $stmt->bindValue(':type', $type);
                $stmt->bindValue(':content', $content);
                $stmt->bindValue(':attachments', $attachmentUrl ? json_encode(['url' => $attachmentUrl, 'name' => $attachmentName]) : null);
                $stmt->bindValue(':metadata', null);
                $stmt->execute();
                
                $messageId = $conn->lastInsertId();
                
                // Mettre à jour les informations de la conversation
                $updateConversationSql = "UPDATE conversations 
                                         SET last_message_at = NOW(),
                                             last_message_preview = :content,
                                             total_messages = total_messages + 1,
                                             updated_at = NOW()
                                         WHERE id = :conversation_id";
                
                $stmt = $conn->prepare($updateConversationSql);
                $stmt->bindValue(':content', $content);
                $stmt->bindValue(':conversation_id', $conversationId);
                $stmt->execute();
                
                // Mettre à jour le compteur de messages non lus pour le destinataire
                $updateParticipantSql = "UPDATE conversation_participants 
                                         SET unread_count = unread_count + 1
                                         WHERE conversation_id = :conversation_id 
                                         AND user_id = :receiver_id";
                
                $stmt = $conn->prepare($updateParticipantSql);
                $stmt->bindValue(':conversation_id', $conversationId);
                $stmt->bindValue(':receiver_id', $receiverId);
                $stmt->execute();
                
                $conn->commit();
                
                // Récupérer le message inséré avec les informations de l'expéditeur
                $sql = "SELECT m.*, u.first_name, u.last_name, u.email, u.profile_photo_url, u.profile_picture
                        FROM messages m
                        LEFT JOIN users u ON m.sender_id = u.id
                        WHERE m.id = :messageId";
                
                $stmt = $conn->prepare($sql);
                $stmt->bindValue(':messageId', $messageId);
                $stmt->execute();
                $message = $stmt->fetch(PDO::FETCH_ASSOC);

                $this->sendResponse([
                    'success' => true,
                    'data' => $message
                ]);
                
            } catch (Exception $e) {
                $conn->rollback();
                throw $e;
            }
            
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to send message: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getConversationId()
    {
        try {
            $user = $this->getCurrentUser();
            $userId1 = $user->id;
            $userId2 = $_GET['participant_id'] ?? $_GET['user_id'] ?? '';

            error_log("getConversationId: user1=$userId1, user2=$userId2");

            if (empty($userId2)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Participant ID is required'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Utiliser la fonction simple pour créer ou récupérer la conversation
            $conversationId = $this->getOrCreateConversation($conn, $userId1, $userId2);
            
            $this->sendResponse([
                'success' => true,
                'conversation_id' => $conversationId
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to get conversation: ' . $e->getMessage()
            ], 500);
        }
    }

    private function getOrCreateConversation($conn, $userId1, $userId2)
    {
        // D'abord, chercher si une conversation existe déjà dans la table conversations
        $sql = "SELECT c.id, c.uuid FROM conversations c
                INNER JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
                INNER JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
                WHERE c.type = 'private'
                AND cp1.user_id = :userId1 
                AND cp2.user_id = :userId2
                AND cp1.left_at IS NULL
                AND cp2.left_at IS NULL
                LIMIT 1";
        
        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':userId1', $userId1);
        $stmt->bindValue(':userId2', $userId2);
        $stmt->execute();
        
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result && $result['id']) {
            error_log("Found existing conversation: " . $result['id']);
            return $result['id'];
        }
        
        // Créer une nouvelle conversation
        error_log("Creating new conversation for users $userId1 and $userId2");
        
        try {
            $conn->beginTransaction();
            
            // Générer un UUID pour la conversation
            $conversationUuid = $this->generateUUID();
            
            // Insérer la conversation
            $sql = "INSERT INTO conversations (uuid, type, message_type, created_by, created_at, updated_at) 
                    VALUES (:uuid, 'private', 'private', :created_by, NOW(), NOW())";
            
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':uuid', $conversationUuid);
            $stmt->bindValue(':created_by', $userId1);
            $stmt->execute();
            
            $conversationId = $conn->lastInsertId();
            
            // Ajouter les deux participants
            $sql = "INSERT INTO conversation_participants (conversation_id, user_id, role, joined_at) 
                    VALUES (:conversation_id, :user_id, 'member', NOW())";
            
            // Ajouter le premier participant
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':conversation_id', $conversationId);
            $stmt->bindValue(':user_id', $userId1);
            $stmt->execute();
            
            // Ajouter le deuxième participant
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':conversation_id', $conversationId);
            $stmt->bindValue(':user_id', $userId2);
            $stmt->execute();
            
            $conn->commit();
            
            error_log("Successfully created conversation with ID: $conversationId");
            return $conversationId;
            
        } catch (Exception $e) {
            $conn->rollback();
            error_log("Failed to create conversation: " . $e->getMessage());
            
            // Fallback: utiliser l'ancienne méthode si la création échoue
            $fallbackId = min($userId1, $userId2) . max($userId1, $userId2);
            error_log("Using fallback conversation_id: $fallbackId");
            return $fallbackId;
        }
    }

    private function generateUUID()
    {
        return sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    public function searchUsersByPhone()
    {
        try {
            $user = $this->getCurrentUser();
            $phone = $_GET['phone'] ?? '';

            if (empty($phone)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Phone number is required'
                ], 400);
            }

            // Nettoyer le numéro de téléphone (supprimer les espaces, tirets, etc.)
            $cleanPhone = preg_replace('/[^0-9]/', '', $phone);

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            $sql = "SELECT id, first_name, last_name, email, profile_photo_url, profile_picture, phone, primary_role 
                     FROM users 
                     WHERE id != :user_id 
                     AND phone IS NOT NULL
                     AND (phone = :phone OR phone LIKE :phone_pattern)
                     LIMIT 10";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':user_id', $user->id);
            $stmt->bindValue(':phone', $cleanPhone);
            $stmt->bindValue(':phone_pattern', "%{$cleanPhone}");
            $stmt->execute();
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $this->sendResponse([
                'success' => true,
                'data' => $users
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to search users by phone: ' . $e->getMessage()
            ], 500);
        }
    }
}
