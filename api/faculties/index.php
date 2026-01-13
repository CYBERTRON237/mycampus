<?php
/**
 * API endpoint principal pour les facultés
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
    $id = $_GET['id'] ?? null;
    $institutionId = $_GET['institution_id'] ?? null;
    $search = $_GET['search'] ?? null;
    $status = $_GET['status'] ?? null;
    $page = (int)($_GET['page'] ?? 1);
    $limit = (int)($_GET['limit'] ?? 20);
    $offset = ($page - 1) * $limit;
    $action = $_GET['action'] ?? null;
    
    switch ($method) {
        case 'GET':
            if ($id) {
                // Récupérer une faculté spécifique
                $stmt = $pdo->prepare("SELECT * FROM faculties WHERE id = ?");
                $stmt->execute([$id]);
                $faculty = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$faculty) {
                    throw new Exception('Faculté non trouvée');
                }
                
                echo json_encode([
                    'success' => true,
                    'data' => $faculty
                ], JSON_UNESCAPED_UNICODE);
            } else {
                // Récupérer la liste des facultés
                $sql = "SELECT f.*, i.name as institution_name 
                        FROM faculties f 
                        LEFT JOIN institutions i ON f.institution_id = i.id 
                        WHERE 1=1";
                $params = [];
                
                if ($institutionId) {
                    $sql .= " AND f.institution_id = ?";
                    $params[] = $institutionId;
                }
                
                if ($search) {
                    $sql .= " AND (f.name LIKE ? OR f.short_name LIKE ? OR f.code LIKE ?)";
                    $params[] = "%$search%";
                    $params[] = "%$search%";
                    $params[] = "%$search%";
                }
                
                if ($status) {
                    $sql .= " AND f.status = ?";
                    $params[] = $status;
                }
                
                $sql .= " ORDER BY f.name LIMIT $limit OFFSET $offset";
                
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $faculties = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                echo json_encode([
                    'success' => true,
                    'data' => $faculties,
                    'pagination' => [
                        'page' => $page,
                        'limit' => $limit,
                        'total' => count($faculties)
                    ]
                ], JSON_UNESCAPED_UNICODE);
            }
            break;
            
        case 'POST':
            // Créer une nouvelle faculté
            $input = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare("
                INSERT INTO faculties (
                    institution_id, code, name, short_name, description, 
                    dean_name, contact_email, contact_phone, office_location,
                    status, total_students, total_staff, total_departments,
                    total_programs, website, logo_url, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
            ");
            
            $stmt->execute([
                $input['institution_id'],
                $input['code'],
                $input['name'],
                $input['short_name'],
                $input['description'] ?? null,
                $input['dean_name'] ?? null,
                $input['contact_email'] ?? null,
                $input['contact_phone'] ?? null,
                $input['office_location'] ?? null,
                $input['status'] ?? 'active',
                $input['total_students'] ?? 0,
                $input['total_staff'] ?? 0,
                $input['total_departments'] ?? 0,
                $input['total_programs'] ?? 0,
                $input['website'] ?? null,
                $input['logo_url'] ?? null,
            ]);
            
            $facultyId = $pdo->lastInsertId();
            
            // Récupérer la faculté créée
            $stmt = $pdo->prepare("SELECT * FROM faculties WHERE id = ?");
            $stmt->execute([$facultyId]);
            $faculty = $stmt->fetch(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'message' => 'Faculté créée avec succès',
                'data' => $faculty
            ], JSON_UNESCAPED_UNICODE);
            break;
            
        case 'PUT':
            // Mettre à jour une faculté
            if (!$id) {
                throw new Exception('ID requis pour la mise à jour');
            }
            
            $input = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare("
                UPDATE faculties SET
                    institution_id = ?, code = ?, name = ?, short_name = ?, description = ?,
                    dean_name = ?, contact_email = ?, contact_phone = ?, office_location = ?,
                    status = ?, total_students = ?, total_staff = ?, total_departments = ?,
                    total_programs = ?, website = ?, logo_url = ?, updated_at = NOW()
                WHERE id = ?
            ");
            
            $stmt->execute([
                $input['institution_id'],
                $input['code'],
                $input['name'],
                $input['short_name'],
                $input['description'] ?? null,
                $input['dean_name'] ?? null,
                $input['contact_email'] ?? null,
                $input['contact_phone'] ?? null,
                $input['office_location'] ?? null,
                $input['status'] ?? 'active',
                $input['total_students'] ?? 0,
                $input['total_staff'] ?? 0,
                $input['total_departments'] ?? 0,
                $input['total_programs'] ?? 0,
                $input['website'] ?? null,
                $input['logo_url'] ?? null,
                $id
            ]);
            
            // Récupérer la faculté mise à jour
            $stmt = $pdo->prepare("SELECT * FROM faculties WHERE id = ?");
            $stmt->execute([$id]);
            $faculty = $stmt->fetch(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'message' => 'Faculté mise à jour avec succès',
                'data' => $faculty
            ], JSON_UNESCAPED_UNICODE);
            break;
            
        case 'DELETE':
            // Supprimer une faculté
            if (!$id) {
                throw new Exception('ID requis pour la suppression');
            }
            
            $stmt = $pdo->prepare("DELETE FROM faculties WHERE id = ?");
            $stmt->execute([$id]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Faculté supprimée avec succès'
            ], JSON_UNESCAPED_UNICODE);
            break;
            
        case 'PATCH':
            // Actions spécifiques comme toggle_status
            if (!$id) {
                throw new Exception('ID requis pour cette action');
            }
            
            if ($action === 'toggle_status') {
                $input = json_decode(file_get_contents('php://input'), true);
                $newStatus = $input['status'] ?? 'active';
                
                $stmt = $pdo->prepare("UPDATE faculties SET status = ?, updated_at = NOW() WHERE id = ?");
                $stmt->execute([$newStatus, $id]);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Statut de la faculté mis à jour avec succès'
                ], JSON_UNESCAPED_UNICODE);
            } else {
                throw new Exception('Action non reconnue');
            }
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
