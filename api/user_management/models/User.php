<?php

namespace App\Models;

use PDO;
use PDOException;
use DateTime;

class User {
    private PDO $db;
    private ?array $data = null;
    private ?array $roles = null;
    private ?array $permissions = null;

    public function __construct(PDO $db) {
        $this->db = $db;
    }

    /**
     * Charge un utilisateur par son ID
     */
    public function findById(int $id): ?array {
        $stmt = $this->db->prepare("
            SELECT u.*, i.name as institution_name, d.name as department_name
            FROM users u
            LEFT JOIN institutions i ON u.institution_id = i.id
            LEFT JOIN departments d ON u.department_id = d.id
            WHERE u.id = :id AND u.deleted_at IS NULL
        ");
        $stmt->execute(['id' => $id]);
        $this->data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($this->data) {
            $this->loadRoles();
            $this->loadPermissions();
        }
        
        return $this->data;
    }

    /**
     * Charge un utilisateur par son email
     */
    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare("
            SELECT u.*, i.name as institution_name, d.name as department_name
            FROM users u
            LEFT JOIN institutions i ON u.institution_id = i.id
            LEFT JOIN departments d ON u.department_id = d.id
            WHERE u.email = :email AND u.deleted_at IS NULL
        ");
        $stmt->execute(['email' => $email]);
        $this->data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($this->data) {
            $this->loadRoles();
            $this->loadPermissions();
        }
        
        return $this->data;
    }

    /**
     * Charge les rôles de l'utilisateur
     */
    private function loadRoles(): void {
        if (!$this->data) return;

        $stmt = $this->db->prepare("
            SELECT r.*, ur.granted_at, ur.expires_at, ur.is_active
            FROM roles r
            JOIN user_roles ur ON r.id = ur.role_id
            WHERE ur.user_id = :user_id AND ur.is_active = 1
            ORDER BY r.level DESC
        ");
        $stmt->execute(['user_id' => $this->data['id']]);
        $this->roles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Charge les permissions de l'utilisateur
     */
    private function loadPermissions(): void {
        if (!$this->roles) return;

        $roleIds = array_column($this->roles, 'id');
        if (empty($roleIds)) return;

        $placeholders = str_repeat('?,', count($roleIds) - 1) . '?';
        
        $stmt = $this->db->prepare("
            SELECT DISTINCT p.*
            FROM permissions p
            JOIN role_permissions rp ON p.id = rp.permission_id
            WHERE rp.role_id IN ($placeholders)
        ");
        $stmt->execute($roleIds);
        $this->permissions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Vérifie si l'utilisateur a une permission spécifique
     */
    public function hasPermission(string $permission): bool {
        if (!$this->permissions) return false;
        
        return in_array($permission, array_column($this->permissions, 'name'));
    }

    /**
     * Vérifie si l'utilisateur a un rôle spécifique
     */
    public function hasRole(string $role): bool {
        if (!$this->roles) return false;
        
        return in_array($role, array_column($this->roles, 'name'));
    }

    /**
     * Obtient le niveau hiérarchique le plus élevé de l'utilisateur
     */
    public function getHighestLevel(): int {
        if (!$this->roles) return 0;
        
        return max(array_column($this->roles, 'level'));
    }

    /**
     * Obtient le rôle principal de l'utilisateur
     */
    public function getPrimaryRole(): ?string {
        if (!$this->roles) return null;
        
        $highestLevelRole = $this->roles[0]; // Déjà trié par level DESC
        return $highestLevelRole['name'];
    }

    /**
     * Vérifie si l'utilisateur peut voir un autre utilisateur
     */
    public function canViewUser(int $targetUserId): bool {
        if (!$this->data) return false;
        
        // Un utilisateur peut toujours voir son propre profil
        if ($this->data['id'] == $targetUserId) return true;

        $stmt = $this->db->prepare("CALL sp_can_view_user(?, ?, @can_view)");
        $stmt->execute([$this->data['id'], $targetUserId]);
        
        $result = $this->db->query("SELECT @can_view as can_view")->fetch(PDO::FETCH_ASSOC);
        
        return (bool) $result['can_view'];
    }

    /**
     * Vérifie si l'utilisateur peut modifier un autre utilisateur
     */
    public function canEditUser(int $targetUserId): bool {
        if (!$this->data) return false;
        
        // Un utilisateur peut toujours modifier son propre profil (limité)
        if ($this->data['id'] == $targetUserId) return true;

        // Vérifier si peut voir l'utilisateur
        if (!$this->canViewUser($targetUserId)) return false;

        // Charger les informations de l'utilisateur cible
        $target = new User($this->db);
        $target->findById($targetUserId);
        
        if (!$target->data) return false;

        $viewerLevel = $this->getHighestLevel();
        $targetLevel = $target->getHighestLevel();

        // Seuls les niveaux supérieurs peuvent modifier
        if ($viewerLevel <= $targetLevel) return false;

        // Vérifier les permissions spécifiques
        if ($viewerLevel >= 90) {
            // Admin national et superadmin peuvent modifier tout le monde
            return $this->hasPermission('users.update');
        } elseif ($viewerLevel >= 80) {
            // Admin local peut modifier les utilisateurs de son institution
            $sameInstitution = $this->data['institution_id'] == $target->data['institution_id'];
            return $sameInstitution && $this->hasPermission('users.update');
        } else {
            // Les autres ont des permissions limitées
            return $this->hasPermission('users.update_limited');
        }
    }

    /**
     * Vérifie si l'utilisateur peut supprimer un autre utilisateur
     */
    public function canDeleteUser(int $targetUserId): bool {
        if (!$this->data) return false;
        
        // On ne peut pas se supprimer soi-même
        if ($this->data['id'] == $targetUserId) return false;

        // Vérifier si peut voir l'utilisateur
        if (!$this->canViewUser($targetUserId)) return false;

        // Charger les informations de l'utilisateur cible
        $target = new User($this->db);
        $target->findById($targetUserId);
        
        if (!$target->data) return false;

        $viewerLevel = $this->getHighestLevel();
        $targetLevel = $target->getHighestLevel();

        // Seuls les niveaux supérieurs peuvent supprimer
        if ($viewerLevel <= $targetLevel) return false;

        // Seuls admin national et superadmin peuvent supprimer
        if ($viewerLevel >= 90) {
            return $this->hasPermission('users.delete');
        }

        return false;
    }

    /**
     * Obtient la liste des utilisateurs visibles pour l'utilisateur courant
     */
    public function getVisibleUsers(array $filters = []): array {
        if (!$this->data) return [];

        $page = $filters['page'] ?? 1;
        $limit = $filters['limit'] ?? 20;
        $search = $filters['search'] ?? null;
        $roleFilter = $filters['role'] ?? null;
        $statusFilter = $filters['status'] ?? null;

        $stmt = $this->db->prepare("CALL sp_get_visible_users(?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            $this->data['id'],
            $page,
            $limit,
            $search,
            $roleFilter,
            $statusFilter
        ]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtient les statistiques des utilisateurs par rôle
     */
    public function getUserRoleStats(): array {
        $stmt = $this->db->query("
            SELECT * FROM user_role_stats 
            WHERE user_count > 0 
            ORDER BY role_level DESC
        ");
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Crée un nouvel utilisateur
     */
    public function create(array $userData): array {
        try {
            $this->db->beginTransaction();

            // Validation des données de base
            $required = ['email', 'first_name', 'last_name', 'password', 'institution_id'];
            foreach ($required as $field) {
                if (empty($userData[$field])) {
                    throw new \InvalidArgumentException("Le champ '$field' est requis");
                }
            }

            // Vérifier si l'email existe déjà
            if ($this->findByEmail($userData['email'])) {
                throw new \InvalidArgumentException("Cet email est déjà utilisé");
            }

            // Générer un UUID et un matricule si nécessaire
            $userData['uuid'] = $userData['uuid'] ?? $this->generateUUID();
            $userData['matricule'] = $userData['matricule'] ?? $this->generateMatricule($userData['institution_id']);
            $userData['password_hash'] = password_hash($userData['password'], PASSWORD_DEFAULT);

            // Insérer l'utilisateur
            $fields = ['uuid', 'institution_id', 'matricule', 'email', 'password_hash', 
                      'first_name', 'last_name', 'primary_role', 'account_status'];
            $values = [];
            $placeholders = [];

            foreach ($fields as $field) {
                if (isset($userData[$field])) {
                    $values[$field] = $userData[$field];
                    $placeholders[] = ":$field";
                }
            }

            $sql = "INSERT INTO users (" . implode(', ', $fields) . ") VALUES (" . implode(', ', $placeholders) . ")";
            $stmt = $this->db->prepare($sql);
            $stmt->execute($values);

            $userId = (int) $this->db->lastInsertId();

            // Assigner le rôle par défaut
            $defaultRole = $userData['primary_role'] ?? 'student';
            $this->assignRole($userId, $defaultRole, $this->data['id'] ?? null);

            $this->db->commit();

            // Retourner l'utilisateur créé
            $createdUser = new User($this->db);
            $createdUser->findById($userId);

            return [
                'success' => true,
                'message' => 'Utilisateur créé avec succès',
                'user' => $createdUser->data
            ];

        } catch (PDOException $e) {
            $this->db->rollBack();
            throw new \RuntimeException("Erreur lors de la création de l'utilisateur: " . $e->getMessage());
        }
    }

    /**
     * Met à jour un utilisateur
     */
    public function update(int $userId, array $userData): array {
        try {
            $this->db->beginTransaction();

            // Vérifier les permissions
            if (!$this->canEditUser($userId)) {
                throw new \RuntimeException("Vous n'avez pas la permission de modifier cet utilisateur");
            }

            // Charger l'utilisateur à modifier
            $targetUser = new User($this->db);
            $targetUser->findById($userId);

            if (!$targetUser->data) {
                throw new \InvalidArgumentException("Utilisateur non trouvé");
            }

            // Champs autorisés à la modification
            $allowedFields = ['first_name', 'last_name', 'phone', 'address', 'city', 
                            'region', 'postal_code', 'bio', 'profile_photo_url'];
            
            // Si l'utilisateur a des permissions élevées, autoriser plus de champs
            if ($this->getHighestLevel() >= 80) {
                $allowedFields = array_merge($allowedFields, ['email', 'phone', 'account_status', 'is_active']);
            }

            // Filtrer les données
            $updateData = array_intersect_key($userData, array_flip($allowedFields));

            if (empty($updateData)) {
                throw new \InvalidArgumentException("Aucun champ valide à modifier");
            }

            // Construire la requête de mise à jour
            $setClause = [];
            $values = ['id' => $userId];

            foreach ($updateData as $field => $value) {
                $setClause[] = "$field = :$field";
                $values[$field] = $value;
            }

            $sql = "UPDATE users SET " . implode(', ', $setClause) . ", updated_at = CURRENT_TIMESTAMP WHERE id = :id";
            $stmt = $this->db->prepare($sql);
            $stmt->execute($values);

            // Si le mot de passe est fourni et que l'utilisateur a la permission
            if (!empty($userData['password']) && $this->hasPermission('users.update')) {
                $passwordHash = password_hash($userData['password'], PASSWORD_DEFAULT);
                $stmt = $this->db->prepare("UPDATE users SET password_hash = ?, password_changed_at = CURRENT_TIMESTAMP WHERE id = ?");
                $stmt->execute([$passwordHash, $userId]);
            }

            $this->db->commit();

            // Retourner l'utilisateur mis à jour
            $updatedUser = new User($this->db);
            $updatedUser->findById($userId);

            return [
                'success' => true,
                'message' => 'Utilisateur mis à jour avec succès',
                'user' => $updatedUser->data
            ];

        } catch (PDOException $e) {
            $this->db->rollBack();
            throw new \RuntimeException("Erreur lors de la mise à jour de l'utilisateur: " . $e->getMessage());
        }
    }

    /**
     * Supprime un utilisateur
     */
    public function delete(int $userId): array {
        try {
            $this->db->beginTransaction();

            // Vérifier les permissions
            if (!$this->canDeleteUser($userId)) {
                throw new \RuntimeException("Vous n'avez pas la permission de supprimer cet utilisateur");
            }

            // Soft delete
            $stmt = $this->db->prepare("UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?");
            $stmt->execute([$userId]);

            // Désactiver les rôles
            $stmt = $this->db->prepare("UPDATE user_roles SET is_active = 0 WHERE user_id = ?");
            $stmt->execute([$userId]);

            $this->db->commit();

            return [
                'success' => true,
                'message' => 'Utilisateur supprimé avec succès'
            ];

        } catch (PDOException $e) {
            $this->db->rollBack();
            throw new \RuntimeException("Erreur lors de la suppression de l'utilisateur: " . $e->getMessage());
        }
    }

    /**
     * Assigne un rôle à un utilisateur
     */
    public function assignRole(int $userId, string $roleName, ?int $assignedBy = null): bool {
        try {
            // Obtenir l'ID du rôle
            $stmt = $this->db->prepare("SELECT id FROM roles WHERE name = ?");
            $stmt->execute([$roleName]);
            $roleId = $stmt->fetchColumn();

            if (!$roleId) {
                throw new \InvalidArgumentException("Rôle '$roleName' non trouvé");
            }

            // Vérifier si l'utilisateur a déjà ce rôle
            $stmt = $this->db->prepare("
                SELECT id FROM user_roles 
                WHERE user_id = ? AND role_id = ? AND is_active = 1
            ");
            $stmt->execute([$userId, $roleId]);
            
            if ($stmt->fetch()) {
                return true; // Le rôle est déjà assigné
            }

            // Assigner le rôle
            $stmt = $this->db->prepare("
                INSERT INTO user_roles (user_id, role_id, granted_by, granted_at, is_active)
                VALUES (?, ?, ?, CURRENT_TIMESTAMP, 1)
                ON DUPLICATE KEY UPDATE is_active = 1, granted_by = VALUES(granted_by), granted_at = CURRENT_TIMESTAMP
            ");
            $stmt->execute([$userId, $roleId, $assignedBy]);

            return true;

        } catch (PDOException $e) {
            throw new \RuntimeException("Erreur lors de l'assignation du rôle: " . $e->getMessage());
        }
    }

    /**
     * Génère un UUID
     */
    private function generateUUID(): string {
        return sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    /**
     * Génère un matricule unique
     */
    private function generateMatricule(int $institutionId): string {
        $prefix = 'USR';
        $year = date('Y');
        $random = str_pad(mt_rand(1, 99999), 5, '0', STR_PAD_LEFT);
        
        return $prefix . $year . $random;
    }

    /**
     * Getters
     */
    public function getData(): ?array {
        return $this->data;
    }

    public function getRoles(): ?array {
        return $this->roles;
    }

    public function getPermissions(): ?array {
        return $this->permissions;
    }

    public function isLoggedIn(): bool {
        return !empty($this->data);
    }
}
