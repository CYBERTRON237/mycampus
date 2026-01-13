<?php
/**
 * API Delete Avatar
 * Suppression de la photo de profil
 */

// Configuration des erreurs
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuration CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: DELETE, POST, OPTIONS");
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

/**
 * Fonction de suppression des fichiers avatar
 */
function deleteAvatarFiles($user_id, $upload_dir) {
    $deleted = [];
    $patterns = [
        $upload_dir . $user_id . '_avatar*',
        $upload_dir . $user_id . '_thumb*'
    ];
    
    foreach ($patterns as $pattern) {
        $files = glob($pattern);
        foreach ($files as $file) {
            if (file_exists($file) && is_file($file)) {
                if (@unlink($file)) {
                    $deleted[] = basename($file);
                }
            }
        }
    }
    
    return $deleted;
}

// Vérification de la méthode
$allowed_methods = ['DELETE', 'POST'];
if (!in_array($_SERVER['REQUEST_METHOD'], $allowed_methods)) {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée. Utilisez DELETE ou POST.'
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
    
    // Connexion à la base de données
    $database = new Database();
    $db = $database->getConnection();
    
    // Récupération de l'URL de l'avatar actuel
    $select_query = "SELECT profile_photo_url, thumb_photo_url FROM users WHERE id = :user_id";
    $select_stmt = $db->prepare($select_query);
    $select_stmt->bindParam(':user_id', $user_id);
    $select_stmt->execute();
    $user = $select_stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Utilisateur non trouvé.'
        ]);
        exit();
    }
    
    $old_avatar_url = $user['profile_photo_url'];
    $old_thumb_url = $user['thumb_photo_url'];
    
    // Suppression des fichiers physiques
    $deleted_files = deleteAvatarFiles($user_id, $upload_dir);
    
    // Mise à jour de la base de données
    $update_query = "UPDATE users 
                    SET profile_photo_url = NULL, 
                        thumb_photo_url = NULL,
                        updated_at = NOW()
                    WHERE id = :user_id";
    
    $update_stmt = $db->prepare($update_query);
    $update_stmt->bindParam(':user_id', $user_id);
    
    if ($update_stmt->execute()) {
        // Enregistrement dans l'historique
        $history_query = "INSERT INTO profile_photo_history 
                         (user_id, photo_url, action, uploaded_at) 
                         VALUES (:user_id, :photo_url, 'deleted', NOW())";
        
        $history_stmt = $db->prepare($history_query);
        $history_stmt->bindParam(':user_id', $user_id);
        $history_stmt->bindParam(':photo_url', $old_avatar_url);
        $history_stmt->execute();
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Photo de profil supprimée avec succès.',
            'deleted_files' => $deleted_files,
            'previous_avatar' => $old_avatar_url,
            'previous_thumb' => $old_thumb_url
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la suppression de la photo de profil dans la base de données.'
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
