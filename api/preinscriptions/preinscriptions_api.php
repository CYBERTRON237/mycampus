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
    $userId = 1;
    
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

function generateUUID() {
    return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

function generateMatricule() {
    return 'PRE' . date('Y') . str_pad(mt_rand(1, 99999), 5, '0', STR_PAD_LEFT);
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

// POST /submit - Soumettre une préinscription
if ($method === 'POST' && (count($pathParts) >= 3 && $pathParts[2] === 'submit') || 
    (count($pathParts) >= 4 && $pathParts[3] === 'submit')) {
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données invalides']);
        exit;
    }
    
    try {
        $required = ['candidate_first_name', 'candidate_last_name', 'email', 'institution_id'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis"]);
                exit;
            }
        }
        
        // Vérifier si l'email existe déjà pour une préinscription active
        $stmt = $pdo->prepare("SELECT id FROM pre_registrations WHERE email = ? AND status NOT IN ('rejected', 'archived')");
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'Cet email a déjà une préinscription active']);
            exit;
        }
        
        $uuid = generateUUID();
        $matricule = generateMatricule();
        
        $sql = "INSERT INTO pre_registrations (uuid, user_id, institution_id, faculty_id, program_id,
                candidate_first_name, candidate_last_name, candidate_middle_name, email, phone,
                birth_date, birth_place, nationality, matricule, exam_type, exam_year, status, payment_status,
                created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $uuid,
            $currentUser['id'],
            $input['institution_id'],
            $input['faculty_id'] ?? null,
            $input['program_id'] ?? null,
            $input['candidate_first_name'],
            $input['candidate_last_name'],
            $input['candidate_middle_name'] ?? null,
            $input['email'],
            $input['phone'] ?? null,
            $input['birth_date'] ?? null,
            $input['birth_place'] ?? null,
            $input['nationality'] ?? null,
            $matricule,
            $input['exam_type'] ?? null,
            $input['exam_year'] ?? null,
            'submitted',
            'pending'
        ]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription créée avec succès',
            'uuid' => $uuid
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}
// Route par défaut
else {
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée',
        'path' => $path,
        'method' => $method,
        'pathParts' => $pathParts
    ]);
}
?>
