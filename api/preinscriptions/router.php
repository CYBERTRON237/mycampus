<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-ID");
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

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// GET /institutions - Lister les institutions
if ($method === 'GET' && (count($pathParts) >= 4 && $pathParts[3] === 'institutions')) {
    
    try {
        $sql = "SELECT id, name, description, city, country, type, is_active as status, created_at 
                FROM institutions 
                WHERE is_active = 1 
                ORDER BY name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $institutions = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $institutions
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des institutions',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /faculties - Lister les facultés
elseif ($method === 'GET' && (count($pathParts) >= 4 && $pathParts[3] === 'faculties')) {
    
    $institutionId = $_GET['institution_id'] ?? null;
    
    try {
        $sql = "SELECT f.id, f.name, f.code, f.description, f.institution_id, i.name as institution_name
                FROM faculties f 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE f.status = 'active'";
        
        $params = [];
        if ($institutionId) {
            $sql .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }
        
        $sql .= " ORDER BY f.name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $faculties = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $faculties
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des facultés',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /programs - Lister les programmes
elseif ($method === 'GET' && (count($pathParts) >= 4 && $pathParts[3] === 'programs')) {
    
    try {
        $sql = "SELECT id, name, code, description, degree_level, duration_years,
                       status, created_at
                FROM programs 
                WHERE status = 'active'
                ORDER BY name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $programs = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $programs
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des programmes',
            'error' => $e->getMessage()
        ]);
    }
}

// Route par défaut
else {
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée',
        'path' => $path,
        'method' => $method,
        'pathParts' => $pathParts
    ]);
}
?>
