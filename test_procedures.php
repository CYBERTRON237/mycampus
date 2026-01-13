<?php
// Script pour exécuter les procédures stockées
$host = '127.0.0.1';
$dbname = 'mycampus';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);

    echo "Connexion réussie à la base de données\n";

    // Lire et exécuter le fichier SQL
    $sql = file_get_contents(__DIR__ . '/database/create_user_management_procedures.sql');
    
    // Supprimer les délimiteurs pour l'exécution PHP
    $sql = str_replace(['DELIMITER $$', 'DELIMITER ;', '$$'], '', $sql);
    
    // Séparer les requêtes
    $statements = array_filter(array_map('trim', explode(';', $sql)));
    
    foreach ($statements as $statement) {
        if (!empty($statement) && !preg_match('/^--/', $statement)) {
            echo "Exécution: " . substr($statement, 0, 50) . "...\n";
            $pdo->exec($statement);
        }
    }
    
    echo "Procédures stockées créées avec succès!\n";
    
} catch (PDOException $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
