<?php
header('Content-Type: application/json');
echo json_encode([
    'success' => true,
    'message' => 'Test API works!',
    'uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
    'method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown'
]);
?>
