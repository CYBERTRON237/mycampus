<?php

class GroupMember {
    private $conn;
    private $table_name = "group_members";
    
    public $id;
    public $group_id;
    public $user_id;
    public $role;
    public $status;
    public $invited_by;
    public $joined_at;
    public $approved_at;
    public $approved_by;
    public $left_at;
    public $banned_at;
    public $banned_by;
    public $ban_reason;
    public $can_post;
    public $can_comment;
    public $can_invite;
    public $notification_enabled;
    public $muted_until;
    public $last_read_at;
    public $unread_count;
    public $metadata;
    public $created_at;
    public $updated_at;
    
    public function __construct($db) {
        $this->conn = $db;
    }
    
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " (
            group_id, user_id, role, status, invited_by, joined_at,
            approved_at, approved_by, can_post, can_comment, can_invite,
            notification_enabled, metadata
        ) VALUES (
            :group_id, :user_id, :role, :status, :invited_by, :joined_at,
            :approved_at, :approved_by, :can_post, :can_comment, :can_invite,
            :notification_enabled, :metadata
        )";
        
        $stmt = $this->conn->prepare($query);
        
        $this->group_id = htmlspecialchars(strip_tags($this->group_id));
        $this->user_id = htmlspecialchars(strip_tags($this->user_id));
        $this->role = $this->role ? htmlspecialchars(strip_tags($this->role)) : 'member';
        $this->status = $this->status ? htmlspecialchars(strip_tags($this->status)) : 'active';
        $this->invited_by = $this->invited_by ? htmlspecialchars(strip_tags($this->invited_by)) : null;
        $this->joined_at = $this->joined_at ? htmlspecialchars(strip_tags($this->joined_at)) : date('Y-m-d H:i:s');
        $this->approved_at = $this->approved_at ? htmlspecialchars(strip_tags($this->approved_at)) : null;
        $this->approved_by = $this->approved_by ? htmlspecialchars(strip_tags($this->approved_by)) : null;
        $this->can_post = $this->can_post ? htmlspecialchars(strip_tags($this->can_post)) : 1;
        $this->can_comment = $this->can_comment ? htmlspecialchars(strip_tags($this->can_comment)) : 1;
        $this->can_invite = $this->can_invite ? htmlspecialchars(strip_tags($this->can_invite)) : 1;
        $this->notification_enabled = $this->notification_enabled ? htmlspecialchars(strip_tags($this->notification_enabled)) : 1;
        
        $metadata_json = is_array($this->metadata) ? json_encode($this->metadata) : $this->metadata;
        
        $stmt->bindParam(":group_id", $this->group_id);
        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->bindParam(":role", $this->role);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":invited_by", $this->invited_by);
        $stmt->bindParam(":joined_at", $this->joined_at);
        $stmt->bindParam(":approved_at", $this->approved_at);
        $stmt->bindParam(":approved_by", $this->approved_by);
        $stmt->bindParam(":can_post", $this->can_post);
        $stmt->bindParam(":can_comment", $this->can_comment);
        $stmt->bindParam(":can_invite", $this->can_invite);
        $stmt->bindParam(":notification_enabled", $this->notification_enabled);
        $stmt->bindParam(":metadata", $metadata_json);
        
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        
        return false;
    }
    
    public function isMember($groupId, $userId) {
        $query = "SELECT id FROM " . $this->table_name . " 
                 WHERE group_id = :group_id AND user_id = :user_id 
                 AND status = 'active'";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    public function getGroupMembers($groupId) {
        $query = "SELECT gm.*, u.first_name, u.last_name, u.email,
                        CONCAT(u.first_name, ' ', u.last_name) as full_name
                 FROM " . $this->table_name . " gm
                 INNER JOIN users u ON gm.user_id = u.id
                 WHERE gm.group_id = :group_id AND gm.status = 'active'
                 ORDER BY 
                    CASE gm.role 
                        WHEN 'admin' THEN 1 
                        WHEN 'moderator' THEN 2 
                        WHEN 'leader' THEN 3 
                        ELSE 4 
                    END,
                    gm.joined_at ASC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->execute();
        
        $members = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            if ($row['metadata']) {
                $row['metadata'] = json_decode($row['metadata'], true);
            }
            $members[] = $row;
        }
        
        return $members;
    }
    
    public function getUserRole($groupId, $userId) {
        $query = "SELECT role FROM " . $this->table_name . " 
                 WHERE group_id = :group_id AND user_id = :user_id 
                 AND status = 'active'";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $row ? $row['role'] : null;
    }
    
    public function isAdmin($groupId, $userId) {
        return $this->getUserRole($groupId, $userId) === 'admin';
    }
    
    public function getAdminCount($groupId) {
        $query = "SELECT COUNT(*) as count FROM " . $this->table_name . " 
                 WHERE group_id = :group_id AND role = 'admin' AND status = 'active'";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $row ? (int)$row['count'] : 0;
    }
    
    public function hasPermission($groupId, $userId, $permission) {
        $query = "SELECT role, can_post, can_comment, can_invite 
                 FROM " . $this->table_name . " 
                 WHERE group_id = :group_id AND user_id = :user_id 
                 AND status = 'active'";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$row) {
            return false;
        }
        
        if ($row['role'] === 'admin') {
            return true;
        }
        
        switch ($permission) {
            case 'can_post':
                return (bool)$row['can_post'];
            case 'can_comment':
                return (bool)$row['can_comment'];
            case 'can_invite':
                return (bool)$row['can_invite'];
            case 'can_remove_members':
                return in_array($row['role'], ['admin', 'moderator']);
            default:
                return false;
        }
    }
    
    public function leaveGroup($groupId, $userId) {
        $query = "UPDATE " . $this->table_name . " 
                 SET status = 'left', left_at = CURRENT_TIMESTAMP 
                 WHERE group_id = :group_id AND user_id = :user_id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->bindParam(":user_id", $userId);
        
        return $stmt->execute();
    }
    
    public function removeMember($memberId) {
        $query = "UPDATE " . $this->table_name . " 
                 SET status = 'left', left_at = CURRENT_TIMESTAMP 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $memberId);
        
        return $stmt->execute();
    }
    
    public function banMember($memberId, $bannedBy, $banReason = null) {
        $query = "UPDATE " . $this->table_name . " 
                 SET status = 'banned', banned_at = CURRENT_TIMESTAMP, 
                     banned_by = :banned_by, ban_reason = :ban_reason 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $memberId);
        $stmt->bindParam(":banned_by", $bannedBy);
        $stmt->bindParam(":ban_reason", $banReason);
        
        return $stmt->execute();
    }
    
    public function updateRole($memberId, $newRole) {
        $query = "UPDATE " . $this->table_name . " 
                 SET role = :role, updated_at = CURRENT_TIMESTAMP 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $memberId);
        $stmt->bindParam(":role", $newRole);
        
        return $stmt->execute();
    }
    
    public function updateUnreadCount($groupId, $userId, $count) {
        $query = "UPDATE " . $this->table_name . " 
                 SET unread_count = :unread_count, last_read_at = CURRENT_TIMESTAMP 
                 WHERE group_id = :group_id AND user_id = :user_id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->bindParam(":user_id", $userId);
        $stmt->bindParam(":unread_count", $count);
        
        return $stmt->execute();
    }
    
    public function resetUnreadCount($groupId, $userId) {
        return $this->updateUnreadCount($groupId, $userId, 0);
    }
    
    public function getPendingMembers($groupId) {
        $query = "SELECT gm.*, u.first_name, u.last_name, u.email, u.avatar_url,
                        CONCAT(u.first_name, ' ', u.last_name) as full_name
                 FROM " . $this->table_name . " gm
                 INNER JOIN users u ON gm.user_id = u.id
                 WHERE gm.group_id = :group_id AND gm.status = 'pending'
                 ORDER BY gm.joined_at ASC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":group_id", $groupId);
        $stmt->execute();
        
        $members = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            if ($row['metadata']) {
                $row['metadata'] = json_decode($row['metadata'], true);
            }
            $members[] = $row;
        }
        
        return $members;
    }
    
    public function approveMember($memberId, $approvedBy) {
        $query = "UPDATE " . $this->table_name . " 
                 SET status = 'active', approved_at = CURRENT_TIMESTAMP, 
                     approved_by = :approved_by 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $memberId);
        $stmt->bindParam(":approved_by", $approvedBy);
        
        return $stmt->execute();
    }
    
    public function rejectMember($memberId) {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $memberId);
        
        return $stmt->execute();
    }
}
?>
