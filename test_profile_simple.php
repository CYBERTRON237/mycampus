<?php
// Test simple pour vérifier si l'API profile fonctionne
header('Content-Type: application/json');

try {
    // Connexion à la base de données
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
    
    // Vérifier la table users
    $result = $conn->query("SELECT COUNT(*) as count FROM users");
    $usersCount = $result->fetch()['count'];
    
    // Vérifier la table preinscriptions
    $result = $conn->query("SELECT COUNT(*) as count FROM preinscriptions");
    $preinscriptionsCount = $result->fetch()['count'];
    
    // Prendre un utilisateur exemple
    $result = $conn->query("SELECT id, email, primary_role, preinscription_id FROM users LIMIT 1");
    $user = $result->fetch();
    
    // Si l'utilisateur a une préinscription, récupérer les infos
    $preinscription = null;
    if ($user && $user['preinscription_id']) {
        $stmt = $conn->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$user['preinscription_id']]);
        $preinscription = $stmt->fetch();
    }
    
    echo json_encode([
        'success' => true,
        'users_count' => $usersCount,
        'preinscriptions_count' => $preinscriptionsCount,
        'sample_user' => $user,
        'sample_preinscription' => $preinscription,
        'message' => 'Database check successful'
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
