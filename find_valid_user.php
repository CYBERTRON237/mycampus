<?php
require_once __DIR__ . '/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

$query = "SELECT id, email, first_name, last_name FROM users ORDER BY id DESC LIMIT 5";
$stmt = $db->prepare($query);
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
    'success' => true,
    'users' => $users,
    'total_found' => count($users)
], JSON_PRETTY_PRINT);
?>
