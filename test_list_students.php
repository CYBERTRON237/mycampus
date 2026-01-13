<?php
// Script pour lister les étudiants disponibles
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

try {
    $pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
    
    // Récupérer les étudiants avec leurs informations
    $query = "SELECT 
                sp.id,
                sp.user_id,
                sp.current_level,
                sp.student_status,
                sp.gpa,
                sp.created_at,
                u.first_name,
                u.last_name,
                u.email,
                u.matricule,
                u.phone,
                u.account_status,
                COALESCE(p.name, 'Programme non défini') as program_name,
                COALESCE(ay.year_code, 'Année académique non définie') as academic_year_name
              FROM student_profiles sp
              LEFT JOIN users u ON sp.user_id = u.id
              LEFT JOIN programs p ON sp.program_id = p.id
              LEFT JOIN academic_years ay ON sp.academic_year_id = ay.id
              ORDER BY u.last_name ASC, u.first_name ASC
              LIMIT 10";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $students = $stmt->fetchAll();
    
    // Compter le total
    $countQuery = "SELECT COUNT(*) as total FROM student_profiles";
    $countStmt = $pdo->prepare($countQuery);
    $countStmt->execute();
    $total = $countStmt->fetch()['total'];
    
    echo json_encode([
        'success' => true,
        'message' => 'Liste des étudiants disponibles',
        'total_count' => $total,
        'showing' => count($students),
        'students' => array_map(function($student) {
            return [
                'id' => $student['id'],
                'user_id' => $student['user_id'],
                'full_name' => $student['first_name'] . ' ' . $student['last_name'],
                'email' => $student['email'],
                'matricule' => $student['matricule'],
                'phone' => $student['phone'],
                'current_level' => $student['current_level'],
                'student_status' => $student['student_status'],
                'account_status' => $student['account_status'],
                'gpa' => $student['gpa'],
                'program_name' => $student['program_name'],
                'academic_year' => $student['academic_year_name'],
                'created_at' => $student['created_at'],
                'test_urls' => [
                    'get_details' => "test_student_edit.php?test_get={$student['id']}",
                    'update_student' => "test_student_edit.php?test_update={$student['id']}"
                ]
            ];
        }, $students)
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors de la récupération des étudiants',
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ], JSON_PRETTY_PRINT);
}
?>
