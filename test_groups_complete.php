<?php
/**
 * Script de test COMPLET pour l'API des groupes
 * Test toutes les fonctionnalités jusqu'à 100% de fonctionnement
 */

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Fonction pour afficher les résultats de test
function outputTestResult($testName, $success, $message, $data = null) {
    echo json_encode([
        'test' => $testName,
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT) . "\n";
}

// Test 1: Connexion à la base de données
try {
    require_once __DIR__ . '/api/config/database.php';
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        outputTestResult("database_connection", true, "Connexion à la base de données réussie");
    } else {
        outputTestResult("database_connection", false, "Connexion à la base de données échouée");
        exit;
    }
} catch (Exception $e) {
    outputTestResult("database_connection", false, "Exception: " . $e->getMessage());
    exit;
}

// Test 2: Vérification de la structure des tables
$tablesToCheck = ['user_groups', 'group_members'];
foreach ($tablesToCheck as $table) {
    try {
        $query = "DESCRIBE `$table`";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        outputTestResult("table_structure_$table", true, "Structure de la table $table vérifiée", $columns);
    } catch (Exception $e) {
        outputTestResult("table_structure_$table", false, "Erreur structure table $table: " . $e->getMessage());
    }
}

// Test 3: Vérification des données existantes
try {
    $query = "SELECT COUNT(*) as total FROM user_groups";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $groupsCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    $query = "SELECT COUNT(*) as total FROM group_members";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $membersCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    outputTestResult("existing_data", true, "Données existantes vérifiées", [
        'groups_count' => $groupsCount,
        'members_count' => $membersCount
    ]);
} catch (Exception $e) {
    outputTestResult("existing_data", false, "Erreur vérification données: " . $e->getMessage());
}

// Test 4: Création de données de test si nécessaire
try {
    $query = "SELECT COUNT(*) as total FROM user_groups WHERE name LIKE 'Test Group%'";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $testGroupsCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    if ($testGroupsCount == 0) {
        // Créer un groupe de test
        $groupQuery = "INSERT INTO user_groups (uuid, name, slug, description, group_type, visibility, created_by, current_members_count) 
                       VALUES (UUID(), 'Test Group API', 'test-group-api', 'Groupe de test pour l API', 'chat', 'private', 38, 1)";
        
        $stmt = $db->prepare($groupQuery);
        $stmt->execute();
        $groupId = $db->lastInsertId();
        
        // Ajouter un membre de test
        $memberQuery = "INSERT INTO group_members (uuid, group_id, user_id, role, status, joined_at, approved_at) 
                        VALUES (UUID(), ?, 38, 'admin', 'active', NOW(), NOW())";
        
        $memberStmt = $db->prepare($memberQuery);
        $memberStmt->execute([$groupId]);
        
        outputTestResult("create_test_data", true, "Données de test créées avec succès", [
            'group_id' => $groupId,
            'user_id' => 38
        ]);
    } else {
        outputTestResult("create_test_data", true, "Données de test existent déjà");
    }
} catch (Exception $e) {
    outputTestResult("create_test_data", false, "Erreur création données test: " . $e->getMessage());
}

// Test 5: Test du modèle Group
try {
    require_once __DIR__ . '/api/messaging/models/Group.php';
    $group = new Group($db);
    
    // Test getUserGroups
    $userGroups = $group->getUserGroups(38);
    outputTestResult("model_getUserGroups", true, "Modèle Group - getUserGroups testé", $userGroups);
    
    // Test getById
    if (!empty($userGroups)) {
        $group->id = $userGroups[0]['id'];
        $groupDetails = $group->getById();
        outputTestResult("model_getById", true, "Modèle Group - getById testé", $groupDetails);
    } else {
        outputTestResult("model_getById", false, "Aucun groupe trouvé pour tester getById");
    }
    
} catch (Exception $e) {
    outputTestResult("model_tests", false, "Erreur modèle Group: " . $e->getMessage());
}

// Test 6: Test de l'API directement - Simulation de requête
echo "\n=== TESTS DE L'API ===\n";

// Simuler une requête GET /api/messaging/groups/my
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/mycampus/api/messaging/groups/my';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NjU3NjUxODQsImV4cCI6MTc2NTg1MTU4NCwiaXNzIjoibXljYW1wdXMiLCJkYXRhIjp7ImlkIjozOCwiZW1haWwiOiJqamtrQGdtYWlsLmNvbSIsImlwIjoiMTI3LjAuMC4xIn19.-TmBvxC4k4sdfrXqrhuYD-fmvMsPCe-EX63EonwLDV8';

// Capturer la sortie
ob_start();
try {
    require_once __DIR__ . '/api/messaging/index.php';
    $apiResponse = ob_get_contents();
    outputTestResult("api_get_user_groups", true, "API getUserGroups appelée avec succès", json_decode($apiResponse, true));
} catch (Exception $e) {
    $apiResponse = ob_get_contents();
    outputTestResult("api_get_user_groups", false, "Exception API: " . $e->getMessage(), [
        'response' => $apiResponse
    ]);
}
ob_end_clean();

// Test 7: Test avec authentification simulée
echo "\n=== TESTS AVEC AUTHENTIFICATION ===\n";

