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

// Route GET /users
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
        $offset = ($page - 1) * $limit;
        
        // Construction de la requête avec filtres
        $sql = "SELECT u.*, i.name as institution_name, d.name as department_name 
                FROM users u 
                LEFT JOIN institutions i ON u.institution_id = i.id 
                LEFT JOIN departments d ON u.department_id = d.id 
                WHERE u.deleted_at IS NULL";
        
        $params = [];
        
        // Ajout des filtres
        if (!empty($_GET['search'])) {
            $sql .= " AND (u.first_name LIKE ? OR u.last_name LIKE ? OR u.email LIKE ?)";
            $searchTerm = '%' . $_GET['search'] . '%';
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
        
        if (!empty($_GET['role'])) {
            $sql .= " AND u.primary_role = ?";
            $params[] = $_GET['role'];
        }
        
        if (!empty($_GET['status'])) {
            $sql .= " AND u.account_status = ?";
            $params[] = $_GET['status'];
        }
        
        if (!empty($_GET['institution_id'])) {
            $sql .= " AND u.institution_id = ?";
            $params[] = (int)$_GET['institution_id'];
        }
        
        // Ajout de la pagination
        $sql .= " ORDER BY u.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $users = $stmt->fetchAll();
        
        // Transformer les données pour correspondre au modèle Flutter
        $result = [];
        foreach ($users as $user) {
            $result[] = [
                'id' => (int)$user['id'],
                'uuid' => $user['uuid'] ?? '',
                'email' => $user['email'],
                'first_name' => $user['first_name'],
                'last_name' => $user['last_name'],
                'matricule' => $user['matricule'],
                'primary_role' => $user['primary_role'] ?? 'user',
                'account_status' => $user['account_status'] ?? 'active',
                'is_active' => (bool)$user['is_active'],
                'created_at' => $user['created_at'],
                'last_login_at' => $user['last_login_at'],
                'institution_name' => $user['institution_name'],
                'department_name' => $user['department_name'],
                'user_level' => (int)($user['user_level'] ?? 10),
                'role_display_name' => $user['primary_role'] ?? 'User',
                'user_roles' => $user['primary_role'] ?? 'user',
                'permissions' => [
                    'canView' => true,
                    'canEdit' => true,
                    'canDelete' => true
                ]
            ];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $result,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => count($result)
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des utilisateurs',
            'error' => $e->getMessage()
        ]);
    }
} 
// Route POST /users (création)
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
        
        // Validation
        $requiredFields = ['first_name', 'last_name', 'email', 'primary_role'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Le champ $field est requis"
                ]);
                exit;
            }
        }
        
        // Vérifier si l'email existe déjà
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND deleted_at IS NULL");
        $stmt->execute([$data['email']]);
        if ($stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Cet email est déjà utilisé'
            ]);
            exit;
        }
        
        // Générer un UUID
        $uuid = sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
        
        // Insertion
        $sql = "INSERT INTO users (uuid, first_name, last_name, email, matricule, primary_role, password, is_active, account_status, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, 1, 'active', NOW())";
        
        $hashedPassword = password_hash($data['password'] ?? 'default123', PASSWORD_DEFAULT);
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $uuid,
            $data['first_name'],
            $data['last_name'],
            $data['email'],
            $data['matricule'] ?? null,
            $data['primary_role'],
            $hashedPassword
        ]);
        
        $userId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Utilisateur créé avec succès',
            'data' => ['id' => (int)$userId]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de l\'utilisateur',
            'error' => $e->getMessage()
        ]);
    }
}
// Route PUT /users/{id} (mise à jour)
else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
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
        
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!$data) {
            echo json_encode([
                'success' => false,
                'message' => 'Données invalides'
            ]);
            exit;
        }
        
        // Vérifier si l'utilisateur existe
        $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$userId]);
        if (!$stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Utilisateur non trouvé'
            ]);
            exit;
        }
        
        // Construction de la requête de mise à jour
        $sql = "UPDATE users SET ";
        $params = [];
        $updates = [];
        
        // Champs modifiables pour mise à jour complète
        $allowedFields = [
            'first_name', 'last_name', 'middle_name', 'email', 'phone', 'matricule', 'student_id',
            'password_hash', 'primary_role', 'account_status', 'is_active', 'is_verified',
            'language_preference', 'timezone', 'gender', 'date_of_birth', 'place_of_birth',
            'nationality', 'profile_photo_url', 'profile_picture', 'cover_photo_url',
            'bio', 'address', 'city', 'region', 'country', 'postal_code',
            'emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relationship',
            'institution_id', 'department_id', 'level', 'academic_year'
        ];
        
        foreach ($allowedFields as $field) {
            if (isset($data[$field])) {
                if ($field === 'password_hash') {
                    $updates[] = "$field = ?";
                    $params[] = password_hash($data[$field], PASSWORD_DEFAULT);
                } else {
                    $updates[] = "$field = ?";
                    $params[] = $data[$field];
                }
            }
        }
        
        // Gestion spéciale pour le mot de passe si envoyé comme 'password'
        if (isset($data['password'])) {
            $updates[] = "password_hash = ?";
            $params[] = password_hash($data['password'], PASSWORD_DEFAULT);
            $updates[] = "password_changed_at = NOW()";
            $updates[] = "must_change_password = 0";
        }
        
        if (empty($updates)) {
            echo json_encode([
                'success' => false,
                'message' => 'Aucun champ à mettre à jour'
            ]);
            exit;
        }
        
        $sql .= implode(', ', $updates);
        $sql .= ", updated_at = NOW() WHERE id = ?";
        $params[] = $userId;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        echo json_encode([
            'success' => true,
            'message' => 'Utilisateur mis à jour avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour de l\'utilisateur',
            'error' => $e->getMessage()
        ]);
    }
}
// Route DELETE /users/{id} (suppression)
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
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
        
        // Vérifier si l'utilisateur existe
        $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$userId]);
        if (!$stmt->fetch()) {
            echo json_encode([
                'success' => false,
                'message' => 'Utilisateur non trouvé'
            ]);
            exit;
        }
        
        // Suppression logique
        $stmt = $pdo->prepare("UPDATE users SET deleted_at = NOW() WHERE id = ?");
        $stmt->execute([$userId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Utilisateur supprimé avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la suppression de l\'utilisateur',
            'error' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée'
    ]);
}
?>
