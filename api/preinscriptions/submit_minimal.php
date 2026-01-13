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

function generateUUID() {
    return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

// POST request handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données JSON invalides']);
        exit;
    }
    
    try {
        // Validation des champs requis
        $required = ['faculty', 'lastName', 'firstName', 'dateOfBirth', 'placeOfBirth', 
                     'gender', 'residenceAddress', 'maritalStatus', 'phoneNumber', 'email',
                     'firstLanguage', 'professionalSituation'];
        
        foreach ($required as $field) {
            if (empty($input[$field])) {
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis"]);
                exit;
            }
        }
        
        // Vérifier si l'email existe déjà pour une préinscription active
        $stmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE email = ? AND status NOT IN ('rejected', 'cancelled') AND deleted_at IS NULL");
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'Cet email a déjà une préinscription active']);
            exit;
        }
        
        $uuid = generateUUID();
        
        // Insertion minimale - seulement les champs requis
        $sql = "INSERT INTO preinscriptions (
            uuid, faculty, last_name, first_name, middle_name,
            date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
            residence_address, marital_status, phone_number, email,
            first_language, professional_situation,
            status, documents_status, review_priority,
            marketing_consent, data_processing_consent, newsletter_subscription,
            ip_address, user_agent,
            submission_date, created_at, updated_at
        ) VALUES (
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?,
            ?, ?, ?,
            ?, ?, ?,
            ?, ?,
            NOW(), NOW(), NOW()
        )";
        
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
            $uuid,
            $input['faculty'] ?? '',
            $input['lastName'] ?? '',
            $input['firstName'] ?? '',
            $input['middleName'] ?? null,
            $input['dateOfBirth'] ?? '',
            $input['isBirthDateOnCertificate'] ?? 1,
            $input['placeOfBirth'] ?? '',
            $input['gender'] ?? '',
            $input['residenceAddress'] ?? '',
            $input['maritalStatus'] ?? '',
            $input['phoneNumber'] ?? '',
            $input['email'] ?? '',
            $input['firstLanguage'] ?? '',
            $input['professionalSituation'] ?? '',
            $input['status'] ?? 'pending',
            $input['documentsStatus'] ?? 'pending',
            $input['reviewPriority'] ?? 'NORMAL',
            $input['marketingConsent'] ?? 0,
            $input['dataProcessingConsent'] ?? 0,
            $input['newsletterSubscription'] ?? 0,
            $input['ipAddress'] ?? $_SERVER['REMOTE_ADDR'],
            $input['userAgent'] ?? $_SERVER['HTTP_USER_AGENT']
        ]);
        
        if ($result) {
            // Récupérer le code unique généré
            $stmt = $pdo->prepare("SELECT unique_code FROM preinscriptions WHERE uuid = ?");
            $stmt->execute([$uuid]);
            $preinsc = $stmt->fetch();
            $uniqueCode = $preinsc['unique_code'] ?? '';
            
            echo json_encode([
                'success' => true,
                'message' => 'Préinscription créée avec succès',
                'uuid' => $uuid,
                'unique_code' => $uniqueCode,
                'data' => [
                    'uuid' => $uuid,
                    'unique_code' => $uniqueCode,
                    'faculty' => $input['faculty'],
                    'firstName' => $input['firstName'],
                    'lastName' => $input['lastName'],
                    'email' => $input['email'],
                    'status' => 'pending'
                ]
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de l\'insertion'
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée',
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
}
?>
