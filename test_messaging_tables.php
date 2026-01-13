<?php
// Script de test pour vérifier les tables de messagerie

require_once __DIR__ . '/config/database.php';

header('Content-Type: application/json');

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception('Connexion à la base de données échouée');
    }
    
    // Vérifier les tables
    $tables = [
        'user_groups',
        'group_members',
        'users'
    ];
    
    $result = [
        'success' => true,
        'message' => 'Vérification des tables',
        'tables' => []
    ];
    
    foreach ($tables as $table) {
        $query = "SHOW TABLES LIKE '$table'";
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $exists = $stmt->rowCount() > 0;
        $result['tables'][$table] = $exists;
        
        if ($exists) {
            // Compter les enregistrements
            $countQuery = "SELECT COUNT(*) as count FROM $table";
            $countStmt = $db->prepare($countQuery);
            $countStmt->execute();
            $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
            $result['tables'][$table . '_count'] = $count;
        }
    }
    
    echo json_encode($result, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
?>
