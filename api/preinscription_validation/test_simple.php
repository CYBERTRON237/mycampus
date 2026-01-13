<?php
// Test simple pour vérifier la connexion à la base de données
try {
    require_once '../config/database.php';
    $pdo = Database::getConnection();
    echo "Connexion à la base de données réussie\n";
    
    // Test simple
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM preinscriptions");
    $result = $stmt->fetch();
    echo "Nombre de préinscriptions: " . $result['total'] . "\n";
    
    // Test des utilisateurs
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $result = $stmt->fetch();
    echo "Nombre d'utilisateurs: " . $result['total'] . "\n";
    
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
