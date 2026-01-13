<?php
// Désactiver complètement les erreurs
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion directe à la base de données
class Database {
    private static $pdo = null;
    
    public static function getConnection() {
        if (self::$pdo === null) {
            try {
                self::$pdo = new PDO(
                    "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
                    "root",
                    "",
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::ATTR_EMULATE_PREPARES => false
                    ]
                );
            } catch (PDOException $e) {
                throw new Exception("Database connection failed");
            }
        }
        return self::$pdo;
    }
}

class PreinscriptionValidationAPI {
    private $pdo;
    
    public function __construct() {
        try {
            $this->pdo = Database::getConnection();
        } catch (Exception $e) {
            $this->sendError('Database connection failed', 500);
        }
    }
    
    private function sendError($message, $code = 400) {
        http_response_code($code);
        echo json_encode([
            'success' => false,
            'message' => $message
        ]);
        exit;
    }
    
    private function sendSuccess($data, $message = 'Success') {
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }
    
    public function getPendingPreinscriptions() {
        try {
            // Test avec une requête simple
            $sql = "SELECT p.*, 
                           u.id as user_id, u.email as user_email, u.primary_role as user_role
                    FROM preinscriptions p 
                    LEFT JOIN users u ON p.email = u.email 
                    WHERE p.status IN ('pending', 'under_review')
                    ORDER BY p.created_at DESC
                    LIMIT 20";
            
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
            
            $this->sendSuccess($preinscriptions);
            
        } catch (PDOException $e) {
            $this->sendError('Database query failed', 500);
        }
    }
    
    public function getValidationStats() {
        try {
            $stats = [];
            
            // Nombre total par statut
            $sql = "SELECT status, COUNT(*) as count FROM preinscriptions GROUP BY status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($result as $row) {
                $stats['by_status'][$row['status']] = (int)$row['count'];
            }
            
            // Nombre en attente de validation
            $sql = "SELECT COUNT(*) as count FROM preinscriptions 
                    WHERE status IN ('pending', 'under_review')";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['pending_validation'] = (int)$stmt->fetchColumn();
            
            // Nombre avec utilisateur existant
            $sql = "SELECT COUNT(*) as count FROM preinscriptions p 
                    INNER JOIN users u ON p.email = u.email 
                    WHERE p.status IN ('pending', 'under_review')";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['with_user_account'] = (int)$stmt->fetchColumn();
            
            $this->sendSuccess($stats);
            
        } catch (PDOException $e) {
            $this->sendError('Database query failed', 500);
        }
    }
    
    public function validatePreinscription($preinscriptionId, $adminId, $comments = '') {
        try {
            $this->pdo->beginTransaction();
            
            // 1. Récupérer les détails de la préinscription
            $sql = "SELECT * FROM preinscriptions WHERE id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([':id' => $preinscriptionId]);
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$preinscription) {
                throw new Exception("Préinscription non trouvée");
            }
            
            // 2. Vérifier si un utilisateur existe avec cet email
            $sql = "SELECT * FROM users WHERE email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([':email' => $preinscription['email']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                throw new Exception("Aucun compte utilisateur trouvé pour cet email");
            }
            
            // 3. Générer un numéro d'admission
            $admissionNumber = $this->generateAdmissionNumber($preinscription['faculty']);
            
            // 4. Mettre à jour la préinscription SANS trigger
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
            $stmt->execute([
                ':admission_number' => $admissionNumber,
                ':admin_id' => $adminId,
                ':comments' => $comments,
                ':user_id' => $user['id'],
                ':id' => $preinscriptionId
            ]);
            
            // 5. Mettre à jour le rôle de l'utilisateur SANS trigger
            $sql = "UPDATE users SET 
                    primary_role = 'student',
                    preinscription_id = :preinscription_id,
                    preinscription_unique_code = :unique_code,
                    updated_at = NOW()
                    WHERE id = :user_id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                ':preinscription_id' => $preinscriptionId,
                ':unique_code' => $preinscription['unique_code'],
                ':user_id' => $user['id']
            ]);
            
            $this->pdo->commit();
            
            $this->sendSuccess([
                'admission_number' => $admissionNumber,
                'user_role' => 'student',
                'user_id' => $user['id']
            ], 'Préinscription validée avec succès');
            
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->sendError($e->getMessage(), 400);
        }
    }
    
    public function rejectPreinscription($preinscriptionId, $adminId, $rejectionReason) {
        try {
            $sql = "UPDATE preinscriptions SET 
                    status = 'rejected',
                    reviewed_by = :admin_id,
                    review_date = NOW(),
                    rejection_reason = :rejection_reason
                    WHERE id = :id";
            
            $stmt = $this->pdo->prepare($sql);
            $result = $stmt->execute([
                ':admin_id' => $adminId,
                ':rejection_reason' => $rejectionReason,
                ':id' => $preinscriptionId
            ]);
            
            if ($stmt->rowCount() > 0) {
                $this->sendSuccess([], 'Préinscription rejetée avec succès');
            } else {
                $this->sendError("Aucune préinscription trouvée avec cet ID");
            }
            
        } catch (Exception $e) {
            $this->sendError($e->getMessage(), 400);
        }
    }
    
    private function generateAdmissionNumber($faculty) {
        $year = date('Y');
        $codes = [
            'UY1' => '01', 'FALSH' => '02', 'FS' => '03',
            'FSE' => '04', 'IUT' => '05', 'ENSPY' => '06'
        ];
        $facultyCode = $codes[$faculty] ?? '00';
        
        do {
            $random = mt_rand(1000, 9999);
            $admissionNumber = "{$year}{$facultyCode}{$random}";
            
            $sql = "SELECT COUNT(*) FROM preinscriptions WHERE admission_number = :admission_number";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([':admission_number' => $admissionNumber]);
            
        } while ($stmt->fetchColumn() > 0);
        
        return $admissionNumber;
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
            if (!$data || !isset($data['action'])) {
                $api->sendError('Action requise');
            }
            
            switch ($data['action']) {
                case 'validate':
                    if (!isset($data['preinscription_id']) || !isset($data['admin_id'])) {
                        $api->sendError('Paramètres manquants pour la validation');
                    }
                    $api->validatePreinscription(
                        $data['preinscription_id'],
                        $data['admin_id'],
                        $data['comments'] ?? ''
                    );
                    break;
                    
                case 'reject':
                    if (!isset($data['preinscription_id']) || !isset($data['admin_id'])) {
                        $api->sendError('Paramètres manquants pour le rejet');
                    }
                    $api->rejectPreinscription(
                        $data['preinscription_id'],
                        $data['admin_id'],
                        $data['rejection_reason'] ?? 'Non spécifié'
                    );
                    break;
                    
                default:
                    $api->sendError('Action non reconnue');
            }
            break;
            
        default:
            $api->sendError('Méthode non autorisée', 405);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur interne du serveur'
    ]);
}
?>
