<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    // Vérifier si la table users existe
    $stmt = $pdo->query("SHOW TABLES LIKE 'users'");
    $tableExists = $stmt->rowCount() > 0;
    
    if (!$tableExists) {
        echo json_encode(['success' => false, 'message' => 'La table users n\'existe pas'], JSON_PRETTY_PRINT);
        exit();
    }
    
    // Obtenir la structure de la table users
    $stmt = $pdo->query("DESCRIBE users");
    $structure = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Obtenir les contraintes
    $stmt = $pdo->query("SHOW INDEX FROM users");
    $indexes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'table' => 'users',
        'structure' => $structure,
        'indexes' => $indexes
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ], JSON_PRETTY_PRINT);
}
