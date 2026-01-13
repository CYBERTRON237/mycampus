<?php
// Test simple pour vérifier la connexion à la base de données
require_once 'config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        echo "Connexion à la base de données réussie!\n";
        
        // Test simple query
        $query = "SELECT COUNT(*) as count FROM institutions";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo "Nombre d'institutions: " . $result['count'] . "\n";
        
        // Test de récupération de quelques institutions
        $query = "SELECT id, name, code, short_name FROM institutions LIMIT 5";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $institutions = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "Institutions trouvées:\n";
        foreach ($institutions as $inst) {
            echo "- ID: {$inst['id']}, Nom: {$inst['name']}, Code: {$inst['code']}\n";
        }
    } else {
        echo "Échec de la connexion à la base de données\n";
    }
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
