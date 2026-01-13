<?php
// Test de l'API submit.php
$data = [
    'unique_code' => 'TEST_' . time(),
    'faculty' => 'UY1',
    'last_name' => 'Test',
    'first_name' => 'User',
    'middle_name' => null,
    'date_of_birth' => '2000-01-01',
    'place_of_birth' => 'Yaoundé',
    'gender' => 'MASCULIN',
    'residence_address' => 'Test Address',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '691234567',
    'email' => 'test' . time() . '@example.com',
    'first_language' => 'FRANÇAIS',
    'professional_situation' => 'SANS EMPLOI',
    'cni_number' => '1234567890'
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscription/submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $http_code\n";
echo "Response: " . $response . "\n";
?>
