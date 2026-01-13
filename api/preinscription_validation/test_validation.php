<?php
// Test de validation complet
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');

// Test validation
$data = [
    'action' => 'validate',
    'preinscription_id' => 2,
    'admin_id' => 1,
    'comments' => 'Test validation depuis API'
];

$options = [
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode($data)
    ]
];

$context = stream_context_create($options);
$result = file_get_contents('http://127.0.0.1/mycampus/api/preinscription_validation/validation_api_final_working.php', false, $context);

echo $result;
?>
