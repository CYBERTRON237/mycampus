<?php
// Test pour compter les colonnes exactes
error_reporting(E_ALL);
ini_set('display_errors', 1);

$pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", 'root', '', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
]);

// Récupérer la structure exacte de la table
$stmt = $pdo->prepare("DESCRIBE preinscriptions");
$stmt->execute();
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "=== STRUCTURE EXACTE DE LA TABLE preinscriptions ===\n";
echo "Nombre total de colonnes: " . count($columns) . "\n\n";

echo "Liste des colonnes:\n";
foreach ($columns as $i => $col) {
    printf("%2d. %s (%s) %s\n", $i+1, $col['Field'], $col['Type'], $col['Null'] == 'NO' ? 'NOT NULL' : 'NULL');
}

echo "\n=== COLONNES POUR INSERT ===\n";
$insertColumns = [];
foreach ($columns as $col) {
    if ($col['Field'] !== 'id') { // Exclure l'auto_increment
        $insertColumns[] = $col['Field'];
    }
}

echo "Colonnes pour INSERT (sans id): " . count($insertColumns) . "\n";
echo "Colonnes:\n" . implode(",\n", $insertColumns) . "\n";
?>
