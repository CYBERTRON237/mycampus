<?php
header("Content-Type: application/json");

echo json_encode([
    'success' => true,
    'message' => 'Test simple fonctionne',
    'method' => $_SERVER['REQUEST_METHOD'],
    'input' => json_decode(file_get_contents('php://input'), true)
]);
?>
