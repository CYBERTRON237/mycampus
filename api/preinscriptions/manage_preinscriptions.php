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
    $userId = 1; // Simulé - remplacer par authentification réelle
    
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

function checkPermission($user, $requiredLevel = 50) {
    return $user && $user['user_level'] >= $requiredLevel;
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

try {
    switch ($method) {
        case 'PUT':
            // PUT /id/accept - Accepter une préinscription
            if (count($pathParts) >= 3 && $pathParts[2] === 'accept') {
                $preinscriptionId = $pathParts[1];
                
                if (!checkPermission($currentUser, 50)) {
                    http_response_code(403);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Permissions insuffisantes'
                    ]);
                    exit;
                }
                
                $input = json_decode(file_get_contents('php://input'), true);
                
                if (!$input || !isset($input['admission_number']) || !isset($input['registration_deadline'])) {
                    http_response_code(400);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Données manquantes: admission_number et registration_deadline requis'
                    ]);
                    exit;
                }
                
                // Vérifier que la préinscription existe et est en statut pending
                $checkStmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE id = ? AND status = 'pending'");
                $checkStmt->execute([$preinscriptionId]);
                
                if (!$checkStmt->fetch()) {
                    http_response_code(404);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Préinscription non trouvée ou déjà traitée'
                    ]);
                    exit;
                }
                
                // Générer un numéro d'admission unique si non fourni
                $admissionNumber = $input['admission_number'];
                if (empty($admissionNumber)) {
                    $admissionNumber = 'ADM' . date('Y') . str_pad(mt_rand(1, 99999), 5, '0', STR_PAD_LEFT);
                }
                
                // Mettre à jour la préinscription
                $stmt = $pdo->prepare("UPDATE preinscriptions SET 
                    status = 'accepted',
                    admission_number = ?,
                    registration_deadline = ?,
                    admission_date = CURRENT_TIMESTAMP,
                    reviewed_by = ?,
                    review_date = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?");
                
                $stmt->execute([
                    $admissionNumber,
                    $input['registration_deadline'],
                    $currentUser['id'],
                    $preinscriptionId
                ]);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Préinscription acceptée avec succès',
                    'data' => [
                        'admission_number' => $admissionNumber,
                        'registration_deadline' => $input['registration_deadline']
                    ]
                ]);
                exit;
            }
            
            // PUT /id/reject - Rejeter une préinscription
            if (count($pathParts) >= 3 && $pathParts[2] === 'reject') {
                $preinscriptionId = $pathParts[1];
                
                if (!checkPermission($currentUser, 50)) {
                    http_response_code(403);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Permissions insuffisantes'
                    ]);
                    exit;
                }
                
                $input = json_decode(file_get_contents('php://input'), true);
                $rejectionReason = $input['rejection_reason'] ?? null;
                
                // Vérifier que la préinscription existe
                $checkStmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE id = ?");
                $checkStmt->execute([$preinscriptionId]);
                
                if (!$checkStmt->fetch()) {
                    http_response_code(404);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Préinscription non trouvée'
                    ]);
                    exit;
                }
                
                // Mettre à jour la préinscription
                $stmt = $pdo->prepare("UPDATE preinscriptions SET 
                    status = 'rejected',
                    rejection_reason = ?,
                    reviewed_by = ?,
                    review_date = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?");
                
                $stmt->execute([
                    $rejectionReason,
                    $currentUser['id'],
                    $preinscriptionId
                ]);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Préinscription rejetée avec succès'
                ]);
                exit;
            }
            
            // PUT /id/interview - Planifier un entretien
            if (count($pathParts) >= 3 && $pathParts[2] === 'interview') {
                $preinscriptionId = $pathParts[1];
                
                if (!checkPermission($currentUser, 50)) {
                    http_response_code(403);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Permissions insuffisantes'
                    ]);
                    exit;
                }
                
                $input = json_decode(file_get_contents('php://input'), true);
                
                if (!$input || !isset($input['interview_date']) || !isset($input['interview_location']) || !isset($input['interview_type'])) {
                    http_response_code(400);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Données manquantes: interview_date, interview_location et interview_type requis'
                    ]);
                    exit;
                }
                
                // Vérifier que la préinscription existe
                $checkStmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE id = ?");
                $checkStmt->execute([$preinscriptionId]);
                
                if (!$checkStmt->fetch()) {
                    http_response_code(404);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Préinscription non trouvée'
                    ]);
                    exit;
                }
                
                // Mettre à jour la préinscription
                $stmt = $pdo->prepare("UPDATE preinscriptions SET 
                    interview_required = 1,
                    interview_date = ?,
                    interview_location = ?,
                    interview_type = ?,
                    interview_result = 'PENDING',
                    status = 'under_review',
                    reviewed_by = ?,
                    review_date = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?");
                
                $stmt->execute([
                    $input['interview_date'],
                    $input['interview_location'],
                    $input['interview_type'],
                    $currentUser['id'],
                    $preinscriptionId
                ]);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Entretien planifié avec succès'
                ]);
                exit;
            }
            
            // PUT /id/payment - Mettre à jour le statut de paiement
            if (count($pathParts) >= 3 && $pathParts[2] === 'payment') {
                $preinscriptionId = $pathParts[1];
                
                if (!checkPermission($currentUser, 50)) {
                    http_response_code(403);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Permissions insuffisantes'
                    ]);
                    exit;
                }
                
                $input = json_decode(file_get_contents('php://input'), true);
                
                if (!$input || !isset($input['payment_status'])) {
                    http_response_code(400);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Donnée manquante: payment_status requis'
                    ]);
                    exit;
                }
                
                // Vérifier que la préinscription existe
                $checkStmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE id = ?");
                $checkStmt->execute([$preinscriptionId]);
                
                if (!$checkStmt->fetch()) {
                    http_response_code(404);
                    echo json_encode([
                        'success' => false,
                        'message' => 'Préinscription non trouvée'
                    ]);
                    exit;
                }
                
                // Mettre à jour le paiement
                $stmt = $pdo->prepare("UPDATE preinscriptions SET 
                    payment_status = ?,
                    payment_amount = COALESCE(?, payment_amount),
                    payment_reference = COALESCE(?, payment_reference),
                    payment_date = COALESCE(?, payment_date),
                    updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?");
                
                $stmt->execute([
                    $input['payment_status'],
                    $input['payment_amount'] ?? null,
                    $input['payment_reference'] ?? null,
                    $input['payment_date'] ?? null,
                    $preinscriptionId
                ]);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Statut de paiement mis à jour avec succès'
                ]);
                exit;
            }
            
            break;
            
        default:
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint non trouvé'
            ]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur',
        'error' => $e->getMessage()
    ]);
}
?>
