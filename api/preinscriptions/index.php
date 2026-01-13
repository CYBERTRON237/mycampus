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

// Fonction de logging des erreurs de préinscriptions
function logPreinscriptionError($message, $error = null, $context = []) {
    $timestamp = date('Y-m-d H:i:s');
    $contextStr = !empty($context) ? ' | Context: ' . json_encode($context) : '';
    $errorStr = $error ? " | Error: $error" : '';
    $logEntry = "[$timestamp] $message$errorStr$contextStr";
    
    // Utiliser uniquement error_log() pour éviter les problèmes de file_put_contents
    error_log("PREINSCRIPTIONS: $logEntry");
    
    // Essayer d'écrire dans le fichier de log en mode simple (sans LOCK_EX)
    $logFile = __DIR__ . '/../logs/preinscriptions_errors.log';
    try {
        @file_put_contents($logFile, $logEntry . PHP_EOL, FILE_APPEND);
    } catch (Exception $e) {
        // Ignorer les erreurs d'écriture
    }
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
    logPreinscriptionError('Erreur de connexion à la base de données', $e->getMessage(), [
        'host' => $host,
        'dbname' => $dbname
    ]);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

// Récupérer l'utilisateur courant depuis le token JWT (simplifié)
function getCurrentUser($pdo) {
    // Pour le développement, on utilise un ID fixe. En production, utiliser le token JWT
    $userId = $_SERVER['HTTP_X_USER_ID'] ?? 1;
    
    try {
        $stmt = $pdo->prepare("SELECT u.*, i.name as institution_name 
                              FROM users u 
                              LEFT JOIN institutions i ON u.institution_id = i.id 
                              WHERE u.id = ? AND u.deleted_at IS NULL");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        
        if ($user) {
            $user['user_level'] = getUserLevel($user['primary_role'] ?? 'student');
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

function canManagePreinscriptions($user) {
    return $user && $user['user_level'] >= 50; // faculty_admin et plus
}

function canValidatePreinscriptions($user) {
    return $user && $user['user_level'] >= 60; // manager et plus
}

$currentUser = getCurrentUser($pdo);

// Pour les endpoints de référence (institutions, faculties, programs), 
// on n'a pas besoin d'authentification
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));
$action = $_GET['action'] ?? null;

// Logger toutes les requêtes pour le débogage
logPreinscriptionError('Requête reçue', null, [
    'path' => $path ?? 'unknown',
    'method' => $method ?? 'unknown',
    'pathParts' => $pathParts ?? [],
    'action' => $action ?? null,
    'get_params' => $_GET ?? [],
    'post_params' => $method === 'POST' ? json_decode(file_get_contents('php://input'), true) : null,
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? null,
    'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? null
]);

// Vérifier si c'est une route "gestion" qui doit générer une erreur
if (in_array('gestion', $pathParts)) {
    logPreinscriptionError('Route "gestion" détectée - génération de Route not found', null, [
        'path' => $path,
        'pathParts' => $pathParts,
        'user_id' => $currentUser['id'] ?? null
    ]);
    
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée',
        'path' => $path,
        'method' => $method,
        'pathParts' => $pathParts
    ]);
    exit;
}

// GET /institutions - Lister les institutions
if ($method === 'GET' && ($action === 'institutions' || (count($pathParts) >= 3 && $pathParts[2] === 'institutions'))) {
    
    try {
        $sql = "SELECT id, name, description, city, country, type, is_active as status, created_at 
                FROM institutions 
                WHERE is_active = 1 
                ORDER BY name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $institutions = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $institutions
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des institutions',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /faculties - Lister les facultés
if ($method === 'GET' && ($action === 'faculties' || (count($pathParts) >= 3 && $pathParts[2] === 'faculties'))) {
    
    $institutionId = $_GET['institution_id'] ?? null;
    
    try {
        $sql = "SELECT f.id, f.name, f.code, f.description, f.institution_id, i.name as institution_name
                FROM faculties f 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE f.status = 'active'";
        
        $params = [];
        if ($institutionId) {
            $sql .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }
        
        $sql .= " ORDER BY f.name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
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

// GET /programs - Lister les programmes
if ($method === 'GET' && ($action === 'programs' || (count($pathParts) >= 3 && $pathParts[2] === 'programs'))) {
    
    $facultyId = $_GET['faculty_id'] ?? null;
    $institutionId = $_GET['institution_id'] ?? null;
    
    try {
        $sql = "SELECT p.id, p.name, p.code, p.description, p.degree_level, p.duration_years,
                       p.faculty_id, p.institution_id, f.name as faculty_name, i.name as institution_name
                FROM programs p 
                LEFT JOIN faculties f ON p.faculty_id = f.id 
                LEFT JOIN institutions i ON p.institution_id = i.id 
                WHERE p.status = 'active'";
        
        $params = [];
        if ($facultyId) {
            $sql .= " AND p.faculty_id = ?";
            $params[] = $facultyId;
        }
        if ($institutionId) {
            $sql .= " AND p.institution_id = ?";
            $params[] = $institutionId;
        }
        
        $sql .= " ORDER BY p.name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $programs = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $programs
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des programmes',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /preinscriptions - Lister les préinscriptions
if ($method === 'GET' && (count($pathParts) >= 3 && $pathParts[2] === 'preinscriptions')) {
    
    // Vérifier l'authentification pour les préinscriptions
    if (!$currentUser) {
        logPreinscriptionError('Utilisateur non authentifié pour accéder aux préinscriptions', null, [
            'path' => $path,
            'method' => $method,
            'pathParts' => $pathParts,
            'page' => $page,
            'limit' => $limit,
            'status' => $status,
            'search' => $search,
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? null,
            'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? null
        ]);
        echo json_encode([
            'success' => false,
            'message' => 'Utilisateur non authentifié'
        ]);
        exit;
    }
    
    $page = max(1, intval($_GET['page'] ?? 1));
    $limit = max(1, min(100, intval($_GET['limit'] ?? 20)));
    $offset = ($page - 1) * $limit;
    
    $status = $_GET['status'] ?? null;
    $institutionId = $_GET['institution_id'] ?? null;
    $search = $_GET['search'] ?? null;
    
    try {
        $whereConditions = [];
        $params = [];
        
        if ($status) {
            $whereConditions[] = "pr.status = ?";
            $params[] = $status;
        }
        
        if ($search) {
            $whereConditions[] = "(pr.first_name LIKE ? OR pr.last_name LIKE ? OR pr.email LIKE ? OR pr.unique_code LIKE ?)";
            $searchParam = "%$search%";
            $params = array_merge($params, [$searchParam, $searchParam, $searchParam, $searchParam]);
        }
        
        $whereClause = !empty($whereConditions) ? "WHERE " . implode(" AND ", $whereConditions) : "";
        
        // Compter le total
        $countSql = "SELECT COUNT(*) as total FROM preinscriptions pr $whereClause";
        $countStmt = $pdo->prepare($countSql);
        $countStmt->execute($params);
        $total = $countStmt->fetch()['total'];
        
        // Récupérer les données
        $sql = "SELECT pr.*, 
                    CASE 
                        WHEN pr.status = 'pending' THEN 'En attente'
                        WHEN pr.status = 'under_review' THEN 'En cours de révision'
                        WHEN pr.status = 'accepted' THEN 'Accepté'
                        WHEN pr.status = 'rejected' THEN 'Rejeté'
                        WHEN pr.status = 'cancelled' THEN 'Annulé'
                        WHEN pr.status = 'deferred' THEN 'Différé'
                        WHEN pr.status = 'waitlisted' THEN 'Liste d\'attente'
                        ELSE pr.status
                    END as status_label,
                    CASE 
                        WHEN pr.payment_status = 'pending' THEN 'En attente'
                        WHEN pr.payment_status = 'paid' THEN 'Payé'
                        WHEN pr.payment_status = 'confirmed' THEN 'Confirmé'
                        WHEN pr.payment_status = 'refunded' THEN 'Remboursé'
                        WHEN pr.payment_status = 'partial' THEN 'Partiel'
                        ELSE pr.payment_status
                    END as payment_status_label
                FROM preinscriptions pr
                $whereClause
                ORDER BY pr.submission_date DESC
                LIMIT ? OFFSET ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute(array_merge($params, [$limit, $offset]));
        $preinscriptions = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $preinscriptions,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'totalPages' => ceil($total / $limit)
            ]
        ]);
        
    } catch (Exception $e) {
        logPreinscriptionError('Erreur lors de la récupération des préinscriptions', $e->getMessage(), [
            'user_id' => $currentUser['id'] ?? null,
            'page' => $page,
            'limit' => $limit,
            'status' => $status,
            'search' => $search,
            'sql_count' => $countSql ?? null,
            'sql_select' => $sql ?? null
        ]);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des préinscriptions',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /preinscriptions/{id} - Récupérer une préinscription spécifique
if ($method === 'GET' && count($pathParts) >= 4 && is_numeric($pathParts[3])) {
    
    // Vérifier l'authentification
    if (!$currentUser) {
        echo json_encode([
            'success' => false,
            'message' => 'Utilisateur non authentifié'
        ]);
        exit;
    }
    
    $id = $pathParts[3];
    
    try {
        $sql = "SELECT pr.*, 
                    CASE 
                        WHEN pr.status = 'pending' THEN 'En attente'
                        WHEN pr.status = 'under_review' THEN 'En cours de révision'
                        WHEN pr.status = 'accepted' THEN 'Accepté'
                        WHEN pr.status = 'rejected' THEN 'Rejeté'
                        WHEN pr.status = 'cancelled' THEN 'Annulé'
                        WHEN pr.status = 'deferred' THEN 'Différé'
                        WHEN pr.status = 'waitlisted' THEN 'Liste d\'attente'
                        ELSE pr.status
                    END as status_label,
                    CASE 
                        WHEN pr.payment_status = 'pending' THEN 'En attente'
                        WHEN pr.payment_status = 'paid' THEN 'Payé'
                        WHEN pr.payment_status = 'confirmed' THEN 'Confirmé'
                        WHEN pr.payment_status = 'refunded' THEN 'Remboursé'
                        WHEN pr.payment_status = 'partial' THEN 'Partiel'
                        ELSE pr.payment_status
                    END as payment_status_label
                FROM preinscriptions pr
                WHERE pr.id = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode([
                'success' => false,
                'message' => 'Préinscription non trouvée'
            ]);
            exit;
        }
        
        // Vérifier les permissions
        if (!canManagePreinscriptions($currentUser)) {
            echo json_encode([
                'success' => false,
                'message' => 'Accès non autorisé'
            ]);
            exit;
        }
        
        echo json_encode([
            'success' => true,
            'data' => $preinscription
        ]);
        
    } catch (Exception $e) {
        logPreinscriptionError('Erreur lors de la récupération de la préinscription spécifique', $e->getMessage(), [
            'user_id' => $currentUser['id'] ?? null,
            'preinscription_id' => $id,
            'sql' => $sql ?? null
        ]);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}

// POST /preinscriptions - Créer une nouvelle préinscription
if ($method === 'POST' && (count($pathParts) >= 3 && $pathParts[2] === 'preinscriptions')) {
    
    // Vérifier l'authentification
    if (!$currentUser) {
        echo json_encode([
            'success' => false,
            'message' => 'Utilisateur non authentifié'
        ]);
        exit;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données invalides']);
        exit;
    }
    
    try {
        $required = ['first_name', 'last_name', 'email', 'faculty'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis"]);
                exit;
            }
        }
        
        // Vérifier si l'email existe déjà pour une préinscription active
        $stmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE email = ? AND status NOT IN ('rejected', 'cancelled', 'deferred')");
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'Cet email a déjà une préinscription active']);
            exit;
        }
        
        $uuid = generateUUID();
        $uniqueCode = generateMatricule();
        
        // Mapper les champs depuis le frontend vers la base de données
        $sql = "INSERT INTO preinscriptions (
            uuid, unique_code, faculty, last_name, first_name, middle_name, 
            date_of_birth, is_birth_date_on_certificate, place_of_birth, gender, 
            cni_number, residence_address, marital_status, phone_number, email, 
            first_language, professional_situation, previous_diploma, previous_institution, 
            graduation_year, graduation_month, desired_program, study_level, specialization, 
            series_bac, bac_year, bac_center, bac_mention, gpa_score, rank_in_class,
            parent_name, parent_phone, parent_email, parent_occupation, parent_address, 
            parent_relationship, parent_income_level, payment_method, payment_reference, 
            payment_amount, payment_currency, payment_status, scholarship_requested, 
            scholarship_type, financial_aid_amount, status, documents_status, review_priority,
            marketing_consent, data_processing_consent, newsletter_subscription,
            ip_address, user_agent, device_type, browser_info, os_info, location_country, 
            location_city, submission_date, last_updated, created_at, updated_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), NOW(), NOW()
        )";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $uuid,
            $uniqueCode,
            $input['faculty'] ?? '',
            $input['last_name'] ?? '',
            $input['first_name'] ?? '',
            $input['middle_name'] ?? null,
            $input['date_of_birth'] ?? null,
            $input['is_birth_date_on_certificate'] ?? 1,
            $input['place_of_birth'] ?? '',
            $input['gender'] ?? '',
            $input['cni_number'] ?? null,
            $input['residence_address'] ?? '',
            $input['marital_status'] ?? '',
            $input['phone_number'] ?? '',
            $input['email'],
            $input['first_language'] ?? 'FRANÇAIS',
            $input['professional_situation'] ?? 'SANS EMPLOI',
            $input['previous_diploma'] ?? null,
            $input['previous_institution'] ?? null,
            $input['graduation_year'] ?? null,
            $input['graduation_month'] ?? null,
            $input['desired_program'] ?? null,
            $input['study_level'] ?? null,
            $input['specialization'] ?? null,
            $input['series_bac'] ?? null,
            $input['bac_year'] ?? null,
            $input['bac_center'] ?? null,
            $input['bac_mention'] ?? null,
            $input['gpa_score'] ?? null,
            $input['rank_in_class'] ?? null,
            $input['parent_name'] ?? null,
            $input['parent_phone'] ?? null,
            $input['parent_email'] ?? null,
            $input['parent_occupation'] ?? null,
            $input['parent_address'] ?? null,
            $input['parent_relationship'] ?? null,
            $input['parent_income_level'] ?? null,
            $input['payment_method'] ?? null,
            $input['payment_reference'] ?? null,
            $input['payment_amount'] ?? null,
            $input['payment_currency'] ?? 'XAF',
            $input['payment_status'] ?? 'pending',
            $input['scholarship_requested'] ?? 0,
            $input['scholarship_type'] ?? null,
            $input['financial_aid_amount'] ?? null,
            $input['status'] ?? 'pending',
            $input['documents_status'] ?? 'pending',
            $input['review_priority'] ?? 'NORMAL',
            $input['marketing_consent'] ?? 0,
            $input['data_processing_consent'] ?? 0,
            $input['newsletter_subscription'] ?? 0,
            $_SERVER['REMOTE_ADDR'] ?? null,
            $_SERVER['HTTP_USER_AGENT'] ?? null,
            $input['device_type'] ?? 'OTHER',
            $input['browser_info'] ?? null,
            $input['os_info'] ?? null,
            $input['location_country'] ?? 'Cameroun',
            $input['location_city'] ?? null
        ]);
        
        $preinscriptionId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription créée avec succès',
            'data' => [
                'id' => $preinscriptionId,
                'uuid' => $uuid,
                'unique_code' => $uniqueCode
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /preinscriptions/{id} - Mettre à jour une préinscription
elseif ($method === 'PUT' && count($pathParts) >= 4 && is_numeric($pathParts[3])) {
    
    $id = $pathParts[3];
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données invalides']);
        exit;
    }
    
    try {
        // Vérifier si la préinscription existe et les permissions
        $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode(['success' => false, 'message' => 'Préinscription non trouvée']);
            exit;
        }
        
        if (!canManagePreinscriptions($currentUser) && $preinscription['user_id'] != $currentUser['id']) {
            echo json_encode(['success' => false, 'message' => 'Accès non autorisé']);
            exit;
        }
        
        // Préparer les champs à mettre à jour
        $updateFields = [];
        $params = [];
        
        $allowedFields = [
            'candidate_first_name', 'candidate_last_name', 'candidate_middle_name',
            'email', 'phone', 'birth_date', 'birth_place', 'nationality',
            'address', 'city', 'country', 'faculty_id', 'program_id',
            'exam_type', 'exam_year', 'exam_score'
        ];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updateFields[] = "$field = ?";
                $params[] = $input[$field];
            }
        }
        
        if (!empty($updateFields)) {
            $updateFields[] = "updated_at = NOW()";
            $params[] = $id;
            
            $sql = "UPDATE preinscriptions SET " . implode(", ", $updateFields) . " WHERE id = ?";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription mise à jour avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /preinscriptions/{id}/accept - Accepter une préinscription
elseif ($method === 'PUT' && count($pathParts) >= 5 && $pathParts[4] === 'accept') {
    
    $id = $pathParts[3];
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!canValidatePreinscriptions($currentUser)) {
        echo json_encode(['success' => false, 'message' => 'Permissions insuffisantes']);
        exit;
    }
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode(['success' => false, 'message' => 'Préinscription non trouvée']);
            exit;
        }
        
        $admissionNumber = 'ADM' . date('Y') . str_pad($id, 6, '0', STR_PAD_LEFT);
        $registrationDeadline = date('Y-m-d', strtotime('+30 days'));
        
        $sql = "UPDATE preinscriptions SET 
                status = 'accepted', 
                reviewed_by = ?, 
                review_date = NOW(), 
                admission_number = ?, 
                admission_date = NOW(), 
                registration_deadline = ?, 
                updated_at = NOW() 
                WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$currentUser['id'], $admissionNumber, $registrationDeadline, $id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription acceptée avec succès',
            'data' => [
                'admission_number' => $admissionNumber,
                'registration_deadline' => $registrationDeadline
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de l\'acceptation de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /preinscriptions/{id}/reject - Rejeter une préinscription
elseif ($method === 'PUT' && count($pathParts) >= 5 && $pathParts[4] === 'reject') {
    
    $id = $pathParts[3];
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!canValidatePreinscriptions($currentUser)) {
        echo json_encode(['success' => false, 'message' => 'Permissions insuffisantes']);
        exit;
    }
    
    if (empty($input['rejection_reason'])) {
        echo json_encode(['success' => false, 'message' => 'Le motif de rejet est requis']);
        exit;
    }
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode(['success' => false, 'message' => 'Préinscription non trouvée']);
            exit;
        }
        
        $sql = "UPDATE preinscriptions SET 
                status = 'rejected', 
                reviewed_by = ?, 
                review_date = NOW(), 
                rejection_reason = ?, 
                updated_at = NOW() 
                WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$currentUser['id'], $input['rejection_reason'], $id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription rejetée avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors du rejet de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}

