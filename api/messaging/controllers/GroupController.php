<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../models/Group.php';
require_once __DIR__ . '/../models/GroupMember.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-Id');

class GroupController {
    private $db;
    private $group;
    private $groupMember;
    private $user;
    private $secret_key = "YOUR_SECRET_KEY";
    
    public function __construct($db = null) {
        if ($db) {
            $this->db = $db;
        } else {
            $database = new Database();
            $this->db = $database->getConnection();
        }
        $this->group = new Group($this->db);
        $this->groupMember = new GroupMember($this->db);
        $this->user = new User($this->db);
    }
    
    /**
     * Créer un nouveau groupe
     */
    public function createGroup() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['name']) || empty($data['name'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Le nom du groupe est requis']);
                return;
            }
            
            $this->group->name = $data['name'];
            $this->group->slug = $this->generateSlug($data['name']);
            $this->group->description = $data['description'] ?? null;
            $this->group->group_type = $data['group_type'] ?? 'chat';
            $this->group->visibility = $data['visibility'] ?? 'private';
            $this->group->created_by = $data['created_by'] ?? $this->getCurrentUserId();
            $this->group->institution_id = $data['institution_id'] ?? null;
            $this->group->program_id = $data['program_id'] ?? null;
            $this->group->department_id = $data['department_id'] ?? null;
            $this->group->avatar_url = $data['avatar_url'] ?? null;
            $this->group->cover_image_url = $data['cover_image_url'] ?? null;
            $this->group->rules = $data['rules'] ?? null;
            $this->group->max_members = $data['max_members'] ?? null;
            $this->group->join_approval_required = $data['join_approval_required'] ?? false;
            $this->group->allow_member_posts = $data['allow_member_posts'] ?? true;
            $this->group->allow_member_invites = $data['allow_member_invites'] ?? false;
            
            $groupId = $this->group->create();
            
            if ($groupId) {
                // Ajouter le créateur comme admin du groupe
                $this->groupMember->group_id = $groupId;
                $this->groupMember->user_id = $this->group->created_by;
                $this->groupMember->role = 'admin';
                $this->groupMember->status = 'active';
                $this->groupMember->joined_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_by = $this->group->created_by;
                
                $memberId = $this->groupMember->create();
                
                if ($memberId) {
                    http_response_code(201);
                    echo json_encode([
                        'success' => true,
                        'message' => 'Groupe créé avec succès',
                        'group_id' => $groupId,
                        'member_id' => $memberId
                    ]);
                } else {
                    http_response_code(500);
                    echo json_encode(['error' => 'Erreur lors de l\'ajout du créateur au groupe']);
                }
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de la création du groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Obtenir les groupes de l'utilisateur
     */
    public function getUserGroups() {
        try {
            $userId = $this->getCurrentUserId();
            
            if (!$userId) {
                http_response_code(401);
                echo json_encode(['error' => 'Utilisateur non authentifié']);
                return;
            }
            
            $groups = $this->group->getUserGroups($userId);
            
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'groups' => $groups
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Obtenir les détails d'un groupe
     */
    public function getGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur est membre du groupe
            if (!$this->groupMember->isMember($groupId, $userId)) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'êtes pas membre de ce groupe']);
                return;
            }
            
            $group = $this->group->getById($groupId);
            
            if ($group) {
                // Obtenir les membres du groupe
                $members = $this->groupMember->getGroupMembers($groupId);
                $group['members'] = $members;
                
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'group' => $group
                ]);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Groupe non trouvé']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Rejoindre un groupe
     */
    public function joinGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            if (!$userId) {
                http_response_code(401);
                echo json_encode(['error' => 'Utilisateur non authentifié']);
                return;
            }
            
            // Vérifier si le groupe existe
            $group = $this->group->getById($groupId);
            if (!$group) {
                http_response_code(404);
                echo json_encode(['error' => 'Groupe non trouvé']);
                return;
            }
            
            // Vérifier si l'utilisateur est déjà membre
            if ($this->groupMember->isMember($groupId, $userId)) {
                http_response_code(400);
                echo json_encode(['error' => 'Vous êtes déjà membre de ce groupe']);
                return;
            }
            
            // Vérifier si le groupe est plein
            if ($group['max_members'] > 0 && $group['current_members_count'] >= $group['max_members']) {
                http_response_code(400);
                echo json_encode(['error' => 'Le groupe est plein']);
                return;
            }
            
            $this->groupMember->group_id = $groupId;
            $this->groupMember->user_id = $userId;
            $this->groupMember->role = 'member';
            $this->groupMember->status = $group['join_approval_required'] ? 'pending' : 'active';
            $this->groupMember->joined_at = date('Y-m-d H:i:s');
            
            if (!$group['join_approval_required']) {
                $this->groupMember->approved_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_by = $group['created_by'];
            }
            
            $memberId = $this->groupMember->create();
            
            if ($memberId) {
                // Mettre à jour le nombre de membres si approuvé automatiquement
                if (!$group['join_approval_required']) {
                    $this->group->incrementMemberCount($groupId);
                }
                
                http_response_code(201);
                echo json_encode([
                    'success' => true,
                    'message' => $group['join_approval_required'] 
                        ? 'Demande d\'adhésion envoyée' 
                        : 'Vous avez rejoint le groupe',
                    'status' => $this->groupMember->status,
                    'member_id' => $memberId
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de l\'adhésion au groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Quitter un groupe
     */
    public function leaveGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            if (!$userId) {
                http_response_code(401);
                echo json_encode(['error' => 'Utilisateur non authentifié']);
                return;
            }
            
            // Vérifier si l'utilisateur est membre du groupe
            if (!$this->groupMember->isMember($groupId, $userId)) {
                http_response_code(400);
                echo json_encode(['error' => 'Vous n\'êtes pas membre de ce groupe']);
                return;
            }
            
            // Vérifier si c'est le dernier admin
            $adminCount = $this->groupMember->getAdminCount($groupId);
            $userRole = $this->groupMember->getUserRole($groupId, $userId);
            
            if ($userRole === 'admin' && $adminCount <= 1) {
                http_response_code(400);
                echo json_encode(['error' => 'Vous ne pouvez pas quitter le groupe car vous êtes le seul administrateur']);
                return;
            }
            
            if ($this->groupMember->leaveGroup($groupId, $userId)) {
                $this->group->decrementMemberCount($groupId);
                
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'Vous avez quitté le groupe'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors du départ du groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Ajouter des membres à un groupe
     */
    public function addMembers($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur a les permissions (admin/moderator)
            if (!$this->groupMember->hasPermission($groupId, $userId, 'can_invite')) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'avez pas la permission d\'ajouter des membres']);
                return;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['user_ids']) || !is_array($data['user_ids'])) {
                http_response_code(400);
                echo json_encode(['error' => 'La liste des utilisateurs est requise']);
                return;
            }
            
            $addedMembers = [];
            $errors = [];
            
            foreach ($data['user_ids'] as $targetUserId) {
                // Vérifier si l'utilisateur est déjà membre
                if ($this->groupMember->isMember($groupId, $targetUserId)) {
                    $errors[] = "L'utilisateur $targetUserId est déjà membre";
                    continue;
                }
                
                // Ajouter le membre
                $this->groupMember->group_id = $groupId;
                $this->groupMember->user_id = $targetUserId;
                $this->groupMember->role = 'member';
                $this->groupMember->status = 'active';
                $this->groupMember->joined_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_by = $userId;
                
                $memberId = $this->groupMember->create();
                
                if ($memberId) {
                    $addedMembers[] = [
                        'user_id' => $targetUserId,
                        'member_id' => $memberId
                    ];
                    $this->group->incrementMemberCount($groupId);
                } else {
                    $errors[] = "Erreur lors de l'ajout de l'utilisateur $targetUserId";
                }
            }
            
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'message' => count($addedMembers) . ' membre(s) ajouté(s) avec succès',
                'added_members' => $addedMembers,
                'errors' => $errors
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Supprimer un membre d'un groupe
     */
    public function removeMember($groupId, $memberId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur a les permissions
            if (!$this->groupMember->hasPermission($groupId, $userId, 'can_remove_members')) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'avez pas la permission de supprimer des membres']);
                return;
            }
            
            if ($this->groupMember->removeMember($memberId)) {
                $this->group->decrementMemberCount($groupId);
                
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'Membre supprimé avec succès'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de la suppression du membre']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Mettre à jour les informations d'un groupe
     */
    public function updateGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur est admin du groupe
            if (!$this->groupMember->isAdmin($groupId, $userId)) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'êtes pas administrateur de ce groupe']);
                return;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            
            $this->group->id = $groupId;
            
            if (isset($data['name'])) $this->group->name = $data['name'];
            if (isset($data['description'])) $this->group->description = $data['description'];
            if (isset($data['avatar_url'])) $this->group->avatar_url = $data['avatar_url'];
            if (isset($data['cover_image_url'])) $this->group->cover_image_url = $data['cover_image_url'];
            if (isset($data['rules'])) $this->group->rules = $data['rules'];
            if (isset($data['max_members'])) $this->group->max_members = $data['max_members'];
            if (isset($data['join_approval_required'])) $this->group->join_approval_required = $data['join_approval_required'];
            if (isset($data['allow_member_posts'])) $this->group->allow_member_posts = $data['allow_member_posts'];
            if (isset($data['allow_member_invites'])) $this->group->allow_member_invites = $data['allow_member_invites'];
            
            if ($this->group->update()) {
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'Groupe mis à jour avec succès'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de la mise à jour du groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Obtenir l'ID de l'utilisateur actuel depuis le token JWT
     */
    private function getCurrentUserId() {
        // D'abord essayer depuis le header X-User-ID (compatibilité)
        if (isset($_SERVER['HTTP_X_USER_ID'])) {
            return (int)$_SERVER['HTTP_X_USER_ID'];
        }
        
        // Sinon, extraire depuis le token JWT
        $headers = getallheaders();
        $authHeader = null;
        
        foreach ($headers as $key => $value) {
            if (strtolower($key) === 'authorization') {
                $authHeader = $value;
                break;
            }
        }
        
        if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }
        
        if (empty($authHeader)) {
            return null;
        }
        
        if (preg_match('/^(Bearer|Token)[\s]+(.*)$/i', $authHeader, $matches)) {
            $token = trim($matches[2]);
            
            try {
                $decoded = JWT::decode($token, new Key($this->secret_key, 'HS256'));
                return $decoded->data->id ?? null;
            } catch (Exception $e) {
                error_log('Erreur JWT: ' . $e->getMessage());
                return null;
            }
        }
        
        return null;
    }
    
    /**
     * Générer un slug unique à partir du nom
     */
    private function generateSlug($name) {
        $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $name)));
        $originalSlug = $slug;
        $counter = 1;
        
        while ($this->group->slugExists($slug)) {
            $slug = $originalSlug . '-' . $counter;
            $counter++;
        }
        
        return $slug;
    }
}

