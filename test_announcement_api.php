<?php
// Test script for announcement API
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Include required files
require_once 'api/announcements/controllers/AnnouncementController.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Simulate announcement data
    $test_data = [
        'title' => 'Test Announcement ' . date('Y-m-d H:i:s'),
        'content' => 'This is a test announcement created via API test',
        'scope' => 'institution',
        'category' => 'general',
        'priority' => 'normal',
        'announcement_type' => 'general',
        'is_published' => true,
        'allow_comments' => true
    ];
    
    // Mock JWT token (you'll need to replace with real token)
    $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer mock_token';
    
    // Create controller and test
    $controller = new AnnouncementController();
    
    // Override input data for testing
    $json_input = json_encode($test_data);
    
    // Temporarily replace php://input
    $backup = file_get_contents('php://input');
    file_put_contents('php://input', $json_input);
    
    try {
        $controller->create();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Test failed: ' . $e->getMessage(),
            'test_data' => $test_data
        ]);
    }
    
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Only POST method allowed'
    ]);
}
?>
