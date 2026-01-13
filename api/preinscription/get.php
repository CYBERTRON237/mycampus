<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        throw new Exception('Méthode non autorisée');
    }
    
    // Get unique code from query parameter
    if (!isset($_GET['code']) || empty($_GET['code'])) {
        throw new Exception('Code unique requis');
    }
    
    $unique_code = $_GET['code'];
    
    // Query preinscription by unique code
    $query = "SELECT * FROM preinscriptions WHERE unique_code = :unique_code";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':unique_code', $unique_code);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription trouvée',
            'data' => $preinscription
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Préinscription non trouvée'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
