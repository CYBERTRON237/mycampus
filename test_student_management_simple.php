<?php

// Test simple pour vérifier que l'API de gestion des étudiants fonctionne
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test API Gestion des Étudiants</h1>";

// Base URL de l'API
$baseUrl = 'http://127.0.0.1/mycampus/api/student_management';

// Fonction pour tester un endpoint
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
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Accept: application/json'
        ]);
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
    echo "<p><strong>Réponse:</strong></p>";
    echo "<pre style='background: #f5f5f5; padding: 10px; border-radius: 5px; max-height: 300px; overflow-y: auto;'>";
    echo htmlspecialchars($response);
    echo "</pre>";
    echo "<hr>";
}

// Test 1: Lister tous les étudiants
testEndpoint($baseUrl . '/students');

// Test 2: Lister les étudiants avec pagination
testEndpoint($baseUrl . '/students?page=1&limit=5');

// Test 3: Obtenir les statistiques
testEndpoint($baseUrl . '/students/stats');

echo "<h2>Tests terminés</h2>";
echo "<p><a href='javascript:history.back()'>Retour</a></p>";
?>
