<?php
// Test simple pour diagnostiquer les erreurs
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "Test de diagnostic du backend de validation<br>";

try {
    // Test 1: Inclusion des fichiers
    echo "1. Test d'inclusion des fichiers...<br>";
    
    require_once '../config/database.php';
    echo "   - database.php inclus avec succès<br>";
    
    require_once '../middleware/auth.php';
    echo "   - auth.php inclus avec succès<br>";
    
    // Test 2: Connexion à la base de données
    echo "2. Test de connexion à la base de données...<br>";
    $db = new Database();
    $pdo = $db->getConnection();
    echo "   - Connexion réussie<br>";
    
    // Test 3: Vérification des tables
    echo "3. Test des tables...<br>";
    
    // Vérifier table preinscriptions
    $stmt = $pdo->query("SHOW TABLES LIKE 'preinscriptions'");
    $tableExists = $stmt->rowCount() > 0;
    echo "   - Table preinscriptions: " . ($tableExists ? "EXISTS" : "NOT FOUND") . "<br>";
    
    // Vérifier table users
    $stmt = $pdo->query("SHOW TABLES LIKE 'users'");
    $tableExists = $stmt->rowCount() > 0;
    echo "   - Table users: " . ($tableExists ? "EXISTS" : "NOT FOUND") . "<br>";
    
    echo "<br><strong>Tous les tests passés avec succès!</strong><br>";
    
} catch (Exception $e) {
    echo "<br><strong>ERREUR:</strong> " . $e->getMessage() . "<br>";
    echo "Stack trace:<br><pre>" . $e->getTraceAsString() . "</pre>";
}
?>
