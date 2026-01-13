<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/database.php';

try {
    $pdo = Database::getConnection();
    
    // Créer une préinscription de test avec statut 'pending'
    $sql = "UPDATE preinscriptions SET status = 'pending' WHERE status != 'pending' LIMIT 1";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    
    // Vérifier le résultat
    $sql = "SELECT id, unique_code, first_name, last_name, email, faculty, status 
            FROM preinscriptions 
            WHERE status = 'pending'";
    
    $stmt = $pdo->query($sql);
    $pendingPreinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Préinscriptions mises à jour',
        'pending_count' => count($pendingPreinscriptions),
        'data' => $pendingPreinscriptions
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>
