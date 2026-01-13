<?php
// Test script for groups API
require_once __DIR__ . '/api/config/database.php';
require_once __DIR__ . '/api/messaging/controllers/GroupController.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $controller = new GroupController($db);
    
    // Simulate a user ID for testing
    $_SERVER['HTTP_X_USER_ID'] = '40'; // User ID from the logs
    
    echo "Testing getUserGroups API...\n";
    
    ob_start();
    $controller->getUserGroups();
    $output = ob_get_clean();
    
    echo "Response: " . $output . "\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
