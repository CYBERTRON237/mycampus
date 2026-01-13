<?php
// Debug spécifique pour l'utilisateur ID 42
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
    
    // Récupérer l'utilisateur ID 42
    $stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
    $stmt->execute([42]);
    $user = $stmt->fetch();
    
    if (!$user) {
        echo json_encode(['error' => 'User ID 42 not found']);
        exit;
    }
    
    // Récupérer sa préinscription
    $preinscription = null;
    if ($user['preinscription_id']) {
        $stmt = $conn->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$user['preinscription_id']]);
        $preinscription = $stmt->fetch();
    }
    
    echo json_encode([
        'success' => true,
        'user' => $user,
        'preinscription' => $preinscription,
        'has_preinscription' => !empty($user['preinscription_id']),
        'is_student' => $user['primary_role'] === 'student',
        'preinscription_status' => $preinscription['status'] ?? null
    ]);
    
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
