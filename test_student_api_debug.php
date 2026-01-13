<?php

// Test simple pour vérifier l'API de gestion des étudiants
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test API Gestion des Étudiants</h1>";

// Test direct de l'API
$apiUrl = 'http://127.0.0.1/mycampus/api/student_management/student_management_api.php';

// Test avec cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl . '?path=students');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "<h2>Test 1: GET /students</h2>";
echo "<p><strong>URL:</strong> $apiUrl?path=students</p>";
echo "<p><strong>Code HTTP:</strong> $httpCode</p>";

if ($error) {
    echo "<p style='color: red;'>Erreur cURL: $error</p>";
} else {
    echo "<p><strong>Réponse:</strong></p>";
    echo "<pre style='background: #f5f5f5; padding: 10px; border-radius: 5px; max-height: 300px; overflow-y: auto;'>";
    echo htmlspecialchars($response);
    echo "</pre>";
}

// Test 2: Statistiques
echo "<h2>Test 2: GET /students/stats</h2>";
$ch2 = curl_init();
curl_setopt($ch2, CURLOPT_URL, $apiUrl . '?path=students/stats');
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, ['Accept: application/json']);

$response2 = curl_exec($ch2);
$httpCode2 = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
$error2 = curl_error($ch2);
curl_close($ch2);

echo "<p><strong>Code HTTP:</strong> $httpCode2</p>";
if ($error2) {
    echo "<p style='color: red;'>Erreur cURL: $error2</p>";
} else {
    echo "<pre style='background: #f5f5f5; padding: 10px; border-radius: 5px; max-height: 300px; overflow-y: auto;'>";
    echo htmlspecialchars($response2);
    echo "</pre>";
}

echo "<hr>";
echo "<p><a href='javascript:history.back()'>Retour</a></p>";
?>
