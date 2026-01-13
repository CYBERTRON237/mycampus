<?php
require_once 'api/config/database.php';

try {
    echo "Test de connexion à la base de données...\n";
    
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Connexion réussie!\n";
    
    // Vérifier les tables existantes
    $stmt = $db->query('SHOW TABLES');
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "Tables existantes: " . implode(', ', $tables) . "\n";
    
    // Vérifier si la table user_groups existe
    if (in_array('user_groups', $tables)) {
        echo "La table user_groups existe.\n";
        
        // Vérifier la structure
        $stmt = $db->query('DESCRIBE user_groups');
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "Structure de user_groups:\n";
        foreach ($columns as $column) {
            echo "- " . $column['Field'] . " (" . $column['Type'] . ")\n";
        }
    } else {
        echo "La table user_groups n'existe PAS!\n";
    }
    
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n";
}
?>
