<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion à la base de données
try {
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

// Récupérer l'utilisateur courant depuis le token JWT (simplifié)
function getCurrentUser($pdo) {
    $userId = 1; // Pour l'instant, on simule un utilisateur connecté
    
    try {
        $stmt = $pdo->prepare("SELECT u.*, i.name as institution_name 
                              FROM users u 
                              LEFT JOIN institutions i ON u.institution_id = i.id 
                              WHERE u.id = ? AND u.deleted_at IS NULL");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        
        if ($user) {
            $user['user_level'] = getUserLevel($user['primary_role'] ?? 'user');
            return $user;
        }
        return null;
    } catch (Exception $e) {
        return null;
    }
}

function getUserLevel($role) {
    $levels = [
        'superadmin' => 100,
        'admin_national' => 90,
        'admin_local' => 80,
        'manager' => 60,
        'faculty_admin' => 50,
        'department_head' => 40,
        'teacher' => 30,
        'student' => 10,
        'user' => 10
    ];
    return $levels[$role] ?? 10;
}

$currentUser = getCurrentUser($pdo);

if (!$currentUser) {
    echo json_encode([
        'success' => false,
        'message' => 'Utilisateur non authentifié'
    ]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// GET /preinscriptions - Lister les préinscriptions avec filtres
if ($method === 'GET' && (count($pathParts) >= 3 && $pathParts[2] === 'preinscriptions') || 
    (count($pathParts) >= 4 && $pathParts[3] === 'preinscriptions')) {
    
    try {
        // Récupérer les paramètres de filtrage
        $faculty = $_GET['faculty'] ?? null;
        $status = $_GET['status'] ?? null;
        $payment_status = $_GET['payment_status'] ?? null;
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, min(100, intval($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;
        
        // Construire la requête de base
        $sql = "SELECT 
                    id, uuid, unique_code, faculty, last_name, first_name, middle_name,
                    email, phone_number, desired_program, study_level, specialization,
                    status, payment_status, payment_amount, payment_date,
                    submission_date, created_at, updated_at,
                    CASE 
                        WHEN status = 'pending' THEN 'En attente'
                        WHEN status = 'under_review' THEN 'En cours de révision'
                        WHEN status = 'accepted' THEN 'Accepté'
                        WHEN status = 'rejected' THEN 'Rejeté'
                        WHEN status = 'cancelled' THEN 'Annulé'
                        WHEN status = 'deferred' THEN 'Différé'
                        WHEN status = 'waitlisted' THEN 'Liste d\'attente'
                        ELSE status
                    END as status_label,
                    CASE 
                        WHEN payment_status = 'pending' THEN 'En attente'
                        WHEN payment_status = 'paid' THEN 'Payé'
                        WHEN payment_status = 'confirmed' THEN 'Confirmé'
                        WHEN payment_status = 'refunded' THEN 'Remboursé'
                        WHEN payment_status = 'partial' THEN 'Partiel'
                        ELSE payment_status
                    END as payment_status_label
                FROM preinscriptions 
                WHERE deleted_at IS NULL";
        
        $params = [];
        
        // Ajouter les filtres
        if ($faculty) {
            $sql .= " AND faculty = ?";
            $params[] = $faculty;
        }
        
        if ($status) {
            $sql .= " AND status = ?";
            $params[] = $status;
        }
        
        if ($payment_status) {
            $sql .= " AND payment_status = ?";
            $params[] = $payment_status;
        }
        
        // Compter le total pour la pagination
        $countSql = str_replace("SELECT id, uuid, unique_code, faculty, last_name, first_name, middle_name,
                    email, phone_number, desired_program, study_level, specialization,
                    status, payment_status, payment_amount, payment_date,
                    submission_date, created_at, updated_at,", "SELECT COUNT(*) as total,", $sql);
        
        $countStmt = $pdo->prepare($countSql);
        $countStmt->execute($params);
        $result = $countStmt->fetch();
        $total = $result['total'] ?? 0;
        
        // Ajouter le tri et la pagination
        $sql .= " ORDER BY submission_date DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $preinscriptions = $stmt->fetchAll();
        
        // Statistiques par faculté
        $statsSql = "SELECT faculty, 
                            COUNT(*) as total,
                            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                            SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted,
                            SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
                            SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid
                    FROM preinscriptions 
                    WHERE deleted_at IS NULL";
        
        $statsParams = [];
        if ($faculty) {
            $statsSql .= " AND faculty = ?";
            $statsParams[] = $faculty;
        }
        
        $statsSql .= " GROUP BY faculty ORDER BY total DESC";
        
        $statsStmt = $pdo->prepare($statsSql);
        $statsStmt->execute($statsParams);
        $statistics = $statsStmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $preinscriptions,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'pages' => ceil($total / $limit)
            ],
            'statistics' => $statistics,
            'filters' => [
                'faculty' => $faculty,
                'status' => $status,
                'payment_status' => $payment_status
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des préinscriptions',
            'error' => $e->getMessage()
        ]);
    }
}
// GET /faculties - Lister les facultés disponibles
else if ($method === 'GET' && (count($pathParts) >= 3 && $pathParts[2] === 'faculties') || 
         (count($pathParts) >= 4 && $pathParts[3] === 'faculties')) {
    
    try {
        $stmt = $pdo->prepare("SELECT DISTINCT faculty, 
                                COUNT(*) as count,
                                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                                SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted,
                                SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected
                              FROM preinscriptions 
                              WHERE deleted_at IS NULL AND faculty IS NOT NULL
                              GROUP BY faculty 
                              ORDER BY count DESC");
        $stmt->execute();
        $faculties = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $faculties
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des facultés',
            'error' => $e->getMessage()
        ]);
    }
}
// GET /preinscriptions/{id} - Détails d'une préinscription
else if ($method === 'GET' && count($pathParts) >= 4 && is_numeric($pathParts[3])) {
    
    $id = intval($pathParts[3]);
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode([
                'success' => false,
                'message' => 'Préinscription non trouvée'
            ]);
            exit;
        }
        
        echo json_encode([
            'success' => true,
            'data' => $preinscription
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des détails',
            'error' => $e->getMessage()
        ]);
    }
}
// PUT /preinscriptions/{id}/status - Mettre à jour le statut
else if ($method === 'PUT' && count($pathParts) >= 5 && $pathParts[3] === 'status' && is_numeric($pathParts[4])) {
    
    $id = intval($pathParts[4]);
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || empty($input['status'])) {
        echo json_encode(['success' => false, 'message' => 'Statut requis']);
        exit;
    }
    
    $allowedStatuses = ['pending', 'under_review', 'accepted', 'rejected', 'cancelled', 'deferred', 'waitlisted'];
    if (!in_array($input['status'], $allowedStatuses)) {
        echo json_encode(['success' => false, 'message' => 'Statut invalide']);
        exit;
    }
    
    try {
        $sql = "UPDATE preinscriptions 
                SET status = ?, 
                    review_date = NOW(),
                    reviewed_by = ?,
                    review_comments = ?
                WHERE id = ? AND deleted_at IS NULL";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $input['status'],
            $currentUser['id'],
            $input['comments'] ?? null,
            $id
        ]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Statut mis à jour avec succès'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Préinscription non trouvée ou déjà mise à jour'
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour du statut',
            'error' => $e->getMessage()
        ]);
    }
}
// Route par défaut
else {
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée',
        'available_routes' => [
            'GET /preinscriptions - Lister les préinscriptions',
            'GET /preinscriptions/{id} - Détails d\'une préinscription',
            'GET /faculties - Lister les facultés disponibles',
            'PUT /preinscriptions/{id}/status - Mettre à jour le statut'
        ],
        'path' => $path,
        'method' => $method,
        'pathParts' => $pathParts
    ]);
}
?>
