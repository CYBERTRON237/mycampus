<?php
/**
 * API Upload Avatar
 * Gère l'upload, la validation, le redimensionnement et l'enregistrement de la photo de profil
 */

// Configuration des erreurs pour le débogage
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuration CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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
$upload_dir = __DIR__ . '/../../uploads/avatars/';
$max_file_size = 5 * 1024 * 1024; // 5MB
$allowed_types = ['image/jpeg', 'image/png', 'image/jpg', 'image/gif', 'image/webp'];
$allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

// Création du dossier d'upload si inexistant
if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0755, true);
}

/**
 * Fonction de validation et nettoyage du nom de fichier
 */
function sanitizeFileName($filename) {
    $filename = preg_replace('/[^a-zA-Z0-9._-]/', '', $filename);
    return $filename;
}

/**
 * Fonction de redimensionnement d'image
 */
function resizeImage($source, $destination, $max_width = 500, $max_height = 500, $quality = 85) {
    try {
        list($width, $height, $type) = getimagesize($source);
        
        // Calcul des nouvelles dimensions
        $ratio = min($max_width / $width, $max_height / $height);
        $new_width = round($width * $ratio);
        $new_height = round($height * $ratio);
        
        // Création de l'image source
        switch ($type) {
            case IMAGETYPE_JPEG:
                $image = imagecreatefromjpeg($source);
                break;
            case IMAGETYPE_PNG:
                $image = imagecreatefrompng($source);
                break;
            case IMAGETYPE_GIF:
                $image = imagecreatefromgif($source);
                break;
            case IMAGETYPE_WEBP:
                $image = imagecreatefromwebp($source);
                break;
            default:
                return false;
        }
        
        if (!$image) {
            return false;
        }
        
        // Création de la nouvelle image
        $new_image = imagecreatetruecolor($new_width, $new_height);
        
        // Préservation de la transparence pour PNG et GIF
        if ($type == IMAGETYPE_PNG || $type == IMAGETYPE_GIF) {
            imagealphablending($new_image, false);
            imagesavealpha($new_image, true);
            $transparent = imagecolorallocatealpha($new_image, 255, 255, 255, 127);
            imagefilledrectangle($new_image, 0, 0, $new_width, $new_height, $transparent);
        }
        
        // Redimensionnement
        imagecopyresampled($new_image, $image, 0, 0, 0, 0, $new_width, $new_height, $width, $height);
        
        // Sauvegarde
        $result = false;
        switch ($type) {
            case IMAGETYPE_JPEG:
                $result = imagejpeg($new_image, $destination, $quality);
                break;
            case IMAGETYPE_PNG:
                $result = imagepng($new_image, $destination, round(9 * $quality / 100));
                break;
            case IMAGETYPE_GIF:
                $result = imagegif($new_image, $destination);
                break;
            case IMAGETYPE_WEBP:
                $result = imagewebp($new_image, $destination, $quality);
                break;
        }
        
        // Libération de la mémoire
        imagedestroy($image);
        imagedestroy($new_image);
        
        return $result;
    } catch (Exception $e) {
        error_log("Erreur redimensionnement: " . $e->getMessage());
        return false;
    }
}

/**
 * Fonction de suppression de l'ancien avatar
 */
function deleteOldAvatar($user_id, $upload_dir) {
    $patterns = [
        $upload_dir . $user_id . '_avatar.*',
        $upload_dir . $user_id . '_thumb.*'
    ];
    
    foreach ($patterns as $pattern) {
        $files = glob($pattern);
        foreach ($files as $file) {
            if (file_exists($file)) {
                @unlink($file);
            }
        }
    }
}

// Vérification de la méthode
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée. Utilisez POST.'
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

