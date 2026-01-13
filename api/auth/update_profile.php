<?php
/**
 * API Update Profile - Version complète
 * Mise à jour complète du profil utilisateur avec validation avancée
 */

// Configuration des erreurs
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuration CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT, PATCH, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Gestion OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Chargement des dépendances
require __DIR__ . '/../../vendor/autoload.php';
require_once __DIR__ . '/../config/database.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

// Configuration
$secret_key = "YOUR_SECRET_KEY";

/**
 * Validation des données
 */
function validateProfileData($data) {
    $errors = [];
    
    // Validation email
    if (isset($data->email)) {
        if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'Format d\'email invalide.';
        }
    }
    
    // Validation téléphone
    if (isset($data->phone) && !empty($data->phone)) {
        if (!preg_match('/^[\d\s\+\-\(\)]+$/', $data->phone)) {
            $errors[] = 'Format de téléphone invalide.';
        }
    }
    
    // Validation date de naissance
    if (isset($data->date_of_birth) && !empty($data->date_of_birth)) {
        $date = DateTime::createFromFormat('Y-m-d', $data->date_of_birth);
        if (!$date || $date->format('Y-m-d') !== $data->date_of_birth) {
            $errors[] = 'Format de date de naissance invalide (YYYY-MM-DD).';
        }
        
        // Vérification de l'âge (minimum 13 ans, maximum 120 ans)
        $age = (new DateTime())->diff($date)->y;
        if ($age < 13 || $age > 120) {
            $errors[] = 'Âge invalide.';
        }
    }
    
    // Validation genre
    if (isset($data->gender) && !empty($data->gender)) {
        $valid_genders = ['male', 'female', 'other', 'prefer_not_to_say'];
        if (!in_array(strtolower($data->gender), $valid_genders)) {
            $errors[] = 'Genre invalide.';
        }
    }
    
    // Validation longueur des champs texte
    $text_fields = [
        'first_name' => ['min' => 2, 'max' => 50],
        'last_name' => ['min' => 2, 'max' => 50],
        'middle_name' => ['min' => 0, 'max' => 50],
        'bio' => ['min' => 0, 'max' => 1000],
        'address' => ['min' => 0, 'max' => 255],
        'city' => ['min' => 0, 'max' => 100],
        'region' => ['min' => 0, 'max' => 100],
        'country' => ['min' => 0, 'max' => 100],
    ];
    
    foreach ($text_fields as $field => $limits) {
        if (isset($data->$field)) {
            $length = mb_strlen($data->$field);
            if ($length < $limits['min']) {
                $errors[] = ucfirst($field) . " doit contenir au moins {$limits['min']} caractères.";
            }
            if ($length > $limits['max']) {
                $errors[] = ucfirst($field) . " ne peut pas dépasser {$limits['max']} caractères.";
            }
        }
    }
    
    return $errors;
}

/**
 * Construction dynamique de la requête UPDATE
 */
function buildUpdateQuery($data, &$params, $user_id) {
    $updates = [];
    $params = [':id' => $user_id];
    
    // Champs de base
    $simple_fields = [
        'first_name', 'last_name', 'middle_name', 'email', 'phone',
        'address', 'bio', 'date_of_birth', 'place_of_birth', 'gender',
        'city', 'region', 'country', 'postal_code',
        'emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relationship'
    ];
    
    foreach ($simple_fields as $field) {
        if (isset($data->$field)) {
            $updates[] = "$field = :$field";
            $params[":$field"] = $data->$field;
        }
    }
    
    // Champ avatar_url (mapping vers profile_photo_url)
    if (isset($data->avatar_url)) {
        $updates[] = "profile_photo_url = :avatar_url";
        $params[':avatar_url'] = $data->avatar_url;
    }
    
    // Champ thumb_url (mapping vers thumb_photo_url)
    if (isset($data->thumb_url)) {
        $updates[] = "thumb_photo_url = :thumb_url";
        $params[':thumb_url'] = $data->thumb_url;
    }
    
    // Ajout de la date de mise à jour
    $updates[] = "updated_at = NOW()";
    
    if (empty($updates)) {
        return null;
    }
    
    return "UPDATE users SET " . implode(", ", $updates) . " WHERE id = :id";
}

/**
 * Enregistrement dans l'historique des modifications
 */
function logProfileUpdate($db, $user_id, $changed_fields) {
    try {
        $query = "INSERT INTO profile_update_history 
                 (user_id, changed_fields, updated_at) 
                 VALUES (:user_id, :changed_fields, NOW())";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $changed_fields_json = json_encode($changed_fields);
        $stmt->bindParam(':changed_fields', $changed_fields_json);
        $stmt->execute();
    } catch (Exception $e) {
        error_log("Erreur lors de l'enregistrement de l'historique: " . $e->getMessage());
    }
}

// Vérification de la méthode
$allowed_methods = ['PUT', 'PATCH', 'POST'];
if (!in_array($_SERVER['REQUEST_METHOD'], $allowed_methods)) {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée. Utilisez PUT, PATCH ou POST.'
    ]);
    exit();
}

