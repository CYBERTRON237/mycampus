<?php
// Test script pour vérifier la gestion des rôles dans l'API Profile
header('Content-Type: application/json');

require_once 'api/config/Database.php';

try {
    $db = new Database();
    
    // Test de différents utilisateurs avec différents rôles
    $testUsers = [
        ['id' => 1, 'email' => 'jorestsamo47@gmail.com', 'role' => 'superadmin'],
        ['id' => 2, 'email' => 'djeugniaberryl@gmail.com', 'role' => 'admin_local'],
        ['id' => 7, 'email' => 'prof.che.professeur@univ.cm', 'role' => 'teacher'],
        ['id' => 42, 'email' => 'ulrich@gmail.com', 'role' => 'student'],
        ['id' => 3, 'email' => 'jean.martin@email.com', 'role' => 'invite'],
    ];
    
    $results = [];
    
    foreach ($testUsers as $testUser) {
        // Simuler l'appel à l'API Profile
        $conn = $db->getConnection();
        
        $query = "SELECT u.*, 
                    i.name as institution_name, 
                    d.name as department_name,
                    p.unique_code as preinscription_code,
                    p.status as preinscription_status,
                    p.faculty,
                    p.study_level,
                    p.desired_program
                  FROM users u 
                  LEFT JOIN institutions i ON u.institution_id = i.id
                  LEFT JOIN departments d ON u.department_id = d.id  
                  LEFT JOIN preinscriptions p ON u.preinscription_id = p.id
                  WHERE u.id = ?";
                  
        $stmt = $conn->prepare($query);
        $stmt->execute([$testUser['id']]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($userData) {
            $results[] = [
                'user_id' => $testUser['id'],
                'email' => $testUser['email'],
                'expected_role' => $testUser['role'],
                'actual_primary_role' => $userData['primary_role'],
                'role_match' => $userData['primary_role'] === $testUser['role'],
                'profile_data' => [
                    'full_name' => trim(($userData['first_name'] ?? '') . ' ' . ($userData['last_name'] ?? '')),
                    'institution_name' => $userData['institution_name'],
                    'has_preinscription' => !empty($userData['preinscription_code']),
                    'preinscription_status' => $userData['preinscription_status'],
                ]
            ];
        } else {
            $results[] = [
                'user_id' => $testUser['id'],
                'email' => $testUser['email'],
                'error' => 'User not found'
            ];
        }
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Test des rôles dans Profile API',
        'test_results' => $results,
        'summary' => [
            'total_tested' => count($testUsers),
            'found' => count(array_filter($results, fn($r) => !isset($r['error']))),
            'roles_correct' => count(array_filter($results, fn($r) => isset($r['role_match']) && $r['role_match']))
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
