<?php
// Version simplifiée pour déboguer le logging

// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-ID");
header("Content-Type: application/json");

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Fonction de logging simplifiée
function logPreinscriptionError($message, $error = null, $context = []) {
    $logFile = __DIR__ . '/../logs/preinscriptions_errors.log';
    $timestamp = date('Y-m-d H:i:s');
    $contextStr = !empty($context) ? ' | Context: ' . json_encode($context) : '';
    $errorStr = $error ? " | Error: $error" : '';
    $logEntry = "[$timestamp] $message$errorStr$contextStr" . PHP_EOL;
    
    // Écrire dans le fichier de log
    file_put_contents($logFile, $logEntry, FILE_APPEND);
    
    // Aussi logger dans les erreurs PHP
    error_log("PREINSCRIPTIONS: $message$errorStr$contextStr");
}

// Logger la requête
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

logPreinscriptionError('Requête debug_simple', null, [
    'method' => $method,
    'path' => $path,
    'pathParts' => $pathParts,
    'user_id' => $_SERVER['HTTP_X_USER_ID'] ?? null
]);

// Simuler une réponse
echo json_encode([
    'success' => true,
    'message' => 'Debug simple fonctionne',
    'method' => $method,
    'path' => $path,
    'pathParts' => $pathParts
]);

?>
