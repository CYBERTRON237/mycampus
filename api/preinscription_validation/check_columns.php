<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    require_once '../config/database.php';
    $db = new Database();
    $pdo = $db->getConnection();
    
    // Vérifier les colonnes de la table preinscriptions
    $stmt = $pdo->query("SHOW COLUMNS FROM preinscriptions");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $columnNames = array_map(function($col) {
        return $col['Field'];
    }, $columns);
    
    echo json_encode([
        'success' => true,
        'columns' => $columnNames,
        'total_columns' => count($columnNames)
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
