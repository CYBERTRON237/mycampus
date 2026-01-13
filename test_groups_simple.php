<?php
/**
 * Test simple et direct de l'API des groupes
 * Sans les headers qui causent des problèmes
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
    
    // Test direct du modèle
    require_once __DIR__ . '/api/messaging/models/Group.php';
    $group = new Group($db);
    
    // Récupérer les groupes de l'utilisateur 39
    $userGroups = $group->getUserGroups(39);
    
    output(true, "API Groups fonctionne parfaitement", [
        'total_groups' => count($userGroups),
        'groups' => $userGroups,
        'user_id' => 39
    ]);
    
} catch (Exception $e) {
    output(false, "Erreur: " . $e->getMessage());
}
?>
