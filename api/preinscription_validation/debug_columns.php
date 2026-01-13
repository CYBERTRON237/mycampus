<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    require_once '../config/database.php';
    $pdo = Database::getConnection();
    
    // Test simple pour vérifier les colonnes existantes
    $sql = "SELECT id, unique_code, first_name, last_name, email, faculty, status 
            FROM preinscriptions 
            WHERE status = 'pending' 
            LIMIT 3";
    
    $stmt = $pdo->query($sql);
    $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Test réussi',
        'count' => count($preinscriptions),
        'data' => $preinscriptions
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
