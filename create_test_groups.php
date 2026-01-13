<?php
require_once __DIR__ . '/api/config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Creating test groups...\n";
    
    // Create some test groups
    $groups = [
        [
            'uuid' => '550e8400-e29b-41d4-a716-446655440001',
            'institution_id' => 1,
            'group_type' => 'club',
            'visibility' => 'public',
            'name' => 'Club de Programmation',
            'slug' => 'club-de-programmation',
            'description' => 'Un club pour les passionnés de programmation',
            'is_official' => 0,
            'created_by' => 1
        ],
        [
            'uuid' => '550e8400-e29b-41d4-a716-446655440002',
            'institution_id' => 1,
            'group_type' => 'academic',
            'visibility' => 'private',
            'name' => 'Groupe d\'étude Mathématiques',
            'slug' => 'groupe-etude-mathematiques',
            'description' => 'Groupe pour étudier les mathématiques ensemble',
            'is_official' => 0,
            'created_by' => 2
        ],
        [
            'uuid' => '550e8400-e29b-41d4-a716-446655440003',
            'institution_id' => 1,
            'group_type' => 'project',
            'visibility' => 'public',
            'name' => 'Projet Mobile App',
            'slug' => 'projet-mobile-app',
            'description' => 'Développement d\'une application mobile',
            'is_official' => 1,
            'created_by' => 1
        ]
    ];
    
    foreach ($groups as $group) {
        $query = "INSERT INTO user_groups (uuid, institution_id, group_type, visibility, name, slug, description, is_official, created_by) 
                  VALUES (:uuid, :institution_id, :group_type, :visibility, :name, :slug, :description, :is_official, :created_by)";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':uuid', $group['uuid']);
        $stmt->bindParam(':institution_id', $group['institution_id']);
        $stmt->bindParam(':group_type', $group['group_type']);
        $stmt->bindParam(':visibility', $group['visibility']);
        $stmt->bindParam(':name', $group['name']);
        $stmt->bindParam(':slug', $group['slug']);
        $stmt->bindParam(':description', $group['description']);
        $stmt->bindParam(':is_official', $group['is_official']);
        $stmt->bindParam(':created_by', $group['created_by']);
        
        $stmt->execute();
        $groupId = $db->lastInsertId();
        
        // Add user 40 as member of first group
        if ($group['uuid'] === '550e8400-e29b-41d4-a716-446655440001') {
            $memberQuery = "INSERT INTO group_members (group_id, user_id, role, status) VALUES (:group_id, :user_id, 'member', 'active')";
            $memberStmt = $db->prepare($memberQuery);
            $memberStmt->bindParam(':group_id', $groupId);
            $memberStmt->bindValue(':user_id', 40);
            $memberStmt->execute();
            
            echo "Added user 40 to group: " . $group['name'] . "\n";
        }
        
        echo "Created group: " . $group['name'] . " (ID: $groupId)\n";
    }
    
    echo "Test groups created successfully!\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
