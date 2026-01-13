<?php
// Activation de l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuration des en-têtes CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT, PATCH, OPTIONS");
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
    
    // Récupération des données envoyées en JSON
    $data = json_decode(file_get_contents("php://input"));
    
    // Vérification des données minimales
    if (!isset($data->first_name) || !isset($data->last_name) || !isset($data->email)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Les champs first_name, last_name et email sont requis.'
        ]);
        exit();
    }
    
    // Préparation de la requête de mise à jour
    $query = "UPDATE users SET 
              first_name = :first_name, 
              last_name = :last_name, 
              email = :email";
    
    // Ajout des champs optionnels
    $params = [
        ':first_name' => $data->first_name,
        ':last_name' => $data->last_name,
        ':email' => $data->email,
        ':id' => $decoded->data->id
    ];
    
    if (isset($data->phone)) {
        $query .= ", phone = :phone";
        $params[':phone'] = $data->phone;
    }
    
    if (isset($data->address)) {
        $query .= ", address = :address";
        $params[':address'] = $data->address;
    }
    
    if (isset($data->bio)) {
        $query .= ", bio = :bio";
        $params[':bio'] = $data->bio;
    }
    
    if (isset($data->avatar_url)) {
        $query .= ", profile_photo_url = :avatar_url";
        $params[':avatar_url'] = $data->avatar_url;
    }
    
    $query .= " WHERE id = :id";
    
    $stmt = $db->prepare($query);
    
    // Exécution de la requête
    if ($stmt->execute($params)) {
        // Récupération des données mises à jour
        $selectQuery = "SELECT id, email, first_name, last_name, primary_role as role, phone, 
                              institution_id as institution, profile_photo_url as avatar,
                              address, bio
                       FROM users 
                       WHERE id = :id";
        
        $selectStmt = $db->prepare($selectQuery);
        $selectStmt->bindParam(":id", $decoded->data->id);
        $selectStmt->execute();
        
        $updatedUser = $selectStmt->fetch(PDO::FETCH_ASSOC);
        
        // Réponse en cas de succès
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Profil mis à jour avec succès.',
            'user' => [
                'id' => $updatedUser['id'],
                'email' => $updatedUser['email'],
                'first_name' => $updatedUser['first_name'],
                'last_name' => $updatedUser['last_name'],
                'role' => $updatedUser['role'],
                'phone' => $updatedUser['phone'],
                'institution' => $updatedUser['institution'],
                'avatar' => $updatedUser['avatar'],
                'address' => $updatedUser['address'],
                'bio' => $updatedUser['bio']
            ]
        ]);
    } else {
        // Erreur lors de la mise à jour
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour du profil.'
        ]);
    }
    
} catch (Exception $e) {
    // Erreur lors du décodage du token ou autre erreur
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Accès non autorisé.',
        'error' => $e->getMessage()
    ]);
}
?>
