<?php

require_once __DIR__ . '/../../config/database.php';

class Announcement {
    private $conn;
    private $table = 'announcements';

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Properties
    public $id;
    public $uuid;
    public $institution_id;
    public $author_id;
    public $published_by;
    public $scope;
    public $scope_ids;
    public $target_audience;
    public $target_levels;
    public $priority;
    public $category;
    public $announcement_type;
    public $title;
    public $content;
    public $excerpt;
    public $cover_image_url;
    public $attachments;
    public $attachments_url;
    public $external_link;
    public $is_pinned;
    public $is_featured;
    public $show_on_homepage;
    public $requires_acknowledgment;
    public $acknowledgment_count;
    public $publish_at;
    public $published_at;
    public $expire_at;
    public $expires_at;
    public $status;
    public $views_count;
    public $shares_count;
    public $comments_count;
    public $allow_comments;
    public $tags;
    public $metadata;
    public $archived_at;
    public $deleted_at;
    public $created_at;
    public $updated_at;

    // Get all announcements with filters and pagination
    public function getAll($page = 1, $limit = 20, $filters = []) {
        $offset = ($page - 1) * $limit;
        
        $where_conditions = ["a.deleted_at IS NULL"];
        $params = [];

        // Filter by institution
        if (!empty($filters['institution_id'])) {
            $where_conditions[] = "a.institution_id = :institution_id";
            $params[':institution_id'] = $filters['institution_id'];
        }

        // Filter by scope
        if (!empty($filters['scope'])) {
            $where_conditions[] = "a.scope = :scope";
            $params[':scope'] = $filters['scope'];
        }

        // Filter by category
        if (!empty($filters['category'])) {
            $where_conditions[] = "a.category = :category";
            $params[':category'] = $filters['category'];
        }

        // Filter by status
        if (!empty($filters['status'])) {
            $where_conditions[] = "a.status = :status";
            $params[':status'] = $filters['status'];
        }

        // Filter by priority
        if (!empty($filters['priority'])) {
            $where_conditions[] = "a.priority = :priority";
            $params[':priority'] = $filters['priority'];
        }

        // Search in title and content
        if (!empty($filters['search'])) {
            $where_conditions[] = "(a.title LIKE :search OR a.content LIKE :search)";
            $params[':search'] = '%' . $filters['search'] . '%';
        }

        // Filter by author
        if (!empty($filters['author_id'])) {
            $where_conditions[] = "a.author_id = :author_id";
            $params[':author_id'] = $filters['author_id'];
        }

        // Only published announcements for regular users
        if (!empty($filters['published_only'])) {
            $where_conditions[] = "a.status = 'published'";
            $where_conditions[] = "(a.published_at IS NOT NULL AND a.published_at <= NOW())";
            $where_conditions[] = "(a.expires_at IS NULL OR a.expires_at > NOW())";
        }

        $where_clause = implode(" AND ", $where_conditions);

        // Count query
        $count_query = "SELECT COUNT(*) as total FROM {$this->table} a WHERE {$where_clause}";
        $count_stmt = $this->conn->prepare($count_query);
        foreach ($params as $key => $value) {
            $count_stmt->bindValue($key, $value);
        }
        $count_stmt->execute();
        $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];

        // Main query with joins
        $query = "SELECT a.*, 
                    u.first_name, u.last_name, u.email as author_email,
                    i.name as institution_name,
                    CONCAT(u.first_name, ' ', u.last_name) as author_name
                  FROM {$this->table} a
                  LEFT JOIN users u ON a.author_id = u.id
                  LEFT JOIN institutions i ON a.institution_id = i.id
                  WHERE {$where_clause}
                  ORDER BY a.is_pinned DESC, a.priority DESC, a.published_at DESC, a.created_at DESC
                  LIMIT :limit OFFSET :offset";

        $stmt = $this->conn->prepare($query);
        
        // Bind parameters
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        
        $stmt->execute();

