<?php
// Test script for the full REST API with authentication
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'api/announcements/controllers/AnnouncementController.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Test data
    $test_data = [
        'title' => 'REST API Test Announcement ' . date('Y-m-d H:i:s'),
        'content' => 'This is a test announcement created via REST API test',
        'scope' => 'institution',
        'category' => 'general',
        'priority' => 'normal',
        'announcement_type' => 'general',
        'is_published' => false,
        'allow_comments' => true,
        'is_pinned' => false,
        'is_featured' => false,
        'show_on_homepage' => false,
        'requires_acknowledgment' => false
    ];
    
    // Mock a simple JWT token for testing (in real app, this would be proper authentication)
    $mock_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJpbnN0aXR1dGlvbl9pZCI6MSwicm9sZSI6ImFkbWluIiwiaWF0IjoxNjM0NTY3ODAwLCJleHAiOjE2MzQ2NTQyMDB9.test';
    
    // Set the authorization header
    $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $mock_token;
    
    // Override php://input with test data
    $json_input = json_encode($test_data);
    file_put_contents('php://input', $json_input);
    
    echo json_encode([
        'success' => true,
        'message' => 'Testing REST API with authentication',
        'test_data' => $test_data,
        'auth_header' => $_SERVER['HTTP_AUTHORIZATION']
    ]);
    
    // Create controller and call create method
    $controller = new AnnouncementController();
    
    try {
        $controller->create();
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'REST API test failed',
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
    }
    
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Only POST method allowed for REST API test'
    ]);
}
?>
