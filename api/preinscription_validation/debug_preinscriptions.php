<?php
// Debug des préinscriptions
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
    
    // Vérifier toutes les préinscriptions
    $stmt = $pdo->query("SELECT * FROM preinscriptions ORDER BY created_at DESC");
    $all_preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Vérifier les statuts
    $stmt = $pdo->query("SELECT status, COUNT(*) as count FROM preinscriptions GROUP BY status");
    $status_counts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Vérifier celles en attente
    $stmt = $pdo->query("SELECT * FROM preinscriptions WHERE status IN ('pending', 'under_review') ORDER BY created_at DESC");
    $pending_preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'total_count' => count($all_preinscriptions),
            'all_preinscriptions' => $all_preinscriptions,
            'status_counts' => $status_counts,
            'pending_count' => count($pending_preinscriptions),
            'pending_preinscriptions' => $pending_preinscriptions
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
