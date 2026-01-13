<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    require_once '../config/database.php';
    $db = new Database();
    $pdo = $db->getConnection();
    
    // Vérifier les colonnes qui contiennent "date" ou "created"
    $stmt = $pdo->query("SHOW COLUMNS FROM preinscriptions");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $dateColumns = [];
    foreach ($columns as $col) {
        $fieldName = $col['Field'];
        if (strpos(strtolower($fieldName), 'date') !== false || 
            strpos(strtolower($fieldName), 'created') !== false ||
            strpos(strtolower($fieldName), 'time') !== false) {
            $dateColumns[] = $fieldName;
        }
    }
    
    echo json_encode([
        'success' => true,
        'date_columns' => $dateColumns,
        'all_columns' => array_map(function($col) {
            return $col['Field'];
        }, $columns)
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>