// PUT /preinscriptions/{id}/payment - Mettre à jour le paiement
elseif ($method === 'PUT' && count($pathParts) >= 5 && $pathParts[4] === 'payment') {
    
    $id = $pathParts[3];
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!canManagePreinscriptions($currentUser)) {
        echo json_encode(['success' => false, 'message' => 'Permissions insuffisantes']);
        exit;
    }
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode(['success' => false, 'message' => 'Préinscription non trouvée']);
            exit;
        }
        
        $sql = "UPDATE preinscriptions SET 
                payment_status = ?, 
                payment_amount = ?, 
                payment_method = ?, 
                payment_reference = ?, 
                payment_date = NOW(), 
                updated_at = NOW() 
                WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $input['payment_status'] ?? 'paid',
            $input['payment_amount'] ?? 10000,
            $input['payment_method'] ?? null,
            $input['payment_reference'] ?? null,
            $id
        ]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Paiement mis à jour avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour du paiement',
            'error' => $e->getMessage()
        ]);
    }
}

// DELETE /preinscriptions/{id} - Supprimer une préinscription
elseif ($method === 'DELETE' && count($pathParts) >= 4 && is_numeric($pathParts[3])) {
    
    $id = $pathParts[3];
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE id = ?");
        $stmt->execute([$id]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode(['success' => false, 'message' => 'Préinscription non trouvée']);
            exit;
        }
        
        // Seuls les admins peuvent supprimer
        if (!canManagePreinscriptions($currentUser)) {
            echo json_encode(['success' => false, 'message' => 'Accès non autorisé']);
            exit;
        }
        
        $sql = "UPDATE preinscriptions SET deleted_at = NOW(), updated_at = NOW() WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription supprimée avec succès'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la suppression de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /preinscriptions/stats - Statistiques des préinscriptions
elseif ($method === 'GET' && count($pathParts) >= 4 && $pathParts[3] === 'stats') {
    
    try {
        $whereClause = "";
        $params = [];
        
        // Pour les stats, tous les admins peuvent voir
        if (!canManagePreinscriptions($currentUser)) {
            echo json_encode(['success' => false, 'message' => 'Permissions insuffisantes']);
            exit;
        }
        
        $sql = "SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                    SUM(CASE WHEN status = 'under_review' THEN 1 ELSE 0 END) as under_review,
                    SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted,
                    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
                    SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid,
                    SUM(CASE WHEN payment_status = 'pending' THEN 1 ELSE 0 END) as payment_pending,
                    SUM(CASE WHEN documents_status = 'verified' THEN 1 ELSE 0 END) as documents_verified
                FROM preinscriptions $whereClause";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $stats = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'data' => $stats
        ]);
        
    } catch (Exception $e) {
        logPreinscriptionError('Erreur lors de la récupération des statistiques des préinscriptions', $e->getMessage(), [
            'user_id' => $currentUser['id'] ?? null,
            'sql' => $sql ?? null
        ]);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des statistiques',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /institutions - Lister les institutions
elseif ($method === 'GET' && (count($pathParts) >= 3 && $pathParts[2] === 'institutions')) {
    
    try {
        $sql = "SELECT id, name, code, type, country, city, status, created_at 
                FROM institutions 
                WHERE status = 'active' 
                ORDER BY name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $institutions = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $institutions
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des institutions',
            'error' => $e->getMessage()
        ]);
    }
}

