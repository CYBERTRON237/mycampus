<?php
// Test simple pour l'API groups

header('Content-Type: application/json');

// Simuler l'appel à l'API
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/mycampus/api/messaging/groups/my';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NjU3NjUxODQsImV4cCI6MTc2NTg1MTU4NCwiaXNzIjoibXljYW1wdXMiLCJkYXRhIjp7ImlkIjozOCwiZW1haWwiOiJqamtrQGdtYWlsLmNvbSIsImlwIjoiMTI3LjAuMC4xIn19.-TmBvxC4k4sdfrXqrhuYD-fmvMsPCe-EX63EonwLDV8';

echo "Test de l'API groups...\n";

try {
    // Inclure le fichier de routage
    require_once __DIR__ . '/api/messaging/index.php';
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