// Router les requêtes
$controller = new GroupController();
$method = $_SERVER['REQUEST_METHOD'];
$requestUri = $_SERVER['REQUEST_URI'];
$uriParts = explode('/', trim($requestUri, '/'));

// Trouver l'index de 'groups' dans l'URL
$groupsIndex = array_search('groups', $uriParts);
if ($groupsIndex !== false) {
    $actionIndex = $groupsIndex + 1;
    $action = $uriParts[$actionIndex] ?? '';
    
    switch ($method) {
        case 'POST':
            if ($action === 'create') {
                $controller->createGroup();
            } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'members') {
                $groupId = (int)$action;
                $controller->addMembers($groupId);
            } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'join') {
                $groupId = (int)$action;
                $controller->joinGroup($groupId);
            }
            break;
            
        case 'GET':
            if ($action === 'my') {
                $controller->getUserGroups();
            } elseif (is_numeric($action)) {
                $groupId = (int)$action;
                $controller->getGroup($groupId);
            }
            break;
            
        case 'PUT':
            if (is_numeric($action)) {
                $groupId = (int)$action;
                $controller->updateGroup($groupId);
            }
            break;
            
        case 'DELETE':
            if (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'leave') {
                $groupId = (int)$action;
                $controller->leaveGroup($groupId);
            } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'members' && isset($uriParts[$actionIndex + 2])) {
                $groupId = (int)$action;
                $memberId = (int)$uriParts[$actionIndex + 2];
                $controller->removeMember($groupId, $memberId);
            }
            break;
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint non trouvé']);
}
?>
