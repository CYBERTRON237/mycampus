<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/database.php';

try {
    $pdo = Database::getConnection();
    
    // Vérifier les statuts des 2 préinscriptions
    $sql = "SELECT id, unique_code, first_name, last_name, email, faculty, status 
            FROM preinscriptions 
            LIMIT 5";
    
    $stmt = $pdo->query($sql);
    $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Préinscriptions trouvées',
        'count' => count($preinscriptions),
        'data' => $preinscriptions
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>
