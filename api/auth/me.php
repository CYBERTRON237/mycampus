<?php
// Activation de l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuration des en-têtes CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Gestion des requêtes OPTIONS (prévol)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Chargement de l'autoloader de Composer
require __DIR__ . '/../../vendor/autoload.php';

// Inclusion de la configuration de la base de données
require_once __DIR__ . '/../config/database.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

// Clé secrète pour la signature JWT (à remplacer par une vraie clé sécurisée en production)
$secret_key = "YOUR_SECRET_KEY";

// Récupération du token depuis l'en-tête Authorization
$headers = getallheaders();
$jwt = null;

// Vérification de la présence du token
if (isset($headers['Authorization'])) {
    $authHeader = $headers['Authorization'];
    
    // Vérification du format du token (Bearer <token>)
    if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        $jwt = $matches[1];
    }
}

if (!$jwt) {
    // Aucun token fourni
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Token d\'authentification manquant.'
    ]);
    exit();
}

try {
    // Décodage du token avec la clé secrète
    $decoded = JWT::decode($jwt, new Key($secret_key, 'HS256'));
    
    // Connexion à la base de données
    $database = new Database();
    $db = $database->getConnection();
    
    // Requête pour récupérer les informations de l'utilisateur
    $query = "SELECT id, email, first_name, last_name, primary_role as role, phone, 
                     institution_id as institution, profile_photo_url as avatar 
              FROM users 
              WHERE id = :id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $decoded->data->id);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Réponse en cas de succès
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'user' => [
                'id' => $row['id'],
                'email' => $row['email'],
                'first_name' => $row['first_name'],
                'last_name' => $row['last_name'],
                'role' => $row['role'],
                'phone' => $row['phone'],
                'institution' => $row['institution'],
                'avatar' => $row['avatar']
            ]
        ]);
    } else {
        // Utilisateur non trouvé
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Utilisateur non trouvé.'
        ]);
    }
    
} catch (Exception $e) {
    // Erreur lors du décodage du token
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Accès non autorisé.',
        'error' => $e->getMessage()
    ]);
}
?>
