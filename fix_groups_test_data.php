<?php
/**
 * Script pour créer des données de test valides pour les groupes
 * Résout le problème des contraintes de clés étrangères
 */

require_once __DIR__ . '/api/config/database.php';

header('Content-Type: application/json');

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception('Connexion à la base de données échouée');
    }
    
    echo "Création des données de test pour les groupes...\n";
    
    // 1. Vérifier s'il existe une institution, sinon en créer une
    $institutionQuery = "SELECT id FROM institutions LIMIT 1";
    $stmt = $db->prepare($institutionQuery);
    $stmt->execute();
    $institution = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$institution) {
        $createInstitutionQuery = "INSERT INTO institutions (uuid, name, acronym, type, status, created_at) 
                                   VALUES (UUID(), 'Institution de Test', 'TEST', 'university', 'active', NOW())";
        $stmt = $db->prepare($createInstitutionQuery);
        $stmt->execute();
        $institutionId = $db->lastInsertId();
        echo "Institution de test créée avec ID: $institutionId\n";
    } else {
        $institutionId = $institution['id'];
        echo "Institution existante utilisée avec ID: $institutionId\n";
    }
    
    // 2. Vérifier s'il existe un programme, sinon en créer un
    $programQuery = "SELECT id FROM programs LIMIT 1";
    $stmt = $db->prepare($programQuery);
    $stmt->execute();
    $program = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$program) {
        $createProgramQuery = "INSERT INTO programs (uuid, institution_id, name, code, level, status, created_at) 
                                VALUES (UUID(), ?, 'Programme de Test', 'TEST001', 'license', 'active', NOW())";
        $stmt = $db->prepare($createProgramQuery);
        $stmt->execute([$institutionId]);
        $programId = $db->lastInsertId();
        echo "Programme de test créé avec ID: $programId\n";
    } else {
        $programId = $program['id'];
        echo "Programme existant utilisé avec ID: $programId\n";
    }
    
    // 3. Vérifier s'il existe un département, sinon en créer un
    $departmentQuery = "SELECT id FROM departments LIMIT 1";
    $stmt = $db->prepare($departmentQuery);
    $stmt->execute();
    $department = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$department) {
        $createDepartmentQuery = "INSERT INTO departments (uuid, institution_id, name, code, status, created_at) 
                                  VALUES (UUID(), ?, 'Département de Test', 'DEPT001', 'active', NOW())";
        $stmt = $db->prepare($createDepartmentQuery);
        $stmt->execute([$institutionId]);
        $departmentId = $db->lastInsertId();
        echo "Département de test créé avec ID: $departmentId\n";
    } else {
        $departmentId = $department['id'];
        echo "Département existant utilisé avec ID: $departmentId\n";
    }
    
    // 4. Créer des groupes de test valides
    $groupsData = [
        [
            'name' => 'Groupe de Test API',
            'slug' => 'groupe-test-api',
            'description' => 'Groupe de test pour l API messagerie',
            'group_type' => 'chat',
            'visibility' => 'private'
        ],
        [
            'name' => 'Groupe d Étude',
            'slug' => 'groupe-etude',
            'description' => 'Groupe pour les sessions d étude',
            'group_type' => 'study',
            'visibility' => 'public'
        ],
        [
            'name' => 'Groupe Projet',
            'slug' => 'groupe-projet',
            'description' => 'Groupe de travail sur les projets',
            'group_type' => 'project',
            'visibility' => 'private'
        ]
    ];
    
    $createdGroups = [];
    
    foreach ($groupsData as $groupData) {
        // Vérifier si le groupe existe déjà
        $checkQuery = "SELECT id FROM user_groups WHERE slug = :slug";
        $stmt = $db->prepare($checkQuery);
        $stmt->bindParam(':slug', $groupData['slug']);
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {
            // Créer le groupe avec les clés étrangères valides
            $groupQuery = "INSERT INTO user_groups (
                uuid, institution_id, program_id, department_id,
                name, slug, description, group_type, visibility,
                created_by, current_members_count, created_at
            ) VALUES (
                UUID(), :institution_id, :program_id, :department_id,
                :name, :slug, :description, :group_type, :visibility,
                :created_by, 0, NOW()
            )";
            
            $stmt = $db->prepare($groupQuery);
            $stmt->bindParam(':institution_id', $institutionId);
            $stmt->bindParam(':program_id', $programId);
            $stmt->bindParam(':department_id', $departmentId);
            $stmt->bindParam(':name', $groupData['name']);
            $stmt->bindParam(':slug', $groupData['slug']);
            $stmt->bindParam(':description', $groupData['description']);
            $stmt->bindParam(':group_type', $groupData['group_type']);
            $stmt->bindParam(':visibility', $groupData['visibility']);
            $stmt->bindValue(':created_by', 39, PDO::PARAM_INT);
            
            $stmt->execute();
            $groupId = $db->lastInsertId();
            
            // Ajouter l'utilisateur 39 comme admin du groupe
            $memberQuery = "INSERT INTO group_members (
                group_id, user_id, role, status, joined_at, approved_at, approved_by
            ) VALUES (
                :group_id, :user_id, 'admin', 'active', NOW(), NOW(), :approved_by
            )";
            
            $memberStmt = $db->prepare($memberQuery);
            $memberStmt->bindParam(':group_id', $groupId);
            $memberStmt->bindValue(':user_id', 39, PDO::PARAM_INT);
            $memberStmt->bindValue(':approved_by', 39, PDO::PARAM_INT);
            $memberStmt->execute();
            
            // Mettre à jour le compteur de membres
            $updateCountQuery = "UPDATE user_groups SET current_members_count = 1 WHERE id = :group_id";
            $updateStmt = $db->prepare($updateCountQuery);
            $updateStmt->bindParam(':group_id', $groupId);
            $updateStmt->execute();
            
            $createdGroups[] = [
                'group_id' => $groupId,
                'name' => $groupData['name'],
                'slug' => $groupData['slug']
            ];
            
            echo "Groupe '{$groupData['name']}' créé avec ID: $groupId\n";
        } else {
            $existingGroup = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "Groupe '{$groupData['name']}' existe déjà avec ID: {$existingGroup['id']}\n";
        }
    }
    
    // 5. Vérifier le résultat final
    $finalCheckQuery = "SELECT COUNT(*) as total FROM user_groups";
    $stmt = $db->prepare($finalCheckQuery);
    $stmt->execute();
    $totalGroups = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    $membersCheckQuery = "SELECT COUNT(*) as total FROM group_members";
    $stmt = $db->prepare($membersCheckQuery);
    $stmt->execute();
    $totalMembers = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo json_encode([
        'success' => true,
        'message' => 'Données de test créées avec succès',
        'statistics' => [
            'total_groups' => $totalGroups,
            'total_members' => $totalMembers,
            'created_groups' => count($createdGroups)
        ],
        'created_groups' => $createdGroups,
        'references' => [
            'institution_id' => $institutionId,
            'program_id' => $programId,
            'department_id' => $departmentId
        ]
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ], JSON_PRETTY_PRINT);
}
?>
