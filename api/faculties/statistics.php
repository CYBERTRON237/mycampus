<?php
/**
 * API endpoint pour les statistiques des facultés
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
    
    $institutionId = $_GET['institution_id'] ?? null;
    
    // Calculer les statistiques
    $statistics = [];
    
    // Total des facultés
    $sql = "SELECT COUNT(*) as total FROM faculties";
    $params = [];
    if ($institutionId) {
        $sql .= " WHERE institution_id = ?";
        $params[] = $institutionId;
    }
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $statistics['total'] = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Par statut
    $sql = "SELECT status, COUNT(*) as count FROM faculties";
    if ($institutionId) {
        $sql .= " WHERE institution_id = ?";
    }
    $sql .= " GROUP BY status";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $byStatus = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($byStatus as $row) {
        $statistics[$row['status']] = $row['count'];
    }
    
    // Par institution
    $sql = "SELECT i.name as institution_name, COUNT(f.id) as faculty_count 
            FROM institutions i 
            LEFT JOIN faculties f ON i.id = f.institution_id";
    if ($institutionId) {
        $sql .= " WHERE i.id = ?";
    }
    $sql .= " GROUP BY i.id, i.name ORDER BY faculty_count DESC";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $byInstitution = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $statistics['by_institution'] = [];
    foreach ($byInstitution as $row) {
        $statistics['by_institution'][$row['institution_name']] = $row['faculty_count'];
    }
    
    // Statistiques additionnelles (basées sur les colonnes existantes)
    $statistics['total_students'] = 0; // À implémenter selon les besoins
    $statistics['total_staff'] = 0; // À implémenter selon les besoins
    $statistics['total_departments'] = 0; // À implémenter selon les besoins
    $statistics['total_programs'] = 0; // À implémenter selon les besoins
    
    echo json_encode([
        'success' => true,
        'data' => $statistics
    ], JSON_UNESCAPED_UNICODE);
    exit;
    
} catch (PDOException $e) {
    error_log("Erreur PDO: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de base de données: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit;
} catch (Exception $e) {
    error_log("Erreur: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>
