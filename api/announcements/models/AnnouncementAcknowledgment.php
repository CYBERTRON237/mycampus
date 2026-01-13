<?php

require_once __DIR__ . '/../../config/database.php';

class AnnouncementAcknowledgment {
    private $conn;
    private $table = 'announcement_acknowledgments';

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Properties
    public $id;
    public $announcement_id;
    public $user_id;
    public $acknowledged_at;
    public $ip_address;
    public $user_agent;

    // Create acknowledgment
    public function create() {
        // Check if already acknowledged
        if ($this->isAcknowledged($this->announcement_id, $this->user_id)) {
            return false; // Already acknowledged
        }

        $query = "INSERT INTO {$this->table} (
            announcement_id, user_id, ip_address, user_agent
        ) VALUES (
            :announcement_id, :user_id, :ip_address, :user_agent
        )";

        $stmt = $this->conn->prepare($query);

        // Bind values
        $stmt->bindParam(':announcement_id', $this->announcement_id);
        $stmt->bindParam(':user_id', $this->user_id);
        $stmt->bindParam(':ip_address', $this->ip_address);
        $stmt->bindParam(':user_agent', $this->user_agent);

        if ($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            
            // Update acknowledgment count in announcements table
            $this->updateAcknowledgmentCount($this->announcement_id);
            
            return true;
        }
        return false;
    }

    // Check if user has acknowledged announcement
    public function isAcknowledged($announcement_id, $user_id) {
        $query = "SELECT id FROM {$this->table} WHERE announcement_id = :announcement_id AND user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':announcement_id', $announcement_id);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    // Get acknowledgment by ID
    public function getById($id) {
        $query = "SELECT aa.*, a.title as announcement_title, u.first_name, u.last_name, u.email
                  FROM {$this->table} aa
                  JOIN announcements a ON aa.announcement_id = a.id
                  JOIN users u ON aa.user_id = u.id
                  WHERE aa.id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Get acknowledgments for announcement
    public function getByAnnouncement($announcement_id, $page = 1, $limit = 50) {
        $offset = ($page - 1) * $limit;

        $query = "SELECT aa.*, u.first_name, u.last_name, u.email, u.role
                  FROM {$this->table} aa
                  JOIN users u ON aa.user_id = u.id
                  WHERE aa.announcement_id = :announcement_id
                  ORDER BY aa.acknowledged_at DESC
                  LIMIT :limit OFFSET :offset";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':announcement_id', $announcement_id);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Get acknowledgments by user
    public function getByUser($user_id, $page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;

        $query = "SELECT aa.*, a.title as announcement_title, a.category, a.priority
                  FROM {$this->table} aa
                  JOIN announcements a ON aa.announcement_id = a.id
                  WHERE aa.user_id = :user_id
                  ORDER BY aa.acknowledged_at DESC
                  LIMIT :limit OFFSET :offset";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Get acknowledgment statistics for announcement
    public function getStatistics($announcement_id) {
        $query = "SELECT 
                    COUNT(*) as total_acknowledgments,
                    DATE(acknowledged_at) as acknowledgment_date,
                    COUNT(*) as daily_count
                  FROM {$this->table}
                  WHERE announcement_id = :announcement_id
                  GROUP BY DATE(acknowledged_at)
                  ORDER BY acknowledgment_date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':announcement_id', $announcement_id);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Update acknowledgment count in announcements table
    private function updateAcknowledgmentCount($announcement_id) {
        $query = "UPDATE announcements 
                  SET acknowledgment_count = (
                      SELECT COUNT(*) FROM {$this->table} 
                      WHERE announcement_id = :announcement_id
                  )
                  WHERE id = :announcement_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':announcement_id', $announcement_id);
        return $stmt->execute();
    }

    // Delete acknowledgment
    public function delete() {
        $query = "DELETE FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        
        if ($stmt->execute()) {
            // Update acknowledgment count
            $this->updateAcknowledgmentCount($this->announcement_id);
            return true;
        }
        return false;
    }

    // Get pending acknowledgments for user
    public function getPendingAcknowledgments($user_id) {
        $query = "SELECT a.*, 
                    CASE WHEN aa.id IS NOT NULL THEN 1 ELSE 0 END as is_acknowledged
                  FROM announcements a
                  LEFT JOIN {$this->table} aa ON a.id = aa.announcement_id AND aa.user_id = :user_id
                  WHERE a.status = 'published' 
                    AND a.requires_acknowledgment = 1
                    AND a.deleted_at IS NULL
                    AND (a.expires_at IS NULL OR a.expires_at > NOW())
                    AND aa.id IS NULL
                  ORDER BY a.priority DESC, a.published_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>
