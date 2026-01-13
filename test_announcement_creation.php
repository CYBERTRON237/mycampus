<?php
// Test script for announcement creation API
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'api/config/database.php';
require_once 'api/announcements/models/Announcement.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $database = new Database();
        $conn = $database->getConnection();
        
        // Create announcement object
        $announcement = new Announcement();
        
        // Set test data
        $announcement->institution_id = 1;
        $announcement->author_id = 1;
        $announcement->scope = 'institution';
        $announcement->priority = 'normal';
        $announcement->category = 'general';
        $announcement->announcement_type = 'general';
        $announcement->title = 'Test Announcement ' . date('Y-m-d H:i:s');
        $announcement->content = 'This is a test announcement created via direct API test';
        $announcement->status = 'draft';
        $announcement->allow_comments = true;
        $announcement->is_pinned = false;
        $announcement->is_featured = false;
        $announcement->show_on_homepage = false;
        $announcement->requires_acknowledgment = false;
        $announcement->acknowledgment_count = 0;
        $announcement->views_count = 0;
        $announcement->shares_count = 0;
        $announcement->comments_count = 0;
        
        echo json_encode([
            'success' => true,
            'message' => 'Attempting to create announcement...',
            'data' => [
                'title' => $announcement->title,
                'content' => $announcement->content,
                'scope' => $announcement->scope,
                'category' => $announcement->category,
                'priority' => $announcement->priority
            ]
        ]);
        
        // Try to create
        if ($announcement->create()) {
            echo json_encode([
                'success' => true,
                'message' => 'Announcement created successfully!',
                'announcement_id' => $announcement->id,
                'uuid' => $announcement->uuid
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to create announcement',
                'error_info' => $conn->errorInfo()
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Exception occurred',
            'error' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Only POST method allowed'
    ]);
}
?>
