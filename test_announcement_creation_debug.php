<?php
// Test script for announcement creation
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Include required files
require_once 'api/config/database.php';
require_once 'api/announcements/models/Announcement.php';

try {
    $database = new Database();
    $conn = $database->getConnection();
    
    // Test database connection
    echo json_encode([
        'success' => true,
        'message' => 'Database connection successful',
        'database_info' => [
            'host' => $conn->getAttribute(PDO::ATTR_CONNECTION_STATUS),
            'version' => $conn->getAttribute(PDO::ATTR_SERVER_VERSION)
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed',
        'error' => $e->getMessage()
    ]);
}
?>
