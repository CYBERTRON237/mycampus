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
        $stmt = $pdo->prepare("SELECT u.*, i.name as institution_name, d.name as department_name 
                              FROM users u 
                              LEFT JOIN institutions i ON u.institution_id = i.id 
                              LEFT JOIN departments d ON u.department_id = d.id 
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

function canViewUser($currentUser, $targetUser) {
    if (!$currentUser || !$targetUser) return false;
    
    if ($currentUser['id'] == $targetUser['id']) return true;
    
    if ($currentUser['user_level'] >= 90) return true;
    
    if ($currentUser['user_level'] >= 80 && $currentUser['institution_id'] == $targetUser['institution_id']) {
        return true;
    }
    
    if ($currentUser['user_level'] > $targetUser['user_level']) {
        return true;
    }
    
    return false;
}

function canEditUser($currentUser, $targetUser) {
    if (!$currentUser || !$targetUser) return false;
    
    if ($currentUser['id'] == $targetUser['id']) return true;
    
    if (!canViewUser($currentUser, $targetUser)) return false;
    
    if ($currentUser['user_level'] <= $targetUser['user_level']) return false;
    
    if ($currentUser['user_level'] >= 90) {
        return true;
    } elseif ($currentUser['user_level'] >= 80) {
        return $currentUser['institution_id'] == $targetUser['institution_id'];
    } else {
        return $currentUser['user_level'] > $targetUser['user_level'];
    }
}

function canDeleteUser($currentUser, $targetUser) {
    if (!$currentUser || !$targetUser) return false;
    
    if ($currentUser['id'] == $targetUser['id']) return false;
    
    if ($currentUser['user_level'] < 80) return false;
    
    if ($currentUser['user_level'] >= 80 && $currentUser['institution_id'] == $targetUser['institution_id']) {
        return $currentUser['user_level'] > $targetUser['user_level'];
    }
    
    if ($currentUser['user_level'] >= 90) {
        return $currentUser['user_level'] > $targetUser['user_level'];
    }
    
    return false;
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

function generateMatricule($institutionId) {
    return 'MC' . $institutionId . date('Y') . str_pad(mt_rand(1, 9999), 4, '0', STR_PAD_LEFT);
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

// GET /users - Lister les utilisateurs
if ($method === 'GET' && count($pathParts) >= 4 && $pathParts[3] === 'users' && !isset($pathParts[4])) {
    try {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
        $offset = ($page - 1) * $limit;
        
        $sql = "SELECT u.*, i.name as institution_name, d.name as department_name 
                FROM users u 
                LEFT JOIN institutions i ON u.institution_id = i.id 
                LEFT JOIN departments d ON u.department_id = d.id 
                WHERE u.deleted_at IS NULL";
        
        $params = [];
        
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
        
        if ($currentUser['user_level'] < 90) {
            if ($currentUser['user_level'] >= 80) {
                $sql .= " AND (u.institution_id = ? OR u.id = ?)";
                $params[] = $currentUser['institution_id'];
                $params[] = $currentUser['id'];
            } else {
                $sql .= " AND u.user_level <= ?";
                $params[] = $currentUser['user_level'];
            }
        }
        
        $sql .= " ORDER BY u.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $users = $stmt->fetchAll();
        
        $result = [];
        foreach ($users as $user) {
            if (canViewUser($currentUser, $user)) {
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
                        'canView' => canViewUser($currentUser, $user),
                        'canEdit' => canEditUser($currentUser, $user),
                        'canDelete' => canDeleteUser($currentUser, $user)
                    ]
                ];
            }
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

// GET /users/{id} - Voir un utilisateur spécifique
elseif ($method === 'GET' && count($pathParts) >= 5 && $pathParts[3] === 'users' && is_numeric($pathParts[4])) {
    $targetId = (int)$pathParts[4];
    
    try {
        $stmt = $pdo->prepare("SELECT u.*, i.name as institution_name, d.name as department_name 
                              FROM users u 
                              LEFT JOIN institutions i ON u.institution_id = i.id 
                              LEFT JOIN departments d ON u.department_id = d.id 
                              WHERE u.id = ? AND u.deleted_at IS NULL");
        $stmt->execute([$targetId]);
        $targetUser = $stmt->fetch();
        
        if (!$targetUser) {
            echo json_encode(['success' => false, 'message' => 'Utilisateur non trouvé']);
            exit;
        }
        
        if (!canViewUser($currentUser, $targetUser)) {
            echo json_encode(['success' => false, 'message' => 'Permission refusée']);
            exit;
        }
        
        $targetUser['user_level'] = getUserLevel($targetUser['primary_role'] ?? 'user');
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => (int)$targetUser['id'],
                'uuid' => $targetUser['uuid'] ?? '',
                'email' => $targetUser['email'],
                'first_name' => $targetUser['first_name'],
                'last_name' => $targetUser['last_name'],
                'matricule' => $targetUser['matricule'],
                'primary_role' => $targetUser['primary_role'] ?? 'user',
                'account_status' => $targetUser['account_status'] ?? 'active',
                'is_active' => (bool)$targetUser['is_active'],
                'created_at' => $targetUser['created_at'],
                'last_login_at' => $targetUser['last_login_at'],
                'institution_name' => $targetUser['institution_name'],
                'department_name' => $targetUser['department_name'],
                'user_level' => (int)($targetUser['user_level'] ?? 10),
                'role_display_name' => $targetUser['primary_role'] ?? 'User',
                'user_roles' => $targetUser['primary_role'] ?? 'user',
                'permissions' => [
                    'canView' => canViewUser($currentUser, $targetUser),
                    'canEdit' => canEditUser($currentUser, $targetUser),
                    'canDelete' => canDeleteUser($currentUser, $targetUser)
                ]
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération de l\'utilisateur',
            'error' => $e->getMessage()
        ]);
    }
}

// POST /users - Créer un utilisateur
elseif ($method === 'POST' && count($pathParts) >= 4 && $pathParts[3] === 'users') {
    if ($currentUser['user_level'] < 80) {
        echo json_encode(['success' => false, 'message' => 'Permission refusée pour créer des utilisateurs']);
        exit;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données invalides']);
        exit;
    }
    
    try {
        $required = ['email', 'first_name', 'last_name', 'primary_role'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis"]);
                exit;
            }
        }
        
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND deleted_at IS NULL");
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'Cet email est déjà utilisé']);
            exit;
        }
        
        $uuid = generateUUID();
        $matricule = generateMatricule($input['institution_id'] ?? $currentUser['institution_id']);
        
        $sql = "INSERT INTO users (uuid, email, first_name, last_name, matricule, primary_role, 
                account_status, is_active, institution_id, department_id, user_level, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $uuid,
            $input['email'],
            $input['first_name'],
            $input['last_name'],
            $matricule,
            $input['primary_role'],
            $input['account_status'] ?? 'active',
            $input['is_active'] ?? 1,
            $input['institution_id'] ?? $currentUser['institution_id'],
            $input['department_id'] ?? null,
            getUserLevel($input['primary_role'])
        ]);
        
        $newUserId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Utilisateur créé avec succès',
            'data' => ['id' => (int)$newUserId]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de l\'utilisateur',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /users/{id} - Mettre à jour un utilisateur
