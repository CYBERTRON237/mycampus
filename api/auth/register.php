<?php
// Activer l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Définition de l'environnement (development/production)
define('ENVIRONMENT', 'development');

// En-têtes CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Fonction de débogage avancée avec sortie terminal
function debugTerminal($message, $data = null) {
    global $db, $lastQuery;
    $output = "\n=== DEBUG === " . date('Y-m-d H:i:s') . " ===\n";
    $output .= "Message: " . $message . "\n";
    
    if ($data !== null) {
        if (is_object($data) || is_array($data)) {
            $output .= "Détails: " . print_r($data, true) . "\n";
        } else {
            $output .= "Détails: " . $data . "\n";
        }
    }
    
    // Affichage des erreurs SQL si disponible
    if (isset($db) && $db instanceof PDO) {
        try {
            $errorInfo = $db->errorInfo();
            if (!empty($errorInfo[2])) {
                $output .= "Erreur SQL: " . $errorInfo[2] . "\n";
                $output .= "Code d'erreur: " . $errorInfo[1] . "\n";
            }
        } catch (Throwable $t) {
            $output .= "Impossible de récupérer errorInfo() depuis PDO: " . $t->getMessage() . "\n";
        }
        
        if (ENVIRONMENT === 'development' && isset($lastQuery) && !empty($lastQuery)) {
            $output .= "Dernière requête: " . $lastQuery . "\n";
        }
    }
    
    $output .= str_repeat("=", 20) . "\n\n";
    
    if ((PHP_SAPI === 'cli' || ENVIRONMENT === 'development') && defined('STDERR')) {
        @fwrite(STDERR, $output);
    }
    
    @error_log($output, 3, __DIR__ . '/register_debug.log');
    return $output;
}

// Gestion de la requête OPTIONS (pré-vol CORS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Inclusion de la configuration de la base de données
require_once __DIR__ . '/../config/database.php';

