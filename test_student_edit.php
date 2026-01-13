<?php
// Script de test pour la modification d'étudiant
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion à la base de données
try {
    $pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

// Inclure les classes nécessaires
require_once __DIR__ . '/api/student_management/models/SimpleStudentModel.php';
require_once __DIR__ . '/api/student_management/controllers/StudentController.php';

// Créer l'instance du contrôleur
$controller = new StudentController($pdo);

// Test de récupération d'un étudiant
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['test_get'])) {
    try {
        $studentId = $_GET['test_get'];
        $controller->getStudent($studentId);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors du test GET',
            'error' => $e->getMessage()
        ]);
    }
    exit;
}

// Test de modification d'un étudiant
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['test_update'])) {
    try {
        $studentId = $_GET['test_update'];
        
        // Données de test
        $testData = [
            'first_name' => 'Jean',
            'last_name' => 'Dupont',
            'email' => 'jean.dupont@test.com',
            'phone' => '237123456789',
            'address' => '123 Rue Test',
            'city' => 'Yaoundé',
            'region' => 'Centre',
            'country' => 'Cameroun',
            'postal_code' => '12345',
            'place_of_birth' => 'Douala',
            'nationality' => 'Camerounaise',
            'gender' => 'male',
            'date_of_birth' => '2000-01-01',
            'bio' => 'Étudiant test',
            'matricule' => 'TEST001',
            'emergency_contact_name' => 'Mère Dupont',
            'emergency_contact_phone' => '237987654321',
            'emergency_contact_relationship' => 'Mère',
            'account_status' => 'active',
            'current_level' => 'licence1',
            'admission_type' => 'regular',
            'enrollment_date' => '2024-10-01',
            'expected_graduation_date' => '2028-07-31',
            'gpa' => 3.5,
            'total_credits_required' => 180,
            'class_rank' => 15,
            'honors' => 'Excellence académique',
            'scholarship_status' => 'partial',
            'scholarship_details' => 'Bourse mérite 50%',
            'graduation_thesis_title' => 'Intelligence Artificielle',
            'thesis_supervisor' => 'Prof. Test'
        ];
        
        // Simuler une requête PUT
        $_SERVER['REQUEST_METHOD'] = 'PUT';
        
        // Utiliser le modèle directement pour tester
        $studentModel = new SimpleStudentModel($pdo);
        $result = $studentModel->updateStudent($studentId, $testData);
        
        echo json_encode([
            'success' => $result['success'],
            'message' => $result['message'],
            'data' => $result['data'] ?? null,
            'test_info' => [
                'student_id' => $studentId,
                'fields_sent' => count($testData),
                'timestamp' => date('Y-m-d H:i:s')
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors du test UPDATE',
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
    }
    exit;
}

// Afficher les instructions
echo json_encode([
    'success' => true,
    'message' => 'Script de test pour la modification d\'étudiant',
    'instructions' => [
        'test_get' => 'GET ?test_get={student_id} pour tester la récupération',
        'test_update' => 'POST ?test_update={student_id} pour tester la modification',
        'example' => [
            'get_student' => 'test_student_edit.php?test_get=1',
            'update_student' => 'test_student_edit.php?test_update=1'
        ]
    ],
    'note' => 'Assurez-vous qu\'il y a des étudiants dans la base de données'
]);
?>
