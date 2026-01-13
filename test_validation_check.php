<?php
// Vérification des données pour le diagnostic
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

    // Vérifier la préinscription ID=1
    $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ?");
    $stmt->execute([1]);
    $preinscription = $stmt->fetch();

    if ($preinscription) {
        // Vérifier si un utilisateur existe avec cet email
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$preinscription['email']]);
        $user = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'preinscription' => [
                'id' => $preinscription['id'],
                'email' => $preinscription['email'],
                'first_name' => $preinscription['first_name'],
                'last_name' => $preinscription['last_name'],
                'status' => $preinscription['status'],
                'faculty' => $preinscription['faculty']
            ],
            'user_found' => $user !== false,
            'user' => $user ? [
                'id' => $user['id'],
                'email' => $user['email'],
                'primary_role' => $user['primary_role'],
                'first_name' => $user['first_name'],
                'last_name' => $user['last_name']
            ] : null,
            'all_pending_preinscriptions' => $pdo->query("SELECT id, email, first_name, last_name, status FROM preinscriptions WHERE status IN ('pending', 'under_review') ORDER BY id")->fetchAll()
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Aucune préinscription trouvée avec ID=1'
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
