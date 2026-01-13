<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-Id");

// Gérer les requêtes OPTIONS (pre-flight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Router les requêtes
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// Debug: afficher le chemin pour diagnostic
error_log("Messaging API Path: $path");
error_log("Messaging API Path parts: " . json_encode($pathParts));

// Route: /api/messaging/messages/*
if (count($pathParts) >= 4 && $pathParts[1] === 'api' && $pathParts[2] === 'messaging' && $pathParts[3] === 'messages') {
    
    require_once __DIR__ . '/routes/messages_api.php';
    exit;
}

// Route: /api/messaging/groups/*
if (count($pathParts) >= 4 && $pathParts[1] === 'api' && $pathParts[2] === 'messaging' && $pathParts[3] === 'groups') {
    
    require_once __DIR__ . '/routes/groups_api.php';
    exit;
}

// Route: /api/messaging/conversations/*
if (count($pathParts) >= 4 && $pathParts[1] === 'api' && $pathParts[2] === 'messaging' && $pathParts[3] === 'conversations') {
    
    require_once __DIR__ . '/routes/conversations_api.php';
    exit;
}

// Route non trouvée
http_response_code(404);
header('Content-Type: application/json');
echo json_encode([
    'success' => false,
    'message' => 'Route non trouvée',
    'error' => 'route_not_found',
    'path' => $path,
    'path_parts' => $pathParts,
    'expected_patterns' => [
        'api/messaging/messages/*',
        'api/messaging/groups/*',
        'api/messaging/conversations/*'
    ]
]);
?>