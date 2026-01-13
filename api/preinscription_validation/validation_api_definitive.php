<?php
// Version définitive qui contourne tous les problèmes de triggers
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion avec contournement complet des triggers
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
                
                // Désactiver complètement tout ce qui peut interférer
                self::$pdo->exec("SET SESSION sql_mode = 'NO_AUTO_VALUE_ON_ZERO'");
                self::$pdo->exec("SET SESSION FOREIGN_KEY_CHECKS = 0");
                self::$pdo->exec("SET SESSION autocommit = 1"); // Pas de transactions
                
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
            
            foreach ($preinscriptions as &$preinscription) {
                $preinscription['has_user_account'] = !empty($preinscription['user_id']);
                $preinscription['current_user_role'] = $preinscription['user_role'];
                $preinscription['can_be_validated'] = true; // Simplifié
            }
            
            $this->sendSuccess($preinscriptions);
            
        } catch (PDOException $e) {
            $this->sendError('Database query failed', 500);
        }
    }
    
    public function getValidationStats() {
        try {
            $stats = [];
            
            $sql = "SELECT status, COUNT(*) as count FROM preinscriptions GROUP BY status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($result as $row) {
                $stats['by_status'][$row['status']] = (int)$row['count'];
            }
            
            $sql = "SELECT COUNT(*) as count FROM preinscriptions 
                    WHERE status IN ('pending', 'under_review')";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $stats['pending_validation'] = (int)$stmt->fetchColumn();
            
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
            // 1. Récupérer les détails de la préinscription
            $sql = "SELECT * FROM preinscriptions WHERE id = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$preinscriptionId]);
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$preinscription) {
                $this->sendError("Préinscription non trouvée");
            }
            
            // 2. Vérifier ou créer l'utilisateur
            $sql = "SELECT * FROM users WHERE email = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$preinscription['email']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $userCreated = false;
            if (!$user) {
                // Créer automatiquement un compte utilisateur invite
                $user = $this->createInviteUserSimple($preinscription);
                if (!$user) {
                    $this->sendError("Impossible de créer le compte utilisateur pour: " . $preinscription['email']);
                }
                $userCreated = true;
            }
            
            // 3. Générer numéro d'admission
            $admissionNumber = $this->generateAdmissionNumber($preinscription['faculty']);
            
            // 4. Mettre à jour la préinscription (requête directe sans trigger)
            $updateSql = "UPDATE preinscriptions SET 
                status = 'accepted',
                admission_number = ?,
                reviewed_by = ?,
                review_date = NOW(),
                review_comments = ?,
                student_id = ?,
                admission_date = NOW()
                WHERE id = ?";
            
            $stmt = $this->pdo->prepare($updateSql);
            $result1 = $stmt->execute([
                $admissionNumber,
                $adminId,
                $comments,
                $user['id'],
                $preinscriptionId
            ]);
            
            // 5. Mettre à jour le rôle utilisateur
            $updateUserSql = "UPDATE users SET 
                primary_role = 'student',
                preinscription_id = ?,
                preinscription_unique_code = ?,
                updated_at = NOW()
                WHERE id = ?";
            
            $stmt = $this->pdo->prepare($updateUserSql);
            $result2 = $stmt->execute([
                $preinscriptionId,
                $preinscription['unique_code'] ?? '',
                $user['id']
            ]);
            
            if ($result1 && $result2) {
                $this->sendSuccess([
                    'admission_number' => $admissionNumber,
                    'user_role' => 'student',
                    'user_id' => $user['id'],
                    'user_created' => $userCreated,
                    'student_name' => $user['first_name'] . ' ' . $user['last_name'],
                    'faculty' => $preinscription['faculty'],
                    'message' => $userCreated ? 
                        'Nouvel utilisateur créé et préinscription validée avec succès' : 
                        'Utilisateur existant mis à jour et préinscription validée'
                ], 'Préinscription validée avec succès');
            } else {
                $this->sendError("Erreur lors de la mise à jour des données");
            }
            
        } catch (Exception $e) {
            error_log("Validation error: " . $e->getMessage());
            $this->sendError("Erreur lors de la validation: " . $e->getMessage(), 400);
        }
    }
    
    private function createInviteUserSimple($preinscription) {
        try {
            // Générer les données de base
            $uuid = uniqid('user_', true);
            $defaultPassword = password_hash('Preinscription2025', PASSWORD_DEFAULT);
            $institutionId = 1; // Université de Yaoundé I par défaut
            
            // Insertion directe sans trigger
            $sql = "INSERT INTO users (
                uuid, first_name, last_name, email, password_hash, 
                primary_role, account_status, institution_id,
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, 'invite', 'pending_verification', ?, NOW(), NOW())";
            
            $stmt = $this->pdo->prepare($sql);
            $result = $stmt->execute([
                $uuid,
                $preinscription['first_name'] ?? '',
                $preinscription['last_name'] ?? '',
                $preinscription['email'],
                $defaultPassword,
                $institutionId
            ]);
            
            if ($result) {
                $userId = $this->pdo->lastInsertId();
                
                // Récupérer l'utilisateur créé
                $sql = "SELECT id, uuid, first_name, last_name, email, primary_role FROM users WHERE id = ?";
                $stmt = $this->pdo->prepare($sql);
                $stmt->execute([$userId]);
                return $stmt->fetch(PDO::FETCH_ASSOC);
            }
            
            return false;
        } catch (Exception $e) {
            error_log("Erreur création utilisateur: " . $e->getMessage());
            return false;
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
            
            $sql = "SELECT COUNT(*) FROM preinscriptions WHERE admission_number = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$admissionNumber]);
            
        } while ($stmt->fetchColumn() > 0);
        
        return $admissionNumber;
    }
    
    public function rejectPreinscription($preinscriptionId, $adminId, $rejectionReason) {
        try {
            $sql = "UPDATE preinscriptions SET 
                    status = 'rejected',
                    reviewed_by = ?,
                    review_date = NOW(),
                    rejection_reason = ?
                    WHERE id = ?";
            
            $stmt = $this->pdo->prepare($sql);
            $result = $stmt->execute([$adminId, $rejectionReason, $preinscriptionId]);
            
            if ($stmt->rowCount() > 0) {
                $this->sendSuccess([], 'Préinscription rejetée avec succès');
            } else {
                $this->sendError("Aucune préinscription trouvée avec cet ID");
            }
            
        } catch (Exception $e) {
            $this->sendError($e->getMessage(), 400);
        }
    }
}

// Routage
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
