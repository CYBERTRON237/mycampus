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
require_once '../middleware/auth.php';

class TestValidationAPI {
    private $pdo;
    
    public function __construct() {
        $this->pdo = Database::getConnection();
    }
    
    /**
     * Tester la connexion à la base de données
     */
    public function testDatabaseConnection() {
        try {
            $stmt = $this->pdo->query("SELECT 1");
            $result = $stmt->fetch();
            
            echo json_encode([
                'success' => true,
                'message' => 'Connexion à la base de données réussie',
                'data' => $result
            ]);
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur de connexion: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Vérifier si la table preinscriptions existe
     */
    public function testPreinscriptionsTable() {
        try {
            $stmt = $this->pdo->query("DESCRIBE preinscriptions");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'message' => 'Table preinscriptions trouvée',
                'data' => [
                    'column_count' => count($columns),
                    'columns' => array_map(function($col) {
                        return $col['Field'];
                    }, $columns)
                ]
            ]);
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Table preinscriptions non trouvée: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Vérifier si la table users existe
     */
    public function testUsersTable() {
        try {
            $stmt = $this->pdo->query("DESCRIBE users");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'message' => 'Table users trouvée',
                'data' => [
                    'column_count' => count($columns),
                    'columns' => array_map(function($col) {
                        return $col['Field'];
                    }, $columns)
                ]
            ]);
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Table users non trouvée: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Compter les préinscriptions par statut
     */
    public function testPreinscriptionsCount() {
        try {
            $sql = "SELECT status, COUNT(*) as count FROM preinscriptions GROUP BY status";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'message' => 'Statistiques des préinscriptions',
                'data' => $results
            ]);
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors du comptage: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Vérifier les utilisateurs avec le rôle invite
     */
    public function testInviteUsers() {
        try {
            $sql = "SELECT COUNT(*) as count FROM users WHERE primary_role = 'invite'";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            $count = $stmt->fetchColumn();
            
            echo json_encode([
                'success' => true,
                'message' => 'Utilisateurs avec le rôle invite',
                'data' => ['count' => $count]
            ]);
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la vérification: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Tester la mise à jour du rôle
     */
    public function testRoleUpdate($email) {
        try {
            // Chercher l'utilisateur
            $sql = "SELECT id, primary_role FROM users WHERE email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $email);
            $stmt->execute();
            
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                echo json_encode([
                    'success' => false,
                    'message' => "Utilisateur non trouvé: $email"
                ]);
                return;
            }
            
            // Mettre à jour le rôle
            $sql = "UPDATE users SET primary_role = 'student', updated_at = NOW() WHERE id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':id', $user['id']);
            $stmt->execute();
            
            echo json_encode([
                'success' => true,
                'message' => 'Rôle mis à jour avec succès',
                'data' => [
                    'user_id' => $user['id'],
                    'email' => $email,
                    'old_role' => $user['primary_role'],
                    'new_role' => 'student'
                ]
            ]);
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour: ' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * Tester la validation complète d'une préinscription
     */
    public function testCompleteValidation($preinscriptionId) {
        try {
            $this->pdo->beginTransaction();
            
            // 1. Récupérer la préinscription
            $sql = "SELECT * FROM preinscriptions WHERE id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':id', $preinscriptionId);
            $stmt->execute();
            
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$preinscription) {
                throw new Exception("Préinscription non trouvée");
            }
            
            // 2. Vérifier l'utilisateur
            $sql = "SELECT id, primary_role FROM users WHERE email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $preinscription['email']);
            $stmt->execute();
            
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                throw new Exception("Aucun utilisateur trouvé avec l'email: " . $preinscription['email']);
            }
            
            // 3. Générer un numéro d'admission
            $year = date('Y');
            $facultyCode = $this->getFacultyCode($preinscription['faculty']);
            $random = mt_rand(1000, 9999);
            $admissionNumber = "{$year}{$facultyCode}{$random}";
            
            // 4. Mettre à jour la préinscription
            $sql = "UPDATE preinscriptions SET 
                    status = 'accepted',
                    admission_number = :admission_number,
                    admission_date = NOW(),
                    review_date = NOW(),
                    student_id = :student_id,
                    is_processed = 1,
                    processed_at = NOW()
                    WHERE id = :id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':admission_number', $admissionNumber);
            $stmt->bindParam(':student_id', $user['id']);
            $stmt->bindParam(':id', $preinscriptionId);
            $stmt->execute();
            
            // 5. Mettre à jour le rôle utilisateur
            $sql = "UPDATE users SET 
                    primary_role = 'student',
                    preinscription_id = :preinscription_id,
                    preinscription_unique_code = :unique_code,
                    updated_at = NOW()
                    WHERE id = :user_id";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':preinscription_id', $preinscriptionId);
            $stmt->bindParam(':unique_code', $preinscription['unique_code']);
            $stmt->bindParam(':user_id', $user['id']);
            $stmt->execute();
            
            $this->pdo->commit();
            
            echo json_encode([
                'success' => true,
                'message' => 'Validation complète réussie',
                'data' => [
                    'preinscription_id' => $preinscriptionId,
                    'admission_number' => $admissionNumber,
                    'user_id' => $user['id'],
                    'user_email' => $preinscription['email'],
                    'previous_role' => $user['primary_role'],
                    'new_role' => 'student'
                ]
            ]);
            
        } catch (Exception $e) {
            $this->pdo->rollBack();
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
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
    
    /**
     * Lister toutes les préinscriptions en attente
     */
    public function testListPendingPreinscriptions() {
        try {
            $sql = "SELECT p.*, 
                           u.id as user_id, u.email as user_email, u.primary_role as user_role
                    FROM preinscriptions p 
                    LEFT JOIN users u ON p.email = u.email 
                    WHERE p.status = 'pending' 
                    OR (p.status = 'under_review' AND p.is_processed = 0)
                    ORDER BY p.submission_date DESC
                    LIMIT 10";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            $preinscriptions = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Ajouter des informations supplémentaires
            foreach ($preinscriptions as &$preinscription) {
                $preinscription['has_user_account'] = !empty($preinscription['user_id']);
                $preinscription['can_be_validated'] = $preinscription['payment_status'] === 'paid' || $preinscription['payment_status'] === 'confirmed';
            }
            
            echo json_encode([
                'success' => true,
                'message' => 'Liste des préinscriptions en attente',
                'data' => $preinscriptions,
                'count' => count($preinscriptions)
            ]);
            
        } catch (PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
            ]);
        }
    }
}

// Router les requêtes de test
$testAPI = new TestValidationAPI();
$action = $_GET['action'] ?? 'database';

switch ($action) {
    case 'database':
        $testAPI->testDatabaseConnection();
        break;
        
    case 'preinscriptions_table':
        $testAPI->testPreinscriptionsTable();
        break;
        
    case 'users_table':
        $testAPI->testUsersTable();
        break;
        
    case 'preinscriptions_count':
        $testAPI->testPreinscriptionsCount();
        break;
        
    case 'invite_users':
        $testAPI->testInviteUsers();
        break;
        
    case 'role_update':
        $email = $_GET['email'] ?? null;
        if ($email) {
            $testAPI->testRoleUpdate($email);
        } else {
            echo json_encode(['success' => false, 'message' => 'Email requis']);
        }
        break;
        
    case 'complete_validation':
        $preinscriptionId = $_GET['preinscription_id'] ?? null;
        if ($preinscriptionId) {
            $testAPI->testCompleteValidation($preinscriptionId);
        } else {
            echo json_encode(['success' => false, 'message' => 'ID de préinscription requis']);
        }
        break;
        
    case 'list_pending':
        $testAPI->testListPendingPreinscriptions();
        break;
        
    default:
        echo json_encode([
            'success' => false,
            'message' => 'Action de test non reconnue',
            'available_actions' => [
                'database',
                'preinscriptions_table',
                'users_table',
                'preinscriptions_count',
                'invite_users',
                'role_update?email=...',
                'complete_validation?preinscription_id=...',
                'list_pending'
            ]
        ]);
}
?>
