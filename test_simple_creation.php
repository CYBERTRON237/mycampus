<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    echo "Test de création simple d'étudiant:\n\n";
    
    // Test 1: Créer un user simple sans contraintes
    echo "1. Création d'un utilisateur simple...\n";
    $userQuery = "INSERT INTO users (
        institution_id, department_id, first_name, last_name, email, matricule, phone, primary_role, 
        created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, 'student', NOW(), NOW())";
    
    $userStmt = $pdo->prepare($userQuery);
    $userResult = $userStmt->execute([1, 1, 'Test', 'Student', 'test.simple@example.com', 'TEST001', '123456789']);
    
    if ($userResult) {
        $userId = $pdo->lastInsertId();
        echo "Utilisateur créé avec ID: $userId\n";
        
        // Test 2: Créer le profile étudiant
        echo "\n2. Création du profile étudiant...\n";
        $profileQuery = "INSERT INTO student_profiles (
            user_id, program_id, academic_year_id, current_level, 
            enrollment_date, student_status, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        
        $profileStmt = $pdo->prepare($profileQuery);
        $profileResult = $profileStmt->execute([$userId, 19, 1, 'licence1', date('Y-m-d'), 'enrolled']);
        
        if ($profileResult) {
            $profileId = $pdo->lastInsertId();
            echo "Profile étudiant créé avec ID: $profileId\n";
            
            // Test 3: Vérifier la création
            echo "\n3. Vérification des données créées:\n";
            $checkQuery = "SELECT sp.*, u.first_name, u.last_name, u.email 
                          FROM student_profiles sp 
                          LEFT JOIN users u ON sp.user_id = u.id 
                          WHERE sp.id = ?";
            $checkStmt = $pdo->prepare($checkQuery);
            $checkStmt->execute([$profileId]);
            $result = $checkStmt->fetch();
            
            if ($result) {
                echo "Étudiant trouvé: {$result['first_name']} {$result['last_name']} ({$result['email']})\n";
                echo "Programme ID: {$result['program_id']}, Niveau: {$result['current_level']}\n";
            }
        } else {
            echo "Erreur lors de la création du profile étudiant\n";
            $errorInfo = $profileStmt->errorInfo();
            echo "Détail de l'erreur: " . $errorInfo[2] . "\n";
        }
    } else {
        echo "Erreur lors de la création de l'utilisateur\n";
        $errorInfo = $userStmt->errorInfo();
        echo "Détail de l'erreur: " . $errorInfo[2] . "\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
