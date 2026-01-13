<?php
/**
 * Test de mise à jour d'étudiant via API
 */

echo "=== TEST DE MISE À JOUR D'ÉTUDIANT ===\n\n";

$baseUrl = 'http://localhost/mycampus/api/student_management/students';

// Test de mise à jour
echo "1. Test de mise à jour d'étudiant\n";
$updateData = [
    'id' => 10,
    'first_name' => 'Test Updated',
    'last_name' => 'Student Modified',
    'email' => 'test.student.updated@example.com',
    'matricule' => 'TESTUPDATED',
    'phone' => '987654321',
    'current_level' => 'licence2',
    'student_status' => 'active',
    'gpa' => 3.5,
    'total_credits_required' => 180
];

echo "Données envoyées:\n";
echo json_encode($updateData, JSON_PRETTY_PRINT) . "\n\n";

$ch = curl_init("$baseUrl/10");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($updateData));
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
    
    // Vérifier l'étudiant mis à jour
    $stmt = $pdo->prepare('SELECT sp.*, u.first_name, u.last_name, u.email, u.matricule, u.phone 
                          FROM student_profiles sp 
                          LEFT JOIN users u ON sp.user_id = u.id 
                          WHERE sp.id = ?');
    $stmt->execute([10]);
    $student = $stmt->fetch();
    
    if ($student) {
        echo "Étudiant ID 10 après mise à jour:\n";
        echo "- Nom: {$student['first_name']} {$student['last_name']}\n";
        echo "- Email: {$student['email']}\n";
        echo "- Matricule: {$student['matricule']}\n";
        echo "- Téléphone: {$student['phone']}\n";
        echo "- Niveau: {$student['current_level']}\n";
        echo "- Statut: {$student['student_status']}\n";
        echo "- GPA: {$student['gpa']}\n";
        echo "- Crédits requis: {$student['total_credits_required']}\n";
    } else {
        echo "Étudiant ID 10 non trouvé\n";
    }
    
} catch (PDOException $e) {
    echo "Erreur base de données: " . $e->getMessage() . "\n";
}

echo "\n=== TEST TERMINÉ ===\n";

?>
