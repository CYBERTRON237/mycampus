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

    $messageId = $data['message_id'] ?? null;
    $status = $data['status'] ?? null; // 'delivered' ou 'read'
    $userId = $_SERVER['HTTP_X_USER_ID'] ?? null;

    if (!$messageId || !$status || !$userId) {
        throw new Exception('Paramètres manquants');
    }

    if (!in_array($status, ['delivered', 'read'])) {
        throw new Exception('Statut invalide');
    }

    $database = new Database();
    $db = $database->getConnection();
    $message = new Message($db);

    // Vérifier que le message existe et que l'utilisateur est le destinataire
    $query = "SELECT id, sender_id, receiver_id, status FROM messages WHERE id = :message_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':message_id', $messageId);
    $stmt->execute();
    
    if ($stmt->rowCount() === 0) {
        throw new Exception('Message non trouvé');
    }

    $msgData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Vérifier que l'utilisateur actuel est bien le destinataire
    if ($msgData['receiver_id'] != $userId) {
        throw new Exception('Non autorisé à mettre à jour ce message');
    }

    // Mettre à jour le statut
    $updateFields = ['status' => $status];
    
    if ($status === 'read') {
        $updateFields['read_at'] = date('Y-m-d H:i:s');
    } elseif ($status === 'delivered') {
        $updateFields['delivered_at'] = date('Y-m-d H:i:s');
    }

    $result = $message->updateMessageStatus($messageId, $updateFields);

    if ($result) {
        // Notifier l'expéditeur via WebSocket si disponible
        $notificationData = [
            'type' => 'message_status_update',
            'message_id' => $messageId,
            'status' => $status,
            'updated_by' => $userId,
            'timestamp' => time()
        ];
        
        // Envoyer la notification WebSocket ici si nécessaire
        
        echo json_encode([
            'success' => true,
            'message' => 'Statut du message mis à jour avec succès',
            'data' => [
                'message_id' => $messageId,
                'status' => $status,
                'updated_at' => date('Y-m-d H:i:s')
            ]
        ]);
    } else {
        throw new Exception('Erreur lors de la mise à jour du statut');
    }

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
