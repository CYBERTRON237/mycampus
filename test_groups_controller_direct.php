<?php
/**
 * Test direct du contrôleur sans passer par les headers
 */

require_once __DIR__ . '/api/config/database.php';

header('Content-Type: application/json');

function output($success, $message, $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        output(false, "Connexion BD échouée");
        exit;
    }
    
    // Inclure les classes nécessaires
    require_once __DIR__ . '/api/messaging/models/Group.php';
    require_once __DIR__ . '/api/messaging/models/GroupMember.php';
    
    // Créer le contrôleur manuellement
    class TestGroupController {
        private $db;
        private $group;
        private $groupMember;
        
        public function __construct($db) {
            $this->db = $db;
            $this->group = new Group($db);
            $this->groupMember = new GroupMember($db);
        }
        
        public function getUserGroups($userId) {
            try {
                $groups = $this->group->getUserGroups($userId);
                
                return [
                    'success' => true,
                    'groups' => $groups,
                    'total' => count($groups)
                ];
            } catch (Exception $e) {
                return [
                    'success' => false,
                    'error' => $e->getMessage()
                ];
            }
        }
        
        public function createGroup($data) {
            try {
                $this->group->name = $data['name'];
                $this->group->description = $data['description'] ?? null;
                $this->group->group_type = $data['group_type'] ?? 'chat';
                $this->group->visibility = $data['visibility'] ?? 'private';
                $this->group->created_by = $data['created_by'];
                
                $groupId = $this->group->create();
                
                if ($groupId) {
                    // Ajouter le créateur comme admin
                    $this->groupMember->group_id = $groupId;
                    $this->groupMember->user_id = $data['created_by'];
                    $this->groupMember->role = 'admin';
                    $this->groupMember->status = 'active';
                    $this->groupMember->joined_at = date('Y-m-d H:i:s');
                    $this->groupMember->approved_at = date('Y-m-d H:i:s');
                    $this->groupMember->approved_by = $data['created_by'];
                    
                    $memberId = $this->groupMember->create();
                    
                    if ($memberId) {
                        return [
                            'success' => true,
                            'message' => 'Groupe créé avec succès',
                            'group_id' => $groupId,
                            'member_id' => $memberId
                        ];
                    }
                }
                
                return ['success' => false, 'error' => 'Erreur création'];
            } catch (Exception $e) {
                return [
                    'success' => false,
                    'error' => $e->getMessage()
                ];
            }
        }
    }
    
    $controller = new TestGroupController($db);
    
    // Test 1: Récupérer les groupes de l'utilisateur 39
    $result = $controller->getUserGroups(39);
    if ($result['success']) {
        output(true, "Test récupération groupes réussi", $result);
    } else {
        output(false, "Test récupération groupes échoué", $result);
    }
    
    // Test 2: Créer un nouveau groupe
    echo "\n";
    $newGroupData = [
        'name' => 'Test Group Controller ' . date('His'),
        'description' => 'Groupe créé via test contrôleur',
        'group_type' => 'chat',
        'visibility' => 'private',
        'created_by' => 39
    ];
    
    $createResult = $controller->createGroup($newGroupData);
    if ($createResult['success']) {
        output(true, "Test création groupe réussi", $createResult);
        
        // Test 3: Vérifier que le groupe a été créé
        echo "\n";
        $verifyResult = $controller->getUserGroups(39);
        output(true, "Vérification finale - Total groupes: " . $verifyResult['total'], $verifyResult);
    } else {
        output(false, "Test création groupe échoué", $createResult);
    }
    
} catch (Exception $e) {
    output(false, "Erreur générale: " . $e->getMessage());
}
?>