// GET /faculties - Lister les facultés
if ($method === 'GET' && ($action === 'faculties' || (count($pathParts) >= 3 && $pathParts[2] === 'faculties'))) {
    
    $institutionId = $_GET['institution_id'] ?? null;
    
    try {
        $sql = "SELECT f.id, f.name, f.code, f.description, f.institution_id, i.name as institution_name
                FROM faculties f 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE f.status = 'active'";
        
        $params = [];
        if ($institutionId) {
            $sql .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }
        
        $sql .= " ORDER BY f.name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
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

// GET /programs - Lister les programmes
if ($method === 'GET' && ($action === 'programs' || (count($pathParts) >= 3 && $pathParts[2] === 'programs'))) {
    
    $facultyId = $_GET['faculty_id'] ?? null;
    $institutionId = $_GET['institution_id'] ?? null;
    
    try {
        $sql = "SELECT p.id, p.name, p.code, p.description, p.degree_level, p.duration_years,
                       p.faculty_id, p.institution_id, f.name as faculty_name, i.name as institution_name
                FROM programs p 
                LEFT JOIN faculties f ON p.faculty_id = f.id 
                LEFT JOIN institutions i ON p.institution_id = i.id 
                WHERE p.status = 'active'";
        
        $params = [];
        if ($facultyId) {
            $sql .= " AND p.faculty_id = ?";
            $params[] = $facultyId;
        }
        if ($institutionId) {
            $sql .= " AND p.institution_id = ?";
            $params[] = $institutionId;
        }
        
        $sql .= " ORDER BY p.name ASC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $programs = $stmt->fetchAll();
        
        echo json_encode([
            'success' => true,
            'data' => $programs
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des programmes',
            'error' => $e->getMessage()
        ]);
    }
}

// Route par défaut
else {
    logPreinscriptionError('Route non trouvée', null, [
        'path' => $path,
        'method' => $method,
        'pathParts' => $pathParts,
        'user_id' => $currentUser['id'] ?? null,
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? null,
        'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? null
    ]);
    
    echo json_encode([
        'success' => false,
        'message' => 'Route non trouvée',
        'path' => $path,
        'method' => $method,
        'pathParts' => $pathParts
    ]);
}
?>
