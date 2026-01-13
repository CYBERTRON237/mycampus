<?php
// Test de l'API des préinscriptions
echo "Test de l'API des préinscriptions...\n";

// Test de l'endpoint list_preinscriptions
$api_url = 'http://127.0.0.1/mycampus/api/preinscriptions/list_preinscriptions.php';

$data = [
    'page' => 1,
    'limit' => 5
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $api_url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $http_code\n";
echo "Response: $response\n";

// Test de l'endpoint stats
$stats_url = 'http://127.0.0.1/mycampus/api/preinscriptions/list_preinscriptions.php';

$stats_data = ['limit' => 1];

$ch2 = curl_init();
curl_setopt($ch2, CURLOPT_URL, $stats_url);
curl_setopt($ch2, CURLOPT_POST, true);
curl_setopt($ch2, CURLOPT_POSTFIELDS, json_encode($stats_data));
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$stats_response = curl_exec($ch2);
$stats_http_code = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
curl_close($ch2);

echo "\n=== STATS TEST ===\n";
echo "HTTP Code: $stats_http_code\n";
echo "Response: $stats_response\n";
?>
