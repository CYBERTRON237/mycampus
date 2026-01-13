<?php
// CORS headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get the full request URI and rewrite it properly
$fullUri = $_SERVER['REQUEST_URI'];
$rewrittenUri = str_replace('/api/students', '/api/student_management/students', $fullUri);

// Update server variables
$_SERVER['REQUEST_URI'] = $rewrittenUri;
$_SERVER['SCRIPT_NAME'] = '/api/student_management/students';
$_SERVER['PHP_SELF'] = '/api/student_management/students';

// Override the path parsing by setting a global variable
$_GET['rewritten_path'] = str_replace('/api/students', '/api/student_management/students', parse_url($fullUri, PHP_URL_PATH));

// Include the student_management API
require_once '../student_management/index.php';
?>
