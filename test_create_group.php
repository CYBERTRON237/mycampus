<?php
// Script de test pour créer un groupe et un membre

require_once __DIR__ . '/config/database.php';

header('Content-Type: application/json');

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception('Connexion à la base de données échouée');
    }
    
    // Créer un groupe de test
    $groupQuery = "INSERT INTO user_groups (uuid, name, slug, description, group_type, visibility, created_by) 
                   VALUES (UUID(), 'Groupe de Test', 'groupe-de-test', 'Groupe de test pour la messagerie', 'chat', 'private', 38)";
    
    $stmt = $db->prepare($groupQuery);
    $stmt->execute();
    $groupId = $db->lastInsertId();
    
    // Ajouter l'utilisateur comme membre du groupe
    $memberQuery = "INSERT INTO group_members (uuid, group_id, user_id, role, status) 
                    VALUES (UUID(), ?, ?, 'admin', 'active')";
    
    $memberStmt = $db->prepare($memberQuery);
    $memberStmt->execute([$groupId, 38]);
    
    // Mettre à jour le compteur de membres
    $updateCountQuery = "UPDATE user_groups SET current_members_count = 1 WHERE id = ?";
    $updateCountStmt = $db->prepare($updateCountQuery);
    $updateCountStmt->execute([$groupId]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Groupe de test créé avec succès',
        'group_id' => $groupId,
        'test_data' => [
            'group_name' => 'Groupe de Test',
            'user_id' => 38,
            'role' => 'admin'
        ]
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error' => $e->getTraceAsString()
    ], JSON_PRETTY_PRINT);
}
?>
