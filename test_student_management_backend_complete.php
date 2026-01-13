<?php
/**
 * Script de test complet pour le backend Student Management
 * Teste tous les endpoints API avec validation des réponses
 */

// Configuration
$baseUrl = 'http://localhost/mycampus/api/student_management';
$testResults = [];
$totalTests = 0;
$passedTests = 0;

// Fonctions utilitaires
function makeRequest($url, $method = 'GET', $data = null, $headers = []) {
    $ch = curl_init();
    
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => array_merge([
            'Content-Type: application/json',
            'Accept: application/json'
        ], $headers),
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => false
    ]);
    
    if ($data && in_array($method, ['POST', 'PUT', 'PATCH'])) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    return [
        'response' => $response,
        'http_code' => $httpCode,
        'error' => $error
    ];
}

function logTest($testName, $expected, $actual, $passed) {
    global $testResults, $totalTests, $passedTests;
    
    $totalTests++;
    if ($passed) $passedTests++;
    
    $testResults[] = [
        'test' => $testName,
        'expected' => $expected,
        'actual' => $actual,
        'passed' => $passed
    ];
    
    echo sprintf(
        "[%s] %s\nExpected: %s\nActual: %s\n\n",
        $passed ? "PASS" : "FAIL",
        $testName,
        $expected,
        $actual
    );
}

echo "=== TEST COMPLET DU BACKEND STUDENT MANAGEMENT ===\n\n";

// Test 1: Vérifier que le endpoint principal répond
echo "1. Test du endpoint principal\n";
$result = makeRequest($baseUrl);
logTest(
    "Endpoint principal accessible",
    "HTTP 200",
    "HTTP " . $result['http_code'],
    $result['http_code'] == 200
);

// Test 2: Lister tous les étudiants (GET)
echo "2. Test de listing des étudiants\n";
$result = makeRequest($baseUrl . '/students');
$data = json_decode($result['response'], true);
logTest(
    "Liste des étudiants",
    "HTTP 200 + JSON valide",
    "HTTP " . $result['http_code'] . " + " . (is_array($data) ? "JSON valide" : "JSON invalide"),
    $result['http_code'] == 200 && is_array($data)
);

// Test 3: Créer un étudiant (POST)
echo "3. Test de création d'étudiant\n";
$newStudent = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test.student' . time() . '@example.com',
    'matricule' => 'TEST' . time(),
    'institution_id' => 1,
    'department_id' => 1,
    'level' => 'L1',
    'academic_year' => '2024-2025'
];

$result = makeRequest($baseUrl . '/students', 'POST', $newStudent);
$data = json_decode($result['response'], true);
$createdStudentId = null;

if ($result['http_code'] == 201 && isset($data['id'])) {
    $createdStudentId = $data['id'];
}

logTest(
    "Création d'étudiant",
    "HTTP 201 + ID retourné",
    "HTTP " . $result['http_code'] . " + " . ($createdStudentId ? "ID: $createdStudentId" : "Pas d'ID"),
    $result['http_code'] == 201 && $createdStudentId !== null
);

// Test 4: Récupérer un étudiant spécifique (GET par ID)
echo "4. Test de récupération d'étudiant par ID\n";
if ($createdStudentId) {
    $result = makeRequest($baseUrl . '/students/' . $createdStudentId);
    $data = json_decode($result['response'], true);
    
    logTest(
        "Récupération étudiant par ID",
        "HTTP 200 + données étudiant",
        "HTTP " . $result['http_code'] . " + " . (isset($data['id']) ? "ID trouvé" : "ID non trouvé"),
        $result['http_code'] == 200 && isset($data['id'])
    );
} else {
    logTest("Récupération étudiant par ID", "Test sauté", "Aucun étudiant créé", false);
}

// Test 5: Rechercher des étudiants (GET avec filtre)
echo "5. Test de recherche d'étudiants\n";
$result = makeRequest($baseUrl . '/students?search=Test');
$data = json_decode($result['response'], true);

logTest(
    "Recherche d'étudiants",
    "HTTP 200 + résultats de recherche",
    "HTTP " . $result['http_code'] . " + " . (is_array($data) ? "Tableau résultats" : "Pas de tableau"),
    $result['http_code'] == 200 && is_array($data)
);

