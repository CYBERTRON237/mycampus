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
            // Requête ultra-simple sans JOIN complexe
            $sql = "SELECT * FROM preinscriptions WHERE status = 'pending' ORDER BY id DESC";
            $stmt = $this->pdo->query($sql);
            $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Ajouter les infos utilisateur manuellement
            foreach ($preinscriptions as &$preinscription) {
                $preinscription['has_user_account'] = false;
                $preinscription['current_user_role'] = null;
                
                // Vérifier si l'utilisateur existe
                if (!empty($preinscription['email'])) {
                    $userSql = "SELECT id, primary_role FROM users WHERE email = :email LIMIT 1";
                    $userStmt = $this->pdo->prepare($userSql);
                    $userStmt->bindParam(':email', $preinscription['email']);
                    $userStmt->execute();
                    $user = $userStmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($user) {
                        $preinscription['has_user_account'] = true;
                        $preinscription['current_user_role'] = $user['primary_role'];
                        $preinscription['user_id'] = $user['id'];
                    }
                }
                
                $preinscription['can_be_validated'] = true; // Simplifié
            }
            
            echo json_encode([
                'success' => true,
                'data' => $preinscriptions
            ]);
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
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
            $stmt = $this->pdo->query($sql);
            $statusData = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($statusData as $row) {
                $stats['by_status'][$row['status']] = $row['count'];
            }
            
            // Nombre en attente de validation
            $sql = "SELECT COUNT(*) as count FROM preinscriptions WHERE status = 'pending'";
            $stmt = $this->pdo->query($sql);
            $stats['pending_validation'] = $stmt->fetchColumn();
            
            echo json_encode([
                'success' => true,
                'data' => $stats
            ]);
            
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
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
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur interne: ' . $e->getMessage()
    ]);
}
?>
