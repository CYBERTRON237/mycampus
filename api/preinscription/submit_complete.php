<?php
// Activer l'affichage des erreurs pour le débogage
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Envoyer les headers AVANT toute sortie
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

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
    
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            throw new Exception("Le champ '$field' est obligatoire");
        }
    }
    
    // Validation des valeurs ENUM - mise à jour avec les nouvelles options
    $valid_genders = ['MASCULIN', 'FEMININ'];
    $valid_marital_statuses = ['CELIBATAIRE', 'MARIE(E)', 'DIVORCE(E)', 'VEUF(VE)'];
    $valid_languages = ['FRANÇAIS', 'ANGLAIS', 'BILINGUE'];
    $valid_situations = ['SANS EMPLOI', 'SALARIE(E)', 'EN AUTO-EMPLOI', 'STAGIAIRE', 'RETRAITE(E)'];
    $valid_study_levels = ['LICENCE', 'MASTER', 'DOCTORAT', 'DUT', 'BTS', 'MASTER_PRO', 'DEUST', 'AUTRE'];
    $valid_payment_methods = ['ORANGE_MONEY', 'MTN_MONEY', 'BANK_TRANSFER', 'CASH', 'MOBILE_MONEY', 'CHEQUE', 'OTHER'];
    $valid_parent_relationships = ['PERE', 'MERE', 'TUTEUR', 'AUTRE'];
    $valid_income_levels = ['FAIBLE', 'MOYEN', 'ELEVE'];
    $valid_contact_preferences = ['EMAIL', 'PHONE', 'SMS', 'WHATSAPP'];
    $valid_bac_mentions = ['PASSABLE', 'ASSEZ_BIEN', 'BIEN', 'TRES_BIEN', 'EXCELLENT'];
    
    // Validation des champs ENUM
    if (!in_array($input['gender'], $valid_genders)) {
        throw new Exception('Valeur de genre invalide');
    }
    
    if (!in_array($input['marital_status'], $valid_marital_statuses)) {
        throw new Exception('Valeur de situation maritale invalide');
    }
    
    if (!in_array($input['first_language'], $valid_languages)) {
        throw new Exception('Valeur de langue invalide');
    }
    
    if (!in_array($input['professional_situation'], $valid_situations)) {
        throw new Exception('Valeur de situation professionnelle invalide');
    }
    
    if (!in_array($input['study_level'], $valid_study_levels)) {
        throw new Exception('Valeur de niveau d\'études invalide');
    }
    
    // Validation des années
    $current_year = date('Y');
    if ($input['graduation_year'] < 1900 || $input['graduation_year'] > $current_year + 1) {
        throw new Exception('Année d\'obtention du diplôme invalide');
    }
    
    if (isset($input['bac_year']) && ($input['bac_year'] < 1900 || $input['bac_year'] > $current_year + 1)) {
        throw new Exception('Année du BAC invalide');
    }
    
    // Validation des champs optionnels
    if (isset($input['payment_method']) && !in_array($input['payment_method'], $valid_payment_methods)) {
        throw new Exception('Méthode de paiement invalide');
    }
    
    if (isset($input['parent_relationship']) && !in_array($input['parent_relationship'], $valid_parent_relationships)) {
        throw new Exception('Lien de parenté invalide');
    }
    
    if (isset($input['parent_income_level']) && !in_array($input['parent_income_level'], $valid_income_levels)) {
        throw new Exception('Niveau de revenu invalide');
    }
    
    if (isset($input['contact_preference']) && !in_array($input['contact_preference'], $valid_contact_preferences)) {
        throw new Exception('Préférence de contact invalide');
    }
    
    if (isset($input['bac_mention']) && !in_array($input['bac_mention'], $valid_bac_mentions)) {
        throw new Exception('Mention du BAC invalide');
    }
    
    // Validation des valeurs numériques
    if (isset($input['gpa_score']) && ($input['gpa_score'] < 0.0 || $input['gpa_score'] > 5.0)) {
        throw new Exception('Score GPA invalide (doit être entre 0.0 et 5.0)');
    }
    
    if (isset($input['rank_in_class']) && ($input['rank_in_class'] < 1)) {
        throw new Exception('Rang dans la classe invalide');
    }
    
    if (isset($input['payment_amount']) && ($input['payment_amount'] < 0)) {
        throw new Exception('Montant de paiement invalide');
    }
    
    if (isset($input['financial_aid_amount']) && ($input['financial_aid_amount'] < 0)) {
        throw new Exception('Montant d\'aide financière invalide');
    }
    
    // Validation email
    if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Format d\'email invalide');
    }
    
    if (isset($input['parent_email']) && !empty($input['parent_email']) && !filter_var($input['parent_email'], FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Format d\'email du parent invalide');
    }
    
    // Préparation des valeurs par défaut
    $is_birth_date_on_certificate = isset($input['is_birth_date_on_certificate']) ? 
                                    (int)$input['is_birth_date_on_certificate'] : 1;
    
    $scholarship_requested = isset($input['scholarship_requested']) ? 
                             (int)$input['scholarship_requested'] : 0;
    
    $marketing_consent = isset($input['marketing_consent']) ? 
                        (int)$input['marketing_consent'] : 0;
    
    $data_processing_consent = isset($input['data_processing_consent']) ? 
                               (int)$input['data_processing_consent'] : 0;
    
    $newsletter_subscription = isset($input['newsletter_subscription']) ? 
                               (int)$input['newsletter_subscription'] : 0;
    
    // Vérifier si le code unique existe déjà
    $check_query = "SELECT id FROM preinscriptions WHERE unique_code = :unique_code";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(':unique_code', $input['unique_code']);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() > 0) {
        throw new Exception('Ce code unique existe déjà');
    }
    
    // Requête d'insertion complète avec tous les champs
    $query = "INSERT INTO preinscriptions (
        uuid, unique_code, faculty, last_name, first_name, middle_name,
        date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
        cni_number, residence_address, marital_status, phone_number, email,
        first_language, professional_situation,
        
        -- Informations académiques
        previous_diploma, previous_institution, graduation_year, graduation_month,
        desired_program, study_level, specialization, series_bac, bac_year, bac_center,
        bac_mention, gpa_score, rank_in_class,
        
        -- Documents
        birth_certificate_path, cni_path, diploma_path, transcript_path, photo_path,
        recommendation_letter_path, motivation_letter_path, medical_certificate_path,
        other_documents_path,
        
        -- Parents
        parent_name, parent_phone, parent_email, parent_occupation, parent_address,
        parent_relationship, parent_income_level,
        
        -- Paiement
        payment_method, payment_reference, payment_amount, payment_currency,
        payment_date, payment_status, payment_proof_path, scholarship_requested,
        scholarship_type, financial_aid_amount,
        
        -- Préférences
        contact_preference, marketing_consent, data_processing_consent,
        newsletter_subscription,
        
        -- Système
        ip_address, user_agent, device_type, browser_info, os_info,
        location_country, location_city,
        
        -- Notes
        notes, special_needs, medical_conditions,
        
        -- Statuts
        status, documents_status, review_priority
        
    ) VALUES (
        UUID(), :unique_code, :faculty, :last_name, :first_name, :middle_name,
        :date_of_birth, :is_birth_date_on_certificate, :place_of_birth, :gender,
        :cni_number, :residence_address, :marital_status, :phone_number, :email,
        :first_language, :professional_situation,
        
        -- Informations académiques
        :previous_diploma, :previous_institution, :graduation_year, :graduation_month,
        :desired_program, :study_level, :specialization, :series_bac, :bac_year, :bac_center,
        :bac_mention, :gpa_score, :rank_in_class,
        
        -- Documents
        :birth_certificate_path, :cni_path, :diploma_path, :transcript_path, :photo_path,
        :recommendation_letter_path, :motivation_letter_path, :medical_certificate_path,
        :other_documents_path,
        
        -- Parents
        :parent_name, :parent_phone, :parent_email, :parent_occupation, :parent_address,
        :parent_relationship, :parent_income_level,
        
        -- Paiement
        :payment_method, :payment_reference, :payment_amount, :payment_currency,
        :payment_date, :payment_status, :payment_proof_path, :scholarship_requested,
        :scholarship_type, :financial_aid_amount,
        
        -- Préférences
        :contact_preference, :marketing_consent, :data_processing_consent,
        :newsletter_subscription,
        
        -- Système
        :ip_address, :user_agent, :device_type, :browser_info, :os_info,
        :location_country, :location_city,
        
        -- Notes
        :notes, :special_needs, :medical_conditions,
        
        -- Statuts
        :status, :documents_status, :review_priority
    )";
    
    $stmt = $db->prepare($query);
    
    // Liaison des paramètres - Informations de base
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
    
    // Liaison des paramètres - Informations académiques
    $stmt->bindParam(':previous_diploma', $input['previous_diploma']);
    
    $previous_institution = $input['previous_institution'] ?? null;
    $stmt->bindParam(':previous_institution', $previous_institution);
    
    $stmt->bindParam(':graduation_year', $input['graduation_year'], PDO::PARAM_INT);
    
    $graduation_month = $input['graduation_month'] ?? null;
    $stmt->bindParam(':graduation_month', $graduation_month);
    
    $stmt->bindParam(':desired_program', $input['desired_program']);
    $stmt->bindParam(':study_level', $input['study_level']);
    
    $specialization = $input['specialization'] ?? null;
    $stmt->bindParam(':specialization', $specialization);
    
    $series_bac = $input['series_bac'] ?? null;
    $stmt->bindParam(':series_bac', $series_bac);
    
    $bac_year = $input['bac_year'] ?? null;
    $stmt->bindParam(':bac_year', $bac_year, PDO::PARAM_INT);
    
    $bac_center = $input['bac_center'] ?? null;
    $stmt->bindParam(':bac_center', $bac_center);
    
    $bac_mention = $input['bac_mention'] ?? null;
    $stmt->bindParam(':bac_mention', $bac_mention);
    
    $gpa_score = $input['gpa_score'] ?? null;
    $stmt->bindParam(':gpa_score', $gpa_score);
    
    $rank_in_class = $input['rank_in_class'] ?? null;
    $stmt->bindParam(':rank_in_class', $rank_in_class, PDO::PARAM_INT);
    
    // Liaison des paramètres - Documents
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
    
    $other_documents_path = $input['other_documents_path'] ?? null;
    $stmt->bindParam(':other_documents_path', $other_documents_path);
    
    // Liaison des paramètres - Parents
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
    
    // Liaison des paramètres - Paiement
    $payment_method = $input['payment_method'] ?? null;
    $stmt->bindParam(':payment_method', $payment_method);
    
    $payment_reference = $input['payment_reference'] ?? null;
    $stmt->bindParam(':payment_reference', $payment_reference);
    
    $payment_amount = $input['payment_amount'] ?? null;
    $stmt->bindParam(':payment_amount', $payment_amount);
    
    $payment_currency = $input['payment_currency'] ?? 'XAF';
    $stmt->bindParam(':payment_currency', $payment_currency);
    
    $payment_date = $input['payment_date'] ?? null;
    $stmt->bindParam(':payment_date', $payment_date);
    
    $payment_status = $input['payment_status'] ?? 'pending';
    $stmt->bindParam(':payment_status', $payment_status);
    
    $payment_proof_path = $input['payment_proof_path'] ?? null;
    $stmt->bindParam(':payment_proof_path', $payment_proof_path);
    
    $stmt->bindParam(':scholarship_requested', $scholarship_requested, PDO::PARAM_INT);
    
    $scholarship_type = $input['scholarship_type'] ?? null;
    $stmt->bindParam(':scholarship_type', $scholarship_type);
    
    $financial_aid_amount = $input['financial_aid_amount'] ?? null;
    $stmt->bindParam(':financial_aid_amount', $financial_aid_amount);
    
    // Liaison des paramètres - Préférences
    $contact_preference = $input['contact_preference'] ?? null;
    $stmt->bindParam(':contact_preference', $contact_preference);
    
    $stmt->bindParam(':marketing_consent', $marketing_consent, PDO::PARAM_INT);
    $stmt->bindParam(':data_processing_consent', $data_processing_consent, PDO::PARAM_INT);
    $stmt->bindParam(':newsletter_subscription', $newsletter_subscription, PDO::PARAM_INT);
    
    // Liaison des paramètres - Système
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
    
    // Liaison des paramètres - Notes
    $notes = $input['notes'] ?? null;
    $stmt->bindParam(':notes', $notes);
    
    $special_needs = $input['special_needs'] ?? null;
    $stmt->bindParam(':special_needs', $special_needs);
    
    $medical_conditions = $input['medical_conditions'] ?? null;
    $stmt->bindParam(':medical_conditions', $medical_conditions);
    
    // Liaison des paramètres - Statuts
    $status = $input['status'] ?? 'pending';
    $stmt->bindParam(':status', $status);
    
    $documents_status = $input['documents_status'] ?? 'pending';
    $stmt->bindParam(':documents_status', $documents_status);
    
    $review_priority = $input['review_priority'] ?? 'NORMAL';
    $stmt->bindParam(':review_priority', $review_priority);
    
    // Exécution de la requête
    if ($stmt->execute()) {
        $preinscription_id = $db->lastInsertId();
        
        // Récupérer l'enregistrement créé
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
        throw new Exception('Erreur lors de l\'enregistrement de la préinscription: ' . implode(', ', $stmt->errorInfo()));
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error_details' => $e->getTraceAsString()
    ]);
}
?>
