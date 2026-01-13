<?php

class Group {
    private $conn;
    private $table_name = "user_groups";
    
    public $id;
    public $uuid;
    public $institution_id;
    public $program_id;
    public $department_id;
    public $parent_group_id;
    public $group_type;
    public $visibility;
    public $name;
    public $slug;
    public $description;
    public $cover_image_url;
    public $cover_url;
    public $icon_url;
    public $avatar_url;
    public $academic_level;
    public $academic_year_id;
    public $is_official;
    public $is_verified;
    public $is_national;
    public $max_members;
    public $current_members_count;
    public $join_approval_required;
    public $allow_member_posts;
    public $allow_member_invites;
    public $rules;
    public $tags;
    public $settings;
    public $created_by;
    public $created_at;
    public $updated_at;
    
    public function __construct($db) {
        $this->conn = $db;
    }
    
    /**
     * Créer un nouveau groupe
     */
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " (
            uuid, institution_id, program_id, department_id, parent_group_id,
            group_type, visibility, name, slug, description, cover_image_url,
            icon_url, avatar_url, academic_level, academic_year_id, is_official,
            is_verified, is_national, max_members, current_members_count,
            join_approval_required, allow_member_posts, allow_member_invites,
            rules, tags, settings, created_by
        ) VALUES (
            UUID(), :institution_id, :program_id, :department_id, :parent_group_id,
            :group_type, :visibility, :name, :slug, :description, :cover_image_url,
            :icon_url, :avatar_url, :academic_level, :academic_year_id, :is_official,
            :is_verified, :is_national, :max_members, 0,
            :join_approval_required, :allow_member_posts, :allow_member_invites,
            :rules, :tags, :settings, :created_by
        )";
        
        $stmt = $this->conn->prepare($query);
        
        // Nettoyer et lier les valeurs
        $this->institution_id = $this->institution_id ? htmlspecialchars(strip_tags($this->institution_id)) : null;
        $this->program_id = $this->program_id ? htmlspecialchars(strip_tags($this->program_id)) : null;
        $this->department_id = $this->department_id ? htmlspecialchars(strip_tags($this->department_id)) : null;
        $this->parent_group_id = $this->parent_group_id ? htmlspecialchars(strip_tags($this->parent_group_id)) : null;
        $this->group_type = htmlspecialchars(strip_tags($this->group_type));
        $this->visibility = htmlspecialchars(strip_tags($this->visibility));
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->slug = htmlspecialchars(strip_tags($this->slug));
        $this->description = $this->description ? htmlspecialchars(strip_tags($this->description)) : null;
        $this->cover_image_url = $this->cover_image_url ? htmlspecialchars(strip_tags($this->cover_image_url)) : null;
        $this->icon_url = $this->icon_url ? htmlspecialchars(strip_tags($this->icon_url)) : null;
        $this->avatar_url = $this->avatar_url ? htmlspecialchars(strip_tags($this->avatar_url)) : null;
        $this->academic_level = $this->academic_level ? htmlspecialchars(strip_tags($this->academic_level)) : null;
        $this->academic_year_id = $this->academic_year_id ? htmlspecialchars(strip_tags($this->academic_year_id)) : null;
        $this->is_official = $this->is_official ? htmlspecialchars(strip_tags($this->is_official)) : 0;
        $this->is_verified = $this->is_verified ? htmlspecialchars(strip_tags($this->is_verified)) : 0;
        $this->is_national = $this->is_national ? htmlspecialchars(strip_tags($this->is_national)) : 0;
        $this->max_members = $this->max_members ? htmlspecialchars(strip_tags($this->max_members)) : null;
        $this->join_approval_required = $this->join_approval_required ? htmlspecialchars(strip_tags($this->join_approval_required)) : 0;
        $this->allow_member_posts = $this->allow_member_posts ? htmlspecialchars(strip_tags($this->allow_member_posts)) : 1;
        $this->allow_member_invites = $this->allow_member_invites ? htmlspecialchars(strip_tags($this->allow_member_invites)) : 1;
        $this->rules = $this->rules ? htmlspecialchars(strip_tags($this->rules)) : null;
        $this->created_by = htmlspecialchars(strip_tags($this->created_by));
        
        // Convertir les tableaux en JSON
        $tags_json = is_array($this->tags) ? json_encode($this->tags) : $this->tags;
        $settings_json = is_array($this->settings) ? json_encode($this->settings) : $this->settings;
        
        $stmt->bindParam(":institution_id", $this->institution_id);
        $stmt->bindParam(":program_id", $this->program_id);
        $stmt->bindParam(":department_id", $this->department_id);
        $stmt->bindParam(":parent_group_id", $this->parent_group_id);
        $stmt->bindParam(":group_type", $this->group_type);
        $stmt->bindParam(":visibility", $this->visibility);
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":slug", $this->slug);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":cover_image_url", $this->cover_image_url);
        $stmt->bindParam(":icon_url", $this->icon_url);
        $stmt->bindParam(":avatar_url", $this->avatar_url);
        $stmt->bindParam(":academic_level", $this->academic_level);
        $stmt->bindParam(":academic_year_id", $this->academic_year_id);
        $stmt->bindParam(":is_official", $this->is_official);
        $stmt->bindParam(":is_verified", $this->is_verified);
        $stmt->bindParam(":is_national", $this->is_national);
        $stmt->bindParam(":max_members", $this->max_members);
        $stmt->bindParam(":join_approval_required", $this->join_approval_required);
        $stmt->bindParam(":allow_member_posts", $this->allow_member_posts);
        $stmt->bindParam(":allow_member_invites", $this->allow_member_invites);
        $stmt->bindParam(":rules", $this->rules);
        $stmt->bindParam(":tags", $tags_json);
        $stmt->bindParam(":settings", $settings_json);
        $stmt->bindParam(":created_by", $this->created_by);
        
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        
        return false;
    }
    
    /**
     * Mettre à jour un groupe
     */
    public function update() {
        $query = "UPDATE " . $this->table_name . " SET
            name = :name,
            description = :description,
            cover_image_url = :cover_image_url,
            avatar_url = :avatar_url,
            rules = :rules,
            max_members = :max_members,
            join_approval_required = :join_approval_required,
            allow_member_posts = :allow_member_posts,
            allow_member_invites = :allow_member_invites,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->cover_image_url = htmlspecialchars(strip_tags($this->cover_image_url));
        $this->avatar_url = htmlspecialchars(strip_tags($this->avatar_url));
        $this->rules = htmlspecialchars(strip_tags($this->rules));
        $this->max_members = htmlspecialchars(strip_tags($this->max_members));
        $this->join_approval_required = htmlspecialchars(strip_tags($this->join_approval_required));
        $this->allow_member_posts = htmlspecialchars(strip_tags($this->allow_member_posts));
        $this->allow_member_invites = htmlspecialchars(strip_tags($this->allow_member_invites));
        $this->id = htmlspecialchars(strip_tags($this->id));
        
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":cover_image_url", $this->cover_image_url);
        $stmt->bindParam(":avatar_url", $this->avatar_url);
        $stmt->bindParam(":rules", $this->rules);
        $stmt->bindParam(":max_members", $this->max_members);
        $stmt->bindParam(":join_approval_required", $this->join_approval_required);
        $stmt->bindParam(":allow_member_posts", $this->allow_member_posts);
        $stmt->bindParam(":allow_member_invites", $this->allow_member_invites);
        $stmt->bindParam(":id", $this->id);
        
        return $stmt->execute();
    }
    
    /**
     * Obtenir un groupe par son ID
     */
    public function getById($id = null) {
        $groupId = $id ?? $this->id;
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $groupId);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($row) {
            // Décoder les champs JSON
            if ($row['tags']) {
                $row['tags'] = json_decode($row['tags'], true);
            }
            if ($row['settings']) {
                $row['settings'] = json_decode($row['settings'], true);
            }
            return $row;
        }
        
        return false;
    }
    
    /**
     * Obtenir les groupes d'un utilisateur
     */
    public function getUserGroups($userId) {
        $query = "SELECT g.*, gm.role as user_role, gm.status as member_status, gm.unread_count
                 FROM " . $this->table_name . " g
                 INNER JOIN group_members gm ON g.id = gm.group_id
                 WHERE gm.user_id = :user_id AND gm.status = 'active'
                 ORDER BY g.updated_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        
        $groups = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Décoder les champs JSON
            if ($row['tags']) {
                $row['tags'] = json_decode($row['tags'], true);
            }
            if ($row['settings']) {
                $row['settings'] = json_decode($row['settings'], true);
            }
            $groups[] = $row;
        }
        
        return $groups;
    }
    
    /**
     * Vérifier si un slug existe déjà
     */
    public function slugExists($slug) {
        $query = "SELECT id FROM " . $this->table_name . " WHERE slug = :slug";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":slug", $slug);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    /**
     * Incrémenter le nombre de membres
     */
    public function incrementMemberCount($groupId) {
        $query = "UPDATE " . $this->table_name . " 
                 SET current_members_count = current_members_count + 1 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $groupId);
        
        return $stmt->execute();
    }
    
    /**
     * Décrémenter le nombre de membres
     */
    public function decrementMemberCount($groupId) {
        $query = "UPDATE " . $this->table_name . " 
                 SET current_members_count = GREATEST(current_members_count - 1, 0) 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $groupId);
        
        return $stmt->execute();
    }
    
    /**
     * Rechercher des groupes
     */
    public function search($searchTerm, $userId, $limit = 20, $offset = 0) {
        $query = "SELECT g.*, 
                        CASE WHEN gm.user_id IS NOT NULL THEN 1 ELSE 0 END as is_member,
                        gm.role as user_role
                 FROM " . $this->table_name . " g
                 LEFT JOIN group_members gm ON g.id = gm.group_id AND gm.user_id = :user_id
                 WHERE (g.name LIKE :search_term OR g.description LIKE :search_term)
                 AND g.visibility IN ('public', 'official')
                 ORDER BY g.is_official DESC, g.current_members_count DESC
                 LIMIT :limit OFFSET :offset";
        
        $stmt = $this->conn->prepare($query);
        
        $searchPattern = "%{$searchTerm}%";
        
        $stmt->bindParam(":user_id", $userId);
        $stmt->bindParam(":search_term", $searchPattern);
        $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
        $stmt->bindParam(":offset", $offset, PDO::PARAM_INT);
        
        $stmt->execute();
        
        $groups = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Décoder les champs JSON
            if ($row['tags']) {
                $row['tags'] = json_decode($row['tags'], true);
            }
            if ($row['settings']) {
                $row['settings'] = json_decode($row['settings'], true);
            }
            $groups[] = $row;
        }
        
        return $groups;
    }
}
?>
