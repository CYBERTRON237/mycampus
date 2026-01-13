<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// Désactiver l'affichage des erreurs en production
error_reporting(0);
ini_set('display_errors', 0);

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion à la base de données
try {
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

// POST request handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rawInput = file_get_contents('php://input');
    $input = json_decode($rawInput, true);
    
    // Paramètres de pagination et de filtrage
    $page = isset($input['page']) ? (int)$input['page'] : 1;
    $limit = isset($input['limit']) ? (int)$input['limit'] : 20;
    $offset = ($page - 1) * $limit;
    
    $faculty = trim($input['faculty'] ?? '');
    $status = trim($input['status'] ?? '');
    $paymentStatus = trim($input['payment_status'] ?? '');
    $search = trim($input['search'] ?? '');
    
    try {
        // Construire la requête de base
        $baseQuery = "
            SELECT 
                id,
                uuid,
                unique_code,
                faculty,
                last_name,
                first_name,
                middle_name,
                date_of_birth,
                gender,
                phone_number,
                email,
                desired_program,
                study_level,
                payment_status,
                payment_amount,
                payment_date,
                status,
                submission_date,
                last_updated,
                created_at
            FROM preinscriptions 
            WHERE deleted_at IS NULL
        ";
        
        // Ajouter les filtres
        $params = [];
        $conditions = [];
        
        if (!empty($faculty)) {
            $conditions[] = "faculty = ?";
            $params[] = $faculty;
        }
        
        if (!empty($status)) {
            $conditions[] = "status = ?";
            $params[] = $status;
        }
        
        if (!empty($paymentStatus)) {
            $conditions[] = "payment_status = ?";
            $params[] = $paymentStatus;
        }
        
        if (!empty($search)) {
            $conditions[] = "(last_name LIKE ? OR first_name LIKE ? OR email LIKE ? OR unique_code LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
        }
        
        if (!empty($conditions)) {
            $baseQuery .= " AND " . implode(" AND ", $conditions);
        }
        
        // Compter le total d'enregistrements
        $countQuery = "SELECT COUNT(*) as total FROM preinscriptions WHERE deleted_at IS NULL";
        
        if (!empty($conditions)) {
            $countQuery .= " AND " . implode(" AND ", $conditions);
        }
        $countStmt = $pdo->prepare($countQuery);
        $countStmt->execute($params);
        $totalResult = $countStmt->fetch();
        $total = $totalResult['total'];
        
        // Ajouter l'ordre et la pagination
        $baseQuery .= " ORDER BY submission_date DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        // Exécuter la requête principale
        $stmt = $pdo->prepare($baseQuery);
        $stmt->execute($params);
        $preinscriptions = $stmt->fetchAll();
        
        // Formater les données
        $formattedData = [];
        foreach ($preinscriptions as $preinscription) {
            $formattedData[] = [
                'id' => $preinscription['id'],
                'uuid' => $preinscription['uuid'],
                'unique_code' => $preinscription['unique_code'],
                'faculty' => $preinscription['faculty'],
                'last_name' => $preinscription['last_name'],
                'first_name' => $preinscription['first_name'],
                'middle_name' => $preinscription['middle_name'],
                'date_of_birth' => $preinscription['date_of_birth'],
                'gender' => $preinscription['gender'],
                'phone_number' => $preinscription['phone_number'],
                'email' => $preinscription['email'],
                'desired_program' => $preinscription['desired_program'],
                'study_level' => $preinscription['study_level'],
                'payment_status' => $preinscription['payment_status'],
                'payment_amount' => $preinscription['payment_amount'],
                'payment_date' => $preinscription['payment_date'],
                'status' => $preinscription['status'],
                'submission_date' => $preinscription['submission_date'],
                'last_updated' => $preinscription['last_updated'],
                'created_at' => $preinscription['created_at']
            ];
        }
        
        // Calculer les statistiques
        $statsQuery = "
            SELECT 
                faculty,
                status,
                payment_status,
                COUNT(*) as count
            FROM preinscriptions 
            WHERE deleted_at IS NULL
            GROUP BY faculty, status, payment_status
        ";
        $statsStmt = $pdo->prepare($statsQuery);
        $statsStmt->execute();
        $statsData = $statsStmt->fetchAll();
        
        // Formater les statistiques
        $statistics = [];
        foreach ($statsData as $stat) {
            $faculty = $stat['faculty'];
            if (!isset($statistics[$faculty])) {
                $statistics[$faculty] = [
                    'faculty' => $faculty,
                    'pending' => 0,
                    'accepted' => 0,
                    'rejected' => 0,
                    'paid' => 0,
                    'total' => 0
                ];
            }
            
            $statistics[$faculty][$stat['status']] += $stat['count'];
            $statistics[$faculty]['total'] += $stat['count'];
            
            if ($stat['payment_status'] === 'paid') {
                $statistics[$faculty]['paid'] += $stat['count'];
            }
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscriptions récupérées avec succès',
            'data' => $formattedData,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit)
            ],
            'statistics' => array_values($statistics)
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la récupération des préinscriptions',
            'error' => $e->getMessage()
        ]);
    }
    
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée',
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
}
?>
