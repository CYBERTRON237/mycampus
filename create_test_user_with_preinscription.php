<?php
// Créer un utilisateur test avec préinscription
header('Content-Type: application/json');

try {
    $conn = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // Créer une préinscription test
    $uniqueCode = 'TEST' . date('YmdHis');
    $stmt = $conn->prepare("
        INSERT INTO preinscriptions (
            unique_code, first_name, last_name, email, phone, 
            date_of_birth, place_of_birth, gender, address, 
            faculty, study_level, desired_program, high_school, 
            graduation_year, previous_institution, motivation, 
            submission_date, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 'pending')
    ");
    
    $result = $stmt->execute([
        $uniqueCode,
        'Test',
        'Student',
        'teststudent@example.com',
        '690000000',
        '2000-01-01',
        'Yaoundé',
        'M',
        'Test Address',
        'FALSH',
        'License 1',
        'Informatique',
        'Lycée Test',
        '2020',
        'None',
        'Test motivation pour intégrer MyCampus'
    ]);
    
    $preinscriptionId = $conn->lastInsertId();
    
    // Créer un utilisateur test lié à cette préinscription
    $stmt = $conn->prepare("
        INSERT INTO users (
            email, password, primary_role, preinscription_id, 
            preinscription_unique_code, created_at
        ) VALUES (?, ?, ?, ?, ?, NOW())
    ");
    
    $hashedPassword = password_hash('password123', PASSWORD_DEFAULT);
    $result = $stmt->execute([
        'teststudent@example.com',
        $hashedPassword,
        'invite',
        $preinscriptionId,
        $uniqueCode
    ]);
    
    $userId = $conn->lastInsertId();
    
    echo json_encode([
        'success' => true,
        'message' => 'Utilisateur test créé avec succès',
        'user_id' => $userId,
        'preinscription_id' => $preinscriptionId,
        'unique_code' => $uniqueCode,
        'login_info' => [
            'email' => 'teststudent@example.com',
            'password' => 'password123'
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
