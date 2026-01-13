<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../jwt/jwt_utils.php';
require_once 'models/Institution.php';
require_once 'controllers/InstitutionController.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $institution = new Institution($db);
    $controller = new InstitutionController($institution);
    
    $method = $_SERVER['REQUEST_METHOD'];
    $uri = $_SERVER['REQUEST_URI'];
    $path = parse_url($uri, PHP_URL_PATH);
    
    // Nettoyer le chemin pour correspondre au router principal
    $base_path = '/mycampus/api';
    $path = str_replace($base_path, '', $path);
    $pathParts = explode('/', trim($path, '/'));
    
    // Authentification - Désactivée temporairement pour les tests
    /*
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? '';
    $token = str_replace('Bearer ', '', $authHeader);
    
    // Désactiver temporairement l'authentification pour les régions
    if (count($pathParts) > 3 && $pathParts[2] === 'regions') {
        // Pas d'authentification requise pour les régions
    } elseif (!$token || !JWTUtils::validateToken($token)) {
        http_response_code(401);
        echo json_encode(['error' => 'Non authentifié']);
        exit;
    }
    */
    
    // Router
    switch ($method) {
        case 'GET':
            if (count($pathParts) > 3 && $pathParts[2] === 'regions') {
                // GET /api/universities/regions
                $controller->getRegions();
            } elseif (count($pathParts) > 2 && $pathParts[2] !== '') {
                // GET /api/universities/{id}
                $id = $pathParts[2];
                $controller->getInstitution($id);
            } else {
                // GET /api/universities
                $controller->getInstitutions();
            }
            break;
            
        case 'POST':
            // POST /api/universities
            $controller->createInstitution();
            break;
            
        case 'PUT':
            if (count($pathParts) > 2 && $pathParts[2] !== '') {
                // PUT /api/universities/{id}
                $id = $pathParts[2];
                $controller->updateInstitution($id);
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'ID manquant']);
            }
            break;
            
        case 'DELETE':
            if (count($pathParts) > 2 && $pathParts[2] !== '') {
                // DELETE /api/universities/{id}
                $id = $pathParts[2];
                $controller->deleteInstitution($id);
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'ID manquant']);
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
?>
