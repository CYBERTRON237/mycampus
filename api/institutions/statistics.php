<?php
/**
 * API endpoint pour les statistiques des institutions
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
        // Retourner des statistiques de test avec les bonnes clés
        $statistics = [
            'total' => 2,
            'new_this_month' => 1,
            'growth_rate' => 50.0,
            'top_institutions' => [
                ['name' => 'Université de Yaoundé I', 'count' => 15],
                ['name' => 'Université de Douala', 'count' => 12]
            ]
        ];
    } else {
        // Statistiques réelles
        $sql = "SELECT COUNT(*) as total FROM institutions";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $total = (int)$stmt->fetchColumn();

        // Nouvelles institutions ce mois
        $sql = "SELECT COUNT(*) as count FROM institutions WHERE created_at >= DATE_FORMAT(NOW(), '%Y-%m-01')";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $newThisMonth = (int)$stmt->fetchColumn();

        // Taux de croissance
        $sql = "SELECT 
                  COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as this_month,
                  COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') - INTERVAL 1 MONTH 
                             AND created_at < DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as last_month
                FROM institutions";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $growthData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $thisMonth = (int)$growthData['this_month'];
        $lastMonth = (int)$growthData['last_month'];
        $growthRate = $lastMonth > 0 ? (($thisMonth - $lastMonth) / $lastMonth) * 100 : 0;

        // Top institutions (par nombre de facultés)
        $sql = "SELECT i.name, COUNT(f.id) as faculty_count
                FROM institutions i
                LEFT JOIN faculties f ON i.id = f.institution_id
                GROUP BY i.id, i.name
                ORDER BY faculty_count DESC
                LIMIT 5";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $topInstitutions = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $topInstitutions[] = [
                'name' => $row['name'],
                'count' => (int)$row['faculty_count']
            ];
        }

        $statistics = [
            'total' => $total,
            'new_this_month' => $newThisMonth,
            'growth_rate' => round($growthRate, 2),
            'top_institutions' => $topInstitutions
        ];
    }
        
        // Par type
        $stmt = $pdo->query("SELECT type, COUNT(*) as count FROM institutions GROUP BY type");
        $byType = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($byType as $row) {
            $statistics[$row['type']] = $row['count'];
        }
        
        // Par statut
        $stmt = $pdo->query("SELECT status, COUNT(*) as count FROM institutions GROUP BY status");
        $byStatus = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($byStatus as $row) {
            $statistics[$row['status']] = $row['count'];
        }
        
        // Par région
        $stmt = $pdo->query("SELECT region, COUNT(*) as count FROM institutions WHERE region IS NOT NULL GROUP BY region");
        $byRegion = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $statistics['by_region'] = [];
        foreach ($byRegion as $row) {
            $statistics['by_region'][$row['region']] = $row['count'];
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $statistics
    ], JSON_UNESCAPED_UNICODE);
    exit;
    
catch (PDOException $e) {
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
