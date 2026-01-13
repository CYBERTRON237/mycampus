<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// Activer l'affichage des erreurs pour le debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Charger l'autoloader de Composer pour JWT
require __DIR__ . '/../../vendor/autoload.php';
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

// Créer un fichier de log direct pour le debug
$debugFile = __DIR__ . '/../../debug_preinscription.log';
file_put_contents($debugFile, "\n\n=== " . date('Y-m-d H:i:s') . " - NOUVELLE REQUÊTE ===\n", FILE_APPEND);

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    file_put_contents($debugFile, "MÉTHODE OPTIONS - Sortie immédiate\n", FILE_APPEND);
    http_response_code(200);
    exit;
}

// Fonction pour récupérer l'ID utilisateur depuis le token JWT
function getCurrentUserId() {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
    
    if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
        file_put_contents($debugFile, "ERREUR: Pas de token JWT trouvé\n", FILE_APPEND);
        return null;
    }
    
    $token = substr($authHeader, 7);
    
    try {
        $secretKey = 'votre_secret_key_jwt'; // À remplacer par votre vraie clé secrète
        $decoded = JWT::decode($token, new Key($secretKey, 'HS256'));
        
        $userId = $decoded->user_id ?? $decoded->sub ?? $decoded->id ?? null;
        
        file_put_contents($debugFile, "Token JWT décodé avec succès - User ID: $userId\n", FILE_APPEND);
        return $userId;
        
    } catch (Exception $e) {
        file_put_contents($debugFile, "ERREUR: Token JWT invalide - " . $e->getMessage() . "\n", FILE_APPEND);
        return null;
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
    file_put_contents($debugFile, "DÉBUT TRAITEMENT POST\n", FILE_APPEND);
    
    $rawInput = file_get_contents('php://input');
    
    // Debug terminal direct
    file_put_contents($debugFile, "=== DÉBUT REQUÊTE PRÉINSCRIPTION ===\n", FILE_APPEND);
    file_put_contents($debugFile, "Timestamp: " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);
    file_put_contents($debugFile, "Méthode: " . $_SERVER['REQUEST_METHOD'] . "\n", FILE_APPEND);
    file_put_contents($debugFile, "Content-Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'N/A') . "\n", FILE_APPEND);
    file_put_contents($debugFile, "Longueur brute: " . strlen($rawInput) . "\n", FILE_APPEND);
    
    // Corriger l'encodage UTF-8
    $rawInput = mb_convert_encoding($rawInput, 'UTF-8', 'UTF-8');
    
    // Debug: Afficher les données brutes reçues
    file_put_contents($debugFile, "Données brutes: " . $rawInput . "\n", FILE_APPEND);
    
    $input = json_decode($rawInput, true);
    
    if (!$input) {
        $jsonError = json_last_error_msg();
        $jsonErrorCode = json_last_error();
        
        // Debug terminal pour erreur JSON
        file_put_contents($debugFile, "ERREUR JSON DÉTECTÉE!\n", FILE_APPEND);
        file_put_contents($debugFile, "Message erreur: $jsonError\n", FILE_APPEND);
        file_put_contents($debugFile, "Code erreur: $jsonErrorCode\n", FILE_APPEND);
        file_put_contents($debugFile, "Données reçues: $rawInput\n", FILE_APPEND);
        
        echo json_encode(['success' => false, 'message' => 'Données JSON invalides', 'debug_error' => $jsonError]);
        exit;
    }
    
    // Debug terminal pour les champs reçus
    file_put_contents($debugFile, "JSON décodé avec succès - " . count($input) . " champs reçus\n", FILE_APPEND);
    foreach ($input as $key => $value) {
        file_put_contents($debugFile, "Champ: $key = " . (is_string($value) ? $value : gettype($value)) . "\n", FILE_APPEND);
    }
    
    // Debug: Log des données reçues
    error_log("Données reçues: " . json_encode($input));
    
    // Sauvegarder les données brutes dans un fichier pour analyse
    file_put_contents('debug_last_request.json', json_encode($input, JSON_PRETTY_PRINT));
    
    // Normaliser les noms de champs (camelCase vs snake_case)
    $normalizedInput = [
        'faculty' => $input['faculty'] ?? '',
        'lastName' => $input['lastName'] ?? $input['last_name'] ?? '',
        'firstName' => $input['firstName'] ?? $input['first_name'] ?? '',
        'middleName' => $input['middleName'] ?? $input['middle_name'] ?? null,
        'dateOfBirth' => $input['dateOfBirth'] ?? $input['date_of_birth'] ?? '',
        'isBirthDateOnCertificate' => $input['isBirthDateOnCertificate'] ?? $input['is_birth_date_on_certificate'] ?? 1,
        'placeOfBirth' => $input['placeOfBirth'] ?? $input['place_of_birth'] ?? '',
        'gender' => $input['gender'] ?? '',
        'cniNumber' => $input['cniNumber'] ?? $input['cni_number'] ?? null,
        'residenceAddress' => $input['residenceAddress'] ?? $input['residence_address'] ?? '',
        'maritalStatus' => $input['maritalStatus'] ?? $input['marital_status'] ?? '',
        'phoneNumber' => $input['phoneNumber'] ?? $input['phone_number'] ?? '',
        'email' => $input['email'] ?? '',
        'firstLanguage' => $input['firstLanguage'] ?? $input['first_language'] ?? '',
        'professionalSituation' => $input['professionalSituation'] ?? $input['professional_situation'] ?? '',
        // Académiques
        'previousDiploma' => $input['previousDiploma'] ?? $input['previous_diploma'] ?? null,
        'previousInstitution' => $input['previousInstitution'] ?? $input['previous_institution'] ?? null,
        'graduationYear' => $input['graduationYear'] ?? $input['graduation_year'] ?? null,
        'graduationMonth' => $input['graduationMonth'] ?? $input['graduation_month'] ?? null,
        'desiredProgram' => $input['desiredProgram'] ?? $input['desired_program'] ?? null,
        'studyLevel' => $input['studyLevel'] ?? $input['study_level'] ?? null,
        'specialization' => $input['specialization'] ?? null,
        'seriesBac' => $input['seriesBac'] ?? $input['series_bac'] ?? null,
        'bacYear' => $input['bacYear'] ?? $input['bac_year'] ?? null,
        'bacCenter' => $input['bacCenter'] ?? $input['bac_center'] ?? null,
        'bacMention' => $input['bacMention'] ?? $input['bac_mention'] ?? null,
        'gpaScore' => $input['gpaScore'] ?? $input['gpa_score'] ?? null,
        'rankInClass' => $input['rankInClass'] ?? $input['rank_in_class'] ?? null,
        // Parents
        'parentName' => $input['parentName'] ?? $input['parent_name'] ?? null,
        'parentPhone' => $input['parentPhone'] ?? $input['parent_phone'] ?? null,
        'parentEmail' => $input['parentEmail'] ?? $input['parent_email'] ?? null,
        'parentOccupation' => $input['parentOccupation'] ?? $input['parent_occupation'] ?? null,
        'parentAddress' => $input['parentAddress'] ?? $input['parent_address'] ?? null,
        'parentRelationship' => $input['parentRelationship'] ?? $input['parent_relationship'] ?? null,
        'parentIncomeLevel' => $input['parentIncomeLevel'] ?? $input['parent_income_level'] ?? null,
        // Paiement
        'paymentMethod' => $input['paymentMethod'] ?? $input['payment_method'] ?? null,
        'paymentReference' => $input['paymentReference'] ?? $input['payment_reference'] ?? null,
        'paymentAmount' => $input['paymentAmount'] ?? $input['payment_amount'] ?? null,
        'paymentCurrency' => $input['paymentCurrency'] ?? $input['payment_currency'] ?? 'XAF',
        'paymentDate' => $input['paymentDate'] ?? $input['payment_date'] ?? null,
        'paymentStatus' => $input['paymentStatus'] ?? $input['payment_status'] ?? 'pending',
        'paymentProofPath' => $input['paymentProofPath'] ?? $input['payment_proof_path'] ?? null,
        'scholarshipRequested' => $input['scholarshipRequested'] ?? $input['scholarship_requested'] ?? 0,
        'scholarshipType' => $input['scholarshipType'] ?? $input['scholarship_type'] ?? null,
        'financialAidAmount' => $input['financialAidAmount'] ?? $input['financial_aid_amount'] ?? null,
        // Documents
        'birthCertificatePath' => $input['birthCertificatePath'] ?? $input['birth_certificate_path'] ?? null,
        'cniPath' => $input['cniPath'] ?? $input['cni_path'] ?? null,
        'diplomaPath' => $input['diplomaPath'] ?? $input['diploma_path'] ?? null,
        'transcriptPath' => $input['transcriptPath'] ?? $input['transcript_path'] ?? null,
        'photoPath' => $input['photoPath'] ?? $input['photo_path'] ?? null,
        'recommendationLetterPath' => $input['recommendationLetterPath'] ?? $input['recommendation_letter_path'] ?? null,
        'motivationLetterPath' => $input['motivationLetterPath'] ?? $input['motivation_letter_path'] ?? null,
        'medicalCertificatePath' => $input['medicalCertificatePath'] ?? $input['medical_certificate_path'] ?? null,
        'otherDocumentsPath' => $input['otherDocumentsPath'] ?? $input['other_documents_path'] ?? null,
        // Préférences et consentements
        'contactPreference' => $input['contactPreference'] ?? $input['contact_preference'] ?? null,
        'marketingConsent' => $input['marketingConsent'] ?? $input['marketing_consent'] ?? 0,
        'dataProcessingConsent' => $input['dataProcessingConsent'] ?? $input['data_processing_consent'] ?? 0,
        'newsletterSubscription' => $input['newsletterSubscription'] ?? $input['newsletter_subscription'] ?? 0,
        // Système et tracking
        'ipAddress' => $input['ipAddress'] ?? $input['ip_address'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
        'userAgent' => $input['userAgent'] ?? $input['user_agent'] ?? $_SERVER['HTTP_USER_AGENT'] ?? null,
        'deviceType' => $input['deviceType'] ?? $input['device_type'] ?? null,
        'browserInfo' => $input['browserInfo'] ?? $input['browser_info'] ?? null,
        'osInfo' => $input['osInfo'] ?? $input['os_info'] ?? null,
        'locationCountry' => $input['locationCountry'] ?? $input['location_country'] ?? null,
        'locationCity' => $input['locationCity'] ?? $input['location_city'] ?? null,
        // Notes et commentaires
        'notes' => $input['notes'] ?? null,
        'adminNotes' => $input['adminNotes'] ?? $input['admin_notes'] ?? null,
        'internalComments' => $input['internalComments'] ?? $input['internal_comments'] ?? null,
        'specialNeeds' => $input['specialNeeds'] ?? $input['special_needs'] ?? null,
        'medicalConditions' => $input['medicalConditions'] ?? $input['medical_conditions'] ?? null,
        // Champs pour la gestion du compte invité
        'applicantEmail' => $input['applicantEmail'] ?? $input['applicant_email'] ?? $input['email'] ?? null,
        'applicantPhone' => $input['applicantPhone'] ?? $input['applicant_phone'] ?? $input['phoneNumber'] ?? null,
        'relationship' => $input['relationship'] ?? 'self',
        'studentId' => null, // Sera rempli automatiquement lors du traitement
        'isProcessed' => 0, // Toujours false à la création
        'processedAt' => null, // Sera rempli lors du traitement
    ];
    
    $input = $normalizedInput;
    
    // Debug: Vérifier les champs manquants
    $receivedFields = array_keys($normalizedInput);
    $missingRequired = [];
    
    foreach (['faculty', 'lastName', 'firstName', 'dateOfBirth', 'placeOfBirth', 'gender', 'residenceAddress', 'maritalStatus', 'phoneNumber', 'email', 'firstLanguage', 'professionalSituation'] as $required) {
        if (empty($input[$required])) {
            $missingRequired[] = $required;
        }
    }
    
    if (!empty($missingRequired)) {
        file_put_contents($debugFile, "Champs requis manquants: " . implode(', ', $missingRequired) . "\n", FILE_APPEND);
    }
    
    // Récupérer automatiquement l'ID de l'utilisateur connecté
    $currentUserId = getCurrentUserId();
    
    if (!$currentUserId) {
        file_put_contents($debugFile, "ERREUR: Utilisateur non authentifié\n", FILE_APPEND);
        echo json_encode([
            'success' => false, 
            'message' => 'Authentification requise pour soumettre une préinscription',
            'debug_auth' => 'Aucun token JWT valide trouvé'
        ]);
        exit;
    }
    
    file_put_contents($debugFile, "ID utilisateur connecté: $currentUserId\n", FILE_APPEND);
    
    try {
        // Debug terminal pour la validation
        error_log("=== DÉBUT VALIDATION DES CHAMPS ===");
        
        // Validation des champs requis selon la structure de la table
        $required = ['faculty', 'lastName', 'firstName', 'dateOfBirth', 'placeOfBirth', 
                     'gender', 'residenceAddress', 'maritalStatus', 'phoneNumber', 'email',
                     'firstLanguage', 'professionalSituation'];
        
        error_log("Champs requis à vérifier: " . implode(', ', $required));
        
        foreach ($required as $field) {
            $fieldValue = $input[$field] ?? null;
            error_log("Vérification champ: $field = " . ($fieldValue ?? 'NULL'));
            
            if (empty($fieldValue)) {
                error_log("ERREUR: Champ requis manquant ou vide: $field");
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis", 'debug_field' => $field, 'debug_value' => $fieldValue]);
                exit;
            }
        }
        
        error_log("✓ Tous les champs requis sont valides");
        
        // Validation du score GPA
        error_log("=== VALIDATION SCORE GPA ===");
        $gpaScore = isset($input['gpaScore']) ? floatval($input['gpaScore']) : null;
        if ($gpaScore !== null && ($gpaScore < 0.0 || $gpaScore > 5.0)) {
            error_log("ERREUR: Score GPA invalide: $gpaScore (doit être entre 0.0 et 5.0)");
            echo json_encode([
                'success' => false, 
                'message' => 'Score GPA invalide (doit être entre 0.0 et 5.0)', 
                'debug_gpa' => $gpaScore
            ]);
            exit;
        }
        error_log("✓ Score GPA valide: " . ($gpaScore ?? 'NULL'));
        
        // Validation des autres champs numériques avec contraintes
        error_log("=== VALIDATION CHAMPS NUMÉRIQUES ===");
        
        // Validation graduation_year (1900-2100)
        $graduationYear = isset($input['graduationYear']) ? intval($input['graduationYear']) : null;
        if ($graduationYear !== null && ($graduationYear < 1900 || $graduationYear > 2100)) {
            error_log("ERREUR: Année de graduation invalide: $graduationYear (doit être entre 1900 et 2100)");
            echo json_encode([
                'success' => false, 
                'message' => 'Année de graduation invalide (doit être entre 1900 et 2100)', 
                'debug_graduation_year' => $graduationYear
            ]);
            exit;
        }
        
        // Validation bac_year (1900-2100)
        $bacYear = isset($input['bacYear']) ? intval($input['bacYear']) : null;
        if ($bacYear !== null && ($bacYear < 1900 || $bacYear > 2100)) {
            error_log("ERREUR: Année du bac invalide: $bacYear (doit être entre 1900 et 2100)");
            echo json_encode([
                'success' => false, 
                'message' => 'Année du bac invalide (doit être entre 1900 et 2100)', 
                'debug_bac_year' => $bacYear
            ]);
            exit;
        }
        
        // Validation rank_in_class (>= 1)
        $rankInClass = isset($input['rankInClass']) ? intval($input['rankInClass']) : null;
        if ($rankInClass !== null && $rankInClass < 1) {
            error_log("ERREUR: Rang dans la classe invalide: $rankInClass (doit être >= 1)");
            echo json_encode([
                'success' => false, 
                'message' => 'Rang dans la classe invalide (doit être supérieur à 0)', 
                'debug_rank_in_class' => $rankInClass
            ]);
            exit;
        }
        
        // Validation payment_amount (>= 0)
        $paymentAmount = isset($input['paymentAmount']) ? floatval($input['paymentAmount']) : null;
        if ($paymentAmount !== null && $paymentAmount < 0) {
            error_log("ERREUR: Montant du paiement invalide: $paymentAmount (doit être >= 0)");
            echo json_encode([
                'success' => false, 
                'message' => 'Montant du paiement invalide (doit être positif ou nul)', 
                'debug_payment_amount' => $paymentAmount
            ]);
            exit;
        }
        
        // Validation financial_aid_amount (>= 0)
        $financialAidAmount = isset($input['financialAidAmount']) ? floatval($input['financialAidAmount']) : null;
        if ($financialAidAmount !== null && $financialAidAmount < 0) {
            error_log("ERREUR: Montant aide financière invalide: $financialAidAmount (doit être >= 0)");
            echo json_encode([
                'success' => false, 
                'message' => 'Montant aide financière invalide (doit être positif ou nul)', 
                'debug_financial_aid_amount' => $financialAidAmount
            ]);
            exit;
        }
        
        error_log("✓ Tous les champs numériques sont valides");
        
        // Debug pour vérification email
        error_log("=== VÉRIFICATION EMAIL EXISTANT ===");
        error_log("Email à vérifier: " . $input['email']);
        
        // Vérifier si l'email existe déjà pour une préinscription active
        $stmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE email = ? AND status NOT IN ('rejected', 'cancelled') AND deleted_at IS NULL");
        $stmt->execute([$input['email']]);
        $existingEmail = $stmt->fetch();
        
        if ($existingEmail) {
            error_log("ERREUR: Email déjà existant: " . $input['email']);
            echo json_encode(['success' => false, 'message' => 'Cet email a déjà une préinscription active', 'debug_email' => $input['email']]);
            exit;
        }
        
        error_log("✓ Email non existant - continuation");
        
        $uuid = generateUUID();
        error_log("UUID généré: $uuid");
        
        // Générer un code unique manuellement
        $uniqueCode = 'PRE' . date('Y') . str_pad(mt_rand(1, 999999), 6, '0', STR_PAD_LEFT);
        error_log("Code unique généré: $uniqueCode");
        
        // Vérifier si le code existe déjà
        $stmt = $pdo->prepare("SELECT id FROM preinscriptions WHERE unique_code = ?");
        $stmt->execute([$uniqueCode]);
        while ($stmt->fetch()) {
            $uniqueCode = 'PRE' . date('Y') . str_pad(mt_rand(1, 999999), 6, '0', STR_PAD_LEFT);
            error_log("Code unique régénéré: $uniqueCode");
            $stmt->execute([$uniqueCode]);
        }
        
        error_log("✓ Code unique validé: $uniqueCode");
        
        // Insertion avec TOUS les champs de la table selon la structure exacte
        $sql = "INSERT INTO preinscriptions (
            uuid, unique_code, faculty, last_name, first_name, middle_name,
            date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
            cni_number, residence_address, marital_status, phone_number, email,
            first_language, professional_situation, previous_diploma, previous_institution,
            graduation_year, graduation_month, desired_program, study_level, specialization,
            series_bac, bac_year, bac_center, bac_mention, gpa_score, rank_in_class,
            birth_certificate_path, cni_path, diploma_path, transcript_path, photo_path,
            recommendation_letter_path, motivation_letter_path, medical_certificate_path,
            other_documents_path, parent_name, parent_phone, parent_email, parent_occupation,
            parent_address, parent_relationship, parent_income_level, payment_method,
            payment_reference, payment_amount, payment_currency, payment_date, payment_status,
            payment_proof_path, scholarship_requested, scholarship_type, financial_aid_amount,
            status, documents_status, review_priority, reviewed_by, review_date, review_comments,
            rejection_reason, interview_required, interview_date, interview_location, interview_type,
            interview_result, interview_notes, admission_number, admission_date, registration_deadline,
            registration_completed, student_id, batch_number, contact_preference, marketing_consent,
            data_processing_consent, newsletter_subscription, ip_address, user_agent, device_type,
            browser_info, os_info, location_country, location_city, notes, admin_notes,
            internal_comments, special_needs, medical_conditions, submission_date, last_updated,
            created_at, updated_at, deleted_at, applicant_email, applicant_phone, relationship,
            is_processed, processed_at
        ) VALUES (" . str_repeat('?,', 99) . '?)';
        
        $stmt = $pdo->prepare($sql);
        
        // Préparer tous les paramètres
        $executeParams = [
            $uuid,
            $uniqueCode, // Utiliser le code unique généré
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
            $input['birthCertificatePath'] ?? null,
            $input['cniPath'] ?? null,
            $input['diplomaPath'] ?? null,
            $input['transcriptPath'] ?? null,
            $input['photoPath'] ?? null,
            $input['recommendationLetterPath'] ?? null,
            $input['motivationLetterPath'] ?? null,
            $input['medicalCertificatePath'] ?? null,
            $input['otherDocumentsPath'] ?? null,
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
            $input['paymentDate'] ?? null,
            $input['paymentStatus'] ?? 'pending',
            $input['paymentProofPath'] ?? null,
            $input['scholarshipRequested'] ?? 0,
            $input['scholarshipType'] ?? null,
            $input['financialAidAmount'] ?? null,
            $input['status'] ?? 'pending',
            $input['documentsStatus'] ?? 'pending',
            $input['reviewPriority'] ?? 'NORMAL',
            $input['reviewedBy'] ?? null,
            $input['reviewDate'] ?? null,
            $input['reviewComments'] ?? null,
            $input['rejectionReason'] ?? null,
            $input['interviewRequired'] ?? 0,
            $input['interviewDate'] ?? null,
            $input['interviewLocation'] ?? null,
            $input['interviewType'] ?? null,
            $input['interviewResult'] ?? null,
            $input['interviewNotes'] ?? null,
            $input['admissionNumber'] ?? null,
            $input['admissionDate'] ?? null,
            $input['registrationDeadline'] ?? null,
            $input['registrationCompleted'] ?? 0,
            null, // student_id - sera rempli lors du traitement automatique
            $input['batchNumber'] ?? null,
            $input['contactPreference'] ?? null,
            $input['marketingConsent'] ?? 0,
            $input['dataProcessingConsent'] ?? 0,
            $input['newsletterSubscription'] ?? 0,
            $input['ipAddress'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
            $input['userAgent'] ?? $_SERVER['HTTP_USER_AGENT'] ?? null,
            $input['deviceType'] ?? null,
            $input['browserInfo'] ?? null,
            $input['osInfo'] ?? null,
            $input['locationCountry'] ?? null,
            $input['locationCity'] ?? null,
            $input['notes'] ?? null,
            $input['adminNotes'] ?? null,
            $input['internalComments'] ?? null,
            $input['specialNeeds'] ?? null,
            $input['medicalConditions'] ?? null,
            date('Y-m-d H:i:s'), // submission_date
            date('Y-m-d H:i:s'), // last_updated
            date('Y-m-d H:i:s'), // created_at
            date('Y-m-d H:i:s'), // updated_at
            null, // deleted_at
            $input['applicantEmail'] ?? $input['email'] ?? null, // applicant_email
            $input['applicantPhone'] ?? $input['phoneNumber'] ?? null, // applicant_phone
            $input['relationship'] ?? 'self', // relationship
            $input['isProcessed'] ?? 0, // is_processed
            $input['processedAt'] ?? null // processed_at
        ];
        
        error_log("=== PRÉPARATION EXÉCUTION SQL ===");
        error_log("Nombre de paramètres: " . count($executeParams));
        error_log("ID utilisateur connecté: $currentUserId");
        error_log("Début de l'exécution de la requête INSERT...");
        
        $result = $stmt->execute($executeParams);
        
        error_log("Résultat execute(): " . ($result ? 'SUCCESS' : 'FAILURE'));
        
        if ($result) {
            error_log("✓ Insertion réussie dans la base de données");
            
            // Récupérer le code unique généré
            error_log("=== RÉCUPÉRATION CODE UNIQUE ===");
            $stmt = $pdo->prepare("SELECT unique_code FROM preinscriptions WHERE uuid = ?");
            $stmt->execute([$uuid]);
            $preinsc = $stmt->fetch();
            $uniqueCode = $preinsc['unique_code'] ?? '';
            
            error_log("Code unique récupéré: $uniqueCode");
            
            $responseData = [
                'success' => true,
                'message' => 'Préinscription créée avec succès',
            ];
            
            error_log("=== PRÉPARATION EXÉCUTION SQL ===");
            error_log("Nombre de paramètres: " . count($executeParams));
            error_log("ID utilisateur connecté: $currentUserId");
            error_log("Début de l'exécution de la requête INSERT...");
            // Debug: Afficher les erreurs SQL dans le terminal et la réponse
            $errorInfo = $stmt->errorInfo();
            
            error_log("=== ERREUR SQL DÉTECTÉE ===");
            error_log("SQL State: " . ($errorInfo[0] ?? 'N/A'));
            error_log("Driver Error Code: " . ($errorInfo[1] ?? 'N/A'));
            error_log("Driver Error Message: " . ($errorInfo[2] ?? 'N/A'));
            
            // Compter manuellement les colonnes dans la requête SQL
            $columnsPart = strstr($sql, '(', true);
            $columnsPart = str_replace('INSERT INTO preinscriptions ', '', $columnsPart);
            $columnsPart = str_replace(['(', ' ', "\n", "\r"], '', $columnsPart);
            $columnsArray = explode(',', $columnsPart);
            $columnCount = count($columnsArray);
            
            $paramCount = substr_count($sql, '?');
            
            error_log("Nombre de colonnes SQL: $columnCount");
            error_log("Nombre de ? dans SQL: $paramCount");
            error_log("Nombre de paramètres fournis: " . count($executeParams));
            
            // Debug terminal pour les premiers paramètres
            error_log("=== PREMIERS PARAMÈTRES ===");
            for ($i = 0; $i < min(10, count($executeParams)); $i++) {
                error_log("Param $i: " . ($executeParams[$i] ?? 'NULL'));
            }
            
            $executeParamCount = count($executeParams);
            
            error_log("=== PRÉPARATION RÉPONSE ERREUR ===");
            
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de l\'insertion dans la base de données',
                'sql_error' => $errorInfo,
                'sql_state' => $errorInfo[0] ?? '',
                'driver_error_code' => $errorInfo[1] ?? '',
                'driver_error_message' => $errorInfo[2] ?? '',
                'column_count' => $columnCount,
                'sql_param_count' => $paramCount,
                'execute_param_count' => $executeParamCount,
                'uuid' => $uuid,
                'debug_info' => 'Erreur détaillée ci-dessus',
                'debug_details' => [
                    'sql_state' => $errorInfo[0] ?? '',
                    'driver_code' => $errorInfo[1] ?? '',
                    'message' => $errorInfo[2] ?? '',
                    'full_error_info' => $errorInfo,
                    'columns_count' => $columnCount,
                    'sql_params' => $paramCount,
                    'execute_params' => $executeParamCount,
                    'columns_list' => array_slice($columnsArray, 0, 10), // Premières 10 colonnes
                    'first_5_params' => array_slice($executeParams, 0, 5)
                ]
            ]);
            
            error_log("✓ Réponse erreur envoyée");
        }
        
    } catch (Exception $e) {
        error_log("=== EXCEPTION GÉNÉRALE DÉTECTÉE ===");
        error_log("Message exception: " . $e->getMessage());
        error_log("Code exception: " . $e->getCode());
        error_log("Fichier: " . $e->getFile() . " Ligne: " . $e->getLine());
        error_log("Stack trace: " . $e->getTraceAsString());
        
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de la préinscription',
            'error' => $e->getMessage(),
            'debug_file' => $e->getFile(),
            'debug_line' => $e->getLine(),
            'debug_code' => $e->getCode()
        ]);
        
        error_log("✓ Réponse exception envoyée");
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée',
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
}
?>
