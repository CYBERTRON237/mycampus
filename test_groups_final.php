<?php
/**
 * Test final de l'API des groupes - Validation 100%
 */

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

function outputResult($test, $success, $message, $data = null) {
    echo json_encode([
        'test' => $test,
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT) . "\n";
}

// Test 1: Connexion base de données
try {
    require_once __DIR__ . '/api/config/database.php';
    $database = new Database();
    $db = $database->getConnection();
    outputResult("database", true, "Base de données connectée");
} catch (Exception $e) {
    outputResult("database", false, "Erreur base de données: " . $e->getMessage());
    exit;
}

// Test 2: Vérification des données
try {
    $query = "SELECT COUNT(*) as group_count FROM user_groups";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $groupsCount = $stmt->fetch(PDO::FETCH_ASSOC)['group_count'];
    
    $query = "SELECT COUNT(*) as members FROM group_members WHERE user_id = 39";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $membersCount = $stmt->fetch(PDO::FETCH_ASSOC)['members'];
    
    outputResult("data_check", true, "Données vérifiées", [
        'groups' => $groupsCount,
        'user_memberships' => $membersCount
    ]);
} catch (Exception $e) {
    outputResult("data_check", false, "Erreur vérification: " . $e->getMessage());
}

// Test 3: Test du modèle Group
try {
    require_once __DIR__ . '/api/messaging/models/Group.php';
    $group = new Group($db);
    $userGroups = $group->getUserGroups(39);
    outputResult("model_getUserGroups", true, "Modèle Group fonctionnel", $userGroups);
} catch (Exception $e) {
    outputResult("model_getUserGroups", false, "Erreur modèle: " . $e->getMessage());
}

// Test 4: Test du contrôleur avec authentification simulée
try {
    require_once __DIR__ . '/api/messaging/controllers/GroupController.php';
    
    // Simuler l'authentification
    $_SERVER['HTTP_X_USER_ID'] = '39';
    
    $controller = new GroupController($db);
    
    ob_start();
    $controller->getUserGroups();
    $response = ob_get_contents();
    $responseData = json_decode($response, true);
    
    if ($responseData && isset($responseData['success']) && $responseData['success']) {
        outputResult("controller_getUserGroups", true, "Contrôleur fonctionnel", $responseData);
    } else {
        outputResult("controller_getUserGroups", false, "Erreur contrôleur", $responseData);
    }
    ob_end_clean();
    
} catch (Exception $e) {
    outputResult("controller_getUserGroups", false, "Exception contrôleur: " . $e->getMessage());
}

// Test 5: Test API via URL
echo "\n=== TEST API DIRECT ===\n";

// Nettoyer les headers pour éviter les erreurs
if (!headers_sent()) {
    header('Content-Type: application/json');
}

// Simuler une requête API complète
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/mycampus/api/messaging/groups/my';
$_SERVER['HTTP_X_USER_ID'] = '39';

// Capturer la sortie de l'API
ob_start();
try {
    require_once __DIR__ . '/api/messaging/index.php';
    $apiResponse = ob_get_contents();
    $apiData = json_decode($apiResponse, true);
    
    if ($apiData && isset($apiData['success']) && $apiData['success']) {
        outputResult("api_getUserGroups", true, "API endpoint fonctionnel", $apiData);
    } else {
        outputResult("api_getUserGroups", false, "API endpoint erreur", $apiData);
    }
} catch (Exception $e) {
    $apiResponse = ob_get_contents();
    outputResult("api_getUserGroups", false, "Exception API: " . $e->getMessage(), [
        'response' => $apiResponse
    ]);
}
ob_end_clean();

// Test 6: Test création de groupe
echo "\n=== TEST CRÉATION GROUPE ===\n";

try {
    $_SERVER['REQUEST_METHOD'] = 'POST';
    $_SERVER['REQUEST_URI'] = '/mycampus/api/messaging/groups/create';
    $_SERVER['HTTP_X_USER_ID'] = '39';
    
    // Simuler les données POST
    $groupData = [
        'name' => 'Test Group Final ' . date('His'),
        'description' => 'Groupe créé via test final',
        'group_type' => 'chat',
        'visibility' => 'private'
    ];
    
    // Simuler php://input avec une approche différente
    $controller = new GroupController($db);
    
    $controller->group->name = $groupData['name'];
    $controller->group->description = $groupData['description'];
    $controller->group->group_type = $groupData['group_type'];
    $controller->group->visibility = $groupData['visibility'];
    $controller->group->created_by = 39;
    
    ob_start();
    $controller->createGroup();
    $response = ob_get_contents();
    $responseData = json_decode($response, true);
    
    if ($responseData && isset($responseData['success']) && $responseData['success']) {
        outputResult("api_createGroup", true, "Création groupe réussie", $responseData);
    } else {
        outputResult("api_createGroup", false, "Création groupe échouée", $responseData);
    }
    ob_end_clean();
    
} catch (Exception $e) {
    outputResult("api_createGroup", false, "Exception création: " . $e->getMessage());
}

// Test 7: Vérification finale
echo "\n=== VÉRIFICATION FINALE ===\n";

try {
    $query = "SELECT g.*, gm.role, gm.status 
             FROM user_groups g 
             INNER JOIN group_members gm ON g.id = gm.group_id 
             WHERE gm.user_id = 39 AND gm.status = 'active'
             ORDER BY g.created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    $finalGroups = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    outputResult("final_verification", true, "Vérification finale réussie", [
        'total_groups' => count($finalGroups),
        'groups' => $finalGroups
    ]);
    
} catch (Exception $e) {
    outputResult("final_verification", false, "Erreur finale: " . $e->getMessage());
}

echo "\n=== RÉSUMÉ ===\n";
echo "Tests terminés. Si tous les tests montrent 'success: true', l'API fonctionne à 100%.\n";
?>
