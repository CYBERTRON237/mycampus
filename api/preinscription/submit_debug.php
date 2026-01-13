<?php
// Version debug pour identifier le problème
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    // Log de la requête
    error_log("Méthode: " . $_SERVER['REQUEST_METHOD']);
    error_log("Headers: " . print_r(getallheaders(), true));
    error_log("Input raw: " . file_get_contents('php://input'));
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Méthode non autorisée');
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    error_log("Input parsed: " . print_r($input, true));
    
    if (!$input) {
        throw new Exception('Données JSON invalides');
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Debug réussi',
        'input' => $input,
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
