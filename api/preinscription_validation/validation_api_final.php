<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once '../config/database.php';

class PreinscriptionValidationAPI {
    private $pdo;
    
    public function __construct() {
        $this->pdo = Database::getConnection();
    }
    
    /**
     * Obtenir toutes les préinscriptions en attente de validation
     */
    public function getPendingPreinscriptions() {
        try {
            $sql = "SELECT p.*, 
                           u.id as user_id, u.email as user_email, u.primary_role as user_role
                    FROM preinscriptions p 
                    LEFT JOIN users u ON p.email = u.email 
                    WHERE p.status = 'pending' 
                    OR (p.status = 'under_review' AND p.student_id IS NULL)
                    ORDER BY p.submission_date DESC";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Ajouter des informations supplémentaires
            foreach ($preinscriptions as &$preinscription) {
                $preinscription['has_user_account'] = !empty($preinscription['user_id']);
                $preinscription['current_user_role'] = $preinscription['user_role'];
                $preinscription['can_be_validated'] = isset($preinscription['payment_status']) && 
                    ($preinscription['payment_status'] === 'paid' || $preinscription['payment_status'] === 'confirmed');
            }
            
            echo json_encode([
                'success' => true,
                'data' => $preinscriptions
            ]);
            
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la récupération des préinscriptions: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Obtenir les statistiques de validation
     */
    public function getValidationStats() {
        try {
            $stats = [];
            
            // Nombre total par statut
            $sql = "SELECT status, COUNT(*) as count FROM preinscriptions GROUP BY status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['by_status'] = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
            
            // Nombre en attente de validation
            $sql = "SELECT COUNT(*) as count FROM preinscriptions 
                    WHERE (status = 'pending' OR (status = 'under_review' AND student_id IS NULL))";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['pending_validation'] = $stmt->fetchColumn();
            
            // Nombre avec utilisateur existant
            $sql = "SELECT COUNT(*) as count FROM preinscriptions p 
                    INNER JOIN users u ON p.email = u.email 
                    WHERE p.status IN ('pending', 'under_review') AND p.student_id IS NULL";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['with_user_account'] = $stmt->fetchColumn();
            
            // Validation par faculté
            $sql = "SELECT faculty, status, COUNT(*) as count FROM preinscriptions 
                    GROUP BY faculty, status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['by_faculty'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $stats
            ]);
            
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques: ' . $e->getMessage()
            ]);
        }
    }
}

// Routage des requêtes
try {
    $api = new PreinscriptionValidationAPI();
    
    switch ($_SERVER['REQUEST_METHOD']) {
        case 'GET':
            if (isset($_GET['action']) && $_GET['action'] === 'stats') {
                $api->getValidationStats();
            } else {
                $api->getPendingPreinscriptions();
            }
            break;
            
        default:
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    }
    
} catch (Exception $e) {
    error_log("API Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur interne du serveur: ' . $e->getMessage()
    ]);
}
?>
