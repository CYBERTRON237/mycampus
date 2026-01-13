<?php
// Test script for announcement creation without authentication (for debugging)
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
        
        // Get JSON data
        $data = json_decode(file_get_contents('php://input'), true);
        
        error_log("Test - Raw input: " . file_get_contents('php://input'));
        error_log("Test - Parsed data: " . print_r($data, true));
        
        if (!$data) {
            echo json_encode([
                'success' => false,
                'message' => 'Données invalides'
            ]);
            return;
        }
        
        // Validate required fields
        if (empty($data['title']) || empty($data['content'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Le titre et le contenu sont obligatoires'
            ]);
            return;
        }
        
        // Create announcement object
        $announcement = new Announcement();
        
        // Set announcement properties (mock user_id = 1)
        $announcement->institution_id = $data['institution_id'] ?? 1;
        $announcement->author_id = 1; // Mock user ID
        $announcement->scope = $data['scope'] ?? 'institution';
        $announcement->scope_ids = $data['scope_ids'] ?? [];
        $announcement->target_audience = $data['target_audience'] ?? [];
        $announcement->target_levels = $data['target_levels'] ?? [];
        $announcement->priority = $data['priority'] ?? 'normal';
        $announcement->category = $data['category'] ?? 'general';
        $announcement->announcement_type = $data['announcement_type'] ?? 'general';
        $announcement->title = $data['title'];
        $announcement->content = $data['content'];
        $announcement->excerpt = $data['excerpt'] ?? null;
        $announcement->cover_image_url = $data['cover_image_url'] ?? null;
        $announcement->attachments = $data['attachments'] ?? [];
        $announcement->attachments_url = $data['attachments_url'] ?? null;
        $announcement->external_link = $data['external_link'] ?? null;
        $announcement->is_pinned = $data['is_pinned'] ?? false;
        $announcement->is_featured = $data['is_featured'] ?? false;
        $announcement->show_on_homepage = $data['show_on_homepage'] ?? false;
        $announcement->requires_acknowledgment = $data['requires_acknowledgment'] ?? false;
        $announcement->publish_at = $data['publish_at'] ?? null;
        $announcement->expire_at = $data['expire_at'] ?? null;
        $announcement->expires_at = $data['expires_at'] ?? null;
        $announcement->status = $data['status'] ?? 'draft';
        $announcement->allow_comments = $data['allow_comments'] ?? true;
        $announcement->tags = $data['tags'] ?? [];
        $announcement->metadata = $data['metadata'] ?? [];

        // Auto-publish if status is published and no publish_at is set
        if ($announcement->status === 'published' && !$announcement->publish_at) {
            $announcement->publish_at = date('Y-m-d H:i:s');
        }

        if ($announcement->create()) {
            // Get the created announcement
            $created_announcement = $announcement->getById($announcement->id);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Annonce créée avec succès (test sans auth)',
                'data' => $created_announcement
            ]);
        } else {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la création de l\'annonce',
                'error' => $conn->errorInfo()
            ]);
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Exception: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Only POST method allowed'
    ]);
}
?>
