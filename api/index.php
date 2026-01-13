<?php
// Activer l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Définir le fuseau horaire
date_default_timezone_set('Africa/Douala');

// Gérer les requêtes CORS de manière centralisée
require_once __DIR__ . '/config/cors.php';

// Définir le type de contenu pour toutes les réponses
header("Content-Type: application/json; charset=UTF-8");

// Fonction pour envoyer une réponse JSON
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

// Récupérer l'URL demandée
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$request_method = $_SERVER['REQUEST_METHOD'];

// Debug
error_log("Request URI: " . $_SERVER['REQUEST_URI']);
error_log("Parsed URI: " . $request_uri);

// Nettoyer l'URL en supprimant le chemin de base
$base_path = '/mycampus/api';
$request_uri = str_replace($base_path, '', $request_uri);

error_log("Clean URI: " . $request_uri);
error_log("Checking routes for: '" . $request_uri . "'");

// Router les requêtes
switch ($request_uri) {
    case '/test':
        sendResponse(['success' => true, 'message' => 'Route test works!', 'uri' => $request_uri]);
        break;
        
    case '/institutions':
    case '/institutions/':
        // Temporairement sans authentification pour les tests
        require_once __DIR__ . '/config/database.php';
        require_once __DIR__ . '/jwt/jwt_utils.php';
        require_once __DIR__ . '/universities/models/Institution.php';
        require_once __DIR__ . '/universities/controllers/InstitutionController.php';
        
        $database = new Database();
        $db = $database->getConnection();
        $institution = new Institution($db);
        $controller = new InstitutionController($institution);
        
        try {
            $result = $controller->getInstitutions();
            echo json_encode($result);
        } catch (Exception $e) {
            error_log("Error in institutions route: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => $e->getMessage()]);
        }
        break;
        
    case '/institutions/regions':
    case '/institutions/regions/':
        require_once __DIR__ . '/config/database.php';
        require_once __DIR__ . '/jwt/jwt_utils.php';
        require_once __DIR__ . '/universities/models/Institution.php';
        require_once __DIR__ . '/universities/controllers/InstitutionController.php';
        
        $database = new Database();
        $db = $database->getConnection();
        $institution = new Institution($db);
        $controller = new InstitutionController($institution);
        
        try {
            $result = $controller->getRegions();
            echo json_encode($result);
        } catch (Exception $e) {
            error_log("Error in institutions/regions route: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => $e->getMessage()]);
        }
        break;
        
    case '/announcements':
    case '/announcements/':
        // Forward to announcements API
        require_once __DIR__ . '/announcements/routes/api.php';
        break;
        
    default:
        // Gérer les routes avec ID
        if (strpos($request_uri, '/institutions/') === 0) {
            // Extraire l'ID de l'URL
            $pathParts = explode('/', trim($request_uri, '/'));
            $id = $pathParts[1] ?? null;
            
            if ($id && is_numeric($id)) {
                require_once __DIR__ . '/config/database.php';
                require_once __DIR__ . '/jwt/jwt_utils.php';
                require_once __DIR__ . '/universities/models/Institution.php';
                require_once __DIR__ . '/universities/controllers/InstitutionController.php';
                
                $database = new Database();
                $db = $database->getConnection();
                $institution = new Institution($db);
                $controller = new InstitutionController($institution);
                
                try {
                    if ($request_method === 'GET') {
                        $result = $controller->getInstitution($id);
                        echo json_encode($result);
                    } elseif ($request_method === 'PUT') {
                        $result = $controller->updateInstitution($id);
                        echo json_encode($result);
                    } elseif ($request_method === 'DELETE') {
                        $result = $controller->deleteInstitution($id);
                        echo json_encode($result);
                    } else {
                        sendResponse(['success' => false, 'message' => 'Méthode non autorisée'], 405);
                    }
                } catch (Exception $e) {
                    error_log("Error in institutions ID route: " . $e->getMessage());
                    http_response_code(500);
                    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
                }
            } else {
                sendResponse(['success' => false, 'message' => 'ID invalide'], 400);
            }
        } elseif (strpos($request_uri, '/announcements/') === 0) {
            // Forward all announcements sub-routes to announcements API
            require_once __DIR__ . '/announcements/routes/api.php';
        } else {
            // Vérifier si c'est une requête vers un fichier existant
            $file_path = __DIR__ . $request_uri;
            if (file_exists($file_path) && !is_dir($file_path)) {
                return false; // Laissez le serveur web gérer les fichiers statiques
            }
            
            sendResponse(['success' => false, 'message' => 'Route non trouvée'], 404);
        }
        break;
}
?>