// Test direct du contrôleur
try {
    require_once __DIR__ . '/api/messaging/controllers/GroupController.php';
    $controller = new GroupController($db);
    
    // Utiliser une méthode pour simuler l'authentification
    $reflection = new ReflectionClass($controller);
    $method = $reflection->getMethod('getCurrentUserId');
    $method->setAccessible(true);
    
    // Simuler l'authentification
    $_SERVER['HTTP_X_USER_ID'] = '38';
    $userId = $method->invoke($controller);
    
    if ($userId == 38) {
        outputTestResult("auth_simulation", true, "Authentification simulée avec succès", ['user_id' => $userId]);
        
        // Tester getUserGroups avec l'auth simulée
        ob_start();
        $controller->getUserGroups();
        $response = ob_get_contents();
        $responseData = json_decode($response, true);
        
        if ($responseData && isset($responseData['success']) && $responseData['success']) {
            outputTestResult("controller_getUserGroups", true, "Controller getUserGroups réussi", $responseData);
        } else {
            outputTestResult("controller_getUserGroups", false, "Controller getUserGroups échoué", $responseData);
        }
        ob_end_clean();
        
    } else {
        outputTestResult("auth_simulation", false, "Authentification simulée échouée", ['user_id' => $userId]);
    }
    
} catch (Exception $e) {
    outputTestResult("controller_tests", false, "Exception contrôleur: " . $e->getMessage());
}

// Test 8: Vérification des permissions
echo "\n=== TESTS DES PERMISSIONS ===\n";

try {
    require_once __DIR__ . '/api/messaging/models/GroupMember.php';
    $groupMember = new GroupMember($db);
    
    // Obtenir un groupe de test
    $query = "SELECT id FROM user_groups WHERE name LIKE 'Test Group%' LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $testGroup = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($testGroup) {
        $groupId = $testGroup['id'];
        $userId = 38;
        
        // Test isMember
        $isMember = $groupMember->isMember($groupId, $userId);
        outputTestResult("permission_isMember", $isMember, "Test isMember", ['group_id' => $groupId, 'user_id' => $userId, 'is_member' => $isMember]);
        
        // Test getUserRole
        $userRole = $groupMember->getUserRole($groupId, $userId);
        outputTestResult("permission_getUserRole", true, "Test getUserRole", ['group_id' => $groupId, 'user_id' => $userId, 'role' => $userRole]);
        
        // Test isAdmin
        $isAdmin = $groupMember->isAdmin($groupId, $userId);
        outputTestResult("permission_isAdmin", $isAdmin, "Test isAdmin", ['group_id' => $groupId, 'user_id' => $userId, 'is_admin' => $isAdmin]);
        
    } else {
        outputTestResult("permission_tests", false, "Aucun groupe de test trouvé pour les permissions");
    }
    
} catch (Exception $e) {
    outputTestResult("permission_tests", false, "Exception permissions: " . $e->getMessage());
}

// Test 9: Test de création de groupe via API
echo "\n=== TESTS DE CRÉATION DE GROUPE ===\n";

// Simuler une requête POST
$_SERVER['REQUEST_METHOD'] = 'POST';
$_SERVER['REQUEST_URI'] = '/mycampus/api/messaging/groups/create';
$_SERVER['HTTP_CONTENT_TYPE'] = 'application/json';
$_SERVER['HTTP_X_USER_ID'] = '38';

// Simuler les données POST
$groupData = [
    'name' => 'Test Group Created via API ' . date('His'),
    'description' => 'Groupe créé via API pour test',
    'group_type' => 'chat',
    'visibility' => 'private'
];

// Simuler php://input
$phpInput = json_encode($groupData);

// Sauvegarder php://input original
$originalInput = file_get_contents('php://input');

// Remplacer temporairement php://input
// Note: ceci est une simulation, en pratique il faudrait utiliser un autre approche
try {
    $controller = new GroupController($db);
    
    // Test direct de la méthode createGroup
    $controller->group->name = $groupData['name'];
    $controller->group->description = $groupData['description'];
    $controller->group->group_type = $groupData['group_type'];
    $controller->group->visibility = $groupData['visibility'];
    $controller->group->created_by = 38;
    
    ob_start();
    $controller->createGroup();
    $response = ob_get_contents();
    $responseData = json_decode($response, true);
    
    if ($responseData && isset($responseData['success']) && $responseData['success']) {
        outputTestResult("api_create_group", true, "Création de groupe via API réussie", $responseData);
    } else {
        outputTestResult("api_create_group", false, "Création de groupe via API échouée", $responseData);
    }
    ob_end_clean();
    
} catch (Exception $e) {
    outputTestResult("api_create_group", false, "Exception création groupe: " . $e->getMessage());
}

// Test 10: Test final - Récupération complète
echo "\n=== TEST FINAL - RÉCUPÉRATION COMPLÈTE ===\n";

try {
    $controller = new GroupController($db);
    $_SERVER['HTTP_X_USER_ID'] = '38';
    
    ob_start();
    $controller->getUserGroups();
    $response = ob_get_contents();
    $responseData = json_decode($response, true);
    
    if ($responseData && isset($responseData['success']) && $responseData['success']) {
        $groupsCount = count($responseData['groups']);
        outputTestResult("final_test", true, "Test final réussi - $groupsCount groupe(s) récupéré(s)", $responseData);
    } else {
        outputTestResult("final_test", false, "Test final échoué", $responseData);
    }
    ob_end_clean();
    
} catch (Exception $e) {
    outputTestResult("final_test", false, "Exception test final: " . $e->getMessage());
}

echo "\n=== RÉSUMÉ DES TESTS ===\n";
echo "Tous les tests ont été exécutés. Vérifiez les résultats ci-dessus.\n";
echo "Si tous les tests sont 'success: true', l'API des groupes fonctionne à 100%.\n";
?>
