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
            // Requête optimisée avec les bonnes colonnes
            $sql = "SELECT p.*, 
                           u.id as user_id, u.email as user_email, u.primary_role as user_role,
                           CASE WHEN u.id IS NOT NULL THEN 1 ELSE 0 END as has_user_account
                    FROM preinscriptions p 
                    LEFT JOIN users u ON p.email = u.email AND u.deleted_at IS NULL
                    WHERE p.status IN ('pending', 'under_review') 
                    AND p.deleted_at IS NULL
                    AND (p.student_id IS NULL OR p.student_id = 0)
                    ORDER BY p.submission_date DESC";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Ajouter des informations supplémentaires
            foreach ($preinscriptions as &$preinscription) {
                $preinscription['can_be_validated'] = 
                    $preinscription['payment_status'] === 'paid' || 
                    $preinscription['payment_status'] === 'confirmed';
                
                // Formater les dates
                $preinscription['submission_date_formatted'] = date(
                    'd/m/Y H:i', 
                    strtotime($preinscription['submission_date'])
                );
            }
            
            echo json_encode([
                'success' => true,
                'data' => $preinscriptions,
                'count' => count($preinscriptions)
            ]);
            
        } catch (PDOException $e) {
            error_log("Erreur getPendingPreinscriptions: " . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la récupération des préinscriptions'
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
            $sql = "SELECT status, COUNT(*) as count 
                    FROM preinscriptions 
                    WHERE deleted_at IS NULL 
                    GROUP BY status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $statusData = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($statusData as $row) {
                $stats['by_status'][$row['status']] = (int)$row['count'];
            }
            
            // Nombre en attente de validation
            $sql = "SELECT COUNT(*) as count 
                    FROM preinscriptions 
                    WHERE status IN ('pending', 'under_review') 
                    AND deleted_at IS NULL 
                    AND (student_id IS NULL OR student_id = 0)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['pending_validation'] = (int)$stmt->fetchColumn();
            
            // Nombre avec utilisateur existant
            $sql = "SELECT COUNT(*) as count 
                    FROM preinscriptions p 
                    INNER JOIN users u ON p.email = u.email 
                    WHERE p.status IN ('pending', 'under_review') 
                    AND p.deleted_at IS NULL 
                    AND u.deleted_at IS NULL 
                    AND (p.student_id IS NULL OR p.student_id = 0)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['with_user_account'] = (int)$stmt->fetchColumn();
            
            // Validation par faculté
            $sql = "SELECT faculty, status, COUNT(*) as count 
                    FROM preinscriptions 
                    WHERE deleted_at IS NULL 
                    GROUP BY faculty, status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['by_faculty'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Paiements par statut
            $sql = "SELECT payment_status, COUNT(*) as count 
                    FROM preinscriptions 
                    WHERE deleted_at IS NULL 
                    GROUP BY payment_status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['by_payment'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $stats
            ]);
            
        } catch (PDOException $e) {
            error_log("Erreur getValidationStats: " . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques'
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
            $sql = "SELECT * FROM preinscriptions WHERE id = :id AND deleted_at IS NULL";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':id', $preinscriptionId, PDO::PARAM_INT);
            $stmt->execute();
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$preinscription) {
                throw new Exception("Préinscription non trouvée");
            }
            
            if ($preinscription['status'] === 'accepted') {
                throw new Exception("Cette préinscription est déjà validée");
            }
            
            // 2. Vérifier si un utilisateur existe avec cet email
            $sql = "SELECT * FROM users WHERE email = :email AND deleted_at IS NULL";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $preinscription['email']);
            $stmt->execute();
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                throw new Exception("Aucun compte utilisateur trouvé pour l'email: " . $preinscription['email']);
            }
            
            // 3. Générer un numéro d'admission unique
            $admissionNumber = $this->generateAdmissionNumber($preinscription['faculty']);
            
            // 4. Mettre à jour la préinscription
            $sql = "UPDATE preinscriptions SET 
                    status = 'accepted',
                    admission_number = :admission_number,
                    reviewed_by = :admin_id,
                    review_date = NOW(),
                    review_comments = :comments,
                    student_id = :user_id,
                    admission_date = NOW(),
                    updated_at = NOW()
                    WHERE id = :id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':admission_number', $admissionNumber);
            $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
            $stmt->bindParam(':comments', $comments);
            $stmt->bindParam(':user_id', $user['id'], PDO::PARAM_INT);
            $stmt->bindParam(':id', $preinscriptionId, PDO::PARAM_INT);
            $stmt->execute();
            
            // 5. Mettre à jour le rôle de l'utilisateur
            $sql = "UPDATE users SET 
                    primary_role = 'student',
                    account_status = 'active',
                    level = :level,
                    updated_at = NOW()
                    WHERE id = :user_id";
            
            $level = $preinscription['study_level'] ?? 'L1';
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':level', $level);
            $stmt->bindParam(':user_id', $user['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            $this->pdo->commit();
            
            echo json_encode([
                'success' => true,
                'message' => 'Préinscription validée avec succès',
                'data' => [
                    'admission_number' => $admissionNumber,
                    'user_role' => 'student',
                    'student_name' => $user['first_name'] . ' ' . $user['last_name'],
                    'faculty' => $preinscription['faculty']
                ]
            ]);
            
        } catch (Exception $e) {
            $this->pdo->rollBack();
            error_log("Erreur validatePreinscription: " . $e->getMessage());
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
            // 1. Vérifier que la préinscription existe
            $sql = "SELECT * FROM preinscriptions WHERE id = :id AND deleted_at IS NULL";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':id', $preinscriptionId, PDO::PARAM_INT);
            $stmt->execute();
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$preinscription) {
                throw new Exception("Préinscription non trouvée");
            }
            
            if ($preinscription['status'] === 'rejected') {
                throw new Exception("Cette préinscription est déjà rejetée");
            }
            
            // 2. Mettre à jour la préinscription
            $sql = "UPDATE preinscriptions SET 
                    status = 'rejected',
                    reviewed_by = :admin_id,
                    review_date = NOW(),
                    rejection_reason = :rejection_reason,
                    updated_at = NOW()
                    WHERE id = :id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
            $stmt->bindParam(':rejection_reason', $rejectionReason);
            $stmt->bindParam(':id', $preinscriptionId, PDO::PARAM_INT);
            $stmt->execute();
            
            if ($stmt->rowCount() > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Préinscription rejetée avec succès',
                    'data' => [
                        'student_name' => $preinscription['first_name'] . ' ' . $preinscription['last_name'],
                        'faculty' => $preinscription['faculty']
                    ]
                ]);
            } else {
                throw new Exception("Aucune modification effectuée");
            }
            
        } catch (Exception $e) {
            error_log("Erreur rejectPreinscription: " . $e->getMessage());
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
            $sql = "SELECT COUNT(*) FROM preinscriptions WHERE admission_number = :admission_number AND deleted_at IS NULL";
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

// Routage des requêtes avec authentification
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
            // Pour les actions POST, vérifier l'authentification
            $headers = getallheaders();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
            
            if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
                http_response_code(401);
                echo json_encode(['success' => false, 'message' => 'Token d\'authentification requis']);
                exit;
            }
            
            $token = $matches[1];
            
            // Vérifier le token et obtenir l'utilisateur
            $sql = "SELECT * FROM users WHERE auth_token = :token AND token_expires_at > NOW() AND deleted_at IS NULL";
            $stmt = $api->pdo->prepare($sql);
            $stmt->bindParam(':token', $token);
            $stmt->execute();
            $currentUser = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$currentUser) {
                http_response_code(401);
                echo json_encode(['success' => false, 'message' => 'Token invalide ou expiré']);
                exit;
            }
            
            // Vérifier les permissions admin
            $adminRoles = ['admin_local', 'admin_national', 'superadmin'];
            if (!in_array($currentUser['primary_role'], $adminRoles)) {
                http_response_code(403);
                echo json_encode(['success' => false, 'message' => 'Permissions insuffisantes']);
                exit;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            if (isset($data['action'])) {
                switch ($data['action']) {
                    case 'validate':
                        $api->validatePreinscription(
                            $data['preinscription_id'],
                            $currentUser['id'],
                            $data['comments'] ?? ''
                        );
                        break;
                        
                    case 'reject':
                        $api->rejectPreinscription(
                            $data['preinscription_id'],
                            $currentUser['id'],
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
