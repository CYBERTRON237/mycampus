<?php
// Test script for preinscription submission with valid GPA score - using curl to get clean JSON

$data = [
    'faculty' => 'Faculté des Arts, Lettres et Sciences Humaines',
    'last_name' => 'Test',
    'first_name' => 'User',
    'middle_name' => 'Middle',
    'date_of_birth' => '2000-01-01',
    'is_birth_date_on_certificate' => 1,
    'place_of_birth' => 'Test City',
    'gender' => 'MASCULIN',
    'residence_address' => 'Test Address',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '674747474',
    'email' => 'test.valid.' . time() . '@gmail.com',
    'first_language' => 'ANGLAIS',
    'professional_situation' => 'SANS EMPLOI',
    'previous_diploma' => 'BACCALAUREAT',
    'previous_institution' => 'Lycee Test',
    'graduation_year' => 2020,
    'graduation_month' => 'Mai',
    'desired_program' => 'Test Program',
    'study_level' => 'LICENCE',
    'specialization' => 'Test Specialization',
    'series_bac' => 'TI',
    'bac_year' => 2024,
    'bac_center' => 'LYCEE TEST',
    'bac_mention' => 'PASSABLE',
    'gpa_score' => 3.5, // Valid GPA score (0.00 - 5.00)
    'rank_in_class' => 12,
    'parent_name' => 'Parent Test',
    'parent_phone' => '674747474',
    'parent_email' => 'parent.test@gmail.com',
    'parent_occupation' => 'Test Occupation',
    'parent_address' => 'Parent Address',
    'parent_relationship' => 'PERE',
    'parent_income_level' => 'MOYEN',
    'payment_method' => 'ORANGE_MONEY',
    'payment_currency' => 'XAF',
    'payment_status' => 'pending',
    'scholarship_requested' => 1,
    'marketing_consent' => 1,
    'data_processing_consent' => 1,
    'newsletter_subscription' => 1
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "=== TEST PRÉINSCRIPTION AVEC GPA VALIDE ===\n";
echo "GPA Score: " . $data['gpa_score'] . "\n";
echo "Email: " . $data['email'] . "\n";
echo "HTTP Status: $httpCode\n\n";

// Extract JSON from response (it might contain debug output)
$jsonStart = strpos($response, '{"success"');
$jsonEnd = strrpos($response, '}');
if ($jsonStart !== false && $jsonEnd !== false) {
    $jsonResponse = substr($response, $jsonStart, $jsonEnd - $jsonStart + 1);
    $result = json_decode($jsonResponse, true);
    
    if ($result && isset($result['success']) && $result['success']) {
        echo "✅ SUCCÈS: Préinscription créée avec succès!\n";
        echo "Code unique: " . ($result['unique_code'] ?? 'N/A') . "\n";
        echo "UUID: " . ($result['uuid'] ?? 'N/A') . "\n";
        echo "Statut: " . ($result['data']['status'] ?? 'N/A') . "\n";
    } else {
        echo "❌ ERREUR: Échec de la préinscription\n";
        echo "Message: " . ($result['message'] ?? 'Erreur inconnue') . "\n";
        if (isset($result['debug_gpa'])) {
            echo "Debug GPA: " . $result['debug_gpa'] . "\n";
        }
    }
} else {
    echo "❌ ERREUR: Impossible de parser la réponse JSON\n";
    echo "Réponse brute: " . substr($response, 0, 500) . "...\n";
}

echo "\n=== TEST AVEC GPA INVALIDE (12.0) ===\n";

// Test with invalid GPA
$data['gpa_score'] = 12.0;
$data['email'] = 'test.invalid.' . time() . '@gmail.com';

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "GPA Score: " . $data['gpa_score'] . "\n";
echo "Email: " . $data['email'] . "\n";
echo "HTTP Status: $httpCode\n";

$jsonStart = strpos($response, '{"success"');
$jsonEnd = strrpos($response, '}');
if ($jsonStart !== false && $jsonEnd !== false) {
    $jsonResponse = substr($response, $jsonStart, $jsonEnd - $jsonStart + 1);
    $result = json_decode($jsonResponse, true);
    
    if ($result && isset($result['success']) && !$result['success']) {
        echo "✅ SUCCÈS: Validation GPA invalide correctement détectée!\n";
        echo "Message d'erreur: " . ($result['message'] ?? 'N/A') . "\n";
        echo "Debug GPA: " . ($result['debug_gpa'] ?? 'N/A') . "\n";
    } else {
        echo "❌ ERREUR: La validation GPA invalide n'a pas fonctionné\n";
    }
} else {
    echo "❌ ERREUR: Impossible de parser la réponse JSON\n";
}
?>
