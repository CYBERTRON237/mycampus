<?php
/**
 * Script de debug pour analyser les problèmes du backend student_management
 */

echo "=== DEBUG BACKEND STUDENT MANAGEMENT ===\n\n";

// Test 1: Vérifier l'URL de base
echo "1. Test de l'URL de base\n";
$baseUrl = 'http://localhost/mycampus/api/student_management';
echo "URL de base: $baseUrl\n";

$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$redirectUrl = curl_getinfo($ch, CURLINFO_REDIRECT_URL);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
if ($redirectUrl) {
    echo "Redirect URL: $redirectUrl\n";
}
echo "Response headers:\n" . substr($response, 0, 500) . "\n\n";

// Test 2: Vérifier avec le paramètre debug
echo "2. Test avec paramètre debug\n";
$debugUrl = $baseUrl . '?debug=1';

$ch = curl_init($debugUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n\n";

// Test 3: Tester l'endpoint students
echo "3. Test de l'endpoint students\n";
$studentsUrl = $baseUrl . '/students';

$ch = curl_init($studentsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);
echo "HTTP Code: $httpCode\n";
echo "Response: $response\n\n";

// Test 4: Vérifier les fichiers existants
echo "4. Vérification des fichiers\n";
$files = [
    __DIR__ . '/api/student_management/index.php',
    __DIR__ . '/api/student_management/models/SimpleStudentModel.php',
    __DIR__ . '/api/student_management/controllers/StudentController.php'
];

foreach ($files as $file) {
    echo "Fichier: $file - " . (file_exists($file) ? "EXISTS" : "MISSING") . "\n";
}
echo "\n";

// Test 5: Vérifier la base de données
echo "5. Test de connexion à la base de données\n";
try {
    $pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    // Vérifier la table students
    $stmt = $pdo->query("DESCRIBE students");
    $columns = $stmt->fetchAll();
    echo "Table 'students' existe avec " . count($columns) . " colonnes\n";
    
    // Compter les étudiants
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM students");
    $result = $stmt->fetch();
    echo "Nombre d'étudiants: " . $result['count'] . "\n";
    
} catch (PDOException $e) {
    echo "Erreur base de données: " . $e->getMessage() . "\n";
}
echo "\n";

// Test 6: Tester avec cURL détaillé
echo "6. Test cURL détaillé pour POST\n";
$postData = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test@example.com',
    'matricule' => 'TEST001'
];

$ch = curl_init($studentsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_VERBOSE, true);
$verbose = fopen('php://temp', 'w+');
curl_setopt($ch, CURLOPT_STDERR, $verbose);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

rewind($verbose);
$verboseLog = stream_get_contents($verbose);
fclose($verbose);

curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "CURL Error: $error\n";
echo "Verbose log:\n$verboseLog\n";
echo "Response: $response\n\n";

echo "=== DEBUG TERMINÉ ===\n";

?>
