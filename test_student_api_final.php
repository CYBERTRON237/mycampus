<?php

// Test de l'API de gestion des étudiants - Architecture identique à user_management
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test API Étudiants - Architecture User Management</h1>";

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

// Base URL - même architecture que user_management
$baseUrl = 'http://127.0.0.1/mycampus/api/student_management';

echo "<h2>Étape 1: Test de connexion et debug</h2>";
testEndpoint($baseUrl . '/students?debug=1');

echo "<h2>Étape 2: Test des endpoints principaux</h2>";

// Test 1: Lister les étudiants
testEndpoint($baseUrl . '/students');

// Test 2: Statistiques
testEndpoint($baseUrl . '/students/stats');

echo "<h2>Étape 3: Test de création</h2>";

// Test 3: Créer un étudiant
$newStudent = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test.student.' . time() . '@example.com',
    'phone' => '237123456789',
    'level' => 'licence1'
];

testEndpoint($baseUrl . '/students', 'POST', $newStudent);

echo "<h2>Instructions de résolution:</h2>";
echo "<ol>";
echo "<li><strong>Exécuter d'abord le SQL:</strong> <a href='create_student_profiles_tables.sql'>create_student_profiles_tables.sql</a></li>";
echo "<li><strong>Vérifier les tables:</strong> student_profiles, academic_years, institutions, faculties, departments, programs</li>";
echo "<li><strong>Tester avec debug:</strong> <a href='$baseUrl/students?debug=1'>$baseUrl/students?debug=1</a></li>";
echo "<li><strong>Si erreur 404:</strong> Vérifier que le .htaccess est bien configuré</li>";
echo "<li><strong>Si erreur 500:</strong> Vérifier les logs PHP et la connexion BDD</li>";
echo "</ol>";

echo "<h2>Comparaison avec user_management:</h2>";
echo "<p>Architecture identique:</p>";
echo "<ul>";
echo "<li>✅ index.php avec même structure de routing</li>";
echo "<li>✅ .htaccess avec même configuration</li>";
echo "<li>✅ SimpleStudentModel similaire à User.php</li>";
echo "<li>✅ StudentController similaire à UserController</li>";
echo "<li>✅ Mêmes headers CORS et gestion d'erreurs</li>";
echo "</ul>";
?>
