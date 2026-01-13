<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gérer les requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Inclure les fichiers nécessaires
require_once __DIR__ . '/controllers/StudentController.php';

// Analyser l'URL pour déterminer la route
$requestUri = $_SERVER['REQUEST_URI'];
$method = $_SERVER['REQUEST_METHOD'];

// Debug: Afficher l'URI pour diagnostic
error_log("Request URI: " . $requestUri);

// Simplification: utiliser le query string ou parser depuis REQUEST_URI
$path = '';

// Vérifier si on a des paramètres dans l'URL
if (isset($_GET['path'])) {
    $path = trim($_GET['path'], '/');
} else {
    // Parser depuis REQUEST_URI
    $parsedUrl = parse_url($requestUri);
    $path = $parsedUrl['path'] ?? '';
    
    // Extraire le chemin après /api/student_management/
    if (strpos($path, '/api/student_management') !== false) {
        $path = str_replace('/api/student_management', '', $path);
    }
    
    // Enlever le nom du fichier si présent
    if (strpos($path, 'student_management_api.php') !== false) {
        $path = str_replace('student_management_api.php', '', $path);
    }
    
    // Enlever tout autre préfixe indésirable
    if (strpos($path, 'mycampus') !== false) {
        $path = str_replace('mycampus', '', $path);
    }
    
    $path = trim($path, '/');
    
    // Si le path est vide, considérer comme 'students' pour la route par défaut
    if (empty($path)) {
        $path = 'students';
    }
}

// Debug: Afficher le chemin nettoyé
error_log("Cleaned path: '" . $path . "'");

// Diviser le chemin en segments
$segments = explode('/', $path);

// Router la requête
try {
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $controller = new StudentController($pdo);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur de connexion à la base de données: ' . $e->getMessage()
    ]);
    exit;
}

// Debug: Afficher les informations de routing
error_log("Method: " . $method);
error_log("Path: '" . $path . "'");
error_log("Segments: " . json_encode($segments));

try {
    switch ($method) {
        case 'GET':
            if (empty($path) || $path === 'students' || $path === 'students/') {
                // GET /students - Lister tous les étudiants
                $controller->getStudents();
            } elseif ($path === 'students/stats' || $path === 'students/stats/') {
                // GET /students/stats - Statistiques des étudiants
                $controller->getStudentStats();
            } elseif ($path === 'students/export' || $path === 'students/export/') {
                // GET /students/export - Exporter les étudiants
                $controller->exportStudents();
            } elseif (preg_match('/^students\/(\d+)$/', $path, $matches)) {
                // GET /students/{id} - Récupérer un étudiant
                $studentId = $matches[1];
                $controller->getStudent($studentId);
            } elseif (preg_match('/^students\/(\d+)\/enrollments$/', $path, $matches)) {
                // GET /students/{id}/enrollments - Inscriptions d'un étudiant
                $studentId = $matches[1];
                $controller->getStudentEnrollments($studentId);
            } elseif (preg_match('/^students\/(\d+)\/academic-records$/', $path, $matches)) {
                // GET /students/{id}/academic-records - Résultats académiques
                $studentId = $matches[1];
                $controller->getStudentAcademicRecords($studentId);
            } elseif (preg_match('/^students\/(\d+)\/documents$/', $path, $matches)) {
                // GET /students/{id}/documents - Documents d'un étudiant
                $studentId = $matches[1];
                $controller->getStudentDocuments($studentId);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Endpoint non trouvé: ' . $path
                ]);
            }
            break;
            
        case 'POST':
            if ($path === 'students' || $path === 'students/') {
                // POST /students - Créer un nouvel étudiant
                $controller->createStudent();
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Endpoint non trouvé: ' . $path
                ]);
            }
            break;
            
        case 'PUT':
            if (preg_match('/^students\/(\d+)$/', $path, $matches)) {
                // PUT /students/{id} - Mettre à jour un étudiant
                $studentId = $matches[1];
                $controller->updateStudent($studentId);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Endpoint non trouvé'
                ]);
            }
            break;
            
        case 'DELETE':
            if (preg_match('/^students\/(\d+)$/', $path, $matches)) {
                // DELETE /students/{id} - Supprimer un étudiant
                $studentId = $matches[1];
                $controller->deleteStudent($studentId);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Endpoint non trouvé'
                ]);
            }
            break;
            
        default:
            http_response_code(405);
            echo json_encode([
                'success' => false,
                'error' => 'Méthode non autorisée'
            ]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur serveur: ' . $e->getMessage()
    ]);
}
?>
