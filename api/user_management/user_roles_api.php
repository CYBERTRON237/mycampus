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

// Route GET /user_roles/{user_id} - Obtenir les rôles d'un utilisateur
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $urlParts = explode('/', trim($_SERVER['REQUEST_URI'], '/'));
        $userId = end($urlParts);
        
        if (!is_numeric($userId)) {
            echo json_encode([
                'success' => false,
                'message' => 'ID utilisateur invalide'
            ]);
            exit;
        }
        
        // Récupérer les rôles de l'utilisateur avec les détails des rôles
        $stmt = $pdo->prepare("
            SELECT ur.*, r.code, r.name, r.display_name, r.category, r.level, r.description
            FROM user_roles ur 
            LEFT JOIN roles r ON ur.role_id = r.id 
            WHERE ur.user_id = ? AND ur.is_active = 1
            ORDER BY r.level DESC
        ");
        $stmt->execute([$userId]);
        $userRoles = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $userRoles
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des rôles',
            'error' => $e->getMessage()
        ]);
    }
}
// Route POST /user_roles - Assigner un rôle à un utilisateur
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!$data) {
            echo json_encode([
                'success' => false,
                'message' => 'Données invalides'
            ]);
            exit;
        }
        
        // Validation des champs requis
        $requiredFields = ['user_id', 'role_id'];
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Champ '$field' est requis"
                ]);
                exit;
            }
        }
        
        $userId = (int)$data['user_id'];
        $roleId = (int)$data['role_id'];
        $scope = $data['scope'] ?? 'institution';
        $scopeId = $data['scope_id'] ?? null;
        $grantedBy = $data['granted_by'] ?? null;
        
        // Vérifier si l'utilisateur et le rôle existent
        $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$userId]);
        if (!$stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Utilisateur non trouvé'
            ]);
            exit;
        }
        
        $stmt = $pdo->prepare("SELECT id FROM roles WHERE id = ? AND is_active = 1");
        $stmt->execute([$roleId]);
        if (!$stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Rôle non trouvé'
            ]);
            exit;
        }
        
        // Vérifier si le rôle est déjà assigné
        $stmt = $pdo->prepare("
            SELECT id FROM user_roles 
            WHERE user_id = ? AND role_id = ? AND scope = ? AND scope_id = ? AND is_active = 1
        ");
        $stmt->execute([$userId, $roleId, $scope, $scopeId]);
        if ($stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Ce rôle est déjà assigné à cet utilisateur'
            ]);
            exit;
        }
        
        // Insertion du rôle
        $stmt = $pdo->prepare("
            INSERT INTO user_roles (user_id, role_id, scope, scope_id, granted_by, granted_at, is_active) 
            VALUES (?, ?, ?, ?, ?, NOW(), 1)
        ");
        $stmt->execute([$userId, $roleId, $scope, $scopeId, $grantedBy]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Rôle assigné avec succès',
            'data' => ['id' => $pdo->lastInsertId()]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de l\'assignation du rôle',
            'error' => $e->getMessage()
        ]);
    }
}
// Route PUT /user_roles/{id} - Mettre à jour un rôle utilisateur
else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    try {
        $urlParts = explode('/', trim($_SERVER['REQUEST_URI'], '/'));
        $roleId = end($urlParts);
        
        if (!is_numeric($roleId)) {
            echo json_encode([
                'success' => false,
                'message' => 'ID de rôle invalide'
            ]);
            exit;
        }
        
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!$data) {
            echo json_encode([
                'success' => false,
                'message' => 'Données invalides'
            ]);
            exit;
        }
        
        // Vérifier si le rôle utilisateur existe
        $stmt = $pdo->prepare("SELECT id FROM user_roles WHERE id = ?");
        $stmt->execute([$roleId]);
        if (!$stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Rôle utilisateur non trouvé'
            ]);
            exit;
        }
        
        // Construction de la requête de mise à jour
        $sql = "UPDATE user_roles SET ";
        $params = [];
        $updates = [];
        
        $allowedFields = ['scope', 'scope_id', 'expires_at', 'is_active', 'permissions'];
        
        foreach ($allowedFields as $field) {
            if (isset($data[$field])) {
                $updates[] = "$field = ?";
                $params[] = $data[$field];
            }
        }
        
        if (empty($updates)) {
            echo json_encode([
                'success' => false,
                'message' => 'Aucun champ à mettre à jour'
            ]);
            exit;
        }
        
        $sql .= implode(', ', $updates);
        $sql .= " WHERE id = ?";
        $params[] = $roleId;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        echo json_encode([
            'success' => true,
            'message' => 'Rôle utilisateur mis à jour avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour du rôle utilisateur',
            'error' => $e->getMessage()
        ]);
    }
}
// Route DELETE /user_roles/{id} - Supprimer un rôle utilisateur
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    try {
        $urlParts = explode('/', trim($_SERVER['REQUEST_URI'], '/'));
        $roleId = end($urlParts);
        
        if (!is_numeric($roleId)) {
            echo json_encode([
                'success' => false,
                'message' => 'ID de rôle invalide'
            ]);
            exit;
        }
        
        // Vérifier si le rôle utilisateur existe
        $stmt = $pdo->prepare("SELECT id FROM user_roles WHERE id = ?");
        $stmt->execute([$roleId]);
        if (!$stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Rôle utilisateur non trouvé'
            ]);
            exit;
        }
        
        // Suppression logique (désactivation)
        $stmt = $pdo->prepare("UPDATE user_roles SET is_active = 0 WHERE id = ?");
        $stmt->execute([$roleId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Rôle utilisateur supprimé avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la suppression du rôle utilisateur',
            'error' => $e->getMessage()
        ]);
    }
}
// Route GET /roles - Obtenir tous les rôles disponibles
else if (preg_match('/\/roles$/', $_SERVER['REQUEST_URI']) && $_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $stmt = $pdo->prepare("
            SELECT id, code, name, display_name, category, level, description, is_active, is_system_role
            FROM roles 
            WHERE is_active = 1
            ORDER BY category, level DESC
        ");
        $stmt->execute();
        $roles = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $roles
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des rôles',
            'error' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée ou endpoint non trouvé'
    ]);
}
?>
