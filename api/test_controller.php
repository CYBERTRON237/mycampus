<?php
// Test du contrôleur Institution
require_once 'config/database.php';
require_once 'universities/models/Institution.php';
require_once 'universities/controllers/InstitutionController.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        echo "Connexion à la base de données réussie!\n";
        
        $institution = new Institution($db);
        $controller = new InstitutionController($institution);
        
        echo "Test de getInstitutions()...\n";
        $result = $controller->getInstitutions();
        
        echo "Résultat:\n";
        print_r($result);
        
    } else {
        echo "Échec de la connexion à la base de données\n";
    }
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?>
