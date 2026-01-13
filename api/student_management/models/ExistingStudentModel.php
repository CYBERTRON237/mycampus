<?php

require_once __DIR__ . '/../../config/Database.php';

class ExistingStudentModel {
    private $conn;
    
    public function __construct($connection) {
        $this->conn = $connection;
    }
    
    /**
     * Récupérer tous les étudiants avec la structure existante de la BDD
     */
    public function getStudents($page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        try {
            // Requête adaptée à votre structure de BDD existante
            $query = "SELECT 
                        sp.id,
                        sp.user_id,
                        sp.program_id,
                        sp.academic_year_id,
                        sp.current_level,
                        sp.enrollment_date,
                        sp.student_status,
                        sp.gpa,
                        sp.total_credits_earned,
                        sp.created_at,
                        u.uuid,
                        u.matricule,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.phone,
                        u.date_of_birth,
                        u.gender,
                        u.address,
                        u.account_status,
                        u.institution_id,
                        COALESCE(i.name, 'Institution non définie') as institution_name,
                        COALESCE(p.name, 'Programme non défini') as program_name,
                        COALESCE(ay.year_name, 'Année non définie') as academic_year,
                        CASE 
                            WHEN sp.gpa >= 3.5 THEN 'Excellent'
                            WHEN sp.gpa >= 3.0 THEN 'Bon'
                            WHEN sp.gpa >= 2.5 THEN 'Passable'
                            WHEN sp.gpa >= 2.0 THEN 'Moyen'
                            ELSE 'Insuffisant'
                        END as academic_performance
                    FROM student_profiles sp
                    INNER JOIN users u ON sp.user_id = u.id
                    LEFT JOIN institutions i ON u.institution_id = i.id
                    LEFT JOIN programs p ON sp.program_id = p.id
                    LEFT JOIN academic_years ay ON sp.academic_year_id = ay.id
                    ORDER BY u.last_name ASC, u.first_name ASC
                    LIMIT ? OFFSET ?";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$limit, $offset]);
            $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Compter le total
            $countQuery = "SELECT COUNT(*) as total FROM student_profiles sp INNER JOIN users u ON sp.user_id = u.id";
            $countStmt = $this->conn->prepare($countQuery);
            $countStmt->execute();
            $total = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            return [
                'students' => $students,
                'total' => $total
            ];
            
        } catch (Exception $e) {
            error_log("Erreur dans getStudents: " . $e->getMessage());
            throw new Exception("Erreur lors de la récupération des étudiants: " . $e->getMessage());
        }
    }
    
    /**
     * Récupérer un étudiant par son ID
     */
    public function getStudentById($id) {
        try {
            $query = "SELECT 
                        sp.*,
                        u.uuid,
                        u.matricule,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.phone,
                        u.date_of_birth,
                        u.gender,
                        u.address,
                        u.account_status,
                        u.institution_id,
                        COALESCE(i.name, 'Institution non définie') as institution_name,
                        COALESCE(p.name, 'Programme non défini') as program_name,
                        COALESCE(ay.year_name, 'Année non définie') as academic_year
                    FROM student_profiles sp
                    INNER JOIN users u ON sp.user_id = u.id
                    LEFT JOIN institutions i ON u.institution_id = i.id
                    LEFT JOIN programs p ON sp.program_id = p.id
                    LEFT JOIN academic_years ay ON sp.academic_year_id = ay.id
                    WHERE sp.id = ?";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id]);
            $student = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return $student;
            
        } catch (Exception $e) {
            error_log("Erreur dans getStudentById: " . $e->getMessage());
            throw new Exception("Erreur lors de la récupération de l'étudiant: " . $e->getMessage());
        }
    }
    
