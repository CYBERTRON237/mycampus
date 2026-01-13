<?php
require_once __DIR__ . '/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

$query = "SELECT id, email, first_name, last_name FROM users WHERE id = 38 LIMIT 1";
$stmt = $db->prepare($query);
$stmt->execute();
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    echo json_encode([
        'success' => true,
        'user' => $user
    ], JSON_PRETTY_PRINT);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Utilisateur ID 38 non trouvé'
    ], JSON_PRETTY_PRINT);
}
?>
