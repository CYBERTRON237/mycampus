<?php
// Test direct de l'API avec invoke
echo "=== TEST DIRECT API PRÉINSCRIPTION ===\n\n";

// Test 1: Vérifier si submit.php est accessible
echo "1. Test d'accès direct à submit.php:\n";
$context = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json\r\nAccept: application/json',
        'content' => json_encode(['test' => 'invoke'])
    ]
]);

$response = file_get_contents('http://127.0.0.1/mycampus/api/preinscription/submit.php', false, $context);
echo "Réponse brute: " . $response . "\n\n";

// Test 2: Parser la réponse
$json = json_decode($response, true);
if ($json !== null) {
    echo "2. JSON valide!\n";
    echo "Résultat: " . print_r($json, true) . "\n";
} else {
    echo "2. JSON invalide!\n";
    echo "Erreur JSON: " . json_last_error_msg() . "\n";
    echo "Caractère problème: " . substr($response, 0, 50) . "\n";
}

echo "\n";

// Test 3: Test avec submit_clean.php
echo "3. Test avec submit_clean.php:\n";
$response_clean = file_get_contents('http://127.0.0.1/mycampus/api/preinscription/submit_clean.php', false, $context);
echo "Réponse clean: " . $response_clean . "\n\n";

// Test 4: Test avec données réelles
echo "4. Test avec données réelles:\n";
$real_data = [
    'unique_code' => 'TEST2024004',
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

$context_real = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json\r\nAccept: application/json',
        'content' => json_encode($real_data)
    ]
]);

$response_real = file_get_contents('http://127.0.0.1/mycampus/api/preinscription/submit.php', false, $context_real);
echo "Réponse données réelles: " . $response_real . "\n\n";

// Test 5: Vérifier les headers HTTP
echo "5. Test des headers HTTP:\n";
$headers = get_headers('http://127.0.0.1/mycampus/api/preinscription/submit.php');
echo "Headers retournés:\n";
foreach ($headers as $header) {
    echo "  " . $header . "\n";
}

echo "\n=== FIN DES TESTS ===\n";
?>
