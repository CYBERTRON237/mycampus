<?php
// Test de la base de données sans XDebug
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');

try {
    require_once '../config/database.php';
    $pdo = Database::getConnection();
    
    // Test simple
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM preinscriptions");
    $result = $stmt->fetch();
    
    echo json_encode([
        'success' => true,
        'message' => 'Database connection successful',
        'data' => [
            'preinscriptions_count' => (int)$result['total']
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
