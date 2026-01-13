<?php
// Test with the original failing data but corrected GPA score

$data = [
    'unique_code' => 'PRE2025176592',
    'faculty' => 'Faculté des Arts, Lettres et Sciences Humaines',
    'last_name' => 'dksaj',
    'first_name' => 'lksajda',
    'middle_name' => 'kjldsa',
    'date_of_birth' => '2000-01-01',
    'is_birth_date_on_certificate' => 1,
    'place_of_birth' => 'klsadj',
    'gender' => 'MASCULIN',
    'cni_number' => null,
    'residence_address' => 'sdsa',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '674747474',
    'email' => 'corrected.gpa.' . time() . '@gmail.com',
    'first_language' => 'ANGLAIS',
    'professional_situation' => 'SANS EMPLOI',
    'previous_diploma' => 'BACCALAUREAT',
    'previous_institution' => 'Lycee adklsaj',
    'graduation_year' => 2020,
    'graduation_month' => 'Mai',
    'desired_program' => 'sldsajk',
    'study_level' => 'LICENCE',
    'specialization' => 'dlsakj',
    'series_bac' => 'TI',
    'bac_year' => 2024,
    'bac_center' => 'LYcla',
    'bac_mention' => 'PASSABLE',
    'gpa_score' => 3.8, // Corrected: was 12.0, now within 0.00-5.00 range
    'rank_in_class' => 12,
    'parent_name' => 'slkda',
    'parent_phone' => '674747474',
    'parent_email' => 'sdlkaj@gmail.com',
    'parent_occupation' => 'sdjalk',
    'parent_address' => 'ksdkasjd',
    'parent_relationship' => 'PERE',
    'parent_income_level' => 'MOYEN',
    'payment_method' => 'ORANGE_MONEY',
    'payment_reference' => null,
    'payment_amount' => null,
    'payment_currency' => 'XAF',
    'payment_date' => null,
    'payment_status' => 'pending',
    'payment_proof_path' => null,
    'scholarship_requested' => 1,
    'scholarship_type' => null,
    'financial_aid_amount' => null,
    'birth_certificate_path' => null,
    'cni_path' => null,
    'diploma_path' => null,
    'transcript_path' => null,
    'photo_path' => null,
    'recommendation_letter_path' => null,
    'motivation_letter_path' => null,
    'medical_certificate_path' => null,
    'other_documents_path' => null,
    'contact_preference' => null,
    'marketing_consent' => 1,
    'data_processing_consent' => 1,
    'newsletter_subscription' => 1,
    'ip_address' => '127.0.0.1',
    'user_agent' => 'Flutter App',
    'device_type' => null,
    'browser_info' => null,
    'os_info' => null,
    'location_country' => null,
    'location_city' => null,
    'notes' => null,
    'special_needs' => null,
    'medical_conditions' => null,
    'created_at' => '2025-12-17T10:13:50.424600'
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

echo "=== TEST DONNÉES ORIGINALES AVEC GPA CORRIGÉ ===\n";
echo "GPA Score corrigé: " . $data['gpa_score'] . " (était: 12.0)\n";
echo "Email: " . $data['email'] . "\n";
echo "HTTP Status: $httpCode\n\n";

$jsonStart = strpos($response, '{"success"');
$jsonEnd = strrpos($response, '}');
if ($jsonStart !== false && $jsonEnd !== false) {
    $jsonResponse = substr($response, $jsonStart, $jsonEnd - $jsonStart + 1);
    $result = json_decode($jsonResponse, true);
    
    if ($result && isset($result['success']) && $result['success']) {
        echo "✅ SUCCÈS: Préinscription créée avec succès!\n";
        echo "Code unique: " . ($result['unique_code'] ?? 'N/A') . "\n";
        echo "UUID: " . ($result['uuid'] ?? 'N/A') . "\n";
        echo "Faculté: " . ($result['data']['faculty'] ?? 'N/A') . "\n";
        echo "Nom: " . ($result['data']['firstName'] ?? 'N/A') . " " . ($result['data']['lastName'] ?? 'N/A') . "\n";
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
?>
