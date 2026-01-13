<?php
// Contrôleur de messages avec debug complet
class MessageControllerDebug {
    
    private function getConnection() {
        try {
            $conn = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $conn;
        } catch(PDOException $e) {
            error_log("DB Connection Error: " . $e->getMessage());
            return null;
        }
    }
    
    private function getCurrentUser() {
        $headers = getallheaders();
        error_log("DEBUG - Headers: " . print_r($headers, true));
        
        $userId = $headers['X-User-Id'] ?? $headers['x-user-id'] ?? $headers['X-User-id'] ?? null;
        
        error_log("DEBUG - User ID from headers: " . $userId);
        
        if ($userId && (is_numeric($userId) || is_string($userId))) {
            error_log("DEBUG - Using user ID from headers: " . $userId);
            return (object) ['id' => (int)$userId];
        }
        
        // Fallback pour les tests
        error_log("DEBUG - No valid user ID found - using fallback user ID 1");
        return (object) ['id' => 1];
    }
    
    private function sendResponse($data, $statusCode = 200) {
        while (ob_get_level()) {
            ob_end_clean();
        }
        
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit();
    }
    
    public function sendMessage() {
        error_log("DEBUG - sendMessage called");
        
        try {
            $user = $this->getCurrentUser();
            error_log("DEBUG - Current user ID: " . $user->id);
            
            $rawInput = file_get_contents('php://input');
            error_log("DEBUG - Raw input: " . $rawInput);
            
            if (empty($rawInput)) {
                error_log("DEBUG - ERROR: No input data received");
                $this->sendResponse([
                    'success' => false,
                    'message' => 'No input data received'
                ], 400);
            }
            
            $input = json_decode($rawInput, true);
            error_log("DEBUG - Parsed input: " . print_r($input, true));
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                error_log("DEBUG - ERROR: JSON decode error: " . json_last_error_msg());
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Invalid JSON data: ' . json_last_error_msg()
                ], 400);
            }
            
            $receiverId = $input['receiver_id'] ?? '';
            $content = $input['content'] ?? '';
            $type = $input['type'] ?? 'text';
            $attachmentUrl = $input['attachment_url'] ?? '';
            $attachmentName = $input['attachment_name'] ?? '';
            
            error_log("DEBUG - Extracted data - receiverId: $receiverId, content: $content, type: $type");
            
            if (empty($receiverId)) {
                error_log("DEBUG - ERROR: Receiver ID is required");
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Receiver ID is required'
                ], 400);
            }
            
            if (empty($content) && $type !== 'sticker') {
                error_log("DEBUG - ERROR: Content is required for non-sticker messages");
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Content is required'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                error_log("DEBUG - ERROR: Database connection failed");
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }
            
            error_log("DEBUG - Database connection successful");

            // Créer ou récupérer la conversation selon votre structure
            $conversationId = $this->getOrCreateConversation($conn, $user->id, $receiverId);
            error_log("DEBUG - Conversation ID: $conversationId");
            
            // Insérer le message avec la structure exacte de votre BDD
            $uuid = $this->generateUUID();
            error_log("DEBUG - Generated UUID: $uuid");
            
            $sql = "INSERT INTO messages (uuid, conversation_id, sender_id, receiver_id, type, message_type, content, attachments, metadata, delivery_status, status, sent_at, created_at) 
                    VALUES (:uuid, :conversation_id, :sender_id, :receiver_id, :type, 'private', :content, :attachments, :metadata, 'sent', 'sent', NOW(), NOW())";
            
            error_log("DEBUG - SQL: " . $sql);
            
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':uuid', $uuid);
            $stmt->bindValue(':conversation_id', $conversationId);
            $stmt->bindValue(':sender_id', $user->id);
            $stmt->bindValue(':receiver_id', $receiverId);
            $stmt->bindValue(':type', $type);
            $stmt->bindValue(':content', $content);
            
            // Préparer les attachments si présents
            $attachments = null;
            if ($attachmentUrl) {
                $attachments = json_encode(['url' => $attachmentUrl, 'name' => $attachmentName]);
                error_log("DEBUG - Attachments JSON: " . $attachments);
            }
            $stmt->bindValue(':attachments', $attachments);
            $stmt->bindValue(':metadata', null);
            
            error_log("DEBUG - Executing insert...");
            $stmt->execute();
            
            $messageId = $conn->lastInsertId();
            error_log("DEBUG - Message inserted with ID: $messageId");
            
            // Récupérer le message inséré
            $sql = "SELECT * FROM messages WHERE id = :messageId";
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':messageId', $messageId);
            $stmt->execute();
            $message = $stmt->fetch(PDO::FETCH_ASSOC);
            
            error_log("DEBUG - Retrieved message: " . print_r($message, true));

            $this->sendResponse([
                'success' => true,
                'data' => $message
            ]);
            
        } catch (Exception $e) {
            error_log("DEBUG - EXCEPTION: " . $e->getMessage());
            error_log("DEBUG - Stack trace: " . $e->getTraceAsString());
            
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to send message: ' . $e->getMessage()
            ], 500);
        }
    }
    
    private function getOrCreateConversation($conn, $userId1, $userId2) {
        error_log("DEBUG - getOrCreateConversation called with userId1: $userId1, userId2: $userId2");
        
        // Chercher une conversation existante entre ces deux utilisateurs
        $sql = "SELECT DISTINCT conversation_id FROM messages 
                WHERE (sender_id = :userId1 AND receiver_id = :userId2) 
                   OR (sender_id = :userId2 AND receiver_id = :userId1)
                LIMIT 1";
        
        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':userId1', $userId1);
        $stmt->bindValue(':userId2', $userId2);
        $stmt->execute();
        
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result && $result['conversation_id']) {
            error_log("DEBUG - Found existing conversation_id: " . $result['conversation_id']);
            return $result['conversation_id'];
        }
        
        // Créer un nouveau conversation_id simple et prévisible
        $conversationId = min($userId1, $userId2) . max($userId1, $userId2);
        error_log("DEBUG - Creating new conversation_id: $conversationId for users $userId1 and $userId2");
        
        return $conversationId;
    }
    
    private function generateUUID() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
}

// Point d'entrée
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-User-Id');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$controller = new MessageControllerDebug();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $controller->sendMessage();
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
