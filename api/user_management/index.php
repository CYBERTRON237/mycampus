<?php
// Configuration de la base de données
require_once __DIR__ . '/../../../vendor/autoload.php';

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
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}

// Inclure les classes nécessaires
require_once __DIR__ . '/models/User.php';
require_once __DIR__ . '/controllers/UserController.php';

// Créer l'instance du contrôleur
$controller = new UserController($pdo);

// Router les requêtes
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// Debug: afficher le chemin pour diagnostic
error_log("Path: $path");
error_log("Path parts: " . json_encode($pathParts));

// Output debug info to response for testing
if (isset($_GET['debug'])) {
    echo json_encode([
        'debug' => true,
        'method' => $method,
        'path' => $path,
        'path_parts' => $pathParts,
        'count' => count($pathParts)
    ]);
    exit;
}

// Route: /api/user_management/users/*
if (count($pathParts) >= 4 && $pathParts[1] === 'api' && $pathParts[2] === 'user_management' && $pathParts[3] === 'users') {
    
    $userId = null;
    $action = null;
    
    // Extraire l'ID de l'utilisateur s'il existe
    if (isset($pathParts[4]) && is_numeric($pathParts[4])) {
        $userId = (int) $pathParts[4];
        $action = $pathParts[5] ?? null;
    } elseif (isset($pathParts[4])) {
        $action = $pathParts[4];
    }
    
    try {
        switch ($method) {
            case 'GET':
                if ($userId && !$action) {
                    // GET /api/user_management/users/{id}
                    $controller->show($userId);
                } elseif ($action === 'stats') {
                    // GET /api/user_management/users/stats
                    $controller->stats();
                } elseif ($action === 'current') {
                    // GET /api/user_management/users/current
                    $controller->current();
                } elseif ($action === 'search') {
                    // POST /api/user_management/users/search (redirigé vers POST)
                    if ($method === 'POST') {
                        $controller->search();
                    } else {
                        http_response_code(405);
                        header('Content-Type: application/json');
                        echo json_encode([
                            'success' => false,
                            'message' => 'Méthode non autorisée',
                            'error' => 'method_not_allowed'
                        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                    }
                } else {
                    // GET /api/user_management/users
                    $controller->index();
                }
                break;
                
            case 'POST':
                if ($userId && $action === 'roles') {
                    // POST /api/user_management/users/{id}/roles
                    $controller->assignRole($userId);
                } elseif (!$userId && !$action) {
                    // POST /api/user_management/users
                    $controller->create();
                } else {
                    http_response_code(404);
                    header('Content-Type: application/json');
                    echo json_encode([
                        'success' => false,
                        'message' => 'Route non trouvée',
                        'error' => 'route_not_found'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                }
                break;
                
            case 'PUT':
                if ($userId && !$action) {
                    // PUT /api/user_management/users/{id}
                    $controller->update($userId);
                } else {
                    http_response_code(404);
                    header('Content-Type: application/json');
                    echo json_encode([
                        'success' => false,
                        'message' => 'Route non trouvée',
                        'error' => 'route_not_found'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                }
                break;
                
            case 'DELETE':
                if ($userId && !$action) {
                    // DELETE /api/user_management/users/{id}
                    $controller->delete($userId);
                } else {
                    http_response_code(404);
                    header('Content-Type: application/json');
                    echo json_encode([
                        'success' => false,
                        'message' => 'Route non trouvée',
                        'error' => 'route_not_found'
                    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                }
                break;
                
            default:
                http_response_code(405);
                header('Content-Type: application/json');
                echo json_encode([
                    'success' => false,
                    'message' => 'Méthode non autorisée',
                    'error' => 'method_not_allowed'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                break;
        }
    } catch (Exception $e) {
        http_response_code(500);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Erreur serveur: ' . $e->getMessage(),
            'error' => 'server_error'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} else {
    // Route non trouvée - debug info
    http_response_code(404);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée',
        'error' => 'route_not_found',
        'path' => $path,
        'path_parts' => $pathParts,
        'expected_pattern' => 'api/user_management/users/*',
        'actual_count' => count($pathParts)
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
