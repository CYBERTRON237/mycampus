<?php
// Test the cleaned-up submit.php without debug output

$data = [
    'faculty' => 'Faculté des Arts, Lettres et Sciences Humaines',
    'last_name' => 'Clean',
    'first_name' => 'Test',
    'middle_name' => 'Middle',
    'date_of_birth' => '2000-01-01',
    'is_birth_date_on_certificate' => 1,
    'place_of_birth' => 'Test City',
    'gender' => 'MASCULIN',
    'residence_address' => 'Test Address',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '674747474',
    'email' => 'clean.test.' . time() . '@gmail.com',
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
    'gpa_score' => 4.2, // Valid GPA score
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

echo "=== TEST VERSION NETTOYÉE ===\n";
echo "GPA Score: " . $data['gpa_score'] . "\n";
echo "Email: " . $data['email'] . "\n";
echo "HTTP Status: $httpCode\n";
echo "Response length: " . strlen($response) . " bytes\n\n";

$result = json_decode($response, true);
if ($result && isset($result['success']) && $result['success']) {
    echo "✅ SUCCÈS: Préinscription créée avec succès!\n";
    echo "Code unique: " . ($result['unique_code'] ?? 'N/A') . "\n";
    echo "UUID: " . ($result['uuid'] ?? 'N/A') . "\n";
    echo "Faculté: " . ($result['data']['faculty'] ?? 'N/A') . "\n";
    echo "Nom: " . ($result['data']['firstName'] ?? 'N/A') . " " . ($result['data']['lastName'] ?? 'N/A') . "\n";
    echo "Statut: " . ($result['data']['status'] ?? 'N/A') . "\n";
    echo "Réponse JSON pure: OUI\n";
} else {
    echo "❌ ERREUR: Échec de la préinscription\n";
    echo "Message: " . ($result['message'] ?? 'Erreur inconnue') . "\n";
    echo "Réponse brute: " . $response . "\n";
}

echo "\n=== VÉRIFICATION FORMAT JSON ===\n";
echo "La réponse commence par: " . substr($response, 0, 20) . "...\n";
echo "Est-ce du JSON pur? " . (json_decode($response) ? "OUI" : "NON") . "\n";
?>