// Test 6: Mettre à jour un étudiant (PUT)
echo "6. Test de mise à jour d'étudiant\n";
if ($createdStudentId) {
    $updateData = [
        'first_name' => 'Test Updated',
        'last_name' => 'Student Updated',
        'level' => 'L2'
    ];
    
    $result = makeRequest($baseUrl . '/students/' . $createdStudentId, 'PUT', $updateData);
    $data = json_decode($result['response'], true);
    
    logTest(
        "Mise à jour d'étudiant",
        "HTTP 200 + succès",
        "HTTP " . $result['http_code'] . " + " . (isset($data['success']) ? "Succès" : "Pas de succès"),
        $result['http_code'] == 200
    );
} else {
    logTest("Mise à jour d'étudiant", "Test sauté", "Aucun étudiant créé", false);
}

// Test 7: Test de validation des données (POST invalide)
echo "7. Test de validation des données\n";
$invalidStudent = [
    'first_name' => '', // Nom invalide (vide)
    'email' => 'email-invalide', // Email invalide
    'matricule' => '' // Matricule vide
];

$result = makeRequest($baseUrl . '/students', 'POST', $invalidStudent);
$data = json_decode($result['response'], true);

logTest(
    "Validation des données",
    "HTTP 400 + erreurs de validation",
    "HTTP " . $result['http_code'] . " + " . (isset($data['errors']) ? "Erreurs trouvées" : "Pas d'erreurs"),
    $result['http_code'] == 400 && isset($data['errors'])
);

// Test 8: Test de statistiques
echo "8. Test des statistiques\n";
$result = makeRequest($baseUrl . '/students/stats');
$data = json_decode($result['response'], true);

logTest(
    "Statistiques des étudiants",
    "HTTP 200 + données statistiques",
    "HTTP " . $result['http_code'] . " + " . (isset($data['total']) ? "Total trouvé" : "Pas de total"),
    $result['http_code'] == 200 && isset($data['total'])
);

// Test 9: Test de suppression (DELETE)
echo "9. Test de suppression d'étudiant\n";
if ($createdStudentId) {
    $result = makeRequest($baseUrl . '/students/' . $createdStudentId, 'DELETE');
    $data = json_decode($result['response'], true);
    
    logTest(
        "Suppression d'étudiant",
        "HTTP 200 + succès",
        "HTTP " . $result['http_code'] . " + " . (isset($data['success']) ? "Succès" : "Pas de succès"),
        $result['http_code'] == 200
    );
} else {
    logTest("Suppression d'étudiant", "Test sauté", "Aucun étudiant créé", false);
}

// Test 10: Test d'endpoint inexistant
echo "10. Test d'endpoint inexistant\n";
$result = makeRequest($baseUrl . '/endpoint_inexistant');

logTest(
    "Endpoint inexistant",
    "HTTP 404",
    "HTTP " . $result['http_code'],
    $result['http_code'] == 404
);

// Test 11: Vérification des headers CORS
echo "11. Test des headers CORS\n";
$result = makeRequest($baseUrl);
$headers = curl_getinfo(curl_init(), CURLINFO_HEADER_OUT);

// Pour tester les headers de réponse, nous devons faire une requête avec CURLOPT_HEADER
$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$hasCorsHeaders = strpos($response, 'Access-Control-Allow-Origin') !== false;

logTest(
    "Headers CORS présents",
    "CORS headers trouvés",
    $hasCorsHeaders ? "CORS headers trouvés" : "CORS headers manquants",
    $hasCorsHeaders
);

// Résumé des tests
echo "\n=== RÉSUMÉ DES TESTS ===\n";
echo "Total des tests: $totalTests\n";
echo "Tests réussis: $passedTests\n";
echo "Tests échoués: " . ($totalTests - $passedTests) . "\n";
echo "Taux de réussite: " . round(($passedTests / $totalTests) * 100, 2) . "%\n\n";

// Tests échoués détaillés
$failedTests = array_filter($testResults, function($result) {
    return !$result['passed'];
});

if (!empty($failedTests)) {
    echo "=== TESTS ÉCHOUÉS ===\n";
    foreach ($failedTests as $failed) {
        echo "- {$failed['test']}: {$failed['expected']} vs {$failed['actual']}\n";
    }
    echo "\n";
}

// Test des méthodes HTTP supportées
echo "=== TEST DES MÉTHODES HTTP ===\n";
$methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'];
foreach ($methods as $method) {
    $result = makeRequest($baseUrl, $method);
    echo "$method: HTTP {$result['http_code']}\n";
}

echo "\n=== TEST TERMINÉ ===\n";

?>
