<?php
// Script pour tester l'appel API de validation comme le ferait Flutter
$url = 'http://127.0.0.1/mycampus/api/preinscription_validation/validation_api_working_final.php';

// Données de test comme les envoie Flutter
$testData = [
    'action' => 'validate',
    'preinscription_id' => 1, // À adapter avec un ID réel
    'admin_id' => 1,
    'comments' => 'Test de validation'
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
    ],
    CURLOPT_VERBOSE => true
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

echo "=== Test API Validation ===\n";
echo "URL: $url\n";
echo "HTTP Code: $httpCode\n";
echo "Error: $error\n";
echo "Response:\n";
echo $response;
echo "\n";

// Test avec l'API de debug
echo "\n=== Test API Debug ===\n";
$debugUrl = 'http://127.0.0.1/mycampus/test_validation_debug.php';

$ch2 = curl_init();
curl_setopt_array($ch2, [
    CURLOPT_URL => $debugUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => json_encode($testData),
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'Authorization: Bearer test_token'
    ]
]);

$debugResponse = curl_exec($ch2);
$debugHttpCode = curl_getinfo($ch2, CURLINFO_HTTP_CODE);

curl_close($ch2);

echo "Debug HTTP Code: $debugHttpCode\n";
echo "Debug Response:\n";
echo $debugResponse;
echo "\n";
?>
