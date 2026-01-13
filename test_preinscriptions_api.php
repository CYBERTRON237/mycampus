<?php
// Script de test pour l'API de gestion des préinscriptions

header('Content-Type: application/json');

$baseUrl = 'http://127.0.0.1/mycampus/api/preinscriptions';

function testApi($method, $endpoint, $data = null) {
    global $baseUrl;
    
    $url = $baseUrl . $endpoint;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'X-User-ID: 1'
    ]);
    
    if ($data) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'status_code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "=== TEST DE L'API DE GESTION DES PRÉINSCRIPTIONS ===\n\n";

// Test 1: Créer une préinscription
echo "1. Test de création d'une préinscription:\n";
$createData = [
    'first_name' => 'Jean',
    'last_name' => 'Dupont',
    'middle_name' => 'Pierre',
    'email' => 'jean.dupont.' . time() . '@test.com',
    'phone_number' => '+237123456789',
    'date_of_birth' => '1995-05-15',
    'place_of_birth' => 'Douala',
    'gender' => 'MASCULIN',
    'residence_address' => '123 Rue Test',
    'marital_status' => 'CELIBATAIRE',
    'first_language' => 'FRANÇAIS',
    'professional_situation' => 'SANS EMPLOI',
    'faculty' => 'FALSH',
    'desired_program' => 'Licence en Droit',
    'study_level' => 'LICENCE'
];

$result = testApi('POST', '', $createData);
echo "Status: {$result['status_code']}\n";
echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";

if ($result['status_code'] == 200 && $result['response']['success']) {
    $preinscriptionId = $result['response']['data']['id'];
    
    // Test 2: Récupérer la préinscription créée
    echo "2. Test de récupération d'une préinscription (ID: $preinscriptionId):\n";
    $result = testApi('GET', "/$preinscriptionId");
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
    
    // Test 3: Mettre à jour le paiement
    echo "3. Test de mise à jour du paiement:\n";
    $paymentData = [
        'payment_status' => 'paid',
        'payment_amount' => 10000,
        'payment_method' => 'ORANGE_MONEY',
        'payment_reference' => 'REF123456'
    ];
    $result = testApi('PUT', "/$preinscriptionId/payment", $paymentData);
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
    
    // Test 4: Accepter la préinscription
    echo "4. Test d'acceptation d'une préinscription:\n";
    $result = testApi('PUT', "/$preinscriptionId/accept");
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
    
    // Test 5: Récupérer les statistiques
    echo "5. Test des statistiques:\n";
    $result = testApi('GET', '/stats');
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
    
    // Test 6: Lister les préinscriptions
    echo "6. Test de liste des préinscriptions:\n";
    $result = testApi('GET', '');
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
    
    // Test 7: Rejeter la préinscription
    echo "7. Test de rejet d'une préinscription:\n";
    $rejectData = ['rejection_reason' => 'Test de rejet'];
    $result = testApi('PUT', "/$preinscriptionId/reject", $rejectData);
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
    
    // Test 8: Supprimer la préinscription
    echo "8. Test de suppression d'une préinscription:\n";
    $result = testApi('DELETE', "/$preinscriptionId");
    echo "Status: {$result['status_code']}\n";
    echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n\n";
} else {
    echo "Échec de la création, tests suivants annulés.\n";
}

echo "=== FIN DES TESTS ===\n";
?>
