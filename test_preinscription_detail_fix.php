<?php
// Test pour vérifier que la correction du détail de préinscription fonctionne
echo "Test de la correction du détail de préinscription...\n";

// Test 1: Récupération par ID
$api_url = 'http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php';

// Tester avec un ID (remplacez 1 par un ID existant dans votre base)
$data_id = ['id' => 1];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $api_url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data_id));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response_id = curl_exec($ch);
$http_code_id = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "\n=== TEST PAR ID ===\n";
echo "HTTP Code: $http_code_id\n";
echo "Response: $response_id\n";

// Test 2: Récupération par unique_code (si disponible)
$data_code = ['unique_code' => 'PRE2024001'];

$ch2 = curl_init();
curl_setopt($ch2, CURLOPT_URL, $api_url);
curl_setopt($ch2, CURLOPT_POST, true);
curl_setopt($ch2, CURLOPT_POSTFIELDS, json_encode($data_code));
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response_code = curl_exec($ch2);
$http_code_code = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
curl_close($ch2);

echo "\n=== TEST PAR UNIQUE_CODE ===\n";
echo "HTTP Code: $http_code_code\n";
echo "Response: $response_code\n";

// Test 3: Test sans paramètre
$data_empty = [];

$ch3 = curl_init();
curl_setopt($ch3, CURLOPT_URL, $api_url);
curl_setopt($ch3, CURLOPT_POST, true);
curl_setopt($ch3, CURLOPT_POSTFIELDS, json_encode($data_empty));
curl_setopt($ch3, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch3, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response_empty = curl_exec($ch3);
$http_code_empty = curl_getinfo($ch3, CURLINFO_HTTP_CODE);
curl_close($ch3);

echo "\n=== TEST SANS PARAMÈTRE ===\n";
echo "HTTP Code: $http_code_empty\n";
echo "Response: $response_empty\n";

echo "\nTest terminé.\n";
?>
