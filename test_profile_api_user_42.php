<?php
// Test l'API profile pour l'utilisateur ID 42
header('Content-Type: application/json');

require_once 'api/config/Database.php';
require_once 'api/auth/JWTHandler.php';

try {
    $db = new Database();
    $jwt = new JWTHandler();
    
    // Simuler un token pour l'utilisateur ID 42
    $payload = (object)[
        'user_id' => 42,
        'email' => 'ulrich@gmail.com',
        'primary_role' => 'student',
        'exp' => time() + 3600
    ];
    
    // Simuler l'appel à getMyProfile
    $conn = $db->getConnection();
    
    $query = "SELECT u.*, 
                i.name as institution_name, 
                d.name as department_name,
                p.unique_code as preinscription_code,
                p.status as preinscription_status,
                p.faculty,
                p.study_level,
                p.desired_program,
                p.submission_date as preinscription_date
              FROM users u 
              LEFT JOIN institutions i ON u.institution_id = i.id
              LEFT JOIN departments d ON u.department_id = d.id  
              LEFT JOIN preinscriptions p ON u.preinscription_id = p.id
              WHERE u.id = ?";
              
    $stmt = $conn->prepare($query);
    $stmt->execute([42]);
    $userData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$userData) {
        echo json_encode(['error' => 'User not found']);
        exit;
    }
    
    // Formater les données comme le fait l'API
    $profile = [
        'basicInfo' => [
            'id' => $userData['id'],
            'email' => $userData['email'],
            'firstName' => $userData['first_name'] ?? '',
            'lastName' => $userData['last_name'] ?? '',
            'fullName' => trim(($userData['first_name'] ?? '') . ' ' . ($userData['last_name'] ?? '')),
            'phone' => $userData['phone'] ?? null,
            'dateOfBirth' => $userData['date_of_birth'] ?? null,
            'placeOfBirth' => $userData['place_of_birth'] ?? null,
            'profilePhotoUrl' => $userData['profile_photo_url'] ?? null,
        ],
        'academicInfo' => [
            'role' => $userData['primary_role'],
            'institutionId' => $userData['institution_id'],
            'institutionName' => $userData['institution_name'],
            'departmentId' => $userData['department_id'],
            'departmentName' => $userData['department_name'],
            'faculty' => $userData['faculty'],
            'studyLevel' => $userData['study_level'],
            'desiredProgram' => $userData['desired_program'],
            'preinscriptionCode' => $userData['preinscription_code'],
            'preinscriptionStatus' => $userData['preinscription_status'],
        ],
        'accountInfo' => [
            'status' => $userData['status'] ?? 'active',
            'createdAt' => $userData['created_at'],
            'lastLoginAt' => $userData['last_login_at'],
        ]
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'Profile API test successful',
        'profile' => $profile,
        'raw_user_data' => $userData
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
