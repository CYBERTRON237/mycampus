<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/database.php';

try {
    $pdo = Database::getConnection();
    
    // Vérifier toutes les préinscriptions et leurs statuts
    $sql = "SELECT id, unique_code, first_name, last_name, email, faculty, status, student_id, submission_date 
            FROM preinscriptions 
            ORDER BY submission_date DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Compter par statut
    $sql = "SELECT status, COUNT(*) as count FROM preinscriptions GROUP BY status";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $statusCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'total_preinscriptions' => count($preinscriptions),
        'status_counts' => $statusCounts,
        'preinscriptions' => $preinscriptions
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>
