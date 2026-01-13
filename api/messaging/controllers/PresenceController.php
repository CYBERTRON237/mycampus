<?php

class PresenceController
{
    private function getConnection()
    {
        try {
            $conn = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $conn;
        } catch(PDOException $e) {
            error_log("DB Connection Error: " . $e->getMessage());
            return null;
        }
    }

    private function getCurrentUser()
    {
        $headers = getallheaders();
        $userId = $headers['X-User-Id'] ?? $headers['x-user-id'] ?? $headers['X-User-id'] ?? null;
        
        if ($userId && (is_numeric($userId) || is_string($userId))) {
            return (object) ['id' => (int)$userId];
        }
        
        // Fallback pour les tests
        return (object) ['id' => 1];
    }

    private function sendResponse($data, $statusCode = 200)
    {
        while (ob_get_level()) {
            ob_end_clean();
        }
        
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit();
    }

    // Mettre à jour le statut en ligne
    public function updatePresence()
    {
        try {
            $user = $this->getCurrentUser();
            $rawInput = file_get_contents('php://input');
            
            $input = json_decode($rawInput, true) ?? [];
            $isOnline = $input['is_online'] ?? true;
            $status = $input['status'] ?? ($isOnline ? 'online' : 'offline');
            $deviceType = $input['device_type'] ?? 'web';
            $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
            $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '';

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Upsert dans la table de présence
            $sql = "INSERT INTO user_presence 
                    (user_id, is_online, last_seen, last_activity, status, device_type, ip_address, user_agent)
                    VALUES (:userId, :isOnline, NOW(), NOW(), :status, :deviceType, :ipAddress, :userAgent)
                    ON DUPLICATE KEY UPDATE
                    is_online = VALUES(is_online),
                    last_seen = VALUES(last_seen),
                    last_activity = VALUES(last_activity),
                    status = VALUES(status),
                    device_type = VALUES(device_type),
                    ip_address = VALUES(ip_address),
                    user_agent = VALUES(user_agent),
                    updated_at = NOW()";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $user->id);
            $stmt->bindValue(':isOnline', $isOnline ? 1 : 0);
            $stmt->bindValue(':status', $status);
            $stmt->bindValue(':deviceType', $deviceType);
            $stmt->bindValue(':ipAddress', $ipAddress);
            $stmt->bindValue(':userAgent', $userAgent);
            $stmt->execute();

            // Mettre à jour aussi la table users
            $updateUserSql = "UPDATE users SET last_active_at = NOW() WHERE id = :userId";
            $userStmt = $conn->prepare($updateUserSql);
            $userStmt->bindValue(':userId', $user->id);
            $userStmt->execute();

            // Envoyer via WebSocket si disponible
            $this->broadcastPresenceUpdate($user->id, $isOnline, $status);

            $this->sendResponse([
                'success' => true,
                'data' => [
                    'user_id' => $user->id,
                    'is_online' => $isOnline,
                    'status' => $status,
                    'last_seen' => date('Y-m-d H:i:s')
                ]
            ]);

        } catch (Exception $e) {
            error_log("Error updating presence: " . $e->getMessage());
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to update presence: ' . $e->getMessage()
            ], 500);
        }
    }

    // Obtenir le statut de présence d'un utilisateur
    public function getUserPresence($userId)
    {
        try {
            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            $sql = "SELECT up.*, u.first_name, u.last_name, u.profile_photo_url, u.profile_picture
                    FROM user_presence up
                    LEFT JOIN users u ON up.user_id = u.id
                    WHERE up.user_id = :userId";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $userId);
            $stmt->execute();

            $presence = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($presence) {
                // Calculer si l'utilisateur est vraiment en ligne (activité < 5 minutes)
                $lastActivity = new DateTime($presence['last_activity']);
                $now = new DateTime();
                $interval = $now->diff($lastActivity);
                $minutesAgo = $interval->i + ($interval->h * 60) + ($interval->d * 24 * 60);

                $isActuallyOnline = $presence['is_online'] && $minutesAgo < 5;
                
                $this->sendResponse([
                    'success' => true,
                    'data' => [
                        'user_id' => (int)$presence['user_id'],
                        'is_online' => $isActuallyOnline,
                        'status' => $isActuallyOnline ? $presence['status'] : 'offline',
                        'last_seen' => $presence['last_seen'],
                        'last_activity' => $presence['last_activity'],
                        'first_name' => $presence['first_name'],
                        'last_name' => $presence['last_name'],
                        'profile_photo_url' => $presence['profile_photo_url'] ?? $presence['profile_picture'],
                        'minutes_ago' => $minutesAgo
                    ]
                ]);
            } else {
                // Utilisateur pas encore dans la table de présence
                $this->sendResponse([
                    'success' => true,
                    'data' => [
                        'user_id' => (int)$userId,
                        'is_online' => false,
                        'status' => 'offline',
                        'last_seen' => null,
                        'last_activity' => null
                    ]
                ]);
            }

        } catch (Exception $e) {
            error_log("Error getting user presence: " . $e->getMessage());
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to get user presence: ' . $e->getMessage()
            ], 500);
        }
    }

    // Obtenir la liste des utilisateurs en ligne
    public function getOnlineUsers()
    {
        try {
            $user = $this->getCurrentUser();
            $limit = $_GET['limit'] ?? 50;
            $offset = $_GET['offset'] ?? 0;

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Utilisateurs actifs dans les 5 dernières minutes
            $sql = "SELECT DISTINCT up.user_id, up.is_online, up.status, up.last_seen, up.last_activity,
                           u.first_name, u.last_name, u.email, u.profile_photo_url, u.profile_picture
                    FROM user_presence up
                    LEFT JOIN users u ON up.user_id = u.id
                    WHERE up.user_id != :currentUserId
                    AND up.last_activity > DATE_SUB(NOW(), INTERVAL 5 MINUTE)
                    AND up.is_online = 1
                    ORDER BY up.last_activity DESC
                    LIMIT :limit OFFSET :offset";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':currentUserId', $user->id);
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
            $stmt->execute();

            $onlineUsers = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $onlineUsers[] = [
                    'user_id' => (int)$row['user_id'],
                    'is_online' => true,
                    'status' => $row['status'],
                    'last_seen' => $row['last_seen'],
                    'last_activity' => $row['last_activity'],
                    'first_name' => $row['first_name'],
                    'last_name' => $row['last_name'],
                    'full_name' => trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? '')),
                    'profile_photo_url' => $row['profile_photo_url'] ?? $row['profile_picture']
                ];
            }

            $this->sendResponse([
                'success' => true,
                'data' => $onlineUsers,
                'count' => count($onlineUsers)
            ]);

        } catch (Exception $e) {
            error_log("Error getting online users: " . $e->getMessage());
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to get online users: ' . $e->getMessage()
            ], 500);
        }
    }

    // Nettoyer les anciennes présences (cron job)
    public function cleanupOldPresence()
    {
        try {
            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Marquer comme hors ligne les utilisateurs inactifs depuis plus de 10 minutes
            $sql = "UPDATE user_presence 
                    SET is_online = 0, status = 'offline', updated_at = NOW()
                    WHERE last_activity < DATE_SUB(NOW(), INTERVAL 10 MINUTE) 
                    AND is_online = 1";

            $stmt = $conn->prepare($sql);
            $stmt->execute();

            $affectedRows = $stmt->rowCount();

            $this->sendResponse([
                'success' => true,
                'message' => "Cleaned up $affectedRows inactive users"
            ]);

        } catch (Exception $e) {
            error_log("Error cleaning up presence: " . $e->getMessage());
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to cleanup presence: ' . $e->getMessage()
            ], 500);
        }
    }

    // Broadcast via WebSocket (si disponible)
    private function broadcastPresenceUpdate($userId, $isOnline, $status)
    {
        try {
            $message = [
                'type' => 'presence_update',
                'user_id' => $userId,
                'is_online' => $isOnline,
                'status' => $status,
                'timestamp' => time()
            ];

            // Envoyer au serveur WebSocket si disponible
            $websocketUrl = 'http://127.0.0.1:8080/broadcast';
            $context = stream_context_create([
                'http' => [
                    'method' => 'POST',
                    'header' => 'Content-Type: application/json',
                    'content' => json_encode($message),
                    'timeout' => 1
                ]
            ]);

            @file_get_contents($websocketUrl, false, $context);
        } catch (Exception $e) {
            // Ignorer les erreurs WebSocket - c'est optionnel
            error_log("WebSocket broadcast failed: " . $e->getMessage());
        }
    }
}