        $announcements = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Decode JSON fields
            $row['scope_ids'] = json_decode($row['scope_ids'] ?? '[]', true);
            $row['target_audience'] = json_decode($row['target_audience'] ?? '[]', true);
            $row['target_levels'] = json_decode($row['target_levels'] ?? '[]', true);
            $row['attachments'] = json_decode($row['attachments'] ?? '[]', true);
            $row['tags'] = json_decode($row['tags'] ?? '[]', true);
            $row['metadata'] = json_decode($row['metadata'] ?? '[]', true);
            
            $announcements[] = $row;
        }

        return [
            'data' => $announcements,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit)
            ]
        ];
    }

    // Get announcement by ID
    public function getById($id) {
        $query = "SELECT a.*, 
                    u.first_name, u.last_name, u.email as author_email,
                    i.name as institution_name,
                    CONCAT(u.first_name, ' ', u.last_name) as author_name
                  FROM {$this->table} a
                  LEFT JOIN users u ON a.author_id = u.id
                  LEFT JOIN institutions i ON a.institution_id = i.id
                  WHERE a.id = :id AND a.deleted_at IS NULL";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        $announcement = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($announcement) {
            // Decode JSON fields
            $announcement['scope_ids'] = json_decode($announcement['scope_ids'] ?? '[]', true);
            $announcement['target_audience'] = json_decode($announcement['target_audience'] ?? '[]', true);
            $announcement['target_levels'] = json_decode($announcement['target_levels'] ?? '[]', true);
            $announcement['attachments'] = json_decode($announcement['attachments'] ?? '[]', true);
            $announcement['tags'] = json_decode($announcement['tags'] ?? '[]', true);
            $announcement['metadata'] = json_decode($announcement['metadata'] ?? '[]', true);
        }

        return $announcement;
    }

    // Get announcement by UUID
    public function getByUuid($uuid) {
        $query = "SELECT a.*, 
                    u.first_name, u.last_name, u.email as author_email,
                    i.name as institution_name,
                    CONCAT(u.first_name, ' ', u.last_name) as author_name
                  FROM {$this->table} a
                  LEFT JOIN users u ON a.author_id = u.id
                  LEFT JOIN institutions i ON a.institution_id = i.id
                  WHERE a.uuid = :uuid AND a.deleted_at IS NULL";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uuid', $uuid);
        $stmt->execute();

        $announcement = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($announcement) {
            // Decode JSON fields
            $announcement['scope_ids'] = json_decode($announcement['scope_ids'] ?? '[]', true);
            $announcement['target_audience'] = json_decode($announcement['target_audience'] ?? '[]', true);
            $announcement['target_levels'] = json_decode($announcement['target_levels'] ?? '[]', true);
            $announcement['attachments'] = json_decode($announcement['attachments'] ?? '[]', true);
            $announcement['tags'] = json_decode($announcement['tags'] ?? '[]', true);
            $announcement['metadata'] = json_decode($announcement['metadata'] ?? '[]', true);
        }

        return $announcement;
    }

    // Create new announcement
    public function create() {
        $query = "INSERT INTO {$this->table} (
            uuid, institution_id, author_id, scope, scope_ids, target_audience, target_levels,
            priority, category, announcement_type, title, content, excerpt, cover_image_url,
            attachments, attachments_url, external_link, is_pinned, is_featured, show_on_homepage,
            requires_acknowledgment, publish_at, expire_at, expires_at, status, allow_comments, tags, metadata
        ) VALUES (
            :uuid, :institution_id, :author_id, :scope, :scope_ids, :target_audience, :target_levels,
            :priority, :category, :announcement_type, :title, :content, :excerpt, :cover_image_url,
            :attachments, :attachments_url, :external_link, :is_pinned, :is_featured, :show_on_homepage,
            :requires_acknowledgment, :publish_at, :expire_at, :expires_at, :status, :allow_comments, :tags, :metadata
        )";

        $stmt = $this->conn->prepare($query);

        // Generate UUID
        $this->uuid = $this->generateUuid();

        // Sanitize and bind values
        $stmt->bindParam(':uuid', $this->uuid);
        $stmt->bindParam(':institution_id', $this->institution_id);
        $stmt->bindParam(':author_id', $this->author_id);
        $stmt->bindParam(':scope', $this->scope);
        
        $scope_ids_json = json_encode($this->scope_ids ?? []);
        $stmt->bindParam(':scope_ids', $scope_ids_json);
        
        $target_audience_json = json_encode($this->target_audience ?? []);
        $stmt->bindParam(':target_audience', $target_audience_json);
        
        $target_levels_json = json_encode($this->target_levels ?? []);
        $stmt->bindParam(':target_levels', $target_levels_json);
        
        $stmt->bindParam(':priority', $this->priority);
        $stmt->bindParam(':category', $this->category);
        $stmt->bindParam(':announcement_type', $this->announcement_type);
        $stmt->bindParam(':title', $this->title);
        $stmt->bindParam(':content', $this->content);
        $stmt->bindParam(':excerpt', $this->excerpt);
        $stmt->bindParam(':cover_image_url', $this->cover_image_url);
        
        $attachments_json = json_encode($this->attachments ?? []);
        $stmt->bindParam(':attachments', $attachments_json);
        
        $stmt->bindParam(':attachments_url', $this->attachments_url);
        $stmt->bindParam(':external_link', $this->external_link);
        $stmt->bindParam(':is_pinned', $this->is_pinned);
        $stmt->bindParam(':is_featured', $this->is_featured);
        $stmt->bindParam(':show_on_homepage', $this->show_on_homepage);
        $stmt->bindParam(':requires_acknowledgment', $this->requires_acknowledgment);
        $stmt->bindParam(':publish_at', $this->publish_at);
        $stmt->bindParam(':expire_at', $this->expire_at);
        $stmt->bindParam(':expires_at', $this->expires_at);
        $stmt->bindParam(':status', $this->status);
        $stmt->bindParam(':allow_comments', $this->allow_comments);
        
        $tags_json = json_encode($this->tags ?? []);
        $stmt->bindParam(':tags', $tags_json);
        
        $metadata_json = json_encode($this->metadata ?? []);
        $stmt->bindParam(':metadata', $metadata_json);

        if ($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            error_log("Announcement created successfully with ID: " . $this->id);
            return true;
        } else {
            error_log("Announcement creation failed. SQL error: " . print_r($stmt->errorInfo(), true));
        }
        return false;
    }

    // Update announcement
    public function update() {
        $query = "UPDATE {$this->table} SET
            institution_id = :institution_id,
            scope = :scope,
            scope_ids = :scope_ids,
            target_audience = :target_audience,
            target_levels = :target_levels,
            priority = :priority,
            category = :category,
            announcement_type = :announcement_type,
            title = :title,
            content = :content,
            excerpt = :excerpt,
            cover_image_url = :cover_image_url,
            attachments = :attachments,
            attachments_url = :attachments_url,
            external_link = :external_link,
            is_pinned = :is_pinned,
            is_featured = :is_featured,
            show_on_homepage = :show_on_homepage,
            requires_acknowledgment = :requires_acknowledgment,
            publish_at = :publish_at,
            expire_at = :expire_at,
            expires_at = :expires_at,
            status = :status,
            allow_comments = :allow_comments,
            tags = :tags,
            metadata = :metadata,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        // Bind values
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':institution_id', $this->institution_id);
        $stmt->bindParam(':scope', $this->scope);
        
        $scope_ids_json = json_encode($this->scope_ids ?? []);
        $stmt->bindParam(':scope_ids', $scope_ids_json);
        
        $target_audience_json = json_encode($this->target_audience ?? []);
        $stmt->bindParam(':target_audience', $target_audience_json);
        
        $target_levels_json = json_encode($this->target_levels ?? []);
        $stmt->bindParam(':target_levels', $target_levels_json);
        
        $stmt->bindParam(':priority', $this->priority);
        $stmt->bindParam(':category', $this->category);
        $stmt->bindParam(':announcement_type', $this->announcement_type);
        $stmt->bindParam(':title', $this->title);
        $stmt->bindParam(':content', $this->content);
        $stmt->bindParam(':excerpt', $this->excerpt);
        $stmt->bindParam(':cover_image_url', $this->cover_image_url);
        
        $attachments_json = json_encode($this->attachments ?? []);
        $stmt->bindParam(':attachments', $attachments_json);
        
        $stmt->bindParam(':attachments_url', $this->attachments_url);
        $stmt->bindParam(':external_link', $this->external_link);
        $stmt->bindParam(':is_pinned', $this->is_pinned);
        $stmt->bindParam(':is_featured', $this->is_featured);
        $stmt->bindParam(':show_on_homepage', $this->show_on_homepage);
        $stmt->bindParam(':requires_acknowledgment', $this->requires_acknowledgment);
        $stmt->bindParam(':publish_at', $this->publish_at);
        $stmt->bindParam(':expire_at', $this->expire_at);
        $stmt->bindParam(':expires_at', $this->expires_at);
        $stmt->bindParam(':status', $this->status);
        $stmt->bindParam(':allow_comments', $this->allow_comments);
        
        $tags_json = json_encode($this->tags ?? []);
        $stmt->bindParam(':tags', $tags_json);
        
        $metadata_json = json_encode($this->metadata ?? []);
        $stmt->bindParam(':metadata', $metadata_json);

        return $stmt->execute();
    }

    // Delete announcement (soft delete)
    public function delete() {
        $query = "UPDATE {$this->table} SET deleted_at = CURRENT_TIMESTAMP WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        return $stmt->execute();
    }

    // Get statistics
    public function getStatistics($institution_id = null) {
        $where_clause = $institution_id ? "WHERE institution_id = :institution_id AND deleted_at IS NULL" : "WHERE deleted_at IS NULL";
        $params = $institution_id ? [':institution_id' => $institution_id] : [];

        $query = "SELECT 
                    COUNT(*) as total,
                    COUNT(CASE WHEN status = 'published' THEN 1 END) as published,
                    COUNT(CASE WHEN status = 'draft' THEN 1 END) as draft,
                    COUNT(CASE WHEN status = 'scheduled' THEN 1 END) as scheduled,
                    COUNT(CASE WHEN is_pinned = 1 THEN 1 END) as pinned,
                    COUNT(CASE WHEN requires_acknowledgment = 1 THEN 1 END) as requires_ack,
                    COUNT(CASE WHEN expires_at <= NOW() AND status = 'published' THEN 1 END) as expired
                  FROM {$this->table} {$where_clause}";

        $stmt = $this->conn->prepare($query);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Get announcements for user (based on their profile)
    public function getForUser($user_id, $page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;

        // Get user information
        $user_query = "SELECT u.institution_id, u.department_id, u.role, 
                       sp.program_id, sp.faculty_id
                       FROM users u
                       LEFT JOIN student_profiles sp ON u.id = sp.user_id
                       WHERE u.id = :user_id AND u.deleted_at IS NULL";
        
        $user_stmt = $this->conn->prepare($user_query);
        $user_stmt->bindParam(':user_id', $user_id);
        $user_stmt->execute();
        $user_info = $user_stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user_info) {
            return ['data' => [], 'pagination' => ['page' => $page, 'limit' => $limit, 'total' => 0, 'total_pages' => 0]];
        }

        $where_conditions = [
            "a.deleted_at IS NULL",
            "a.status = 'published'",
            "(a.published_at IS NOT NULL AND a.published_at <= NOW())",
            "(a.expires_at IS NULL OR a.expires_at > NOW())"
        ];

        // Scope conditions
        $scope_conditions = [];
        
        // Institution scope
        $scope_conditions[] = "(a.scope = 'institution' AND a.institution_id = " . $user_info['institution_id'] . ")";
        
        // National scope (always visible)
        $scope_conditions[] = "a.scope = 'national'";
        
        // Faculty scope
        if ($user_info['faculty_id']) {
            $scope_conditions[] = "(a.scope = 'faculty' AND JSON_CONTAINS(a.scope_ids, '" . $user_info['faculty_id'] . "'))";
        }
        
        // Department scope
        if ($user_info['department_id']) {
            $scope_conditions[] = "(a.scope = 'department' AND JSON_CONTAINS(a.scope_ids, '" . $user_info['department_id'] . "'))";
        }
        
        // Program scope
        if ($user_info['program_id']) {
            $scope_conditions[] = "(a.scope = 'program' AND JSON_CONTAINS(a.scope_ids, '" . $user_info['program_id'] . "'))";
        }

        $where_conditions[] = "(" . implode(" OR ", $scope_conditions) . ")";

        $where_clause = implode(" AND ", $where_conditions);

        // Count query
        $count_query = "SELECT COUNT(*) as total FROM {$this->table} a WHERE {$where_clause}";
        $count_stmt = $this->conn->prepare($count_query);
        $count_stmt->execute();
        $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];

        // Main query
        $query = "SELECT a.*, 
                    u.first_name, u.last_name, u.email as author_email,
                    i.name as institution_name,
                    CONCAT(u.first_name, ' ', u.last_name) as author_name
                  FROM {$this->table} a
                  LEFT JOIN users u ON a.author_id = u.id
                  LEFT JOIN institutions i ON a.institution_id = i.id
                  WHERE {$where_clause}
                  ORDER BY a.is_pinned DESC, a.priority DESC, a.published_at DESC
                  LIMIT :limit OFFSET :offset";

        $stmt = $this->conn->prepare($query);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        $announcements = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Decode JSON fields
            $row['scope_ids'] = json_decode($row['scope_ids'] ?? '[]', true);
            $row['target_audience'] = json_decode($row['target_audience'] ?? '[]', true);
            $row['target_levels'] = json_decode($row['target_levels'] ?? '[]', true);
            $row['attachments'] = json_decode($row['attachments'] ?? '[]', true);
            $row['tags'] = json_decode($row['tags'] ?? '[]', true);
            $row['metadata'] = json_decode($row['metadata'] ?? '[]', true);
            
            $announcements[] = $row;
        }

        return [
            'data' => $announcements,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit)
            ]
        ];
    }

    // Generate UUID
    private function generateUuid() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    // Increment view count
    public function incrementViewCount($id) {
        $query = "UPDATE {$this->table} SET views_count = views_count + 1 WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        return $stmt->execute();
    }

    // Get categories list
    public function getCategories() {
        return [
            'academic' => 'Académique',
            'administrative' => 'Administratif', 
            'event' => 'Événement',
            'exam' => 'Examen',
            'registration' => 'Inscription',
            'scholarship' => 'Bourse',
            'alert' => 'Alerte',
            'general' => 'Général',
            'emergency' => 'Urgence',
            'urgent' => 'Urgent'
        ];
    }

    // Get scopes list
    public function getScopes() {
        return [
            'institution' => 'Institution',
            'local' => 'Local',
            'faculty' => 'Faculté',
            'department' => 'Département',
            'program' => 'Programme/Filière',
            'national' => 'National',
            'inter_university' => 'Inter-universitaire',
            'multi_institutions' => 'Multi-institutions'
        ];
    }

    // Get priorities list
    public function getPriorities() {
        return [
            'low' => 'Faible',
            'normal' => 'Normal',
            'high' => 'Élevé',
            'urgent' => 'Urgent',
            'critical' => 'Critique'
        ];
    }
}
?>
