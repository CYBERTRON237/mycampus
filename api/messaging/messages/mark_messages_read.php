<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-User-Id');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config/database.php';
require_once '../models/Message.php';

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    
    if (!$data) {
        throw new Exception('Données JSON invalides');
    }

    $conversationId = $data['conversation_id'] ?? null;
    $userId = $_SERVER['HTTP_USER_ID'] ?? null;
    $messageIds = $data['message_ids'] ?? null; // Optionnel: pour marquer des messages spécifiques

    if (!$conversationId || !$userId) {
        throw new Exception('Paramètres manquants');
    }

    $database = new Database();
    $db = $database->getConnection();

    $updatedCount = 0;
    $updatedMessages = [];

    if ($messageIds && is_array($messageIds)) {
        // Marquer des messages spécifiques comme lus
        $placeholders = str_repeat('?,', count($messageIds) - 1) . '?';
        $query = "UPDATE messages 
                  SET status = 'read', 
                      read_at = NOW() 
                  WHERE id IN ($placeholders)
                    AND receiver_id = ?
                    AND status != 'read'";
        
        $params = [...$messageIds, $userId];
        $stmt = $db->prepare($query);
        $result = $stmt->execute($params);
        $updatedCount = $stmt->rowCount();
        
        // Récupérer les messages mis à jour
        $selectQuery = "SELECT id, sender_id, receiver_id, status, read_at 
                       FROM messages 
                       WHERE id IN ($placeholders)
                         AND receiver_id = ?
                         AND status = 'read'
                         AND read_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)";
        
        $selectStmt = $db->prepare($selectQuery);
        $selectParams = [...$messageIds, $userId];
        $selectStmt->execute($selectParams);
        $updatedMessages = $selectStmt->fetchAll(PDO::FETCH_ASSOC);
        
    } else {
        // Marquer tous les messages non-lus de la conversation comme lus
        $query = "UPDATE messages 
                  SET status = 'read', 
                      read_at = NOW() 
                  WHERE conversation_id = :conversation_id 
                    AND receiver_id = :user_id 
                    AND status IN ('sent', 'delivered')
                    AND read_at IS NULL";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':conversation_id', $conversationId);
        $stmt->bindParam(':user_id', $userId);
        $result = $stmt->execute();
        $updatedCount = $stmt->rowCount();

        // Récupérer les messages mis à jour pour la notification WebSocket
        $selectQuery = "SELECT id, sender_id, receiver_id, status, read_at 
                        FROM messages 
                        WHERE conversation_id = :conversation_id 
                          AND receiver_id = :user_id 
                          AND read_at IS NOT NULL 
                          AND status = 'read'
                          AND read_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)";
        
        $selectStmt = $db->prepare($selectQuery);
        $selectStmt->bindParam(':conversation_id', $conversationId);
        $selectStmt->bindParam(':user_id', $userId);
        $selectStmt->execute();
        
        $updatedMessages = $selectStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    if ($result) {
        echo json_encode([
            'success' => true,
            'message' => 'Messages marqués comme lus',
            'updated_count' => $updatedCount,
            'updated_messages' => $updatedMessages
        ]);
    } else {
        throw new Exception('Erreur lors de la mise à jour des messages');
    }

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