elseif ($method === 'PUT' && count($pathParts) >= 5 && $pathParts[3] === 'users' && is_numeric($pathParts[4])) {
    $targetId = (int)$pathParts[4];
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$targetId]);
        $targetUser = $stmt->fetch();
        
        if (!$targetUser) {
            echo json_encode(['success' => false, 'message' => 'Utilisateur non trouvé']);
            exit;
        }
        
        $targetUser['user_level'] = getUserLevel($targetUser['primary_role'] ?? 'user');
        
        if (!canEditUser($currentUser, $targetUser)) {
            echo json_encode(['success' => false, 'message' => 'Permission refusée']);
            exit;
        }
        
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            echo json_encode(['success' => false, 'message' => 'Données invalides']);
            exit;
        }
        
        $updates = [];
        $params = [];
        
        $allowedFields = ['first_name', 'last_name', 'primary_role', 'account_status', 'is_active', 'institution_id', 'department_id'];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updates[] = "$field = ?";
                $params[] = $input[$field];
                
                if ($field === 'primary_role') {
                    $updates[] = "user_level = ?";
                    $params[] = getUserLevel($input[$field]);
                }
            }
        }
        
        if (empty($updates)) {
            echo json_encode(['success' => false, 'message' => 'Aucune donnée à mettre à jour']);
            exit;
        }
        
        $params[] = $targetId;
        
        $sql = "UPDATE users SET " . implode(', ', $updates) . ", updated_at = NOW() WHERE id = ?";
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

// DELETE /users/{id} - Supprimer un utilisateur
elseif ($method === 'DELETE' && count($pathParts) >= 5 && $pathParts[3] === 'users' && is_numeric($pathParts[4])) {
    $targetId = (int)$pathParts[4];
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$targetId]);
        $targetUser = $stmt->fetch();
        
        if (!$targetUser) {
            echo json_encode(['success' => false, 'message' => 'Utilisateur non trouvé']);
            exit;
        }
        
        $targetUser['user_level'] = getUserLevel($targetUser['primary_role'] ?? 'user');
        
        if (!canDeleteUser($currentUser, $targetUser)) {
            echo json_encode(['success' => false, 'message' => 'Permission refusée']);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE users SET deleted_at = NOW() WHERE id = ?");
        $stmt->execute([$targetId]);
        
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
}

// GET /users/current - Utilisateur courant
elseif ($method === 'GET' && count($pathParts) >= 5 && $pathParts[3] === 'users' && $pathParts[4] === 'current') {
    echo json_encode([
        'success' => true,
        'data' => [
            'user' => [
                'id' => $currentUser['id'],
                'email' => $currentUser['email'],
                'fullName' => $currentUser['first_name'] . ' ' . $currentUser['last_name'],
                'primaryRole' => $currentUser['primary_role'] ?? 'user'
            ],
            'highestLevel' => $currentUser['user_level'],
            'primaryRole' => $currentUser['primary_role'] ?? 'user'
        ]
    ]);
}

else {
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée'
    ]);
}
?>
