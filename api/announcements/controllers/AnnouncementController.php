<?php

require_once __DIR__ . '/../models/Announcement.php';
require_once __DIR__ . '/../models/AnnouncementAcknowledgment.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../jwt/jwt_utils.php';

class AnnouncementController {
    private $announcement;
    private $acknowledgment;
    private $db;

    public function __construct() {
        $this->db = (new Database())->getConnection();
        $this->announcement = new Announcement();
        $this->acknowledgment = new AnnouncementAcknowledgment();
    }

    // Get all announcements with filters and pagination
    public function getAll() {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get query parameters
            $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
            $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
            $institution_id = isset($_GET['institution_id']) ? $_GET['institution_id'] : null;
            $scope = isset($_GET['scope']) ? $_GET['scope'] : null;
            $category = isset($_GET['category']) ? $_GET['category'] : null;
            $status = isset($_GET['status']) ? $_GET['status'] : null;
            $priority = isset($_GET['priority']) ? $_GET['priority'] : null;
            $search = isset($_GET['search']) ? $_GET['search'] : null;
            $author_id = isset($_GET['author_id']) ? $_GET['author_id'] : null;
            $published_only = isset($_GET['published_only']) ? filter_var($_GET['published_only'], FILTER_VALIDATE_BOOLEAN) : false;

            // Validate pagination
            $page = max(1, $page);
            $limit = min(100, max(1, $limit)); // Max 100 items per page

            $filters = [
                'institution_id' => $institution_id,
                'scope' => $scope,
                'category' => $category,
                'status' => $status,
                'priority' => $priority,
                'search' => $search,
                'author_id' => $author_id,
                'published_only' => $published_only
            ];

            // Remove null values
            $filters = array_filter($filters, function($value) {
                return $value !== null;
            });

            $result = $this->announcement->getAll($page, $limit, $filters);

            echo json_encode([
                'success' => true,
                'data' => $result['data'],
                'pagination' => $result['pagination'],
                'filters' => [
                    'categories' => $this->announcement->getCategories(),
                    'scopes' => $this->announcement->getScopes(),
                    'priorities' => $this->announcement->getPriorities()
                ]
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Get announcement by ID
    public function getById($id) {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            $announcement = $this->announcement->getById($id);

            if (!$announcement) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Annonce non trouvée'
                ]);
                return;
            }

            // Increment view count
            $this->announcement->incrementViewCount($id);

            echo json_encode([
                'success' => true,
                'data' => $announcement
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Get announcement by UUID
    public function getByUuid($uuid) {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            $announcement = $this->announcement->getByUuid($uuid);

            if (!$announcement) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Annonce non trouvée'
                ]);
                return;
            }

            // Increment view count
            $this->announcement->incrementViewCount($announcement['id']);

            echo json_encode([
                'success' => true,
                'data' => $announcement
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Create new announcement
    public function create() {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: POST");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = JWTUtils::decodeToken($jwt);

            if (!$user_data || !isset($user_data['user_id'])) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Authentification requise'
                ]);
                return;
            }

            // Get JSON data
            $data = json_decode(file_get_contents('php://input'), true);

            // Debug logging
            error_log("Announcement creation - Raw data: " . file_get_contents('php://input'));
            error_log("Announcement creation - Parsed data: " . print_r($data, true));

            if (!$data) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Données invalides'
                ]);
                return;
            }

            // Validate required fields
            if (empty($data['title']) || empty($data['content'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Le titre et le contenu sont obligatoires'
                ]);
                return;
            }

            // Set announcement properties
            $this->announcement->institution_id = $data['institution_id'] ?? $user_data['institution_id'];
            $this->announcement->author_id = $user_data['user_id'];
            $this->announcement->scope = $data['scope'] ?? 'institution';
            $this->announcement->scope_ids = $data['scope_ids'] ?? [];
            $this->announcement->target_audience = $data['target_audience'] ?? [];
            $this->announcement->target_levels = $data['target_levels'] ?? [];
            $this->announcement->priority = $data['priority'] ?? 'normal';
            $this->announcement->category = $data['category'] ?? 'general';
            $this->announcement->announcement_type = $data['announcement_type'] ?? 'general';
            $this->announcement->title = $data['title'];
            $this->announcement->content = $data['content'];
            $this->announcement->excerpt = $data['excerpt'] ?? null;
            $this->announcement->cover_image_url = $data['cover_image_url'] ?? null;
            $this->announcement->attachments = $data['attachments'] ?? [];
            $this->announcement->attachments_url = $data['attachments_url'] ?? null;
            $this->announcement->external_link = $data['external_link'] ?? null;
            $this->announcement->is_pinned = $data['is_pinned'] ?? false;
            $this->announcement->is_featured = $data['is_featured'] ?? false;
            $this->announcement->show_on_homepage = $data['show_on_homepage'] ?? false;
            $this->announcement->requires_acknowledgment = $data['requires_acknowledgment'] ?? false;
            $this->announcement->publish_at = $data['publish_at'] ?? null;
            $this->announcement->expire_at = $data['expire_at'] ?? null;
            $this->announcement->expires_at = $data['expires_at'] ?? null;
            $this->announcement->status = $data['status'] ?? 'draft';
            $this->announcement->allow_comments = $data['allow_comments'] ?? true;
            $this->announcement->tags = $data['tags'] ?? [];
            $this->announcement->metadata = $data['metadata'] ?? [];

            // Auto-publish if status is published and no publish_at is set
            if ($this->announcement->status === 'published' && !$this->announcement->publish_at) {
                $this->announcement->publish_at = date('Y-m-d H:i:s');
            }

            if ($this->announcement->create()) {
                // Get the created announcement
                $created_announcement = $this->announcement->getById($this->announcement->id);

                // Create notifications for targeted users (if published)
                if ($this->announcement->status === 'published') {
                    $this->createNotifications($created_announcement);
                }

                http_response_code(201);
                echo json_encode([
                    'success' => true,
                    'message' => 'Annonce créée avec succès',
                    'data' => $created_announcement
                ]);
            } else {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'message' => 'Erreur lors de la création de l\'annonce'
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Update announcement
    public function update($id) {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: PUT");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = JWTUtils::decodeToken($jwt);

            if (!$user_data || !isset($user_data['user_id'])) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Authentification requise'
                ]);
                return;
            }

            // Check if announcement exists
            $existing_announcement = $this->announcement->getById($id);
            if (!$existing_announcement) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Annonce non trouvée'
                ]);
                return;
            }

            // Check permissions (author or admin)
            if ($existing_announcement['author_id'] != $user_data['user_id'] && !$this->isAdmin($user_data)) {
                http_response_code(403);
                echo json_encode([
                    'success' => false,
                    'message' => 'Permission refusée'
                ]);
                return;
            }

            // Get JSON data
            $data = json_decode(file_get_contents('php://input'), true);

            if (!$data) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Données invalides'
                ]);
                return;
            }

            // Update announcement properties
            $this->announcement->id = $id;
            $this->announcement->institution_id = $data['institution_id'] ?? $existing_announcement['institution_id'];
            $this->announcement->scope = $data['scope'] ?? $existing_announcement['scope'];
            $this->announcement->scope_ids = $data['scope_ids'] ?? $existing_announcement['scope_ids'];
            $this->announcement->target_audience = $data['target_audience'] ?? $existing_announcement['target_audience'];
            $this->announcement->target_levels = $data['target_levels'] ?? $existing_announcement['target_levels'];
            $this->announcement->priority = $data['priority'] ?? $existing_announcement['priority'];
            $this->announcement->category = $data['category'] ?? $existing_announcement['category'];
            $this->announcement->announcement_type = $data['announcement_type'] ?? $existing_announcement['announcement_type'];
            $this->announcement->title = $data['title'] ?? $existing_announcement['title'];
            $this->announcement->content = $data['content'] ?? $existing_announcement['content'];
            $this->announcement->excerpt = $data['excerpt'] ?? $existing_announcement['excerpt'];
            $this->announcement->cover_image_url = $data['cover_image_url'] ?? $existing_announcement['cover_image_url'];
            $this->announcement->attachments = $data['attachments'] ?? $existing_announcement['attachments'];
            $this->announcement->attachments_url = $data['attachments_url'] ?? $existing_announcement['attachments_url'];
            $this->announcement->external_link = $data['external_link'] ?? $existing_announcement['external_link'];
            $this->announcement->is_pinned = $data['is_pinned'] ?? $existing_announcement['is_pinned'];
            $this->announcement->is_featured = $data['is_featured'] ?? $existing_announcement['is_featured'];
            $this->announcement->show_on_homepage = $data['show_on_homepage'] ?? $existing_announcement['show_on_homepage'];
            $this->announcement->requires_acknowledgment = $data['requires_acknowledgment'] ?? $existing_announcement['requires_acknowledgment'];
            $this->announcement->publish_at = $data['publish_at'] ?? $existing_announcement['publish_at'];
            $this->announcement->expire_at = $data['expire_at'] ?? $existing_announcement['expire_at'];
            $this->announcement->expires_at = $data['expires_at'] ?? $existing_announcement['expires_at'];
            $this->announcement->status = $data['status'] ?? $existing_announcement['status'];
            $this->announcement->allow_comments = $data['allow_comments'] ?? $existing_announcement['allow_comments'];
            $this->announcement->tags = $data['tags'] ?? $existing_announcement['tags'];
            $this->announcement->metadata = $data['metadata'] ?? $existing_announcement['metadata'];

            // Auto-publish if status is published and no publish_at is set
            if ($this->announcement->status === 'published' && !$this->announcement->publish_at) {
                $this->announcement->publish_at = date('Y-m-d H:i:s');
            }

            if ($this->announcement->update()) {
                // Get the updated announcement
                $updated_announcement = $this->announcement->getById($id);

                // Create notifications if newly published
                if ($existing_announcement['status'] !== 'published' && $this->announcement->status === 'published') {
                    $this->createNotifications($updated_announcement);
                }

                echo json_encode([
                    'success' => true,
                    'message' => 'Annonce mise à jour avec succès',
                    'data' => $updated_announcement
                ]);
            } else {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'message' => 'Erreur lors de la mise à jour de l\'annonce'
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Delete announcement
    public function delete($id) {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: DELETE");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = JWTUtils::decodeToken($jwt);

            if (!$user_data || !isset($user_data['user_id'])) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Authentification requise'
                ]);
                return;
            }

            // Check if announcement exists
            $existing_announcement = $this->announcement->getById($id);
            if (!$existing_announcement) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Annonce non trouvée'
                ]);
                return;
            }

            // Check permissions (author or admin)
            if ($existing_announcement['author_id'] != $user_data['user_id'] && !$this->isAdmin($user_data)) {
                http_response_code(403);
                echo json_encode([
                    'success' => false,
                    'message' => 'Permission refusée'
                ]);
                return;
            }

            $this->announcement->id = $id;

            if ($this->announcement->delete()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Annonce supprimée avec succès'
                ]);
            } else {
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'message' => 'Erreur lors de la suppression de l\'annonce'
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Get announcements for current user
    public function getForUser() {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = JWTUtils::decodeToken($jwt);

            if (!$user_data || !isset($user_data['user_id'])) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Authentification requise'
                ]);
                return;
            }

            // Get query parameters
            $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
            $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;

            // Validate pagination
            $page = max(1, $page);
            $limit = min(100, max(1, $limit));

            $result = $this->announcement->getForUser($user_data['user_id'], $page, $limit);

            echo json_encode([
                'success' => true,
                'data' => $result['data'],
                'pagination' => $result['pagination']
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Get statistics
    public function getStatistics() {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user (optional for public stats)
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = null;
            $institution_id = null;

            if (!empty($jwt)) {
                $user_data = JWTUtils::decodeToken($jwt);
                if ($user_data && isset($user_data['user_id'])) {
                    $institution_id = isset($_GET['institution_id']) ? $_GET['institution_id'] : $user_data['institution_id'];
                }
            }

            // If no auth or invalid token, get public statistics (all institutions)
            if (!$user_data || !isset($user_data['user_id'])) {
                $institution_id = isset($_GET['institution_id']) ? $_GET['institution_id'] : null;
            }

            $stats = $this->announcement->getStatistics($institution_id);

            echo json_encode([
                'success' => true,
                'data' => $stats
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Acknowledge announcement
    public function acknowledge($id) {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: POST");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = JWTUtils::decodeToken($jwt);

            if (!$user_data || !isset($user_data['user_id'])) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Authentification requise'
                ]);
                return;
            }

            // Check if announcement exists and requires acknowledgment
            $announcement = $this->announcement->getById($id);
            if (!$announcement) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Annonce non trouvée'
                ]);
                return;
            }

            if (!$announcement['requires_acknowledgment']) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Cette annonce ne requiert pas d\'accusé de réception'
                ]);
                return;
            }

            // Create acknowledgment
            $this->acknowledgment->announcement_id = $id;
            $this->acknowledgment->user_id = $user_data['user_id'];
            $this->acknowledgment->ip_address = $_SERVER['REMOTE_ADDR'] ?? null;
            $this->acknowledgment->user_agent = $_SERVER['HTTP_USER_AGENT'] ?? null;

            if ($this->acknowledgment->create()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Annonce accusée avec succès'
                ]);
            } else {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Déjà accusée ou erreur lors de l\'accusé de réception'
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Get pending acknowledgments for user
    public function getPendingAcknowledgments() {
        header("Content-Type: application/json");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        try {
            // Get auth user
            $auth_header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            $jwt = str_replace('Bearer ', '', $auth_header);
            $user_data = JWTUtils::decodeToken($jwt);

            if (!$user_data || !isset($user_data['user_id'])) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Authentification requise'
                ]);
                return;
            }

            $pending = $this->acknowledgment->getPendingAcknowledgments($user_data['user_id']);

            echo json_encode([
                'success' => true,
                'data' => $pending,
                'count' => count($pending)
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ]);
        }
    }

    // Helper methods
    private function isAdmin($user_data) {
        $admin_roles = ['admin', 'superadmin', 'admin_local', 'admin_national'];
        return in_array($user_data['role'] ?? '', $admin_roles);
    }

    private function createNotifications($announcement) {
        // This would integrate with the notifications system
        // For now, we'll just log that notifications should be created
        error_log("Should create notifications for announcement: " . $announcement['id']);
    }
}
?>
