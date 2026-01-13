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

    if (!$conversationId || !$userId) {
        throw new Exception('Paramètres manquants');
    }

    $database = new Database();
    $db = $database->getConnection();

    // Marquer tous les messages non-lus envoyés à l'utilisateur actuel comme "delivered"
    $query = "UPDATE messages 
              SET status = 'delivered', 
                  delivered_at = NOW() 
              WHERE conversation_id = :conversation_id 
                AND receiver_id = :user_id 
                AND status IN ('sent', 'sending')
                AND delivered_at IS NULL";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':conversation_id', $conversationId);
    $stmt->bindParam(':user_id', $userId);
    $result = $stmt->execute();

    $updatedCount = $stmt->rowCount();

    if ($result) {
        // Récupérer les messages mis à jour pour la notification WebSocket
        $selectQuery = "SELECT id, sender_id, receiver_id, status, delivered_at 
                        FROM messages 
                        WHERE conversation_id = :conversation_id 
                          AND receiver_id = :user_id 
                          AND delivered_at IS NOT NULL 
                          AND status = 'delivered'
                          AND delivered_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)";
        
        $selectStmt = $db->prepare($selectQuery);
        $selectStmt->bindParam(':conversation_id', $conversationId);
        $selectStmt->bindParam(':user_id', $userId);
        $selectStmt->execute();
        
        $updatedMessages = $selectStmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Messages marqués comme delivered',
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