// Vérification alternative via POST
if (!$jwt && isset($_POST['token'])) {
    $jwt = $_POST['token'];
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
    
    // Vérification de l'upload
    if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
        $error_messages = [
            UPLOAD_ERR_INI_SIZE => 'Le fichier dépasse la taille maximale autorisée par le serveur.',
            UPLOAD_ERR_FORM_SIZE => 'Le fichier dépasse la taille maximale autorisée par le formulaire.',
            UPLOAD_ERR_PARTIAL => 'Le fichier n\'a été que partiellement téléchargé.',
            UPLOAD_ERR_NO_FILE => 'Aucun fichier n\'a été téléchargé.',
            UPLOAD_ERR_NO_TMP_DIR => 'Dossier temporaire manquant.',
            UPLOAD_ERR_CANT_WRITE => 'Échec de l\'écriture du fichier sur le disque.',
            UPLOAD_ERR_EXTENSION => 'Une extension PHP a arrêté le téléchargement du fichier.'
        ];
        
        $error_code = isset($_FILES['avatar']) ? $_FILES['avatar']['error'] : UPLOAD_ERR_NO_FILE;
        $error_message = $error_messages[$error_code] ?? 'Erreur inconnue lors de l\'upload.';
        
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => $error_message
        ]);
        exit();
    }
    
    $file = $_FILES['avatar'];
    
    // Validation de la taille
    if ($file['size'] > $max_file_size) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Le fichier est trop volumineux. Taille maximale : 5MB.'
        ]);
        exit();
    }
    
    // Validation du type MIME
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime_type = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);
    
    if (!in_array($mime_type, $allowed_types)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Type de fichier non autorisé. Formats acceptés : JPG, PNG, GIF, WEBP.'
        ]);
        exit();
    }
    
    // Validation de l'extension
    $file_extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($file_extension, $allowed_extensions)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Extension de fichier non autorisée.'
        ]);
        exit();
    }
    
    // Suppression de l'ancien avatar
    deleteOldAvatar($user_id, $upload_dir);
    
    // Génération des noms de fichiers
    $timestamp = time();
    $main_filename = $user_id . '_avatar_' . $timestamp . '.' . $file_extension;
    $thumb_filename = $user_id . '_thumb_' . $timestamp . '.' . $file_extension;
    
    $main_path = $upload_dir . $main_filename;
    $thumb_path = $upload_dir . $thumb_filename;
    
    // Déplacement du fichier uploadé
    if (!move_uploaded_file($file['tmp_name'], $main_path)) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la sauvegarde du fichier.'
        ]);
        exit();
    }
    
    // Redimensionnement de l'image principale (800x800 max)
    if (!resizeImage($main_path, $main_path, 800, 800, 90)) {
        // Si le redimensionnement échoue, on garde l'original
        error_log("Échec du redimensionnement de l'image principale");
    }
    
    // Création de la miniature (150x150)
    if (!resizeImage($main_path, $thumb_path, 150, 150, 85)) {
        error_log("Échec de la création de la miniature");
        // La miniature n'est pas critique
    }
    
    // Construction des URLs
    $avatar_url = '/uploads/avatars/' . $main_filename;
    $thumb_url = '/uploads/avatars/' . $thumb_filename;
    
    // Mise à jour de la base de données
    $database = new Database();
    $db = $database->getConnection();
    
    $query = "UPDATE users 
              SET profile_photo_url = :avatar_url,
                  thumb_photo_url = :thumb_url,
                  updated_at = NOW()
              WHERE id = :user_id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':avatar_url', $avatar_url);
    $stmt->bindParam(':thumb_url', $thumb_url);
    $stmt->bindParam(':user_id', $user_id);
    
    if ($stmt->execute()) {
        // Récupération des données utilisateur mises à jour
        $select_query = "SELECT id, email, first_name, last_name, primary_role as role,
                               phone, address, bio, profile_photo_url, thumb_photo_url,
                               institution_id, updated_at
                        FROM users 
                        WHERE id = :user_id";
        
        $select_stmt = $db->prepare($select_query);
        $select_stmt->bindParam(':user_id', $user_id);
        $select_stmt->execute();
        
        $user = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        // Enregistrement dans l'historique
        $history_query = "INSERT INTO profile_photo_history 
                         (user_id, photo_url, uploaded_at) 
                         VALUES (:user_id, :photo_url, NOW())";
        
        $history_stmt = $db->prepare($history_query);
        $history_stmt->bindParam(':user_id', $user_id);
        $history_stmt->bindParam(':photo_url', $avatar_url);
        $history_stmt->execute();
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Photo de profil mise à jour avec succès.',
            'avatar_url' => $avatar_url,
            'thumb_url' => $thumb_url,
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'first_name' => $user['first_name'],
                'last_name' => $user['last_name'],
                'role' => $user['role'],
                'phone' => $user['phone'],
                'address' => $user['address'],
                'bio' => $user['bio'],
                'avatar_url' => $user['profile_photo_url'],
                'thumb_url' => $user['thumb_photo_url'],
                'institution_id' => $user['institution_id'],
                'updated_at' => $user['updated_at']
            ]
        ]);
    } else {
        // Suppression des fichiers en cas d'échec de la BDD
        @unlink($main_path);
        @unlink($thumb_path);
        
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour de la base de données.'
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
