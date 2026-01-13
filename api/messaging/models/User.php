<?php

class User {
    private $db;
    
    public function __construct($db) {
        $this->db = $db;
    }
    
    public function getById($id) {
        $stmt = $this->db->prepare("SELECT * FROM users WHERE id = :id AND deleted_at IS NULL");
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    public function getByEmail($email) {
        $stmt = $this->db->prepare("SELECT * FROM users WHERE email = :email AND deleted_at IS NULL");
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    public function search($query, $limit = 20, $offset = 0) {
        $stmt = $this->db->prepare("SELECT id, first_name, last_name, email, avatar_url FROM users 
                                   WHERE (first_name LIKE :query OR last_name LIKE :query OR email LIKE :query) 
                                   AND deleted_at IS NULL 
                                   ORDER BY first_name, last_name 
                                   LIMIT :limit OFFSET :offset");
        $searchTerm = "%$query%";
        $stmt->bindParam(':query', $searchTerm);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>
