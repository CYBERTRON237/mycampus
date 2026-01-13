<?php
// Activer l'affichage des erreurs pour le debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Headers CORS complets pour le web
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-User-Id, X-Requested-With, Accept, Origin');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Max-Age: 3600');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

error_log("API Request: " . $_SERVER['REQUEST_METHOD'] . " " . $_SERVER['REQUEST_URI']);
error_log("Headers: " . print_r(getallheaders(), true));

require_once '../controllers/ContactController.php';

$controller = new ContactController();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $controller->getContacts();
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
