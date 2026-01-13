<?php
// Test pour vérifier que la liste des préinscriptions renvoie bien les IDs
echo "Test de la liste des préinscriptions avec IDs...\n";

$api_url = 'http://127.0.0.1/mycampus/api/preinscriptions/list_preinscriptions.php';

$data = [
    'page' => 1,
    'limit' => 3
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

// Analyser la réponse pour vérifier si les IDs sont présents
$data_array = json_decode($response, true);
if ($data_array && isset($data_array['data'])) {
    echo "\n=== VÉRIFICATION DES IDs ===\n";
    foreach ($data_array['data'] as $index => $preinscription) {
        $has_id = isset($preinscription['id']);
        $has_unique_code = isset($preinscription['unique_code']);
        echo "Préinscription " . ($index + 1) . ": ";
        echo "ID: " . ($has_id ? $preinscription['id'] : 'MANQUANT') . " | ";
        echo "Unique Code: " . ($has_unique_code ? ($preinscription['unique_code'] ?? 'NULL') : 'MANQUANT') . "\n";
    }
}

echo "\nTest terminé.\n";
?>
