<?php
// Script pour créer la table preinscriptions
require_once 'config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Lire le fichier de migration
    $migration_file = 'database/migrations/20241216_create_preinscriptions_table.sql';
    if (!file_exists($migration_file)) {
        throw new Exception("Fichier de migration non trouvé: $migration_file");
    }
    
    $sql = file_get_contents($migration_file);
    
    // Exécuter la migration
    $db->exec($sql);
    
    echo "Table preinscriptions créée avec succès!\n";
    
    // Vérifier que la table existe
    $stmt = $db->query("SHOW TABLES LIKE 'preinscriptions'");
    if ($stmt->rowCount() > 0) {
        echo "Vérification: La table 'preinscriptions' existe bien.\n";
        
        // Afficher le nombre d'enregistrements
        $stmt = $db->query("SELECT COUNT(*) as count FROM preinscriptions");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "Nombre d'enregistrements: " . $result['count'] . "\n";
    } else {
        echo "ERREUR: La table n'a pas été créée.\n";
    }
    
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
