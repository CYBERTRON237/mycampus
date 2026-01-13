<?php
// Test script to debug path parsing
$request_uri = $_SERVER['REQUEST_URI'];
error_log("DEBUG: Raw request_uri = " . $request_uri);

// Simulate main index.php logic
$base_path = '/mycampus/api';
$request_uri_clean = str_replace($base_path, '', $request_uri);
error_log("DEBUG: Clean URI = " . $request_uri_clean);

echo json_encode([
    'raw_uri' => $request_uri,
    'clean_uri' => $request_uri_clean,
    'starts_with_announcements' => strpos($request_uri_clean, '/announcements/') === 0
]);
?>
