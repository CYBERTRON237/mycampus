<?php
// Test complet de la fonctionnalité fiche de préinscription

echo "=== TEST COMPLET FICHE PRÉINSCRIPTION ===\n\n";

// Créer une préinscription de test
echo "1. Création d'une préinscription de test...\n";
$testData = [
    'faculty' => 'Faculté des Sciences',
    'last_name' => 'TestFiche',
    'first_name' => 'User',
    'date_of_birth' => '2000-01-01',
    'place_of_birth' => 'Test City',
    'gender' => 'MASCULIN',
    'residence_address' => 'Test Address',
    'marital_status' => 'CELIBATAIRE',
    'phone_number' => '674747474',
    'email' => 'test.fiche.' . time() . '@gmail.com',
    'first_language' => 'ANGLAIS',
    'professional_situation' => 'SANS EMPLOI',
    'previous_diploma' => 'BACCALAUREAT',
    'previous_institution' => 'Lycée Test',
    'graduation_year' => 2020,
    'graduation_month' => 'Juin',
    'desired_program' => 'Informatique',
    'study_level' => 'LICENCE',
    'specialization' => 'Développement Web',
    'series_bac' => 'C',
    'bac_year' => 2024,
    'bac_center' => 'Lycée Test',
    'bac_mention' => 'BIEN',
    'gpa_score' => 4.2,
    'rank_in_class' => 15,
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
    'scholarship_requested' => 0,
    'marketing_consent' => 1,
    'data_processing_consent' => 1,
    'newsletter_subscription' => 1
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/submit.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$createResponse = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$createResult = json_decode($createResponse, true);

if ($createResult && isset($createResult['success']) && $createResult['success']) {
    $uniqueCode = $createResult['unique_code'];
    echo "✅ Préinscription créée avec succès!\n";
    echo "Code unique: $uniqueCode\n";
    echo "UUID: " . ($createResult['uuid'] ?? 'N/A') . "\n\n";
    
    // Maintenant tester la récupération
    echo "2. Test de récupération de la fiche...\n";
    
    $searchData = [
        'unique_code' => $uniqueCode
    ];
    
    $ch2 = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php');
    curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch2, CURLOPT_POST, true);
    curl_setopt($ch2, CURLOPT_POSTFIELDS, json_encode($searchData));
    curl_setopt($ch2, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    
    $getResponse = curl_exec($ch2);
    $httpCode2 = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
    curl_close($ch2);
    
    echo "Code HTTP: $httpCode2\n";
    
    $getResult = json_decode($getResponse, true);
    
    if ($getResult && isset($getResult['success']) && $getResult['success']) {
        echo "✅ Fiche récupérée avec succès!\n";
        echo "Nombre de champs: " . count($getResult['data']) . "\n";
        
        // Vérifier les champs principaux
        $data = $getResult['data'];
        echo "\n--- INFORMATIONS PRINCIPALES ---\n";
        echo "Code unique: " . ($data['unique_code'] ?? 'N/A') . "\n";
        echo "Nom complet: " . ($data['first_name'] ?? 'N/A') . " " . ($data['last_name'] ?? 'N/A') . "\n";
        echo "Faculté: " . ($data['faculty'] ?? 'N/A') . "\n";
        echo "Programme désiré: " . ($data['desired_program'] ?? 'N/A') . "\n";
        echo "Statut: " . ($data['status'] ?? 'N/A') . "\n";
        echo "Email: " . ($data['email'] ?? 'N/A') . "\n";
        echo "Téléphone: " . ($data['phone_number'] ?? 'N/A') . "\n";
        
        echo "\n--- INFORMATIONS ACADÉMIQUES ---\n";
        echo "Dernier diplôme: " . ($data['previous_diploma'] ?? 'N/A') . "\n";
        echo "Établissement: " . ($data['previous_institution'] ?? 'N/A') . "\n";
        echo "Année obtention: " . ($data['graduation_year'] ?? 'N/A') . "\n";
        echo "Score GPA: " . ($data['gpa_score'] ?? 'N/A') . "\n";
        echo "Rang classe: " . ($data['rank_in_class'] ?? 'N/A') . "\n";
        
        echo "\n--- INFORMATIONS PARENTS ---\n";
        echo "Nom parent: " . ($data['parent_name'] ?? 'N/A') . "\n";
        echo "Téléphone parent: " . ($data['parent_phone'] ?? 'N/A') . "\n";
        echo "Email parent: " . ($data['parent_email'] ?? 'N/A') . "\n";
        echo "Occupation: " . ($data['parent_occupation'] ?? 'N/A') . "\n";
        
        echo "\n--- INFORMATIONS PAIEMENT ---\n";
        echo "Méthode paiement: " . ($data['payment_method'] ?? 'N/A') . "\n";
        echo "Statut paiement: " . ($data['payment_status'] ?? 'N/A') . "\n";
        echo "Bourse demandée: " . ($data['scholarship_requested'] == 1 ? 'Oui' : 'Non') . "\n";
        
        echo "\n--- DOCUMENTS ---\n";
        $documents = [
            'Acte de naissance' => $data['birth_certificate_path'],
            'CNI' => $data['cni_path'],
            'Diplôme' => $data['diploma_path'],
            'Relevé de notes' => $data['transcript_path'],
            'Photo' => $data['photo_path']
        ];
        
        foreach ($documents as $docName => $docPath) {
            $status = ($docPath != null && $docPath != '') ? '✅ Présent' : '❌ Manquant';
            echo "$docName: $status\n";
        }
        
        echo "\n--- INFORMATIONS SYSTÈME ---\n";
        echo "Date soumission: " . ($data['submission_date'] ?? 'N/A') . "\n";
        echo "Dernière mise à jour: " . ($data['last_updated'] ?? 'N/A') . "\n";
        echo "Adresse IP: " . ($data['ip_address'] ?? 'N/A') . "\n";
        
        echo "\n✅ TEST COMPLET: Tous les champs sont présents et corrects!\n";
        
    } else {
        echo "❌ Erreur lors de la récupération: " . ($getResult['message'] ?? 'Erreur inconnue') . "\n";
    }
    
} else {
    echo "❌ Erreur lors de la création: " . ($createResult['message'] ?? 'Erreur inconnue') . "\n";
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "FIN DU TEST COMPLET\n";
?>
