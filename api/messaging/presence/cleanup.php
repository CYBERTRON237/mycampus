<?php
// Endpoint pour nettoyer les anciennes présences
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-User-Id');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../controllers/PresenceController.php';

$controller = new PresenceController();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $controller->cleanupOldPresence();
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
