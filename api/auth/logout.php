<?php
// logout.php

// Activer l'affichage des erreurs pour le débogage (à désactiver en production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Charger la configuration de la base de données
require_once '../config/database.php';

// Charger la librairie JWT si disponible
if (file_exists(__DIR__ . '/../../vendor/firebase/php-jwt/src/JWT.php')) {
    require_once __DIR__ . '/../../vendor/firebase/php-jwt/src/JWT.php';
    require_once __DIR__ . '/../../vendor/firebase/php-jwt/src/Key.php';
}

// Démarrer la session
session_start();

// Mettre à jour la présence en ligne (hors ligne)
try {
    $database = new Database();
    $pdo = $database->getConnection();
    
    // Récupérer l'ID utilisateur depuis le token JWT si disponible
    $userId = null;
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (strpos($authHeader, 'Bearer ') === 0) {
        $token = substr($authHeader, 7);
        // Décoder le token pour récupérer l'ID utilisateur
        try {
            // Vérifier si la classe JWT est disponible
            if (class_exists('Firebase\JWT\JWT')) {
                $secret_key = "YOUR_SECRET_KEY";
                $decoded = Firebase\JWT\JWT::decode($token, new Firebase\JWT\Key($secret_key, 'HS256'));
                $userId = $decoded->data->id ?? null;
            } else {
                // Alternative: utiliser une méthode simple pour extraire l'ID
                $parts = explode('.', $token);
                if (count($parts) >= 2) {
                    $payload = json_decode(base64_decode($parts[1]));
                    $userId = $payload->data->id ?? $payload->sub ?? null;
                }
            }
        } catch (Exception $e) {
            // Ignorer les erreurs de token
        }
    }
    
    // Si on a l'ID utilisateur, mettre à jour sa présence
    if ($userId) {
        $presenceQuery = "UPDATE user_presence 
                         SET is_online = 0, status = 'offline', last_seen = NOW() 
                         WHERE user_id = :userId";
        
        $stmt = $pdo->prepare($presenceQuery);
        $stmt->execute([':userId' => $userId]);
    }
} catch (Exception $e) {
    // Continuer même si la mise à jour de présence échoue
    error_log('Erreur mise à jour présence logout: ' . $e->getMessage());
}

// Détruire toutes les données de session
$_SESSION = [];

// Si vous voulez détruire complètement la session, supprimez également le cookie de session
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(
        session_name(),
        '',
        time() - 42000,
        $params["path"],
        $params["domain"],
        $params["secure"],
        $params["httponly"]
    );
}

// Détruire la session
session_destroy();

// Renvoyer une réponse JSON de succès
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

echo json_encode([
    'success' => true,
    'message' => 'Déconnexion réussie',
    'data' => null
]);
exit;
