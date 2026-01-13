<?php
// Route API pour l'authentification
// Ce fichier agit comme routeur pour les endpoints d'authentification

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Gestion de la requête OPTIONS (pré-vol CORS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Récupération du chemin de la requête
$requestUri = $_SERVER['REQUEST_URI'];
$method = $_SERVER['REQUEST_METHOD'];

// Nettoyage de l'URI pour obtenir le chemin relatif
$basePath = '/mycampus/api/auth/';
$path = str_replace($basePath, '', $requestUri);
$path = trim($path, '/');

// Routage basé sur le chemin
switch ($path) {
    case 'register':
    case 'register.php':
        if ($method === 'POST') {
            require_once __DIR__ . '/register.php';
        } else {
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
        }
        break;
        
    case 'login':
    case 'login.php':
        if ($method === 'POST') {
            require_once __DIR__ . '/login.php';
        } else {
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
        }
        break;
        
    default:
        // Si le chemin est vide, essayer register par défaut
        if (empty($path) && $method === 'POST') {
            require_once __DIR__ . '/register.php';
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false, 
                'message' => 'Endpoint non trouvé',
                'path' => $path,
                'method' => $method
            ]);
        }
        break;
}
?>