    /**
     * Créer un nouvel étudiant avec la structure existante
     */
    public function createStudent($data) {
        try {
            // Vérifier si l'email existe déjà dans users
            $checkQuery = "SELECT id FROM users WHERE email = ?";
            $checkStmt = $this->conn->prepare($checkQuery);
            $checkStmt->execute([$data['email']]);
            
            if ($checkStmt->fetch()) {
                return [
                    'success' => false,
                    'message' => 'Un utilisateur avec cet email existe déjà'
                ];
            }
            
            // Générer un matricule si non fourni
            if (empty($data['matricule'])) {
                $data['matricule'] = 'STU' . date('Y') . str_pad(mt_rand(1, 9999), 4, '0', STR_PAD_LEFT);
            }
            
            // Hasher le mot de passe
            $passwordHash = password_hash($data['password'] ?? 'password123', PASSWORD_DEFAULT);
            
            // Démarrer une transaction
            $this->conn->beginTransaction();
            
            try {
                // 1. Créer l'utilisateur dans la table users
                $userQuery = "INSERT INTO users (
                                uuid, institution_id, matricule, email, password_hash,
                                first_name, last_name, primary_role, account_status,
                                phone, date_of_birth, gender, address
                            ) VALUES (
                                UUID(), ?, ?, ?, ?, ?, ?, 'student', 'active', ?, ?, ?, ?
                            )";
                
                $userStmt = $this->conn->prepare($userQuery);
                $userResult = $userStmt->execute([
                    $data['institution_id'] ?? 1,
                    $data['matricule'],
                    $data['email'],
                    $passwordHash,
                    $data['first_name'],
                    $data['last_name'],
                    $data['phone'] ?? null,
                    $data['date_of_birth'] ?? null,
                    $data['gender'] ?? null,
                    $data['address'] ?? null
                ]);
                
                if (!$userResult) {
                    throw new Exception("Erreur lors de la création de l'utilisateur");
                }
                
                $userId = $this->conn->lastInsertId();
                
                // 2. Créer le profil étudiant
                $profileQuery = "INSERT INTO student_profiles (
                                    user_id, program_id, academic_year_id, current_level,
                                    enrollment_date, student_status
                                ) VALUES (
                                    ?, ?, ?, ?, CURDATE(), 'enrolled'
                                )";
                
                $profileStmt = $this->conn->prepare($profileQuery);
                $profileResult = $profileStmt->execute([
                    $userId,
                    $data['program_id'] ?? 1,
                    $data['academic_year_id'] ?? 1,
                    $data['level'] ?? 'licence1'
                ]);
                
                if (!$profileResult) {
                    throw new Exception("Erreur lors de la création du profil étudiant");
                }
                
                // 3. Créer les settings utilisateur
                $settingsQuery = "INSERT INTO user_settings (user_id) VALUES (?)";
                $settingsStmt = $this->conn->prepare($settingsQuery);
                $settingsStmt->execute([$userId]);
                
                // Valider la transaction
                $this->conn->commit();
                
                // Récupérer l'étudiant créé
                $studentId = $this->conn->lastInsertId();
                $student = $this->getStudentById($studentId);
                
                return [
                    'success' => true,
                    'message' => 'Étudiant créé avec succès',
                    'data' => $student
                ];
                
            } catch (Exception $e) {
                $this->conn->rollback();
                throw $e;
            }
            
        } catch (Exception $e) {
            error_log("Erreur dans createStudent: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Obtenir les statistiques des étudiants
     */
    public function getStudentStats() {
        try {
            $stats = [];
            
            // Statut général
            $statusQuery = "SELECT sp.student_status, COUNT(*) as count 
                          FROM student_profiles sp 
                          INNER JOIN users u ON sp.user_id = u.id
                          GROUP BY sp.student_status";
            $statusStmt = $this->conn->prepare($statusQuery);
            $statusStmt->execute();
            $statusData = $statusStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($statusData as $row) {
                $stats['by_status'][$row['student_status']] = (int)$row['count'];
            }
            
            // Niveau
            $levelQuery = "SELECT sp.current_level, COUNT(*) as count 
                         FROM student_profiles sp 
                         INNER JOIN users u ON sp.user_id = u.id
                         GROUP BY sp.current_level";
            $levelStmt = $this->conn->prepare($levelQuery);
            $levelStmt->execute();
            $levelData = $levelStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_level'] = [];
            foreach ($levelData as $row) {
                $stats['by_level'][$row['current_level']] = (int)$row['count'];
            }
            
            // Total
            $totalQuery = "SELECT COUNT(*) as total FROM student_profiles sp INNER JOIN users u ON sp.user_id = u.id";
            $totalStmt = $this->conn->prepare($totalQuery);
            $totalStmt->execute();
            $stats['total'] = (int)$totalStmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            // GPA moyen
            $gpaQuery = "SELECT AVG(sp.gpa) as avg_gpa 
                        FROM student_profiles sp 
                        INNER JOIN users u ON sp.user_id = u.id
                        WHERE sp.gpa IS NOT NULL";
            $gpaStmt = $this->conn->prepare($gpaQuery);
            $gpaStmt->execute();
            $stats['average_gpa'] = round((float)$gpaStmt->fetch(PDO::FETCH_ASSOC)['avg_gpa'], 2);
            
            return $stats;
            
        } catch (Exception $e) {
            error_log("Erreur dans getStudentStats: " . $e->getMessage());
            throw new Exception("Erreur lors de la récupération des statistiques: " . $e->getMessage());
        }
    }
    
    /**
     * Exporter les étudiants
     */
    public function exportStudents() {
        try {
            $query = "SELECT 
                        u.matricule, u.first_name, u.last_name, u.email, u.phone,
                        sp.student_status, sp.current_level, sp.gpa,
                        sp.enrollment_date, u.created_at
                    FROM student_profiles sp
                    INNER JOIN users u ON sp.user_id = u.id
                    ORDER BY u.last_name ASC, u.first_name ASC";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
            
        } catch (Exception $e) {
            error_log("Erreur dans exportStudents: " . $e->getMessage());
            throw new Exception("Erreur lors de l'exportation: " . $e->getMessage());
        }
    }
}
?>
