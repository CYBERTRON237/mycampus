<?php
// Test script that simulates exactly what Flutter sends
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'api/announcements/controllers/AnnouncementController.php';

// Get the actual data that Flutter would send
$flutter_data = [
    'title' => 'Flutter Test Announcement ' . date('Y-m-d H:i:s'),
    'content' => 'This is a test announcement from Flutter simulation',
    'scope' => 'institution',  // This is what Flutter sends (string)
    'category' => 'general',    // This is what Flutter sends (string)
    'priority' => 'normal',    // This is what Flutter sends (string)
    'announcement_type' => 'general',
    'is_published' => false,
    'allow_comments' => true,
    'send_notification' => false
];

// Log what we're sending
error_log("Flutter simulation - Data being sent: " . json_encode($flutter_data));

// Override php://input with Flutter data
$json_input = json_encode($flutter_data);
file_put_contents('php://input', $json_input);

echo json_encode([
    'success' => true,
    'message' => 'Simulating Flutter request',
    'flutter_data' => $flutter_data,
    'raw_input' => $json_input
]);

// Create controller and test
$controller = new AnnouncementController();

try {
    // Temporarily bypass authentication for testing
    // In real scenario, Flutter would send a valid JWT token
    
    // Mock authentication by setting session variables
    $_SESSION['user_id'] = 1;
    $_SESSION['institution_id'] = 1;
    
    $controller->create();
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Flutter simulation failed',
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
