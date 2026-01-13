<?php
// Version simplifiée pour diagnostiquer
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    require_once '../config/database.php';
    $db = new Database();
    $pdo = $db->getConnection();
    
    // Test simple
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM preinscriptions");
    $result = $stmt->fetch();
    
    echo json_encode([
        'success' => true,
        'message' => 'API fonctionne!',
        'total_preinscriptions' => $result['total']
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
