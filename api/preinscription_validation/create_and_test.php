<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    require_once '../config/database.php';
    $pdo = Database::getConnection();
    
    // D'abord créer une préinscription de test si elle n'existe pas
    $sql = "SELECT COUNT(*) as count FROM preinscriptions";
    $stmt = $pdo->query($sql);
    $count = $stmt->fetchColumn();
    
    if ($count == 0) {
        // Créer une préinscription de test
        $sql = "INSERT INTO preinscriptions 
                (uuid, unique_code, faculty, last_name, first_name, email, phone_number, status, submission_date, created_at, updated_at)
                VALUES 
                (UUID(), 'TEST001', 'UY1', 'Test', 'Student', 'test@example.com', '123456789', 'pending', NOW(), NOW(), NOW())";
        $pdo->query($sql);
        echo "Préinscription de test créée<br>";
    }
    
    // Maintenant vérifier les préinscriptions
    $sql = "SELECT id, unique_code, first_name, last_name, email, faculty, status 
            FROM preinscriptions 
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
