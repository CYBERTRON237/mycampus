<?php
// Endpoint pour obtenir le statut de présence d'un utilisateur
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-User-Id');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../controllers/PresenceController.php';

$controller = new PresenceController();

$userId = $_GET['user_id'] ?? null;

if (empty($userId) || !is_numeric($userId)) {
    http_response_code(400);
    echo json_encode(['error' => 'Valid user_id required']);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $controller->getUserPresence($userId);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
