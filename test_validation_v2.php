<?php
// Script pour tester la nouvelle API V2 avec création automatique d'utilisateur
$url = 'http://127.0.0.1/mycampus/api/preinscription_validation/validation_api_v2.php';

// Données de test comme les envoie Flutter
$testData = [
    'action' => 'validate',
    'preinscription_id' => 1, // ID de la préinscription tsamojores76@gmail.com
    'admin_id' => 1,
    'comments' => 'Test de validation avec création automatique'
];

$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => json_encode($testData),
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'Authorization: Bearer test_token' // Token de test
    ]
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

echo "=== Test API Validation V2 ===\n";
echo "URL: $url\n";
echo "HTTP Code: $httpCode\n";
echo "Error: $error\n";
echo "Response:\n";
echo $response;
echo "\n";

// Vérifier si l'utilisateur a été créé
echo "\n=== Vérification post-validation ===\n";
$checkUrl = 'http://127.0.0.1/mycampus/test_validation_check.php';

$ch2 = curl_init();
curl_setopt_array($ch2, [
    CURLOPT_URL => $checkUrl,
    CURLOPT_RETURNTRANSFER => true
]);

$checkResponse = curl_exec($ch2);
curl_close($ch2);

echo $checkResponse;
echo "\n";
?>
