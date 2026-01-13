<?php
// Test complet de l'API submit.php avec tous les nouveaux champs
$data = [
    'unique_code' => 'COMPLETE_' . time(),
    'faculty' => 'UY1',
    'last_name' => 'Test',
    'first_name' => 'User',
    'middle_name' => 'Complete',
    'date_of_birth' => '2000-01-01',
    'place_of_birth' => 'Yaoundé',
    'gender' => 'MASCULIN',
    'residence_address' => 'Test Address, Yaoundé',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '691234567',
    'email' => 'complete' . time() . '@example.com',
    'first_language' => 'FRANÇAIS',
    'professional_situation' => 'SANS EMPLOI',
    'cni_number' => '1234567890',
    
    // Academic information
    'previous_diploma' => 'BACCALAUREAT C',
    'previous_institution' => 'Lycée Leclerc',
    'graduation_year' => 2022,
    'desired_program' => 'Informatique',
    'study_level' => 'LICENCE',
    'series_bac' => 'C',
    'bac_year' => 2022,
    'bac_center' => 'Lycée Leclerc Yaoundé',
    
    // Documents paths (simulation)
    'birth_certificate_path' => '/uploads/documents/birth_cert_' . time() . '.pdf',
    'cni_path' => '/uploads/documents/cni_' . time() . '.pdf',
    'diploma_path' => '/uploads/documents/diploma_' . time() . '.pdf',
    'transcript_path' => '/uploads/documents/transcript_' . time() . '.pdf',
    'photo_path' => '/uploads/photos/photo_' . time() . '.jpg',
    
    // Parent information
    'parent_name' => 'Parent Test',
    'parent_phone' => '698765432',
    'parent_email' => 'parent' . time() . '@example.com',
    'parent_occupation' => 'Enseignant',
    'parent_address' => 'Parent Address, Douala',
    
    // Payment information
    'payment_method' => 'ORANGE_MONEY',
    'payment_reference' => 'OM' . time(),
    'payment_amount' => 15000.00,
    'payment_date' => date('Y-m-d H:i:s')
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

// Decode response for better display
$result = json_decode($response, true);
if ($result && $result['success']) {
    echo "\n=== PRÉINSCRIPTION CRÉÉE AVEC SUCCÈS ===\n";
    echo "ID: " . $result['data']['id'] . "\n";
    echo "UUID: " . $result['data']['uuid'] . "\n";
    echo "Code Unique: " . $result['data']['unique_code'] . "\n";
    echo "Programme: " . $result['data']['desired_program'] . "\n";
    echo "Niveau: " . $result['data']['study_level'] . "\n";
    echo "Parent: " . $result['data']['parent_name'] . "\n";
    echo "Paiement: " . $result['data']['payment_method'] . " - " . $result['data']['payment_amount'] . " FCFA\n";
} else {
    echo "\n=== ERREUR ===\n";
    echo "Message: " . ($result['message'] ?? 'Unknown error') . "\n";
}
?>
