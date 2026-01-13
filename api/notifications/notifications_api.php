<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion à la base de données
try {
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

// Récupérer l'utilisateur courant depuis le token JWT (simplifié)
function getCurrentUser($pdo) {
    $userId = 1;
    
    try {
        $stmt = $pdo->prepare("SELECT u.*, i.name as institution_name 
                              FROM users u 
                              LEFT JOIN institutions i ON u.institution_id = i.id 
                              WHERE u.id = ? AND u.deleted_at IS NULL");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        
        if ($user) {
            $user['user_level'] = getUserLevel($user['primary_role'] ?? 'user');
            return $user;
        }
        return null;
    } catch (Exception $e) {
        return null;
    }
}

function getUserLevel($role) {
    $levels = [
        'superadmin' => 100,
        'admin_national' => 90,
        'admin_local' => 80,
        'manager' => 60,
        'faculty_admin' => 50,
        'department_head' => 40,
        'teacher' => 30,
        'student' => 10,
        'user' => 10
    ];
    return $levels[$role] ?? 10;
}

function generateUUID() {
    return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

$currentUser = getCurrentUser($pdo);

if (!$currentUser) {
    echo json_encode([
        'success' => false,
        'message' => 'Utilisateur non authentifié'
    ]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// GET /api/notifications/notifications - Lister les notifications
if ($method === 'GET' && count($pathParts) >= 4 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php') && !isset($pathParts[4])) {
    try {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
        $offset = ($page - 1) * $limit;
        
        $sql = "SELECT n.*, u.first_name, u.last_name as actor_last_name,
                       CONCAT(u.first_name, ' ', u.last_name) as actor_name
                FROM notifications n
                LEFT JOIN users u ON n.actor_id = u.id
                WHERE n.user_id = ? AND n.deleted_at IS NULL";
        
        $params = [$currentUser['id']];
        
        // Filtres
        if (!empty($_GET['is_read'])) {
            $sql .= " AND n.is_read = ?";
            $params[] = $_GET['is_read'] === 'true' ? 1 : 0;
        }
        
        if (!empty($_GET['category'])) {
            $sql .= " AND n.category = ?";
            $params[] = $_GET['category'];
        }
        
        if (!empty($_GET['type'])) {
            $sql .= " AND n.type = ?";
            $params[] = $_GET['type'];
        }
        
        $sql .= " ORDER BY n.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $notifications = $stmt->fetchAll();
        
        $result = [];
        foreach ($notifications as $notif) {
            $result[] = [
                'id' => (int)$notif['id'],
                'uuid' => $notif['uuid'],
                'user_id' => (int)$notif['user_id'],
                'type' => $notif['type'],
                'notification_type' => $notif['notification_type'],
                'category' => $notif['category'],
                'title' => $notif['title'],
                'body' => $notif['body'],
                'content' => $notif['content'],
                'icon' => $notif['icon'],
                'image_url' => $notif['image_url'],
                'action_url' => $notif['action_url'],
                'action_type' => $notif['action_type'],
                'related_id' => $notif['related_id'] ? (int)$notif['related_id'] : null,
                'related_type' => $notif['related_type'],
                'actor_id' => $notif['actor_id'] ? (int)$notif['actor_id'] : null,
                'actor_name' => $notif['actor_name'],
                'priority' => $notif['priority'],
                'is_read' => (bool)$notif['is_read'],
                'read_at' => $notif['read_at'],
                'is_sent_push' => (bool)$notif['is_sent_push'],
                'sent_push_at' => $notif['sent_push_at'],
                'is_sent_email' => (bool)$notif['is_sent_email'],
                'sent_email_at' => $notif['sent_email_at'],
                'metadata' => json_decode($notif['metadata'] ?? '{}'),
                'expires_at' => $notif['expires_at'],
                'created_at' => $notif['created_at']
            ];
        }
        
        // Compter les notifications non lues
        $unreadCount = 0;
        if ($page === 1) {
            $stmt = $pdo->prepare("SELECT COUNT(*) as unread_count FROM notifications WHERE user_id = ? AND is_read = 0 AND deleted_at IS NULL");
            $stmt->execute([$currentUser['id']]);
            $unreadCount = (int)$stmt->fetch()['unread_count'];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $result,
            'unread_count' => $unreadCount,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => count($result)
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des notifications',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /api/notifications/notifications/{id} - Voir une notification spécifique
elseif ($method === 'GET' && count($pathParts) >= 5 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php') && is_numeric($pathParts[4])) {
    $notifId = (int)$pathParts[4];
    
    try {
        $sql = "SELECT n.*, u.first_name, u.last_name as actor_last_name,
                       CONCAT(u.first_name, ' ', u.last_name) as actor_name
                FROM notifications n
                LEFT JOIN users u ON n.actor_id = u.id
                WHERE n.id = ? AND n.user_id = ? AND n.deleted_at IS NULL";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$notifId, $currentUser['id']]);
        $notif = $stmt->fetch();
        
        if (!$notif) {
            echo json_encode(['success' => false, 'message' => 'Notification non trouvée']);
            exit;
        }
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => (int)$notif['id'],
                'uuid' => $notif['uuid'],
                'user_id' => (int)$notif['user_id'],
                'type' => $notif['type'],
                'notification_type' => $notif['notification_type'],
                'category' => $notif['category'],
                'title' => $notif['title'],
                'body' => $notif['body'],
                'content' => $notif['content'],
                'icon' => $notif['icon'],
                'image_url' => $notif['image_url'],
                'action_url' => $notif['action_url'],
                'action_type' => $notif['action_type'],
                'related_id' => $notif['related_id'] ? (int)$notif['related_id'] : null,
                'related_type' => $notif['related_type'],
                'actor_id' => $notif['actor_id'] ? (int)$notif['actor_id'] : null,
                'actor_name' => $notif['actor_name'],
                'priority' => $notif['priority'],
                'is_read' => (bool)$notif['is_read'],
                'read_at' => $notif['read_at'],
                'is_sent_push' => (bool)$notif['is_sent_push'],
                'sent_push_at' => $notif['sent_push_at'],
                'is_sent_email' => (bool)$notif['is_sent_email'],
                'sent_email_at' => $notif['sent_email_at'],
                'metadata' => json_decode($notif['metadata'] ?? '{}'),
                'expires_at' => $notif['expires_at'],
                'created_at' => $notif['created_at']
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération de la notification',
            'error' => $e->getMessage()
        ]);
    }
}

// POST /api/notifications/notifications - Créer une notification
elseif ($method === 'POST' && count($pathParts) >= 4 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php')) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données invalides']);
        exit;
    }
    
    try {
        $required = ['user_id', 'title', 'content'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis"]);
                exit;
            }
        }
        
        // Permissions : seul un admin peut créer des notifications pour d'autres
        if ($input['user_id'] != $currentUser['id'] && $currentUser['user_level'] < 80) {
            echo json_encode(['success' => false, 'message' => 'Permission refusée']);
            exit;
        }
        
        $uuid = generateUUID();
        
        $sql = "INSERT INTO notifications (uuid, user_id, type, notification_type, category, title, body, content,
                icon, image_url, action_url, action_type, related_id, related_type, actor_id, priority, metadata, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $uuid,
            $input['user_id'],
            $input['type'] ?? 'system',
            $input['notification_type'] ?? $input['type'] ?? 'system',
            $input['category'] ?? 'system',
            $input['title'],
            $input['body'] ?? $input['content'],
            $input['content'],
            $input['icon'] ?? null,
            $input['image_url'] ?? null,
            $input['action_url'] ?? null,
            $input['action_type'] ?? null,
            $input['related_id'] ?? null,
            $input['related_type'] ?? null,
            $currentUser['id'], // actor_id
            $input['priority'] ?? 'normal',
            $input['metadata'] ? json_encode($input['metadata']) : null
        ]);
        
        $newId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Notification créée avec succès',
            'data' => [
                'id' => (int)$newId,
                'uuid' => $uuid
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de la notification',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /api/notifications/notifications/{id}/read - Marquer comme lu
elseif ($method === 'PUT' && count($pathParts) >= 6 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php') && is_numeric($pathParts[4]) && $pathParts[5] === 'read') {
    $notifId = (int)$pathParts[4];
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM notifications WHERE id = ? AND user_id = ? AND deleted_at IS NULL");
        $stmt->execute([$notifId, $currentUser['id']]);
        $notif = $stmt->fetch();
        
        if (!$notif) {
            echo json_encode(['success' => false, 'message' => 'Notification non trouvée']);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1, read_at = NOW() WHERE id = ?");
        $stmt->execute([$notifId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Notification marquée comme lue'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour de la notification',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /api/notifications/notifications/read-all - Marquer toutes comme lues
elseif ($method === 'PUT' && count($pathParts) >= 5 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php') && $pathParts[4] === 'read-all') {
    try {
        $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1, read_at = NOW() 
                              WHERE user_id = ? AND is_read = 0 AND deleted_at IS NULL");
        $stmt->execute([$currentUser['id']]);
        
        $updatedCount = $stmt->rowCount();
        
        echo json_encode([
            'success' => true,
            'message' => "$updatedCount notification(s) marquée(s) comme lue(s)",
            'updated_count' => $updatedCount
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour des notifications',
            'error' => $e->getMessage()
        ]);
    }
}

// DELETE /api/notifications/notifications/{id} - Supprimer une notification
elseif ($method === 'DELETE' && count($pathParts) >= 5 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php') && is_numeric($pathParts[4])) {
    $notifId = (int)$pathParts[4];
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM notifications WHERE id = ? AND user_id = ? AND deleted_at IS NULL");
        $stmt->execute([$notifId, $currentUser['id']]);
        $notif = $stmt->fetch();
        
        if (!$notif) {
            echo json_encode(['success' => false, 'message' => 'Notification non trouvée']);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE notifications SET deleted_at = NOW() WHERE id = ?");
        $stmt->execute([$notifId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Notification supprimée avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la suppression de la notification',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /api/notifications/notifications/unread-count - Compter les notifications non lues
elseif ($method === 'GET' && count($pathParts) >= 5 && $pathParts[1] === 'api' && $pathParts[2] === 'notifications' && ($pathParts[3] === 'notifications' || $pathParts[3] === 'notifications_api.php') && $pathParts[4] === 'unread-count') {
    try {
        $stmt = $pdo->prepare("SELECT COUNT(*) as unread_count FROM notifications 
                              WHERE user_id = ? AND is_read = 0 AND deleted_at IS NULL");
        $stmt->execute([$currentUser['id']]);
        $result = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'unread_count' => (int)$result['unread_count']
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors du comptage des notifications',
            'error' => $e->getMessage()
        ]);
    }
}

else {
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée'
    ]);
}
?>
