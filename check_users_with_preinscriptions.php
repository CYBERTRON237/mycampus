<?php
// Vérifier les utilisateurs qui ont des préinscriptions liées
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
    
    // Chercher des utilisateurs avec préinscriptions
    $result = $conn->query("
        SELECT u.id, u.email, u.primary_role, u.preinscription_id, u.preinscription_unique_code,
               p.unique_code, p.status, p.first_name, p.last_name, p.faculty
        FROM users u 
        LEFT JOIN preinscriptions p ON u.preinscription_id = p.id 
        WHERE u.preinscription_id IS NOT NULL
        LIMIT 5
    ");
    
    $usersWithPreinscriptions = $result->fetchAll();
    
    // Compter les utilisateurs par rôle
    $result = $conn->query("
        SELECT primary_role, COUNT(*) as count 
        FROM users 
        GROUP BY primary_role
    ");
    $roleCounts = $result->fetchAll();
    
    echo json_encode([
        'success' => true,
        'users_with_preinscriptions' => $usersWithPreinscriptions,
        'role_counts' => $roleCounts,
        'message' => 'Found ' . count($usersWithPreinscriptions) . ' users with preinscriptions'
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
