<?php
// URL de l'API
$url = 'http://127.0.0.1/mycampus/api/preinscription/submit.php';

// Données de test
$data = [
    'unique_code' => 'TEST2024002',
    'faculty' => 'Faculté des Sciences (FS)',
    'last_name' => 'Test',
    'first_name' => 'User',
    'middle_name' => null,
    'date_of_birth' => '2000-01-01',
    'is_birth_date_on_certificate' => 1,
    'place_of_birth' => 'Yaoundé',
    'gender' => 'MASCULIN',
    'cni_number' => null,
    'residence_address' => 'Yaoundé, Cameroun',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '655123456',
    'email' => 'test@example.com',
    'first_language' => 'FRANÇAIS',
    'professional_situation' => 'SANS EMPLOI'
];

// Initialiser cURL
$ch = curl_init($url);

// Configurer cURL
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_HEADER, true); // Pour voir les headers

// Exécuter la requête
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
$headers = substr($response, 0, $header_size);
$body = substr($response, $header_size);

curl_close($ch);

echo "=== TEST API PRÉINSCRIPTION ===\n\n";
echo "HTTP Code: $http_code\n\n";
echo "Headers:\n$headers\n";
echo "Body:\n$body\n\n";

// Essayer de parser le JSON
$json_data = json_decode($body, true);
if ($json_data !== null) {
    echo "JSON valide!\n";
    echo "Résultat: " . print_r($json_data, true) . "\n";
} else {
    echo "JSON invalide!\n";
    echo "Erreur JSON: " . json_last_error_msg() . "\n";
}
?>
