<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-User-Id');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../controllers/GroupController.php';

$database = new Database();
$db = $database->getConnection();

$controller = new GroupController($db);

$method = $_SERVER['REQUEST_METHOD'];
$requestUri = $_SERVER['REQUEST_URI'];
$uriParts = explode('/', trim($requestUri, '/'));

$groupsIndex = array_search('groups', $uriParts);

if ($groupsIndex !== false) {
    $actionIndex = $groupsIndex + 1;
    $action = $uriParts[$actionIndex] ?? '';
    
    try {
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
                } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'search') {
                    $groupId = (int)$action;
                    $controller->searchMembers($groupId);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Endpoint non trouvé']);
                }
                break;
                
            case 'GET':
                if ($action === 'my') {
                    $controller->getUserGroups();
                } elseif ($action === 'search') {
                    $searchTerm = $_GET['q'] ?? '';
                    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
                    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
                    $controller->searchGroups($searchTerm, $limit, $offset);
                } elseif (is_numeric($action)) {
                    $groupId = (int)$action;
                    if (isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'members') {
                        if (isset($uriParts[$actionIndex + 2]) && $uriParts[$actionIndex + 2] === 'pending') {
                            $controller->getPendingMembers($groupId);
                        } else {
                            $controller->getGroupMembers($groupId);
                        }
                    } else {
                        $controller->getGroup($groupId);
                    }
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Endpoint non trouvé']);
                }
                break;
                
            case 'PUT':
                if (is_numeric($action)) {
                    $groupId = (int)$action;
                    if (isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'members') {
                        $memberId = (int)($uriParts[$actionIndex + 2] ?? 0);
                        $newRole = $_GET['role'] ?? 'member';
                        $controller->updateMemberRole($groupId, $memberId, $newRole);
                    } else {
                        $controller->updateGroup($groupId);
                    }
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Endpoint non trouvé']);
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
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Endpoint non trouvé']);
                }
                break;
                
            default:
                http_response_code(405);
                echo json_encode(['error' => 'Méthode non autorisée']);
                break;
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint non trouvé']);
}
?>
