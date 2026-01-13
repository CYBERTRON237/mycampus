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
        
        // Insertion avec les champs principaux
        $sql = "INSERT INTO preinscriptions (
            uuid, faculty, last_name, first_name, middle_name,
            date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
            cni_number, residence_address, marital_status, phone_number, email,
            first_language, professional_situation, previous_diploma, previous_institution,
            graduation_year, graduation_month, desired_program, study_level, specialization,
            series_bac, bac_year, bac_center, bac_mention, gpa_score, rank_in_class,
            parent_name, parent_phone, parent_email, parent_occupation,
            parent_address, parent_relationship, parent_income_level, payment_method,
            payment_reference, payment_amount, payment_currency, payment_status,
            scholarship_requested, scholarship_type, financial_aid_amount,
            status, documents_status, review_priority, contact_preference, marketing_consent,
            data_processing_consent, newsletter_subscription, ip_address, user_agent,
            device_type, browser_info, os_info, location_country, location_city,
            notes, special_needs, medical_conditions,
            submission_date, created_at, updated_at
        ) VALUES (
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?, ?,
            ?, ?, ?,
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
            $input['cniNumber'] ?? null,
            $input['residenceAddress'] ?? '',
            $input['maritalStatus'] ?? '',
            $input['phoneNumber'] ?? '',
            $input['email'] ?? '',
            $input['firstLanguage'] ?? '',
            $input['professionalSituation'] ?? '',
            $input['previousDiploma'] ?? null,
            $input['previousInstitution'] ?? null,
            $input['graduationYear'] ?? null,
            $input['graduationMonth'] ?? null,
            $input['desiredProgram'] ?? null,
            $input['studyLevel'] ?? null,
            $input['specialization'] ?? null,
            $input['seriesBac'] ?? null,
            $input['bacYear'] ?? null,
            $input['bacCenter'] ?? null,
            $input['bacMention'] ?? null,
            $input['gpaScore'] ?? null,
            $input['rankInClass'] ?? null,
            $input['parentName'] ?? null,
            $input['parentPhone'] ?? null,
            $input['parentEmail'] ?? null,
            $input['parentOccupation'] ?? null,
            $input['parentAddress'] ?? null,
            $input['parentRelationship'] ?? null,
            $input['parentIncomeLevel'] ?? null,
            $input['paymentMethod'] ?? null,
            $input['paymentReference'] ?? null,
            $input['paymentAmount'] ?? null,
            $input['paymentCurrency'] ?? 'XAF',
            $input['paymentStatus'] ?? 'pending',
            $input['scholarshipRequested'] ?? 0,
            $input['scholarshipType'] ?? null,
            $input['financialAidAmount'] ?? null,
            $input['status'] ?? 'pending',
            $input['documentsStatus'] ?? 'pending',
            $input['reviewPriority'] ?? 'NORMAL',
            $input['contactPreference'] ?? null,
            $input['marketingConsent'] ?? 0,
            $input['dataProcessingConsent'] ?? 0,
            $input['newsletterSubscription'] ?? 0,
            $input['ipAddress'] ?? $_SERVER['REMOTE_ADDR'],
            $input['userAgent'] ?? $_SERVER['HTTP_USER_AGENT'],
            $input['deviceType'] ?? null,
            $input['browserInfo'] ?? null,
            $input['osInfo'] ?? null,
            $input['locationCountry'] ?? null,
            $input['locationCity'] ?? null,
            $input['notes'] ?? null,
            $input['specialNeeds'] ?? null,
            $input['medicalConditions'] ?? null
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
