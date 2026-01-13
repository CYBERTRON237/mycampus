<?php
// Script pour désactiver tous les triggers sur la base de données
header('Content-Type: application/json');

try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );

    // Lister tous les triggers
    $triggers = $pdo->query("SHOW TRIGGERS")->fetchAll(PDO::FETCH_COLUMN);
    
    echo "Triggers trouvés: " . count($triggers) . "\n";
    foreach ($triggers as $trigger) {
        echo "- $trigger\n";
    }
    
    // Désactiver tous les triggers
    foreach ($triggers as $trigger) {
        try {
            $pdo->exec("DROP TRIGGER IF EXISTS $trigger");
            echo "Trigger $trigger désactivé\n";
        } catch (Exception $e) {
            echo "Erreur désactivation $trigger: " . $e->getMessage() . "\n";
        }
    }
    
    echo "\nOpération terminée\n";
    
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
