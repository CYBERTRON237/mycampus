<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "Test de parsing d'URL<br>";

$request_uri = '/mycampus/api/universities/1';
echo "Request URI: $request_uri<br>";

$base_path = '/mycampus/api';
$clean_uri = str_replace($base_path, '', $request_uri);
echo "Clean URI: $clean_uri<br>";

$pathParts = explode('/', trim($clean_uri, '/'));
echo "Path parts: ";
print_r($pathParts);

$id = $pathParts[2] ?? null;
echo "ID: $id<br>";
echo "Is numeric: " . (is_numeric($id) ? 'true' : 'false') . "<br>";
?>
