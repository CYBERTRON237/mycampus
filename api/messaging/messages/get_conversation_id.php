<?php
// Désactiver l'affichage des erreurs pour éviter le HTML dans la réponse
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../controllers/SimpleMessageController.php';

$controller = new SimpleMessageController();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $controller->getConversationId();
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
