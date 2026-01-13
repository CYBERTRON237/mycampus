<?php
// Test avec un utilisateur existant dans la base de données
$host = '127.0.0.1';
$dbname = 'mycampus';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);

    // Vérifier s'il y a des utilisateurs dans la base
    $stmt = $pdo->query("SELECT id, email, first_name, last_name FROM users LIMIT 1");
    $user = $stmt->fetch();

    if (!$user) {
        echo "Aucun utilisateur trouvé dans la base de données.\n";
        echo "Création d'un utilisateur de test...\n";
        
        // Créer un utilisateur de test
        $stmt = $pdo->prepare("
            INSERT INTO users (uuid, institution_id, matricule, email, password_hash, first_name, last_name, primary_role, account_status, is_active)
            VALUES (?, 1, ?, ?, ?, ?, ?, 'admin_local', 'active', 1)
        ");
        $stmt->execute([
            'test-user-uuid-' . uniqid(),
            'TEST' . date('Y') . '00001',
            'test@mycampus.com',
            password_hash('test123', PASSWORD_DEFAULT),
            'Test',
            'User'
        ]);
        
        $userId = $pdo->lastInsertId();
        
        // Assigner un rôle
        $stmt = $pdo->prepare("
            INSERT INTO user_roles (user_id, role_id, assigned_by, assigned_at, is_active)
            VALUES (?, 2, ?, NOW(), 1)
        ");
        $stmt->execute([$userId, $userId]);
        
        echo "Utilisateur de test créé avec ID: $userId\n";
        $user = ['id' => $userId, 'email' => 'test@mycampus.com', 'first_name' => 'Test', 'last_name' => 'User'];
    }

    echo "Utilisateur trouvé: {$user['first_name']} {$user['last_name']} (ID: {$user['id']})\n";

    // Créer un token JWT simple pour le test
    $token = base64_encode(json_encode(['user_id' => $user['id'], 'exp' => time() + 3600])) . '.signature';

    // Simuler une requête à l'API
    $_SERVER['REQUEST_METHOD'] = 'GET';
    $_SERVER['REQUEST_URI'] = '/api/user_management/users';
    $_SERVER['HTTP_HOST'] = '127.0.0.1';
    $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $token;

    ob_start();
    include 'api/user_management/routes/api.php';
    $output = ob_get_clean();

    // Nettoyer les warnings
    $output = preg_replace('/Warning:.*?\n/', '', $output);

    echo "\nTest de l'API avec l'utilisateur {$user['id']}\n";
    echo "URL: http://127.0.0.1/mycampus/api/user_management/users\n";
    echo "Token: $token\n\n";
    echo "Réponse de l'API:\n";
    echo $output . "\n";

} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
