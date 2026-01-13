<?php
/**
 * Script de debug v2 pour analyser les réponses détaillées du backend
 */

echo "=== DEBUG BACKEND STUDENT MANAGEMENT V2 ===\n\n";

// Test 1: Vérifier la réponse détaillée de l'API
echo "1. Test de l'API students avec détails\n";
$baseUrl = 'http://localhost/mycampus/api/student_management/students';

$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "CURL Error: $error\n";
echo "Response: $response\n\n";

// Test 2: Test de création avec debug
echo "2. Test de création d'étudiant avec debug\n";
$createData = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test.student.' . time() . '@example.com',
    'matricule' => 'TEST' . time(),
    'phone' => '123456789',
    'program_id' => 1,
    'level' => 'licence1'
];

$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($createData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "CURL Error: $error\n";
echo "Response: $response\n\n";

// Test 3: Test des statistiques
echo "3. Test des statistiques\n";
$statsUrl = $baseUrl . '/stats';

$ch = curl_init($statsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "CURL Error: $error\n";
echo "Response: $response\n\n";

// Test 4: Vérifier les tables nécessaires
echo "4. Vérification des tables nécessaires\n";
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    $tables = ['users', 'student_profiles', 'programs', 'academic_years'];
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        $exists = $stmt->rowCount() > 0;
        echo "Table '$table': " . ($exists ? "EXISTS" : "MISSING") . "\n";
        
        if ($exists) {
            $stmt = $pdo->query("SELECT COUNT(*) as count FROM $table");
            $count = $stmt->fetch()['count'];
            echo "  - Records: $count\n";
        }
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
echo "\n";

// Test 5: Vérifier les colonnes de la table users
echo "5. Structure de la table users\n";
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    $stmt = $pdo->query('DESCRIBE users');
    $columns = $stmt->fetchAll();
    foreach ($columns as $column) {
        echo "- {$column['Field']} ({$column['Type']})\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
echo "\n";

echo "=== DEBUG TERMINÉ ===\n";

?>
