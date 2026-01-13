<?php

// Version simplifiée pour tester
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo json_encode([
    'success' => true,
    'message' => 'API Student Management fonctionne',
    'debug' => [
        'request_uri' => $_SERVER['REQUEST_URI'] ?? 'not set',
        'method' => $_SERVER['REQUEST_METHOD'] ?? 'not set',
        'path_info' => $_SERVER['PATH_INFO'] ?? 'not set'
    ]
]);
?>
