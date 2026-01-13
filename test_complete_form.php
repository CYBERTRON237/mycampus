<?php
// Test pour simuler un formulaire complet
$data = [
    // Champs de base (déjà testés)
    'faculty' => 'UY1',
    'lastName' => 'Test',
    'firstName' => 'User',
    'middleName' => 'Middle',
    'dateOfBirth' => '2000-01-01',
    'isBirthDateOnCertificate' => 1,
    'placeOfBirth' => 'Yaounde',
    'gender' => 'MASCULIN',
    'cniNumber' => '123456789012',
    'residenceAddress' => 'Test Address Complete',
    'maritalStatus' => 'CELIBATAIRE',
    'phoneNumber' => '698765432',
    'email' => 'test.complete.' . time() . '@example.com',
    'firstLanguage' => 'FRANÇAIS',
    'professionalSituation' => 'SANS EMPLOI',
    
    // Champs académiques
    'previousDiploma' => 'BACCALAUREAT',
    'previousInstitution' => 'Lycée Test',
    'graduationYear' => 2020,
    'graduationMonth' => 'Juin',
    'desiredProgram' => 'Informatique',
    'studyLevel' => 'LICENCE',
    'specialization' => 'Développement Web',
    'seriesBac' => 'C',
    'bacYear' => 2020,
    'bacCenter' => 'Yaounde',
    'bacMention' => 'BIEN',
    'gpaScore' => 3.5,
    'rankInClass' => 15,
    
    // Champs parents
    'parentName' => 'Parent Test',
    'parentPhone' => '612345678',
    'parentEmail' => 'parent@example.com',
    'parentOccupation' => 'Fonctionnaire',
    'parentAddress' => 'Parent Address',
    'parentRelationship' => 'PERE',
    'parentIncomeLevel' => 'MOYEN',
    
    // Champs paiement
    'paymentMethod' => 'ORANGE_MONEY',
    'paymentReference' => 'REF123456',
    'paymentAmount' => 10000.00,
    'paymentCurrency' => 'XAF',
    'paymentDate' => '2025-12-17 10:00:00',
    'paymentStatus' => 'paid',
    'scholarshipRequested' => 0,
    
    // Champs documents (paths simulés)
    'birthCertificatePath' => '/uploads/birth_cert.pdf',
    'cniPath' => '/uploads/cni.pdf',
    'diplomaPath' => '/uploads/diploma.pdf',
    'transcriptPath' => '/uploads/transcript.pdf',
    'photoPath' => '/uploads/photo.jpg',
    
    // Consentements
    'marketingConsent' => 1,
    'dataProcessingConsent' => 1,
    'newsletterSubscription' => 0,
    
    // Notes
    'notes' => 'Notes supplémentaires',
    'specialNeeds' => 'Aucun besoin spécial'
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

echo "=== Test Formulaire Complet ===\n";
echo "Nombre de champs envoyés: " . count($data) . "\n\n";

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
echo "================================\n";
?>
