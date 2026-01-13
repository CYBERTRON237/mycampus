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
require_once __DIR__ . '/models/UsersStudentModel.php';
require_once __DIR__ . '/controllers/StudentController.php';

// Créer l'instance du contrôleur
$controller = new StudentController($pdo);

// Router les requêtes
$method = $_SERVER['REQUEST_METHOD'];
// Use rewritten path if available, otherwise use REQUEST_URI
$path = isset($_GET['rewritten_path']) ? $_GET['rewritten_path'] : parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
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

// Route: /api/student_management/students/*
// Handle both /mycampus/api/student_management/students/*, /api/student_management/students/*, and /mycampus/api/students/*
$apiIndex = array_search('api', $pathParts);
if ($apiIndex !== false && count($pathParts) > $apiIndex + 1) {
    $isStudentRoute = false;
    
    // Check for /api/student_management/students pattern
    if (count($pathParts) > $apiIndex + 2 && 
        $pathParts[$apiIndex + 1] === 'student_management' && 
        $pathParts[$apiIndex + 2] === 'students') {
        $isStudentRoute = true;
        $studentIdIndex = $apiIndex + 3;
        $actionIndex = $apiIndex + 4;
    }
    // Check for /api/students pattern (direct route)
    elseif ($pathParts[$apiIndex + 1] === 'students') {
        $isStudentRoute = true;
        $studentIdIndex = $apiIndex + 2;
        $actionIndex = $apiIndex + 3;
    }
    
    if ($isStudentRoute) {
    
    $studentId = null;
    $action = null;
    
    // Extraire l'ID de l'étudiant s'il existe
    if (isset($pathParts[$studentIdIndex]) && is_numeric($pathParts[$studentIdIndex])) {
        $studentId = (int) $pathParts[$studentIdIndex];
        $action = $pathParts[$actionIndex] ?? null;
    } elseif (isset($pathParts[$studentIdIndex])) {
        $action = $pathParts[$studentIdIndex];
    }
    
    try {
        switch ($method) {
            case 'GET':
                if ($studentId && !$action) {
                    // GET /api/student_management/students/{id}
                    $controller->getStudent($studentId);
                } elseif ($action === 'stats') {
                    // GET /api/student_management/students/stats
                    $controller->getStudentStats();
                } elseif ($action === 'export') {
                    // GET /api/student_management/students/export
                    $controller->exportStudents();
                } else {
                    // GET /api/student_management/students
                    $controller->getStudents();
                }
                break;
                
            case 'POST':
                if (!$studentId && !$action) {
                    // POST /api/student_management/students
                    $controller->createStudent();
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
                if ($studentId && !$action) {
                    // PUT /api/student_management/students/{id}
                    $controller->updateStudent($studentId);
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
                if ($studentId && !$action) {
                    // DELETE /api/student_management/students/{id}
                    $controller->deleteStudent($studentId);
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
        'expected_pattern' => 'api/student_management/students/*',
        'actual_count' => count($pathParts)
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>
