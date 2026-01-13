<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Gérer les requêtes OPTIONS (pre-flight)
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
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}

// Router les requêtes
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// Route: /api/user_management/users/*
if (count($pathParts) >= 3 && $pathParts[0] === 'api' && $pathParts[1] === 'user_management' && $pathParts[2] === 'users') {
    
    $userId = null;
    $action = null;
    
    // Extraire l'ID de l'utilisateur s'il existe
    if (isset($pathParts[3]) && is_numeric($pathParts[3])) {
        $userId = (int) $pathParts[3];
        $action = $pathParts[4] ?? null;
    } elseif (isset($pathParts[3])) {
        $action = $pathParts[3];
    }
    
    try {
        switch ($method) {
            case 'GET':
                if ($userId && !$action) {
                    // GET /api/user_management/users/{id}
                    getUserById($pdo, $userId);
                } elseif ($action === 'stats') {
                    // GET /api/user_management/users/stats
                    getUserStats($pdo);
                } elseif ($action === 'current') {
                    // GET /api/user_management/users/current
                    getCurrentUser($pdo);
                } else {
                    // GET /api/user_management/users
                    getUsers($pdo);
                }
                break;
                
            case 'POST':
                if ($userId && $action === 'roles') {
                    // POST /api/user_management/users/{id}/roles
                    assignRole($pdo, $userId);
                } elseif (!$userId && !$action) {
                    // POST /api/user_management/users
                    createUser($pdo);
                } else {
                    sendJsonResponse(['success' => false, 'message' => 'Route non trouvée'], 404);
                }
                break;
                
            case 'PUT':
                if ($userId && !$action) {
                    // PUT /api/user_management/users/{id}
                    updateUser($pdo, $userId);
                } else {
                    sendJsonResponse(['success' => false, 'message' => 'Route non trouvée'], 404);
                }
                break;
                
            case 'DELETE':
                if ($userId && !$action) {
                    // DELETE /api/user_management/users/{id}
                    deleteUser($pdo, $userId);
                } else {
                    sendJsonResponse(['success' => false, 'message' => 'Route non trouvée'], 404);
                }
                break;
                
            default:
                sendJsonResponse(['success' => false, 'message' => 'Méthode non autorisée'], 405);
                break;
        }
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur serveur: ' . $e->getMessage()], 500);
    }
} else {
    // Route non trouvée - debug info
    sendJsonResponse([
        'success' => false,
        'message' => 'Route non trouvée',
        'path' => $path,
        'path_parts' => $pathParts,
        'expected_pattern' => 'api/user_management/users/*'
    ], 404);
}

// Fonctions utilitaires
function sendJsonResponse(array $data, int $statusCode = 200): void {
    header('Content-Type: application/json');
    http_response_code($statusCode);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}

function getJsonInput(): array {
    $input = file_get_contents('php://input');
    return json_decode($input, true) ?: [];
}

function authenticate(): bool {
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
    
    if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
        return false;
    }

    $token = substr($authHeader, 7);
    
    try {
        // Token simple pour tests: base64 de {"user_id":1}
        $payload = json_decode(base64_decode($token), true);
        return $payload && isset($payload['user_id']);
    } catch (\Exception $e) {
        return false;
    }
}

// Fonctions API simplifiées
function getUsers($pdo): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $stmt = $pdo->query("SELECT * FROM users LIMIT 10");
        $users = $stmt->fetchAll();
        
        sendJsonResponse([
            'success' => true,
            'data' => $users,
            'pagination' => ['page' => 1, 'limit' => 10, 'total' => count($users)]
        ]);
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function getUserById($pdo, $id): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$id]);
        $user = $stmt->fetch();
        
        if ($user) {
            sendJsonResponse(['success' => true, 'data' => $user]);
        } else {
            sendJsonResponse(['success' => false, 'message' => 'Utilisateur non trouvé'], 404);
        }
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function createUser($pdo): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $input = getJsonInput();
        
        if (empty($input['email']) || empty($input['first_name']) || empty($input['last_name'])) {
            sendJsonResponse(['success' => false, 'message' => 'Champs requis manquants'], 400);
        }

        $stmt = $pdo->prepare("INSERT INTO users (email, first_name, last_name, created_at) VALUES (?, ?, ?, NOW())");
        $success = $stmt->execute([$input['email'], $input['first_name'], $input['last_name']]);
        
        if ($success) {
            sendJsonResponse(['success' => true, 'message' => 'Utilisateur créé avec succès', 'user_id' => $pdo->lastInsertId()], 201);
        } else {
            sendJsonResponse(['success' => false, 'message' => 'Échec de la création'], 400);
        }
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function updateUser($pdo, $id): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $input = getJsonInput();
        
        if (empty($input)) {
            sendJsonResponse(['success' => false, 'message' => 'Aucune donnée fournie'], 400);
        }

        $fields = [];
        $values = [];
        
        foreach (['first_name', 'last_name', 'email'] as $field) {
            if (isset($input[$field])) {
                $fields[] = "$field = ?";
                $values[] = $input[$field];
            }
        }
        
        if (empty($fields)) {
            sendJsonResponse(['success' => false, 'message' => 'Aucun champ valide à mettre à jour'], 400);
        }
        
        $values[] = $id;
        $sql = "UPDATE users SET " . implode(', ', $fields) . " WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $success = $stmt->execute($values);
        
        if ($success) {
            sendJsonResponse(['success' => true, 'message' => 'Utilisateur mis à jour avec succès']);
        } else {
            sendJsonResponse(['success' => false, 'message' => 'Échec de la mise à jour'], 400);
        }
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function deleteUser($pdo, $id): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
        $success = $stmt->execute([$id]);
        
        if ($success) {
            sendJsonResponse(['success' => true, 'message' => 'Utilisateur supprimé avec succès']);
        } else {
            sendJsonResponse(['success' => false, 'message' => 'Échec de la suppression'], 400);
        }
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function getUserStats($pdo): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $stmt = $pdo->query("SELECT COUNT(*) as total_users FROM users");
        $stats = $stmt->fetchAll();
        
        sendJsonResponse(['success' => true, 'data' => $stats]);
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function getCurrentUser($pdo): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        // Pour l'instant, retourner un utilisateur fixe pour les tests
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = 1");
        $stmt->execute();
        $user = $stmt->fetch();
        
        if ($user) {
            sendJsonResponse(['success' => true, 'data' => $user]);
        } else {
            sendJsonResponse(['success' => false, 'message' => 'Utilisateur non trouvé'], 404);
        }
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}

function assignRole($pdo, $userId): void {
    if (!authenticate()) {
        sendJsonResponse(['success' => false, 'message' => 'Authentification requise'], 401);
    }

    try {
        $input = getJsonInput();
        
        if (empty($input['role'])) {
            sendJsonResponse(['success' => false, 'message' => 'Rôle requis'], 400);
        }

        // Simulation - à implémenter avec la table des rôles
        sendJsonResponse(['success' => true, 'message' => 'Rôle assigné avec succès']);
    } catch (Exception $e) {
        sendJsonResponse(['success' => false, 'message' => 'Erreur: ' . $e->getMessage()], 500);
    }
}
?>
