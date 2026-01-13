<?php

// Test de l'API avec modèle adapté à la BDD existante
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test API Étudiants - BDD Existante</h1>";

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
    echo "<pre style='background: #f5f5f5; padding: 10px; border-radius: 5px; max-height: 400px; overflow-y: auto;'>";
    echo htmlspecialchars($response);
    echo "</pre>";
    echo "<hr>";
}

// Base URL
$baseUrl = 'http://127.0.0.1/mycampus/api/student_management';

echo "<h2>🔍 Diagnostic de la connexion</h2>";

// Test 1: Debug du routing
testEndpoint($baseUrl . '/students?debug=1');

echo "<h2>📋 Test de récupération des étudiants</h2>";

// Test 2: Lister les étudiants
testEndpoint($baseUrl . '/students');

echo "<h2>📊 Test des statistiques</h2>";

// Test 3: Statistiques
testEndpoint($baseUrl . '/students/stats');

echo "<h2>➕ Test de création</h2>";

// Test 4: Créer un étudiant
$newStudent = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test.student.' . time() . '@example.com',
    'phone' => '237123456789',
    'level' => 'licence1',
    'password' => 'password123'
];

testEndpoint($baseUrl . '/students', 'POST', $newStudent);

echo "<h2>🔧 Résolution des problèmes</h2>";
echo "<div style='background: #f0f8ff; padding: 15px; border-radius: 8px; border-left: 4px solid #007bff;'>";
echo "<h3>Si vous voyez une erreur 404:</h3>";
echo "<ul>";
echo "<li>Vérifiez que le .htaccess est bien activé dans Apache</li>";
echo "<li>Vérifiez que mod_rewrite est activé</li>";
echo "<li>Testez avec: <a href='$baseUrl/students?debug=1' target='_blank'>$baseUrl/students?debug=1</a></li>";
echo "</ul>";

echo "<h3>Si vous voyez une erreur 500:</h3>";
echo "<ul>";
echo "<li>Vérifiez les logs d'erreurs PHP</li>";
echo "<li>Vérifiez que les tables existent: student_profiles, users, institutions, programs, academic_years</li>";
echo "<li>Vérifiez la connexion à la base de données</li>";
echo "</ul>";

echo "<h3>Si la liste est vide:</h3>";
echo "<ul>";
echo "<li>Aucun étudiant dans la base de données</li>";
echo "<li>Les étudiants existent mais ne sont pas liés correctement (user_id)</li>";
echo "<li>Problème dans la requête SQL</li>";
echo "</ul>";

echo "<h3>Structure attendue:</h3>";
echo "<ul>";
echo "<li>✅ Table <strong>users</strong> avec les informations de base</li>";
echo "<li>✅ Table <strong>student_profiles</strong> liée à users via user_id</li>";
echo "<li>✅ Tables de référence: institutions, programs, academic_years</li>";
echo "</ul>";

echo "</div>";

echo "<h2>🚀 Actions recommandées</h2>";
echo "<ol>";
echo "<li><strong>1. Vérifier la BDD:</strong> Exécutez une requête SELECT sur student_profiles</li>";
echo "<li><strong>2. Tester le debug:</strong> <a href='$baseUrl/students?debug=1' target='_blank'>Lien de debug</a></li>";
echo "<li><strong>3. Créer un étudiant:</strong> Utilisez le formulaire de création</li>";
echo "<li><strong>4. Vérifier les logs:</strong> Consultez les logs d'erreurs Apache/PHP</li>";
echo "</ol>";
?>
