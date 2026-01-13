<?php

require_once __DIR__ . '/../controllers/AnnouncementController.php';

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$controller = new AnnouncementController();

// Get the request path
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);

// Debug logging
error_log("Announcements API - Request URI: " . $request_uri);
error_log("Announcements API - Parsed path: " . $path);
error_log("Announcements API - Request method: " . $_SERVER['REQUEST_METHOD']);

// Remove base path from the URL
// Handle both full paths (/mycampus/api/announcements/stats) and cleaned paths (/announcements/stats)
$base_paths = ['/mycampus/api/announcements', '/api/announcements', '/announcements'];
$request_path = $path;
foreach ($base_paths as $base_path) {
    $request_path = str_replace($base_path, '', $request_path);
}
$request_path = rtrim($request_path, '/');

error_log("Announcements API - Final request path: '" . $request_path . "'");

// Parse the path
$path_parts = explode('/', trim($request_path, '/'));

// Route the request
switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        if (empty($request_path) || $request_path === '/') {
            // GET /api/announcements - Get all announcements
            $controller->getAll();
        } elseif ($path_parts[0] === 'user') {
            // GET /api/announcements/user - Get announcements for current user
            $controller->getForUser();
        } elseif ($path_parts[0] === 'stats') {
            // GET /api/announcements/stats - Get statistics
            $controller->getStatistics();
        } elseif ($path_parts[0] === 'pending') {
            // GET /api/announcements/pending - Get pending acknowledgments
            $controller->getPendingAcknowledgments();
        } elseif (is_numeric($path_parts[0])) {
            // GET /api/announcements/{id} - Get announcement by ID
            $controller->getById($path_parts[0]);
        } elseif (count($path_parts) === 2 && $path_parts[0] === 'uuid' && !empty($path_parts[1])) {
            // GET /api/announcements/uuid/{uuid} - Get announcement by UUID
            $controller->getByUuid($path_parts[1]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint non trouvé'
            ]);
        }
        break;

    case 'POST':
        if (empty($request_path) || $request_path === '/') {
            // POST /api/announcements - Create new announcement
            $controller->create();
        } elseif (count($path_parts) === 2 && is_numeric($path_parts[0]) && $path_parts[1] === 'acknowledge') {
            // POST /api/announcements/{id}/acknowledge - Acknowledge announcement
            $controller->acknowledge($path_parts[0]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint non trouvé'
            ]);
        }
        break;

    case 'PUT':
        if (is_numeric($path_parts[0])) {
            // PUT /api/announcements/{id} - Update announcement
            $controller->update($path_parts[0]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint non trouvé'
            ]);
        }
        break;

    case 'DELETE':
        if (is_numeric($path_parts[0])) {
            // DELETE /api/announcements/{id} - Delete announcement
            $controller->delete($path_parts[0]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint non trouvé'
            ]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'message' => 'Méthode non autorisée'
        ]);
        break;
}
?>
