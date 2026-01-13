<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus', 'root', '');
    $stmt = $pdo->query('DESCRIBE users');
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo 'Colonnes de la table users:' . PHP_EOL;
    foreach ($columns as $column) {
        echo "- $column" . PHP_EOL;
    }
} catch (Exception $e) {
    echo 'Erreur: ' . $e->getMessage() . PHP_EOL;
}
?>
