<?php
// Test simple de l'API
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');

try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // Test simple
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM preinscriptions WHERE status IN ('pending', 'under_review')");
    $result = $stmt->fetch();
    
    echo json_encode([
        'success' => true,
        'message' => 'API fonctionne',
        'data' => [
            'pending_count' => (int)$result['total'],
            'api_url' => 'validation_api_working_final.php'
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
