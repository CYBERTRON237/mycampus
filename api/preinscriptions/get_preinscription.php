<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// Activer l'affichage des erreurs pour le debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

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

// POST request handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rawInput = file_get_contents('php://input');
    $input = json_decode($rawInput, true);
    
    if (!$input) {
        echo json_encode([
            'success' => false,
            'message' => 'Données JSON invalides'
        ]);
        exit;
    }
    
    $uniqueCode = trim($input['unique_code'] ?? '');
    $id = intval($input['id'] ?? 0);
    
    if (empty($uniqueCode) && $id === 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Le code unique ou l\'ID est requis'
        ]);
        exit;
    }
    
    try {
        // Récupérer les informations de la préinscription
        $whereClause = '';
        $params = [];
        
        if (!empty($uniqueCode)) {
            $whereClause = 'WHERE unique_code = ? AND deleted_at IS NULL';
            $params[] = $uniqueCode;
        } else {
            $whereClause = 'WHERE id = ? AND deleted_at IS NULL';
            $params[] = $id;
        }
        
        $stmt = $pdo->prepare("
            SELECT * FROM preinscriptions 
            $whereClause
        ");
        
        $stmt->execute($params);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode([
                'success' => false,
                'message' => 'Aucune préinscription trouvée'
            ]);
            exit;
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription trouvée avec succès',
            'data' => $preinscription
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
    
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée',
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
}
?>
