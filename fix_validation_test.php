<?php
// Créer un compte utilisateur pour la préinscription ID=1 ou mettre à jour l'email
header('Content-Type: application/json');

try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );

    // Option 1: Créer un compte utilisateur pour l'email de la préinscription
    $preinscriptionEmail = 'tsamojores76@gmail.com';
    
    // Vérifier si l'utilisateur existe déjà
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$preinscriptionEmail]);
    $existingUser = $stmt->fetch();
    
    if (!$existingUser) {
        // Créer le compte utilisateur
        $hashedPassword = password_hash('password123', PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("INSERT INTO users (first_name, last_name, email, password_hash, primary_role, account_status, created_at, updated_at) VALUES (?, ?, ?, ?, 'invite', 'pending_verification', NOW(), NOW())");
        $stmt->execute([
            'jores',
            'Tsamo Nanfack',
            $preinscriptionEmail,
            $hashedPassword
        ]);
        
        $userId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Compte utilisateur créé avec succès',
            'user_id' => $userId,
            'email' => $preinscriptionEmail,
            'password' => 'password123', // Pour les tests
            'next_step' => 'Vous pouvez maintenant tester la validation avec la préinscription ID=1'
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'message' => 'Le compte utilisateur existe déjà',
            'user_id' => $existingUser['id'],
            'email' => $preinscriptionEmail
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
