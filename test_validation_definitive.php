<?php
// Test final de l'API définitive
$url = 'http://127.0.0.1/mycampus/api/preinscription_validation/validation_api_definitive.php';

// Test 1: Validation de la préinscription ID=1
$testData = [
    'action' => 'validate',
    'preinscription_id' => 1,
    'admin_id' => 1,
    'comments' => 'Test validation définitive avec création auto utilisateur'
];

$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => json_encode($testData),
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'Authorization: Bearer test_token'
    ]
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "=== TEST VALIDATION DÉFINITIVE ===\n";
echo "URL: $url\n";
echo "HTTP Code: $httpCode\n";
echo "Error: $error\n";
echo "Response:\n$response\n\n";

// Test 2: Vérification après validation
$checkUrl = 'http://127.0.0.1/mycampus/test_validation_check.php';
$ch2 = curl_init();
curl_setopt_array($ch2, [
    CURLOPT_URL => $checkUrl,
    CURLOPT_RETURNTRANSFER => true
]);
$checkResponse = curl_exec($ch2);
curl_close($ch2);

echo "=== VÉRIFICATION POST-VALIDATION ===\n";
echo $checkResponse . "\n\n";

// Test 3: Liste des préinscriptions en attente
$listUrl = 'http://127.0.0.1/mycampus/api/preinscription_validation/validation_api_definitive.php';
$ch3 = curl_init();
curl_setopt_array($ch3, [
    CURLOPT_URL => $listUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPGET => true
]);
$listResponse = curl_exec($ch3);
curl_close($ch3);

echo "=== LISTE DES PRÉINSCRIPTIONS EN ATTENTE ===\n";
echo $listResponse . "\n";
?>