// Initialisation de la connexion à la base de données
try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Erreur de connexion à la base de données");
    }
    
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    
    $lastQuery = '';
    $json = file_get_contents('php://input');
    debugTerminal("JSON brut reçu", $json);
    
    if (empty($json)) {
        throw new Exception("Aucune donnée reçue");
    }
    
    $data = json_decode($json);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        debugTerminal("Erreur JSON", json_last_error_msg() . " (Code: " . json_last_error() . ")");
        throw new Exception("Erreur de décodage JSON: " . json_last_error_msg());
    }
    
    if (!is_object($data)) {
        debugTerminal("Format de données invalide", $data);
        throw new Exception("Format de données invalide");
    }
    
    debugTerminal("=== NOUVELLE DEMANDE D'INSCRIPTION ===");
    debugTerminal("Données brutes reçues", $json);
    debugTerminal("Données décodées", $data);
    
    // Validation des champs obligatoires du formulaire simplifié
    $requiredFields = [
        'email' => 'Email',
        'password' => 'Mot de passe',
        'firstName' => 'Prénom',  // camelCase comme envoyé par Flutter
        'lastName' => 'Nom',      // camelCase comme envoyé par Flutter
        'phone' => 'Téléphone'
    ];
    
    // Le genre est optionnel mais géré séparément
    
    $missingFields = [];
    foreach ($requiredFields as $field => $label) {
        // Vérification plus robuste des champs
        if (!isset($data->$field) || empty($data->$field)) {
            $missingFields[] = $label;
            debugTerminal("Champ manquant: $field", "Valeur: " . (isset($data->$field) ? $data->$field : 'non défini'));
        }
    }
    
    if (!empty($missingFields)) {
        $errorMsg = count($missingFields) > 1 
            ? "Les champs suivants sont obligatoires : " . implode(', ', $missingFields)
            : "Le champ " . $missingFields[0] . " est obligatoire";
        throw new Exception($errorMsg);
    }

    // Nettoyage des données - uniquement les champs du formulaire simplifié
    $email = filter_var(trim($data->email), FILTER_SANITIZE_EMAIL);
    $password = $data->password;
    $first_name = trim($data->firstName);  // camelCase depuis Flutter
    $last_name = trim($data->lastName);    // camelCase depuis Flutter
    $phone = trim($data->phone);
    $gender = $data->gender ?? null;
    
    // Validation de l'email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception("Format d'email invalide");
    }

    // Vérification de l'unicité de l'email
    $checkEmail = $db->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
    $checkEmail->bindParam(':email', $email);
    $checkEmail->execute();
    
    if ($checkEmail->rowCount() > 0) {
        throw new Exception("Cette adresse email est déjà utilisée");
    }

    // Hachage du mot de passe
    $password_hash = password_hash($password, PASSWORD_BCRYPT);
    
    // Valeurs par défaut simplifiées
    $institution_id = 1;
    $uuid = null;
    $middle_name = null;
    $date_of_birth = null;
    $place_of_birth = null;
    $nationality = 'Camerounaise';
    $address = null;
    $city = null;
    $region = null;
    $country = 'Cameroun';
    $postal_code = null;
    $matricule = null;
    $student_id = null;
    $emergency_contact_name = null;
    $emergency_contact_phone = null;
    $emergency_contact_relationship = null;
    $primary_role = 'invite';
    $account_status = 'active';
    $is_verified = 0;
    $is_active = 1;
    $language_preference = 'fr';
    $timezone = 'Africa/Douala';
    $created_at = date('Y-m-d H:i:s');
    $updated_at = $created_at;

    // Préparation de la requête d'insertion
    $query = "INSERT INTO users (
        uuid,
        institution_id,
        email,
        password_hash,
        first_name,
        last_name,
        middle_name,
        phone,
        gender,
        date_of_birth,
        place_of_birth,
        nationality,
        address,
        city,
        region,
        country,
        postal_code,
        matricule,
        student_id,
        emergency_contact_name,
        emergency_contact_phone,
        emergency_contact_relationship,
        primary_role,
        account_status,
        is_verified,
        is_active,
        language_preference,
        timezone,
        created_at,
        updated_at
    ) VALUES (
        :uuid,
        :institution_id,
        :email,
        :password_hash,
        :first_name,
        :last_name,
        :middle_name,
        :phone,
        :gender,
        :date_of_birth,
        :place_of_birth,
        :nationality,
        :address,
        :city,
        :region,
        :country,
        :postal_code,
        :matricule,
        :student_id,
        :emergency_contact_name,
        :emergency_contact_phone,
        :emergency_contact_relationship,
        :primary_role,
        :account_status,
        :is_verified,
        :is_active,
        :language_preference,
        :timezone,
        :created_at,
        :updated_at
    )";

    $stmt = $db->prepare($query);
    $lastQuery = $query;

    // Liaison des paramètres
    $stmt->bindValue(':uuid', $uuid, $uuid !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':institution_id', $institution_id, PDO::PARAM_INT);
    $stmt->bindValue(':email', $email);
    $stmt->bindValue(':password_hash', $password_hash);
    $stmt->bindValue(':first_name', $first_name);
    $stmt->bindValue(':last_name', $last_name);
    $stmt->bindValue(':middle_name', $middle_name, $middle_name !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':phone', $phone);
    $stmt->bindValue(':gender', $gender, $gender !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':date_of_birth', $date_of_birth, $date_of_birth !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':place_of_birth', $place_of_birth, $place_of_birth !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':nationality', $nationality);
    $stmt->bindValue(':address', $address, $address !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':city', $city, $city !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':region', $region, $region !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':country', $country);
    $stmt->bindValue(':postal_code', $postal_code, $postal_code !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':matricule', $matricule, $matricule !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':student_id', $student_id, $student_id !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':emergency_contact_name', $emergency_contact_name, $emergency_contact_name !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':emergency_contact_phone', $emergency_contact_phone, $emergency_contact_phone !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':emergency_contact_relationship', $emergency_contact_relationship, $emergency_contact_relationship !== null ? PDO::PARAM_STR : PDO::PARAM_NULL);
    $stmt->bindValue(':primary_role', $primary_role);
    $stmt->bindValue(':account_status', $account_status);
    $stmt->bindValue(':is_verified', $is_verified, PDO::PARAM_INT);
    $stmt->bindValue(':is_active', $is_active, PDO::PARAM_INT);
    $stmt->bindValue(':language_preference', $language_preference);
    $stmt->bindValue(':timezone', $timezone);
    $stmt->bindValue(':created_at', $created_at);
    $stmt->bindValue(':updated_at', $updated_at);

    // Exécution de la requête
    $stmt->execute();
    $userId = $db->lastInsertId();

    // Récupération de l'UUID généré
    $stmt = $db->prepare("SELECT uuid FROM users WHERE id = :id");
    $stmt->bindValue(':id', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    $uuid = $user['uuid'];

    // Réponse de succès
    http_response_code(201);
    echo json_encode([
        "success" => true,
        "message" => "Utilisateur enregistré avec succès",
        "user_id" => $userId,
        "uuid" => $uuid
    ]);

} catch (PDOException $e) {
    $errorInfo = $e->errorInfo ?? $db->errorInfo();
    $errorMessage = "Erreur de base de données: " . ($errorInfo[2] ?? $e->getMessage());
    error_log($errorMessage);
    
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Erreur lors de l'inscription",
        "error" => ENVIRONMENT === 'development' ? $errorMessage : "Une erreur est survenue"
    ]);
} catch (Exception $e) {
    error_log('Erreur d\'inscription: ' . $e->getMessage());
    
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
} finally {
    // Fermeture de la connexion
    if (isset($db)) {
        $db = null;
    }
}