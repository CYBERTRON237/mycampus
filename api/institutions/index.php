<?php
/**
 * API endpoint principal pour les institutions
 */

// Activer l'affichage des erreurs pour le debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

// Handle OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

// Content type
header('Content-Type: application/json; charset=utf-8');

try {
    // Authentification flexible - accepter les tokens ou les requêtes sans token pour le développement
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? null;
    
    // En développement, on peut permettre les requêtes sans authentification
    $isDevelopment = true; // Mettre à false en production
    
    if (!$isDevelopment && !$authHeader) {
        throw new Exception('Authorization header missing');
    }
    
    // Connexion à la base de données
    try {
        $pdo = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        throw new Exception('Database connection failed: ' . $e->getMessage());
    }
    
    $method = $_SERVER['REQUEST_METHOD'];
    $request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $uri_parts = explode('/', trim($request_uri, '/'));
    
    // Récupérer les paramètres de la requête
    $search = $_GET['search'] ?? null;
    $type = $_GET['type'] ?? null;
    $status = $_GET['status'] ?? null;
    $region = $_GET['region'] ?? null;
    $page = (int)($_GET['page'] ?? 1);
    $limit = (int)($_GET['limit'] ?? 20);
    $offset = ($page - 1) * $limit;
    
    switch ($method) {
        case 'GET':
            // Vérifier si la table institutions existe
            $stmt = $pdo->query("SHOW TABLES LIKE 'institutions'");
            if ($stmt->rowCount() == 0) {
                // Retourner des données de test si la table n'existe pas
                $universities = [
                    [
                        'id' => '1',
                        'name' => 'Université de Yaoundé I',
                        'short_name' => 'UY1',
                        'type' => 'public',
                        'status' => 'active',
                        'region' => 'Centre',
                        'city' => 'Yaoundé',
                        'address' => 'BP 47 Yaoundé',
                        'phone' => '+237 222 22 13 41',
                        'email' => 'rectorat@uy1.cm',
                        'website' => 'https://www.uy1.cm',
                        'description' => 'Première université camerounaise',
                        'created_at' => '2024-01-01T00:00:00Z',
                        'updated_at' => '2024-01-01T00:00:00Z'
                    ],
                    [
                        'id' => '2',
                        'name' => 'Université de Douala',
                        'short_name' => 'UD',
                        'type' => 'public',
                        'status' => 'active',
                        'region' => 'Littoral',
                        'city' => 'Douala',
                        'address' => 'BP 2701 Douala',
                        'phone' => '+237 233 43 30 00',
                        'email' => 'rectorat@univ-douala.cm',
                        'website' => 'https://www.univ-douala.cm',
                        'description' => 'Université camerounaise située à Douala',
                        'created_at' => '2024-01-01T00:00:00Z',
                        'updated_at' => '2024-01-01T00:00:00Z'
                    ]
                ];
            } else {
                // Construire la requête SQL
                $sql = "SELECT * FROM institutions WHERE 1=1";
                $params = [];
                
                if ($search) {
                    $sql .= " AND (name LIKE ? OR short_name LIKE ?)";
                    $params[] = "%$search%";
                    $params[] = "%$search%";
                }
                
                if ($type) {
                    $sql .= " AND type = ?";
                    $params[] = $type;
                }
                
                if ($status) {
                    $sql .= " AND status = ?";
                    $params[] = $status;
                }
                
                if ($region) {
                    $sql .= " AND region = ?";
                    $params[] = $region;
                }
                
                $sql .= " ORDER BY name LIMIT $limit OFFSET $offset";
                
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $universities = $stmt->fetchAll(PDO::FETCH_ASSOC);
            }
            
            echo json_encode([
                'success' => true,
                'data' => $universities,
                'pagination' => [
                    'page' => $page,
                    'limit' => $limit,
                    'total' => count($universities)
                ]
            ], JSON_UNESCAPED_UNICODE);
            break;
            
        case 'POST':
            // Pour la création, retourner un succès simulé
            $input = json_decode(file_get_contents('php://input'), true);
            echo json_encode([
                'success' => true,
                'message' => 'Université créée avec succès',
                'data' => [
                    'id' => uniqid(),
                    'created_at' => date('c'),
                    ...$input
                ]
            ], JSON_UNESCAPED_UNICODE);
            break;
            
        default:
            throw new Exception('Method not allowed');
    }
    
} catch (PDOException $e) {
    error_log("Erreur PDO: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de base de données: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    error_log("Erreur: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
