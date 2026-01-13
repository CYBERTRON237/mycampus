<?php

// Script de test simple pour diagnostiquer l'API
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Diagnostic API Student Management</h1>";

// Test 1: Vérifier si le fichier existe
echo "<h2>Test 1: Vérification des fichiers</h2>";
$apiFile = __DIR__ . '/api/student_management/student_management_api.php';
$indexFile = __DIR__ . '/api/student_management/index.php';

echo "<p>Fichier API: " . $apiFile . "</p>";
echo "<p>Fichier existe: " . (file_exists($apiFile) ? "Oui" : "Non") . "</p>";
echo "<p>Fichier Index: " . $indexFile . "</p>";
echo "<p>Fichier Index existe: " . (file_exists($indexFile) ? "Oui" : "Non") . "</p>";

// Test 2: URL directe vers le fichier
echo "<h2>Test 2: Appel direct de l'API</h2>";
$apiUrl = 'http://127.0.0.1/mycampus/api/student_management/student_management_api.php';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json']);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($error) {
    echo "<p style='color: red;'>Erreur cURL: $error</p>";
} else {
    echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
    echo "<p><strong>Réponse:</strong></p>";
    echo "<pre style='background: #f5f5f5; padding: 10px; border-radius: 5px;'>";
    echo htmlspecialchars($response);
    echo "</pre>";
}

echo "<h2>Tests terminés</h2>";
?>
