<?php
// Test script for preinscriptions API
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test API Préinscriptions</h1>";

// Test 1: Lister toutes les préinscriptions
echo "<h2>1. Lister toutes les préinscriptions</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>HTTP Status:</strong> $http_code</p>";
echo "<p><strong>Response:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 2: Lister les préinscriptions par faculté
echo "<h2>2. Lister les préinscriptions pour la faculté FALSH</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?faculty=FALSH");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>HTTP Status:</strong> $http_code</p>";
echo "<p><strong>Response:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 3: Lister les préinscriptions par statut
echo "<h2>3. Lister les préinscriptions avec statut 'pending'</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?status=pending");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>HTTP Status:</strong> $http_code</p>";
echo "<p><strong>Response:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 4: Lister les facultés disponibles
echo "<h2>4. Lister les facultés disponibles</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/faculties");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>HTTP Status:</strong> $http_code</p>";
echo "<p><strong>Response:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 5: Détails d'une préinscription spécifique
echo "<h2>5. Détails de la préinscription ID 1</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions/1");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>HTTP Status:</strong> $http_code</p>";
echo "<p><strong>Response:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 6: Pagination
echo "<h2>6. Test pagination (page=1, limit=3)</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=1&limit=3");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>HTTP Status:</strong> $http_code</p>";
echo "<p><strong>Response:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

echo "<h2>Tests terminés!</h2>";
?>
