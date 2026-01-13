<?php
// Test simple pour l'API de préinscription
$data = [
    'faculty' => 'UY1',
    'lastName' => 'Test',
    'firstName' => 'User',
    'dateOfBirth' => '2000-01-01',
    'placeOfBirth' => 'Yaounde',
    'gender' => 'MASCULIN',
    'residenceAddress' => 'Test Address',
    'maritalStatus' => 'CELIBATAIRE',
    'phoneNumber' => '698765432',
    'email' => 'test' . time() . '@example.com',
    'firstLanguage' => 'FRANÇAIS',
    'professionalSituation' => 'SANS EMPLOI'
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

echo "=== Test API Préinscription ===\n";
echo "Données envoyées:\n";
echo json_encode($data, JSON_PRETTY_PRINT) . "\n\n";

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

echo "HTTP Code: $httpCode\n";
if ($error) {
    echo "CURL Error: $error\n";
}
echo "Réponse:\n";
echo $response . "\n";
echo "===============================\n";
?>
