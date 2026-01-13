<?php
// Test du backend avec le formulaire complet d'étudiant
// Ce script envoie les données complètes à l'API et vérifie la réponse

require_once 'api/student_management/index.php';

// URL de l'API
$apiUrl = 'http://127.0.0.1/mycampus/api/student_management/students/1';

// Données de test complètes
$testData = [
    'id' => 1,
    // Informations personnelles
    'first_name' => 'Jean',
    'middle_name' => 'Pierre',
    'last_name' => 'Dupont',
    'email' => 'jean.dupont.test@email.com',
    'phone' => '+237 699 123 456',
    'address' => '123 Rue de la République',
    'city' => 'Yaoundé',
    'region' => 'Centre',
    'country' => 'Cameroun',
    'postal_code' => 'BP 12345',
    'place_of_birth' => 'Douala',
    'nationality' => 'Camerounaise',
    'bio' => 'Étudiant motivé en informatique',
    'matricule' => 'STU2024001',
    'gender' => 'male',
    'date_of_birth' => '2000-01-15',
    
    // Contact d'urgence
    'emergency_contact_name' => 'Marie Dupont',
    'emergency_contact_phone' => '+237 699 789 012',
    'emergency_contact_relationship' => 'Mère',
    
    // Statut du compte
    'account_status' => 'active',
    
    // Informations académiques
    'current_level' => 'licence2',
    'admission_type' => 'regular',
    'enrollment_date' => '2023-10-01',
    'expected_graduation_date' => '2026-07-31',
    'actual_graduation_date' => null,
    
    // Performance académique
    'gpa' => 3.75,
    'total_credits_required' => 180,
    'class_rank' => 15,
    'honors' => 'Mention Bien',
    'disciplinary_records' => null,
    
    // Bourse
    'scholarship_status' => 'partial',
    'scholarship_details' => 'Bourse d\'excellence académique 50%',
    
    // Thèse
    'graduation_thesis_title' => 'Système de gestion intelligent pour MyCampus',
    'thesis_supervisor' => 'Prof. Martin',
    'thesis_defense_date' => null,
];

// Convertir en JSON
$jsonData = json_encode($testData);

echo "<h2>Test du Backend - Formulaire Complet Étudiant</h2>";
echo "<h3>Données envoyées à l'API:</h3>";
echo "<pre>" . $jsonData . "</pre>";

// Initialiser cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($jsonData)
]);

// Exécuter la requête
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<h3>Réponse de l'API (Code HTTP: $httpCode):</h3>";
echo "<pre>" . $response . "</pre>";

// Décoder la réponse
$result = json_decode($response, true);

if ($result && isset($result['success'])) {
    if ($result['success']) {
        echo "<h2 style='color: green;'>✅ SUCCÈS: Les données ont été enregistrées avec succès!</h2>";
        
        // Vérifier que les données ont bien été sauvegardées en les récupérant
        echo "<h3>Vérification des données sauvegardées:</h3>";
        
        $getApiUrl = 'http://127.0.0.1/mycampus/api/student_management/students/1';
        $getCh = curl_init();
        curl_setopt($getCh, CURLOPT_URL, $getApiUrl);
        curl_setopt($getCh, CURLOPT_RETURNTRANSFER, true);
        $getResponse = curl_exec($getCh);
        curl_close($getCh);
        
        $studentData = json_decode($getResponse, true);
        
        if ($studentData && isset($studentData['success']) && $studentData['success']) {
            $student = $studentData['data'];
            
            echo "<table border='1' cellpadding='5'>";
            echo "<tr><th>Champ</th><th>Valeur envoyée</th><th>Valeur sauvegardée</th><th>Statut</th></tr>";
            
            // Vérifier chaque champ
            $fieldsToCheck = [
                'first_name' => 'Jean',
                'middle_name' => 'Pierre',
                'last_name' => 'Dupont',
                'email' => 'jean.dupont.test@email.com',
                'phone' => '+237 699 123 456',
                'address' => '123 Rue de la République',
                'city' => 'Yaoundé',
                'region' => 'Centre',
                'country' => 'Cameroun',
                'postal_code' => 'BP 12345',
                'place_of_birth' => 'Douala',
                'nationality' => 'Camerounaise',
                'bio' => 'Étudiant motivé en informatique',
                'matricule' => 'STU2024001',
                'gender' => 'male',
                'date_of_birth' => '2000-01-15',
                'emergency_contact_name' => 'Marie Dupont',
                'emergency_contact_phone' => '+237 699 789 012',
                'emergency_contact_relationship' => 'Mère',
                'account_status' => 'active',
                'current_level' => 'licence2',
                'admission_type' => 'regular',
                'enrollment_date' => '2023-10-01',
                'expected_graduation_date' => '2026-07-31',
                'gpa' => '3.75',
                'total_credits_required' => '180',
                'class_rank' => '15',
                'honors' => 'Mention Bien',
                'scholarship_status' => 'partial',
                'scholarship_details' => 'Bourse d\'excellence académique 50%',
                'graduation_thesis_title' => 'Système de gestion intelligent pour MyCampus',
                'thesis_supervisor' => 'Prof. Martin'
            ];
            
            foreach ($fieldsToCheck as $field => $expectedValue) {
                $actualValue = $student[$field] ?? 'NULL';
                $status = ($actualValue == $expectedValue) ? '✅ OK' : '❌ ERREUR';
                $color = ($actualValue == $expectedValue) ? 'green' : 'red';
                
                echo "<tr>";
                echo "<td>$field</td>";
                echo "<td>$expectedValue</td>";
                echo "<td>$actualValue</td>";
                echo "<td style='color: $color; font-weight: bold;'>$status</td>";
                echo "</tr>";
            }
            
            echo "</table>";
        } else {
            echo "<h2 style='color: red;'>❌ ERREUR: Impossible de vérifier les données sauvegardées</h2>";
        }
    } else {
        echo "<h2 style='color: red;'>❌ ERREUR: " . ($result['message'] ?? 'Erreur inconnue') . "</h2>";
    }
} else {
    echo "<h2 style='color: red;'>❌ ERREUR: Réponse invalide de l'API</h2>";
}

echo "<hr>";
echo "<h3>Test terminé!</h3>";
?>
