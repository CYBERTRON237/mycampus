<?php

// Test de l'API de gestion des étudiants simplifiée
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test API Étudiants - Version Simplifiée</h1>";

// Fonction de test
function testEndpoint($url, $method = 'GET', $data = null) {
    echo "<h3>Test: $method $url</h3>";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    
    if ($data && $method === 'POST') {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
    } else {
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json']);
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "<p style='color: red;'>Erreur cURL: $error</p>";
        return;
    }
    
    echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
    echo "<pre style='background: #f5f5f5; padding: 10px; border-radius: 5px; max-height: 300px; overflow-y: auto;'>";
    echo htmlspecialchars($response);
    echo "</pre>";
    echo "<hr>";
}

// Base URL
$baseUrl = 'http://127.0.0.1/mycampus/api/student_management';

// Test 1: Lister les étudiants
testEndpoint($baseUrl . '/students');

// Test 2: Statistiques
testEndpoint($baseUrl . '/students/stats');

// Test 3: Créer un étudiant
$newStudent = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test.student' . time() . '@example.com',
    'phone' => '237123456789',
    'level' => 'licence1'
];

testEndpoint($baseUrl . '/students', 'POST', $newStudent);

echo "<h2>Instructions pour résoudre les problèmes:</h2>";
echo "<ol>";
echo "<li>Exécutez d'abord le script SQL: <a href='create_student_profiles_tables.sql'>create_student_profiles_tables.sql</a></li>";
echo "<li>Vérifiez que les tables <strong>student_profiles</strong> et <strong>academic_years</strong> existent</li>";
echo "<li>Assurez-vous que les tables <strong>institutions</strong>, <strong>faculties</strong>, <strong>departments</strong>, <strong>programs</strong> existent</li>";
echo "<li>Vérifiez les permissions de la base de données”;</li>";
TimeString
echo "</ol>";
?>
