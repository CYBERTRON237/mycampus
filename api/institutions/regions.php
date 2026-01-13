<?php
/**
 * API endpoint pour récupérer les régions
 */

// Activer l'affichage des erreurs pour le debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Headers CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

// Handle OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

// Content type
header('Content-Type: application/json; charset=utf-8');

try {
    // Authentification flexible - accepter les tokens ou les requêtes sans token pour le développement
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? null;
    
    // En développement, on peut permettre les requêtes sans authentification
    $isDevelopment = true; // Mettre à false en production
    
    if (!$isDevelopment && !$authHeader) {
        throw new Exception('Authorization header missing');
    }
    
    // Connexion à la base de données
    try {
        $pdo = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        throw new Exception('Database connection failed: ' . $e->getMessage());
    }
    
    // Vérifier si la table institutions existe
    $stmt = $pdo->query("SHOW TABLES LIKE 'institutions'");
    if ($stmt->rowCount() == 0) {
        // Si la table n'existe pas, retourner des régions par défaut
        $regions = ["Adamaoua", "Centre", "Est", "Extrême-Nord", "Littoral", "Nord", "Nord-Ouest", "Ouest", "Sud", "Sud-Ouest"];
    } else {
        $query = "SELECT DISTINCT region FROM institutions WHERE region IS NOT NULL AND region != '' ORDER BY region";
        $stmt = $pdo->prepare($query);
        $stmt->execute();
        
        $regions = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Si aucune région trouvée, retourner les régions par défaut
        if (empty($regions)) {
            $regions = ["Adamaoua", "Centre", "Est", "Extrême-Nord", "Littoral", "Nord", "Nord-Ouest", "Ouest", "Sud", "Sud-Ouest"];
        }
    }
    
    // Envoyer la réponse et arrêter le script
    echo json_encode([
        'success' => true,
        'data' => $regions
    ], JSON_UNESCAPED_UNICODE);
    exit; // Important: arrêter le script ici pour éviter le 'null' à la fin
    
} catch (PDOException $e) {
    error_log("Erreur PDO dans getRegions(): " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors de la récupération des régions: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit;
} catch (Exception $e) {
    error_log("Erreur dans getRegions(): " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors de la récupération des régions: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>
