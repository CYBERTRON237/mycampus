<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Test direct de l'API student management
require_once 'api/student_management/models/UsersStudentModel.php';

try {
    // Connexion à la base de données
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $studentModel = new UsersStudentModel($conn);
    
    // Récupérer les étudiants
    $result = $studentModel->getStudents(1, 10);
    
    echo json_encode([
        'success' => true,
        'message' => 'Test direct de l\'API student management',
        'total_students' => $result['total'],
        'students_sample' => array_slice($result['students'], 0, 3),
        'database_info' => [
            'host' => $host,
            'database' => $dbname,
            'table' => 'users',
            'role_filter' => "primary_role = 'student'"
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
