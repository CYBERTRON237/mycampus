<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "Test script started\n";

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

echo "Method: $method\n";
echo "Path: $path\n";
echo "Path parts: " . print_r($pathParts, true) . "\n";

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    echo "Input: " . print_r($input, true) . "\n";
}

echo "Test script ended\n";
?>
