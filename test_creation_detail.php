<?php
/**
 * Test détaillé de la création d'étudiant via API
 */

echo "=== TEST DÉTAILLÉ DE CRÉATION D'ÉTUDIANT ===\n\n";

$baseUrl = 'http://localhost/mycampus/api/student_management/students';

// Test de création
echo "1. Test de création d'étudiant\n";
$createData = [
    'first_name' => 'Test',
    'last_name' => 'Student',
    'email' => 'test.student.' . time() . '@example.com',
    'matricule' => 'TEST' . time(),
    'phone' => '123456789',
    'program_id' => 19,
    'level' => 'licence1'
];

echo "Données envoyées:\n";
echo json_encode($createData, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init($baseUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($createData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "CURL Error: $error\n";
echo "Response: $response\n\n";

// Analyser la réponse
$data = json_decode($response, true);
if ($data) {
    echo "Analyse de la réponse:\n";
    echo "- Success: " . ($data['success'] ? 'true' : 'false') . "\n";
    if (isset($data['message'])) {
        echo "- Message: " . $data['message'] . "\n";
    }
    if (isset($data['data'])) {
        echo "- Data présent: Oui\n";
        if (isset($data['data']['id'])) {
            echo "- ID de l'étudiant: " . $data['data']['id'] . "\n";
        } else {
            echo "- ID de l'étudiant: Non trouvé dans data\n";
        }
    } else {
        echo "- Data présent: Non\n";
    }
    if (isset($data['error'])) {
        echo "- Error: " . $data['error'] . "\n";
    }
} else {
    echo "Réponse JSON invalide\n";
}

echo "\n=== Vérification dans la base de données ===\n";

try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    // Compter les étudiants
    $stmt = $pdo->query('SELECT COUNT(*) as count FROM student_profiles');
    $count = $stmt->fetch()['count'];
    echo "Nombre total d'étudiants dans la base: $count\n";
    
    // Lister les derniers étudiants
    $stmt = $pdo->query('SELECT sp.id, u.first_name, u.last_name, u.email 
                          FROM student_profiles sp 
                          LEFT JOIN users u ON sp.user_id = u.id 
                          ORDER BY sp.id DESC 
                          LIMIT 3');
    $students = $stmt->fetchAll();
    
    echo "Derniers étudiants créés:\n";
    foreach ($students as $student) {
        echo "- ID: {$student['id']} - {$student['first_name']} {$student['last_name']} ({$student['email']})\n";
    }
    
} catch (PDOException $e) {
    echo "Erreur base de données: " . $e->getMessage() . "\n";
}

echo "\n=== TEST TERMINÉ ===\n";

?>
