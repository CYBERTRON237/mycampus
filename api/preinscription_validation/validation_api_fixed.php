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
                    ORDER BY p.created_at DESC";
            
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
    
    /**
     * Valider une préinscription
     */
    public function validatePreinscription($preinscriptionId, $adminId, $comments = '') {
        try {
            $this->pdo->beginTransaction();
            
            // 1. Récupérer les détails de la préinscription
            $sql = "SELECT * FROM preinscriptions WHERE id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':id', $preinscriptionId);
            $stmt->execute();
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$preinscription) {
                throw new Exception("Préinscription non trouvée");
            }
            
            // 2. Vérifier si un utilisateur existe avec cet email
            $sql = "SELECT * FROM users WHERE email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $preinscription['email']);
            $stmt->execute();
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                throw new Exception("Aucun compte utilisateur trouvé pour cet email");
            }
            
            // 3. Générer un numéro d'admission
            $admissionNumber = $this->generateAdmissionNumber($preinscription['faculty']);
            
            // 4. Mettre à jour la préinscription
            $sql = "UPDATE preinscriptions SET 
                    status = 'accepted',
                    admission_number = :admission_number,
                    reviewed_by = :admin_id,
                    review_date = NOW(),
                    review_comments = :comments,
                    student_id = :user_id,
                    admission_date = NOW()
                    WHERE id = :id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':admission_number', $admissionNumber);
            $stmt->bindParam(':admin_id', $adminId);
            $stmt->bindParam(':comments', $comments);
            $stmt->bindParam(':user_id', $user['id']);
            $stmt->bindParam(':id', $preinscriptionId);
            $stmt->execute();
            
            // 5. Mettre à jour le rôle de l'utilisateur
            $sql = "UPDATE users SET 
                    primary_role = 'student',
                    updated_at = NOW()
                    WHERE id = :user_id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':user_id', $user['id']);
            $stmt->execute();
            
            $this->pdo->commit();
            
            echo json_encode([
                'success' => true,
                'message' => 'Préinscription validée avec succès',
                'data' => [
                    'admission_number' => $admissionNumber,
                    'user_role' => 'student'
                ]
            ]);
            
        } catch (Exception $e) {
            $this->pdo->rollBack();
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }
    
    /**
     * Rejeter une préinscription
     */
    public function rejectPreinscription($preinscriptionId, $adminId, $rejectionReason) {
        try {
            $sql = "UPDATE preinscriptions SET 
                    status = 'rejected',
                    reviewed_by = :admin_id,
                    review_date = NOW(),
                    rejection_reason = :rejection_reason
                    WHERE id = :id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':admin_id', $adminId);
            $stmt->bindParam(':rejection_reason', $rejectionReason);
            $stmt->bindParam(':id', $preinscriptionId);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Préinscription rejetée avec succès'
                ]);
            } else {
                throw new Exception("Aucune préinscription trouvée avec cet ID");
            }
            
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }
    
    /**
     * Générer un numéro d'admission unique
     */
    private function generateAdmissionNumber($faculty) {
        $year = date('Y');
        $facultyCode = $this->getFacultyCode($faculty);
        
        do {
            $random = mt_rand(1000, 9999);
            $admissionNumber = "{$year}{$facultyCode}{$random}";
            
            // Vérifier l'unicité
            $sql = "SELECT COUNT(*) FROM preinscriptions WHERE admission_number = :admission_number";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':admission_number', $admissionNumber);
            $stmt->execute();
            
        } while ($stmt->fetchColumn() > 0);
        
        return $admissionNumber;
    }
    
    /**
     * Obtenir le code d'une faculté
     */
    private function getFacultyCode($faculty) {
        $codes = [
            'UY1' => '01',
            'FALSH' => '02', 
            'FS' => '03',
            'FSE' => '04',
            'IUT' => '05',
            'ENSPY' => '06'
        ];
        
        return $codes[$faculty] ?? '00';
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
            
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            if (isset($data['action'])) {
                switch ($data['action']) {
                    case 'validate':
                        $api->validatePreinscription(
                            $data['preinscription_id'],
                            $data['admin_id'],
                            $data['comments'] ?? ''
                        );
                        break;
                        
                    case 'reject':
                        $api->rejectPreinscription(
                            $data['preinscription_id'],
                            $data['admin_id'],
                            $data['rejection_reason'] ?? 'Non spécifié'
                        );
                        break;
                        
                    default:
                        http_response_code(400);
                        echo json_encode(['success' => false, 'message' => 'Action non reconnue']);
                }
            } else {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Action requise']);
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
        'message' => 'Erreur interne du serveur'
    ]);
}
?>
