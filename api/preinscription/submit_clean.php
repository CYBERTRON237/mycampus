<?php
// Désactiver TOUTE sortie avant les headers
ob_start();
error_reporting(E_ALL);
ini_set('display_errors', 0); // Désactiver l'affichage des erreurs

// Headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    // Vider le buffer de sortie pour s'assurer qu'il n'y a pas de contenu HTML
    ob_clean();
    
    // Test simple
    echo json_encode([
        'success' => true,
        'message' => 'Test simple réussi',
        'method' => $_SERVER['REQUEST_METHOD'],
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    
} catch (Exception $e) {
    ob_clean();
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}

ob_end_flush();
?>