// Récupération du token JWT
$headers = getallheaders();
$jwt = null;

if (isset($headers['Authorization'])) {
    if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
        $jwt = $matches[1];
    }
}

if (!$jwt) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Token d\'authentification manquant.'
    ]);
    exit();
}

try {
    // Décodage du token
    $decoded = JWT::decode($jwt, new Key($secret_key, 'HS256'));
    $user_id = $decoded->data->id;
    
    // Récupération des données
    $input = file_get_contents("php://input");
    $data = json_decode($input);
    
    if (!$data) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Données JSON invalides.'
        ]);
        exit();
    }
    
    // Validation des données
    $validation_errors = validateProfileData($data);
    if (!empty($validation_errors)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Erreurs de validation.',
            'errors' => $validation_errors
        ]);
        exit();
    }
    
    // Connexion à la base de données
    $database = new Database();
    $db = $database->getConnection();
    
    // Vérification de l'unicité de l'email si modifié
    if (isset($data->email)) {
        $check_query = "SELECT id FROM users WHERE email = :email AND id != :user_id";
        $check_stmt = $db->prepare($check_query);
        $check_stmt->bindParam(':email', $data->email);
        $check_stmt->bindParam(':user_id', $user_id);
        $check_stmt->execute();
        
        if ($check_stmt->fetch()) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Cet email est déjà utilisé par un autre compte.'
            ]);
            exit();
        }
    }
    
    // Construction de la requête UPDATE
    $params = [];
    $update_query = buildUpdateQuery($data, $params, $user_id);
    
    if (!$update_query) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Aucune donnée à mettre à jour.'
        ]);
        exit();
    }
    
    // Exécution de la mise à jour
    $stmt = $db->prepare($update_query);
    
    if ($stmt->execute($params)) {
        // Enregistrement dans l'historique
        logProfileUpdate($db, $user_id, array_keys(get_object_vars($data)));
        
        // Récupération des données mises à jour
        $select_query = "SELECT 
                            u.id, u.uuid, u.email, u.first_name, u.last_name, u.middle_name,
                            u.primary_role as role, u.phone, u.address, u.bio,
                            u.profile_photo_url as avatar_url, u.thumb_photo_url as thumb_url,
                            u.date_of_birth, u.place_of_birth, u.gender,
                            u.city, u.region, u.country, u.postal_code,
                            u.institution_id, u.is_active, u.is_verified, u.account_status,
                            u.created_at, u.updated_at, u.last_login_at,
                            u.emergency_contact_name, u.emergency_contact_phone, 
                            u.emergency_contact_relationship,
                            i.name as institution_name
                         FROM users u
                         LEFT JOIN institutions i ON u.institution_id = i.id
                         WHERE u.id = :id";
        
        $select_stmt = $db->prepare($select_query);
        $select_stmt->bindParam(':id', $user_id);
        $select_stmt->execute();
        
        $updated_user = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        // Formatage de la réponse
        $formatted_user = [
            'id' => $updated_user['id'],
            'uuid' => $updated_user['uuid'],
            'email' => $updated_user['email'],
            'firstName' => $updated_user['first_name'],
            'lastName' => $updated_user['last_name'],
            'middleName' => $updated_user['middle_name'],
            'role' => $updated_user['role'],
            'phone' => $updated_user['phone'],
            'address' => $updated_user['address'],
            'bio' => $updated_user['bio'],
            'avatarUrl' => $updated_user['avatar_url'],
            'thumbUrl' => $updated_user['thumb_url'],
            'dateOfBirth' => $updated_user['date_of_birth'],
            'placeOfBirth' => $updated_user['place_of_birth'],
            'gender' => $updated_user['gender'],
            'city' => $updated_user['city'],
            'region' => $updated_user['region'],
            'country' => $updated_user['country'],
            'postalCode' => $updated_user['postal_code'],
            'institutionId' => $updated_user['institution_id'],
            'institutionName' => $updated_user['institution_name'],
            'isActive' => (bool)$updated_user['is_active'],
            'isVerified' => (bool)$updated_user['is_verified'],
            'accountStatus' => $updated_user['account_status'],
            'createdAt' => $updated_user['created_at'],
            'updatedAt' => $updated_user['updated_at'],
            'lastLogin' => $updated_user['last_login_at'],
            'emergencyContactName' => $updated_user['emergency_contact_name'],
            'emergencyContactPhone' => $updated_user['emergency_contact_phone'],
            'emergencyContactRelationship' => $updated_user['emergency_contact_relationship'],
        ];
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Profil mis à jour avec succès.',
            'user' => $formatted_user,
            'updated_fields' => array_keys(get_object_vars($data))
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour du profil.',
            'error_info' => $stmt->errorInfo()
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur d\'authentification.',
        'error' => $e->getMessage()
    ]);
}
?>
