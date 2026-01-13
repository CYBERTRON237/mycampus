<?php
// Activer l'affichage des erreurs pour le débogage
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Logger les erreurs dans un fichier
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/error.log');

// Envoyer les headers AVANT toute sortie
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Loguer la requête pour débogage
error_log("=== NOUVELLE REQUÊTE ===");
error_log("Méthode: " . $_SERVER['REQUEST_METHOD']);
error_log("Content-Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'non défini'));
error_log("Input brut: " . file_get_contents('php://input'));

try {
    require_once '../config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception('Erreur de connexion à la base de données');
    }
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Méthode non autorisée');
    }
    
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    error_log("Input décodé: " . print_r($input, true));
    
    if (!$input) {
        throw new Exception('Données JSON invalides');
    }
    
    // Validate required fields
    $required_fields = [
        'unique_code', 'faculty', 'last_name', 'first_name', 'date_of_birth',
        'place_of_birth', 'gender', 'residence_address', 'marital_status',
        'phone_number', 'email', 'first_language', 'professional_situation',
        'previous_diploma', 'graduation_year', 'desired_program', 'study_level',
        'parent_name', 'parent_phone'
    ];
    
    error_log("Vérification des champs obligatoires...");
    
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            error_log("Champ manquant ou vide: '$field'");
            throw new Exception("Le champ '$field' est obligatoire");
        }
    }
    
    error_log("Tous les champs obligatoires sont présents");
    
    // Validate ENUM values
    $valid_genders = ['MASCULIN', 'FEMININ'];
    $valid_marital_statuses = ['CELIBATAIRE', 'MARIE(E)', 'DIVORCE(E)', 'VEUF(VE)'];
    $valid_languages = ['FRANÇAIS', 'ANGLAIS', 'BILINGUE'];
    $valid_situations = ['SANS EMPLOI', 'SALARIE(E)', 'EN AUTO-EMPLOI', 'STAGIAIRE', 'RETRAITE(E)'];
    $valid_study_levels = ['LICENCE', 'MASTER', 'DOCTORAT', 'DUT', 'BTS', 'MASTER_PRO', 'DEUST', 'AUTRE'];
    $valid_payment_methods = ['ORANGE_MONEY', 'MTN_MONEY', 'BANK_TRANSFER', 'CASH', 'MOBILE_MONEY', 'CHEQUE', 'OTHER'];
    $valid_bac_series = ['A1', 'A2', 'A3', 'A4', 'A5', 'ABI', 'C', 'D', 'TI', 'SH', 'AC'];
    $valid_bac_mentions = ['PASSABLE', 'ASSEZ_BIEN', 'BIEN', 'TRES_BIEN', 'EXCELLENT'];
    
    error_log("Validation des valeurs ENUM...");
    error_log("Genre reçu: " . ($input['gender'] ?? 'non défini'));
    
    if (!in_array($input['gender'], $valid_genders)) {
        error_log("Genre invalide: " . $input['gender']);
        throw new Exception('Valeur de genre invalide');
    }
    
    if (!in_array($input['marital_status'], $valid_marital_statuses)) {
        error_log("Situation maritale invalide: " . $input['marital_status']);
        throw new Exception('Valeur de situation maritale invalide');
    }
    
    if (!in_array($input['first_language'], $valid_languages)) {
        error_log("Langue invalide: " . $input['first_language']);
        throw new Exception('Valeur de langue invalide');
    }
    
    if (!in_array($input['professional_situation'], $valid_situations)) {
        error_log("Situation professionnelle invalide: " . $input['professional_situation']);
        throw new Exception('Valeur de situation professionnelle invalide');
    }
    
    if (!in_array($input['study_level'], $valid_study_levels)) {
        error_log("Niveau d'études invalide: " . $input['study_level']);
        throw new Exception('Valeur de niveau d\'études invalide');
    }
    
    // Validate years
    $current_year = date('Y');
    if ($input['graduation_year'] < 1900 || $input['graduation_year'] > $current_year + 1) {
        throw new Exception('Année d\'obtention du diplôme invalide');
    }
    
    if (isset($input['bac_year']) && ($input['bac_year'] < 1900 || $input['bac_year'] > $current_year + 1)) {
        throw new Exception('Année du BAC invalide');
    }
    
    // Validate payment method if provided
    if (isset($input['payment_method']) && !in_array($input['payment_method'], $valid_payment_methods)) {
        throw new Exception('Méthode de paiement invalide');
    }
    
    // Validate BAC series if provided
    if (isset($input['series_bac']) && !in_array($input['series_bac'], $valid_bac_series)) {
        throw new Exception('Série du BAC invalide');
    }
    
    // Validate BAC mention if provided
    if (isset($input['bac_mention']) && !in_array($input['bac_mention'], $valid_bac_mentions)) {
        throw new Exception('Mention du BAC invalide');
    }
    
    // Validate email format
    if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Format d\'email invalide');
    }
    
    // Set default value for is_birth_date_on_certificate if not provided
    $is_birth_date_on_certificate = isset($input['is_birth_date_on_certificate']) ? 
                                    (int)$input['is_birth_date_on_certificate'] : 1;
    
    // Check if unique code already exists
    $check_query = "SELECT id FROM preinscriptions WHERE unique_code = :unique_code";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(':unique_code', $input['unique_code']);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() > 0) {
        throw new Exception('Ce code unique existe déjà');
    }
    
    // Insert preinscription
    $query = "INSERT INTO preinscriptions (
        uuid, unique_code, faculty, last_name, first_name, middle_name,
        date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
        cni_number, residence_address, marital_status, phone_number, email,
        first_language, professional_situation, status, documents_status,
        previous_diploma, previous_institution, graduation_year, graduation_month, desired_program, study_level,
        specialization, series_bac, bac_year, bac_center, bac_mention, gpa_score, rank_in_class,
        birth_certificate_path, cni_path, diploma_path, transcript_path, photo_path,
        recommendation_letter_path, motivation_letter_path, medical_certificate_path, other_documents_path,
        parent_name, parent_phone, parent_email, parent_occupation, parent_address, parent_relationship, parent_income_level,
        payment_method, payment_reference, payment_amount, payment_currency, payment_date, payment_proof_path,
        scholarship_requested, scholarship_type, financial_aid_amount,
        review_priority, interview_required, contact_preference,
        marketing_consent, data_processing_consent, newsletter_subscription,
        ip_address, user_agent, device_type, browser_info, os_info, location_country, location_city,
        notes, admin_notes, internal_comments, special_needs, medical_conditions,
        applicant_email, applicant_phone, relationship, is_processed
    ) VALUES (
        UUID(), :unique_code, :faculty, :last_name, :first_name, :middle_name,
        :date_of_birth, :is_birth_date_on_certificate, :place_of_birth, :gender,
        :cni_number, :residence_address, :marital_status, :phone_number, :email,
        :first_language, :professional_situation, 'pending', 'pending',
        :previous_diploma, :previous_institution, :graduation_year, :graduation_month, :desired_program, :study_level,
        :specialization, :series_bac, :bac_year, :bac_center, :bac_mention, :gpa_score, :rank_in_class,
        :birth_certificate_path, :cni_path, :diploma_path, :transcript_path, :photo_path,
        :recommendation_letter_path, :motivation_letter_path, :medical_certificate_path, :other_documents_path,
        :parent_name, :parent_phone, :parent_email, :parent_occupation, :parent_address, :parent_relationship, :parent_income_level,
        :payment_method, :payment_reference, :payment_amount, 'XAF', :payment_date, :payment_proof_path,
        :scholarship_requested, :scholarship_type, :financial_aid_amount,
        'NORMAL', 0, :contact_preference,
        :marketing_consent, :data_processing_consent, :newsletter_subscription,
        :ip_address, :user_agent, :device_type, :browser_info, :os_info, :location_country, :location_city,
        :notes, :admin_notes, :internal_comments, :special_needs, :medical_conditions,
        :applicant_email, :applicant_phone, :relationship, 0
    )";
    
    $stmt = $db->prepare($query);
    
    // Bind parameters
    $stmt->bindParam(':unique_code', $input['unique_code']);
    $stmt->bindParam(':faculty', $input['faculty']);
    $stmt->bindParam(':last_name', $input['last_name']);
    $stmt->bindParam(':first_name', $input['first_name']);
    
    $middle_name = $input['middle_name'] ?? null;
    $stmt->bindParam(':middle_name', $middle_name);
    
    $stmt->bindParam(':date_of_birth', $input['date_of_birth']);
    $stmt->bindParam(':is_birth_date_on_certificate', $is_birth_date_on_certificate, PDO::PARAM_INT);
    $stmt->bindParam(':place_of_birth', $input['place_of_birth']);
    $stmt->bindParam(':gender', $input['gender']);
    
    $cni_number = $input['cni_number'] ?? null;
    $stmt->bindParam(':cni_number', $cni_number);
    
    $stmt->bindParam(':residence_address', $input['residence_address']);
    $stmt->bindParam(':marital_status', $input['marital_status']);
    $stmt->bindParam(':phone_number', $input['phone_number']);
    $stmt->bindParam(':email', $input['email']);
    $stmt->bindParam(':first_language', $input['first_language']);
    $stmt->bindParam(':professional_situation', $input['professional_situation']);
    
    // Academic fields
    $stmt->bindParam(':previous_diploma', $input['previous_diploma']);
    $previous_institution = $input['previous_institution'] ?? null;
    $stmt->bindParam(':previous_institution', $previous_institution);
    $stmt->bindParam(':graduation_year', $input['graduation_year']);
    
    $graduation_month = $input['graduation_month'] ?? null;
    $stmt->bindParam(':graduation_month', $graduation_month);
    
    $stmt->bindParam(':desired_program', $input['desired_program']);
    $stmt->bindParam(':study_level', $input['study_level']);
    
    $specialization = $input['specialization'] ?? null;
    $stmt->bindParam(':specialization', $specialization);
    
    $series_bac = $input['series_bac'] ?? null;
    $stmt->bindParam(':series_bac', $series_bac);
    
    $bac_year = $input['bac_year'] ?? null;
    $stmt->bindParam(':bac_year', $bac_year);
    
    $bac_center = $input['bac_center'] ?? null;
    $stmt->bindParam(':bac_center', $bac_center);
    
    $bac_mention = $input['bac_mention'] ?? null;
    $stmt->bindParam(':bac_mention', $bac_mention);
    
    $gpa_score = $input['gpa_score'] ?? null;
    $stmt->bindParam(':gpa_score', $gpa_score);
    
    $rank_in_class = $input['rank_in_class'] ?? null;
    $stmt->bindParam(':rank_in_class', $rank_in_class);
    
    // Document paths
    $birth_certificate_path = $input['birth_certificate_path'] ?? null;
    $stmt->bindParam(':birth_certificate_path', $birth_certificate_path);
    
    $cni_path = $input['cni_path'] ?? null;
    $stmt->bindParam(':cni_path', $cni_path);
    
    $diploma_path = $input['diploma_path'] ?? null;
    $stmt->bindParam(':diploma_path', $diploma_path);
    
    $transcript_path = $input['transcript_path'] ?? null;
    $stmt->bindParam(':transcript_path', $transcript_path);
    
    $photo_path = $input['photo_path'] ?? null;
    $stmt->bindParam(':photo_path', $photo_path);
    
    $recommendation_letter_path = $input['recommendation_letter_path'] ?? null;
    $stmt->bindParam(':recommendation_letter_path', $recommendation_letter_path);
    
    $motivation_letter_path = $input['motivation_letter_path'] ?? null;
    $stmt->bindParam(':motivation_letter_path', $motivation_letter_path);
    
    $medical_certificate_path = $input['medical_certificate_path'] ?? null;
    $stmt->bindParam(':medical_certificate_path', $medical_certificate_path);
    
    $other_documents_path = isset($input['other_documents_path']) ? json_encode($input['other_documents_path']) : null;
    $stmt->bindParam(':other_documents_path', $other_documents_path);
    
    // Parent information
    $stmt->bindParam(':parent_name', $input['parent_name']);
    $stmt->bindParam(':parent_phone', $input['parent_phone']);
    
    $parent_email = $input['parent_email'] ?? null;
    $stmt->bindParam(':parent_email', $parent_email);
    
    $parent_occupation = $input['parent_occupation'] ?? null;
    $stmt->bindParam(':parent_occupation', $parent_occupation);
    
    $parent_address = $input['parent_address'] ?? null;
    $stmt->bindParam(':parent_address', $parent_address);
    
    $parent_relationship = $input['parent_relationship'] ?? null;
    $stmt->bindParam(':parent_relationship', $parent_relationship);
    
    $parent_income_level = $input['parent_income_level'] ?? null;
    $stmt->bindParam(':parent_income_level', $parent_income_level);
    
    // Payment information
    $payment_method = $input['payment_method'] ?? null;
    $stmt->bindParam(':payment_method', $payment_method);
    
    $payment_reference = $input['payment_reference'] ?? null;
    $stmt->bindParam(':payment_reference', $payment_reference);
    
    $payment_amount = $input['payment_amount'] ?? null;
    $stmt->bindParam(':payment_amount', $payment_amount);
    
    $payment_date = $input['payment_date'] ?? null;
    $stmt->bindParam(':payment_date', $payment_date);
    
    $payment_proof_path = $input['payment_proof_path'] ?? null;
    $stmt->bindParam(':payment_proof_path', $payment_proof_path);
    
    // Scholarship information
    $scholarship_requested = isset($input['scholarship_requested']) ? (int)$input['scholarship_requested'] : 0;
    $stmt->bindParam(':scholarship_requested', $scholarship_requested, PDO::PARAM_INT);
    
    $scholarship_type = $input['scholarship_type'] ?? null;
    $stmt->bindParam(':scholarship_type', $scholarship_type);
    
    $financial_aid_amount = $input['financial_aid_amount'] ?? null;
    $stmt->bindParam(':financial_aid_amount', $financial_aid_amount);
    
    // Contact preferences and consent
    $contact_preference = $input['contact_preference'] ?? null;
    $stmt->bindParam(':contact_preference', $contact_preference);
    
    $marketing_consent = isset($input['marketing_consent']) ? (int)$input['marketing_consent'] : 0;
    $stmt->bindParam(':marketing_consent', $marketing_consent, PDO::PARAM_INT);
    
    $data_processing_consent = isset($input['data_processing_consent']) ? (int)$input['data_processing_consent'] : 0;
    $stmt->bindParam(':data_processing_consent', $data_processing_consent, PDO::PARAM_INT);
    
    $newsletter_subscription = isset($input['newsletter_subscription']) ? (int)$input['newsletter_subscription'] : 0;
    $stmt->bindParam(':newsletter_subscription', $newsletter_subscription, PDO::PARAM_INT);
    
    // System information
    $ip_address = $_SERVER['REMOTE_ADDR'] ?? null;
    $stmt->bindParam(':ip_address', $ip_address);
    
    $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? null;
    $stmt->bindParam(':user_agent', $user_agent);
    
    $device_type = $input['device_type'] ?? null;
    $stmt->bindParam(':device_type', $device_type);
    
    $browser_info = $input['browser_info'] ?? null;
    $stmt->bindParam(':browser_info', $browser_info);
    
    $os_info = $input['os_info'] ?? null;
    $stmt->bindParam(':os_info', $os_info);
    
    $location_country = $input['location_country'] ?? null;
    $stmt->bindParam(':location_country', $location_country);
    
    $location_city = $input['location_city'] ?? null;
    $stmt->bindParam(':location_city', $location_city);
    
    // Notes and additional information
    $notes = $input['notes'] ?? null;
    $stmt->bindParam(':notes', $notes);
    
    $admin_notes = $input['admin_notes'] ?? null;
    $stmt->bindParam(':admin_notes', $admin_notes);
    
    $internal_comments = $input['internal_comments'] ?? null;
    $stmt->bindParam(':internal_comments', $internal_comments);
    
    $special_needs = $input['special_needs'] ?? null;
    $stmt->bindParam(':special_needs', $special_needs);
    
    $medical_conditions = $input['medical_conditions'] ?? null;
    $stmt->bindParam(':medical_conditions', $medical_conditions);
    
    // Applicant information
    $applicant_email = $input['applicant_email'] ?? null;
    $stmt->bindParam(':applicant_email', $applicant_email);
    
    $applicant_phone = $input['applicant_phone'] ?? null;
    $stmt->bindParam(':applicant_phone', $applicant_phone);
    
    $relationship = $input['relationship'] ?? 'self';
    $stmt->bindParam(':relationship', $relationship);
    
    error_log("Tous les paramètres bindés, exécution de la requête...");
    
    if ($stmt->execute()) {
        error_log("Requête exécutée avec succès");
        $preinscription_id = $db->lastInsertId();
        error_log("ID de la préinscription: " . $preinscription_id);
        
        // Get the created record
        $select_query = "SELECT * FROM preinscriptions WHERE id = :id";
        $select_stmt = $db->prepare($select_query);
        $select_stmt->bindParam(':id', $preinscription_id);
        $select_stmt->execute();
        
        $preinscription = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription enregistrée avec succès',
            'data' => $preinscription
        ]);
    } else {
        error_log("Erreur lors de l'exécution: " . print_r($stmt->errorInfo(), true));
        throw new Exception('Erreur lors de l\'enregistrement de la préinscription');
    }
    
} catch (Exception $e) {
    error_log("ERREUR CAPTURÉE: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
