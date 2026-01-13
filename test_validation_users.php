<?php
// Vérifier tous les utilisateurs et trouver des correspondances
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

    // Tous les utilisateurs
    $users = $pdo->query("SELECT id, email, first_name, last_name, primary_role FROM users ORDER BY id LIMIT 10")->fetchAll();
    
    // Toutes les préinscriptions en attente
    $preinscriptions = $pdo->query("SELECT id, email, first_name, last_name, status FROM preinscriptions WHERE status IN ('pending', 'under_review') ORDER BY id")->fetchAll();
    
    // Trouver des correspondances d'email
    $matches = [];
    foreach ($preinscriptions as $preinscription) {
        foreach ($users as $user) {
            if (strtolower($preinscription['email']) === strtolower($user['email'])) {
                $matches[] = [
                    'preinscription' => $preinscription,
                    'user' => $user
                ];
            }
        }
    }
    
    echo json_encode([
        'success' => true,
        'users_count' => count($users),
        'preinscriptions_count' => count($preinscriptions),
        'matches_count' => count($matches),
        'matches' => $matches,
        'users' => array_slice($users, 0, 5), // Premier 5 utilisateurs
        'preinscriptions' => $preinscriptions
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
