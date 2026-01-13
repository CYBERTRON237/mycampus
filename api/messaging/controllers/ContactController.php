<?php

class ContactController
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
        $headers = getallheaders();
        error_log("All headers: " . print_r($headers, true));
        
        $userId = $headers['X-User-Id'] ?? $headers['x-user-id'] ?? $headers['X-User-id'] ?? null;
        
        error_log("User ID from headers: " . $userId);
        
        if ($userId && (is_numeric($userId) || is_string($userId))) {
            error_log("Using user ID from headers: " . $userId);
            return (object) ['id' => (int)$userId];
        }
        
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        if (isset($_SESSION['user_id'])) {
            error_log("Using user ID from session: " . $_SESSION['user_id']);
            return (object) ['id' => $_SESSION['user_id']];
        }
        
        error_log("No valid user ID found - returning error");
        $this->sendResponse([
            'success' => false,
            'message' => 'User authentication required'
        ], 401);
        exit;
    }

    public function getContacts()
    {
        try {
            $user = $this->getCurrentUser();
            $limit = $_GET['limit'] ?? 50;
            $offset = $_GET['offset'] ?? 0;
            $status = $_GET['status'] ?? 'accepted';

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            $sql = "SELECT 
                        uc.id,
                        uc.user_id,
                        uc.contact_user_id,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.profile_photo_url,
                        u.profile_picture,
                        u.phone,
                        u.primary_role,
                        uc.status,
                        uc.created_at,
                        fc.id as is_favorite,
                        CASE 
                            WHEN u.updated_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE) THEN 1 
                            ELSE 0 
                        END as is_online
                    FROM user_contacts uc
                    JOIN users u ON uc.contact_user_id = u.id
                    LEFT JOIN favorite_contacts fc ON uc.user_id = fc.user_id AND uc.contact_user_id = fc.contact_user_id
                    WHERE uc.user_id = :userId AND uc.status = :status
                    ORDER BY is_online DESC, u.last_name ASC, u.first_name ASC
                    LIMIT :limit OFFSET :offset";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $user->id);
            $stmt->bindValue(':status', $status);
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
            $stmt->execute();

            $contacts = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $contacts[] = [
                    'id' => $row['id'],
                    'user_id' => $row['user_id'],
                    'contact_user_id' => $row['contact_user_id'],
                    'first_name' => $row['first_name'],
                    'last_name' => $row['last_name'],
                    'email' => $row['email'],
                    'profile_photo_url' => $row['profile_photo_url'],
                    'profile_picture' => $row['profile_picture'],
                    'phone' => $row['phone'],
                    'primary_role' => $row['primary_role'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                    'is_favorite' => $row['is_favorite'] ? 1 : 0,
                    'is_online' => $row['is_online'] ? 1 : 0,
                ];
            }

            $this->sendResponse([
                'success' => true,
                'data' => $contacts
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to fetch contacts: ' . $e->getMessage()
            ], 500);
        }
    }

    public function sendContactRequest()
    {
        try {
            $user = $this->getCurrentUser();
            $rawInput = file_get_contents('php://input');
            
            if (empty($rawInput)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'No input data received'
                ], 400);
            }
            
            $input = json_decode($rawInput, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Invalid JSON data: ' . json_last_error_msg()
                ], 400);
            }
            
            $recipientId = $input['recipient_id'] ?? '';
            $message = $input['message'] ?? '';
            
            if (empty($recipientId) || $recipientId == $user->id) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Valid recipient ID is required'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Vérifier si le destinataire existe
            $checkUserSql = "SELECT id FROM users WHERE id = :recipientId AND account_status = 'active' AND is_active = 1";
            $checkUserStmt = $conn->prepare($checkUserSql);
            $checkUserStmt->bindValue(':recipientId', $recipientId);
            $checkUserStmt->execute();
            
            if (!$checkUserStmt->fetch(PDO::FETCH_ASSOC)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'User not found or inactive'
                ], 404);
            }

            // Vérifier si une demande existe déjà
            $checkRequestSql = "SELECT id, status FROM contact_requests 
                               WHERE (requester_id = :userId1 AND recipient_id = :userId2) 
                               OR (requester_id = :userId2 AND recipient_id = :userId1)";
            $checkRequestStmt = $conn->prepare($checkRequestSql);
            $checkRequestStmt->bindValue(':userId1', $user->id);
            $checkRequestStmt->bindValue(':userId2', $recipientId);
            $checkRequestStmt->execute();
            
            $existingRequest = $checkRequestStmt->fetch(PDO::FETCH_ASSOC);
            if ($existingRequest) {
                if ($existingRequest['status'] === 'pending') {
                    $this->sendResponse([
                        'success' => false,
                        'message' => 'Contact request already pending'
                    ], 409);
                } else {
                    $this->sendResponse([
                        'success' => false,
                        'message' => 'Contact already exists or was processed'
                    ], 409);
                }
            }

            // Créer la demande de contact
            $sql = "INSERT INTO contact_requests (requester_id, recipient_id, message, status) 
                    VALUES (:requesterId, :recipientId, :message, 'pending')";
            
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':requesterId', $user->id);
            $stmt->bindValue(':recipientId', $recipientId);
            $stmt->bindValue(':message', $message);
            $stmt->execute();
            
            $requestId = $conn->lastInsertId();

            $this->sendResponse([
                'success' => true,
                'message' => 'Contact request sent successfully',
                'data' => [
                    'id' => $requestId,
                    'requester_id' => $user->id,
                    'recipient_id' => $recipientId,
                    'message' => $message,
                    'status' => 'pending'
                ]
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to send contact request: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getContactRequests()
    {
        try {
            $user = $this->getCurrentUser();
            $type = $_GET['type'] ?? 'received'; // 'sent' or 'received'

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            if ($type === 'sent') {
                $sql = "SELECT 
                            cr.id,
                            cr.recipient_id as contact_user_id,
                            cr.message,
                            cr.status,
                            cr.created_at,
                            u.first_name,
                            u.last_name,
                            u.profile_photo_url,
                            u.profile_picture
                        FROM contact_requests cr
                        JOIN users u ON cr.recipient_id = u.id
                        WHERE cr.requester_id = :userId AND cr.status = 'pending'
                        ORDER BY cr.created_at DESC";
            } else {
                $sql = "SELECT 
                            cr.id,
                            cr.requester_id as contact_user_id,
                            cr.message,
                            cr.status,
                            cr.created_at,
                            u.first_name,
                            u.last_name,
                            u.profile_photo_url,
                            u.profile_picture
                        FROM contact_requests cr
                        JOIN users u ON cr.requester_id = u.id
                        WHERE cr.recipient_id = :userId AND cr.status = 'pending'
                        ORDER BY cr.created_at DESC";
            }

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':userId', $user->id);
            $stmt->execute();

            $requests = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $requests[] = [
                    'id' => $row['id'],
                    'contact_user_id' => $row['contact_user_id'],
                    'first_name' => $row['first_name'],
                    'last_name' => $row['last_name'],
                    'profile_photo_url' => $row['profile_photo_url'],
                    'profile_picture' => $row['profile_picture'],
                    'message' => $row['message'],
                    'status' => $row['status'],
                    'created_at' => $row['created_at'],
                ];
            }

            $this->sendResponse([
                'success' => true,
                'data' => $requests
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to fetch contact requests: ' . $e->getMessage()
            ], 500);
        }
    }

    public function respondToContactRequest($requestId)
    {
        try {
            $user = $this->getCurrentUser();
            $rawInput = file_get_contents('php://input');
            
            if (empty($rawInput)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'No input data received'
                ], 400);
            }
            
            $input = json_decode($rawInput, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Invalid JSON data: ' . json_last_error_msg()
                ], 400);
            }
            
            $action = $input['action'] ?? ''; // 'accept' or 'reject'
            
            if (!in_array($action, ['accept', 'reject'])) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Invalid action. Must be "accept" or "reject"'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Vérifier que la demande existe et appartient à l'utilisateur
            $checkSql = "SELECT requester_id, recipient_id FROM contact_requests 
                        WHERE id = :requestId AND recipient_id = :userId AND status = 'pending'";
            $checkStmt = $conn->prepare($checkSql);
            $checkStmt->bindValue(':requestId', $requestId);
            $checkStmt->bindValue(':userId', $user->id);
            $checkStmt->execute();
            
            $request = $checkStmt->fetch(PDO::FETCH_ASSOC);
            if (!$request) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Contact request not found or already processed'
                ], 404);
            }

            $conn->beginTransaction();

            try {
                // Mettre à jour le statut de la demande
                $newStatus = $action === 'accept' ? 'accepted' : 'rejected';
                $updateSql = "UPDATE contact_requests SET status = :status WHERE id = :requestId";
                $updateStmt = $conn->prepare($updateSql);
                $updateStmt->bindValue(':status', $newStatus);
                $updateStmt->bindValue(':requestId', $requestId);
                $updateStmt->execute();

                if ($action === 'accept') {
                    // Ajouter le contact dans les deux sens
                    $contactSql = "INSERT INTO user_contacts (user_id, contact_user_id, status) VALUES 
                                  (:userId1, :userId2, 'accepted'), 
                                  (:userId2, :userId1, 'accepted')";
                    $contactStmt = $conn->prepare($contactSql);
                    $contactStmt->bindValue(':userId1', $user->id);
                    $contactStmt->bindValue(':userId2', $request['requester_id']);
                    $contactStmt->execute();
                }

                $conn->commit();

                $this->sendResponse([
                    'success' => true,
                    'message' => "Contact request $newStatus successfully"
                ]);
            } catch (Exception $e) {
                $conn->rollBack();
                throw $e;
            }
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to process contact request: ' . $e->getMessage()
            ], 500);
        }
    }

    public function toggleFavoriteContact($contactUserId)
    {
        try {
            $user = $this->getCurrentUser();

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            // Vérifier si le contact existe
            $checkSql = "SELECT id FROM user_contacts 
                        WHERE user_id = :userId AND contact_user_id = :contactUserId AND status = 'accepted'";
            $checkStmt = $conn->prepare($checkSql);
            $checkStmt->bindValue(':userId', $user->id);
            $checkStmt->bindValue(':contactUserId', $contactUserId);
            $checkStmt->execute();
            
            if (!$checkStmt->fetch(PDO::FETCH_ASSOC)) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Contact not found'
                ], 404);
            }

            // Vérifier si déjà favori
            $checkFavoriteSql = "SELECT id FROM favorite_contacts 
                                 WHERE user_id = :userId AND contact_user_id = :contactUserId";
            $checkFavoriteStmt = $conn->prepare($checkFavoriteSql);
            $checkFavoriteStmt->bindValue(':userId', $user->id);
            $checkFavoriteStmt->bindValue(':contactUserId', $contactUserId);
            $checkFavoriteStmt->execute();
            
            $isFavorite = $checkFavoriteStmt->fetch(PDO::FETCH_ASSOC);

            if ($isFavorite) {
                // Retirer des favoris
                $deleteSql = "DELETE FROM favorite_contacts 
                             WHERE user_id = :userId AND contact_user_id = :contactUserId";
                $deleteStmt = $conn->prepare($deleteSql);
                $deleteStmt->bindValue(':userId', $user->id);
                $deleteStmt->bindValue(':contactUserId', $contactUserId);
                $deleteStmt->execute();
                
                $message = 'Contact removed from favorites';
                $isNowFavorite = false;
            } else {
                // Ajouter aux favoris
                $insertSql = "INSERT INTO favorite_contacts (user_id, contact_user_id) 
                             VALUES (:userId, :contactUserId)";
                $insertStmt = $conn->prepare($insertSql);
                $insertStmt->bindValue(':userId', $user->id);
                $insertStmt->bindValue(':contactUserId', $contactUserId);
                $insertStmt->execute();
                
                $message = 'Contact added to favorites';
                $isNowFavorite = true;
            }

            $this->sendResponse([
                'success' => true,
                'message' => $message,
                'is_favorite' => $isNowFavorite
            ]);
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to toggle favorite: ' . $e->getMessage()
            ], 500);
        }
    }

    public function deleteContact($contactUserId)
    {
        try {
            $user = $this->getCurrentUser();

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            $conn->beginTransaction();

            try {
                // Supprimer le contact dans les deux sens
                $deleteSql = "DELETE FROM user_contacts 
                             WHERE (user_id = :userId AND contact_user_id = :contactUserId)
                             OR (user_id = :contactUserId AND contact_user_id = :userId)";
                $deleteStmt = $conn->prepare($deleteSql);
                $deleteStmt->bindValue(':userId', $user->id);
                $deleteStmt->bindValue(':contactUserId', $contactUserId);
                $deleteStmt->execute();

                // Supprimer des favoris
                $deleteFavoriteSql = "DELETE FROM favorite_contacts 
                                     WHERE (user_id = :userId AND contact_user_id = :contactUserId)
                                     OR (user_id = :contactUserId AND contact_user_id = :userId)";
                $deleteFavoriteStmt = $conn->prepare($deleteFavoriteSql);
                $deleteFavoriteStmt->bindValue(':userId', $user->id);
                $deleteFavoriteStmt->bindValue(':contactUserId', $contactUserId);
                $deleteFavoriteStmt->execute();

                $conn->commit();

                $this->sendResponse([
                    'success' => true,
                    'message' => 'Contact deleted successfully'
                ]);
            } catch (Exception $e) {
                $conn->rollBack();
                throw $e;
            }
        } catch (Exception $e) {
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to delete contact: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getContactInfo()
    {
        try {
            $user = $this->getCurrentUser();
            $headers = getallheaders();
            $contactUserId = $headers['X-Contact-User-Id'] ?? $headers['x-contact-user-id'] ?? null;

            if (!$contactUserId) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Contact user ID required'
                ], 400);
            }

            $conn = $this->getConnection();
            if (!$conn) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Database connection failed'
                ], 500);
            }

            $sql = "SELECT 
                        u.id,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.profile_photo_url,
                        u.profile_picture,
                        u.phone,
                        u.primary_role,
                        u.updated_at
                    FROM users u
                    WHERE u.id = :contactUserId";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':contactUserId', $contactUserId);
            $stmt->execute();

            $contactData = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$contactData) {
                $this->sendResponse([
                    'success' => false,
                    'message' => 'Contact not found'
                ], 404);
            }

            // Formater les données comme un ContactModel
            $contact = [
                'id' => $contactUserId,
                'user_id' => $user->id,
                'contact_user_id' => $contactUserId,
                'first_name' => $contactData['first_name'],
                'last_name' => $contactData['last_name'],
                'email' => $contactData['email'],
                'profile_photo_url' => $contactData['profile_photo_url'],
                'profile_picture' => $contactData['profile_picture'],
                'phone' => $contactData['phone'],
                'primary_role' => $contactData['primary_role'],
                'status' => 'accepted',
                'created_at' => date('Y-m-d H:i:s'),
                'last_seen_at' => $contactData['updated_at'],
                'is_favorite' => 0,
                'is_online' => (strtotime($contactData['updated_at']) >= strtotime('-5 minutes')) ? 1 : 0,
            ];

            $this->sendResponse([
                'success' => true,
                'data' => $contact
            ]);

        } catch (Exception $e) {
            error_log("Error getting contact info: " . $e->getMessage());
            $this->sendResponse([
                'success' => false,
                'message' => 'Failed to get contact info: ' . $e->getMessage()
            ], 500);
        }
    }
}
?>
