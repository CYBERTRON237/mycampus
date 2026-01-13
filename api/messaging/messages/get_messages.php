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

// Récupérer l'ID de la conversation depuis les paramètres GET
$conversationId = $_GET['id'] ?? null;

if (empty($conversationId) || !is_numeric($conversationId)) {
    http_response_code(400);
    echo json_encode(['error' => 'Valid Conversation ID required']);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $controller->getMessages($conversationId);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
