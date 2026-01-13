<?php

require_once __DIR__ . '/../../config/Database.php';

class SimpleStudentModel {
    private $conn;
    
    public function __construct($connection) {
        $this->conn = $connection;
    }
    
    /**
     * Récupérer tous les étudiants avec pagination simple
     */
    public function getStudents($page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        try {
            // Requête adaptée à la structure réelle de student_profiles
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
                        sp.total_credits_required,
                        sp.class_rank,
                        sp.honors,
                        sp.created_at,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.matricule,
                        u.phone,
                        COALESCE(p.name, 'Programme non défini') as program_name,
                        COALESCE(ay.year_code, 'Année académique non définie') as academic_year_name,
                        CASE 
                            WHEN sp.gpa >= 3.5 THEN 'Excellent'
                            WHEN sp.gpa >= 3.0 THEN 'Bon'
                            WHEN sp.gpa >= 2.5 THEN 'Passable'
                            WHEN sp.gpa >= 2.0 THEN 'Moyen'
                            ELSE 'Insuffisant'
                        END as academic_performance
                    FROM student_profiles sp
                    LEFT JOIN users u ON sp.user_id = u.id
                    LEFT JOIN programs p ON sp.program_id = p.id
                    LEFT JOIN academic_years ay ON sp.academic_year_id = ay.id
                    ORDER BY u.last_name ASC, u.first_name ASC
                    LIMIT ? OFFSET ?";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$limit, $offset]);
            $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Compter le total
            $countQuery = "SELECT COUNT(*) as total FROM student_profiles";
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
                        sp.id,
                        sp.user_id,
                        sp.program_id,
                        sp.academic_year_id,
                        sp.current_level,
                        sp.enrollment_date,
                        sp.expected_graduation_date,
                        sp.actual_graduation_date,
                        sp.student_status,
                        sp.admission_type,
                        sp.scholarship_status,
                        sp.scholarship_details,
                        sp.gpa,
                        sp.total_credits_earned,
                        sp.total_credits_required,
                        sp.class_rank,
                        sp.honors,
                        sp.disciplinary_records,
                        sp.graduation_thesis_title,
                        sp.thesis_supervisor,
                        sp.thesis_defense_date,
                        sp.created_at,
                        sp.updated_at,
                        u.first_name,
                        u.last_name,
                        u.middle_name,
                        u.email,
                        u.matricule,
                        u.phone,
                        u.gender,
                        u.date_of_birth,
                        u.place_of_birth,
                        u.nationality,
                        u.address,
                        u.city,
                        u.region,
                        u.country,
                        u.postal_code,
                        u.bio,
                        u.emergency_contact_name,
                        u.emergency_contact_phone,
                        u.emergency_contact_relationship,
                        u.account_status,
                        u.primary_role as role,
                        COALESCE(p.name, 'Programme non défini') as program_name,
                        COALESCE(ay.year_code, 'Année académique non définie') as academic_year_name
                    FROM student_profiles sp
                    LEFT JOIN users u ON sp.user_id = u.id
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
     * Créer un nouvel étudiant
     */
    public function createStudent($data) {
        try {
            // D'abord créer ou récupérer l'utilisateur
            $this->conn->beginTransaction();
            
            // Vérifier si l'utilisateur existe déjà
            $checkUserQuery = "SELECT id FROM users WHERE email = ?";
            $checkUserStmt = $this->conn->prepare($checkUserQuery);
            $checkUserStmt->execute([$data['email']]);
            $existingUser = $checkUserStmt->fetch();
            
            if ($existingUser) {
                $userId = $existingUser['id'];
            } else {
                // Créer le user d'abord
                $userQuery = "INSERT INTO users (
                    institution_id, department_id, first_name, last_name, email, matricule, phone, primary_role, 
                    created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, 'student', NOW(), NOW())";
                
                $userStmt = $this->conn->prepare($userQuery);
                $userResult = $userStmt->execute([
                    $data['institution_id'] ?? 1,
                    $data['department_id'] ?? 1,
                    $data['first_name'],
                    $data['last_name'],
                    $data['email'],
                    $data['matricule'] ?? 'STU' . date('Y') . str_pad(mt_rand(1, 9999), 4, '0', STR_PAD_LEFT),
                    $data['phone'] ?? null
                ]);
                
                if (!$userResult) {
                    throw new Exception("Erreur lors de la création de l'utilisateur");
                }
                
                $userId = $this->conn->lastInsertId();
            }
            
            // Vérifier si le profile étudiant existe déjà
            $checkProfileQuery = "SELECT id FROM student_profiles WHERE user_id = ?";
            $checkProfileStmt = $this->conn->prepare($checkProfileQuery);
            $checkProfileStmt->execute([$userId]);
            
            if ($checkProfileStmt->fetch()) {
                $this->conn->rollBack();
                return [
                    'success' => false,
                    'message' => 'Un profile étudiant existe déjà pour cet utilisateur'
                ];
            }
            
            // Créer le profile étudiant
            $query = "INSERT INTO student_profiles (
                user_id, program_id, academic_year_id, current_level, 
                enrollment_date, student_status, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
            
            $stmt = $this->conn->prepare($query);
            $result = $stmt->execute([
                $userId,
                $data['program_id'] ?? 19, // ID 19 existe pour Informatique (Licence)
                $data['academic_year_id'] ?? 1, // ID 1 pour l'année académique 2024-2025
                $data['level'] ?? 'licence1',
                $data['enrollment_date'] ?? date('Y-m-d'),
                $data['student_status'] ?? 'enrolled'
            ]);
            
            if ($result) {
                $studentId = $this->conn->lastInsertId();
                $this->conn->commit();
                $student = $this->getStudentById($studentId);
                
                return [
                    'success' => true,
                    'message' => 'Étudiant créé avec succès',
                    'data' => $student
                ];
            } else {
                $this->conn->rollBack();
                return [
                    'success' => false,
                    'message' => 'Erreur lors de la création du profile étudiant'
                ];
            }
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            error_log("Erreur dans createStudent: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Mettre à jour un étudiant
     */
    public function updateStudent($id, $data) {
        try {
            $this->conn->beginTransaction();
            
            // Récupérer le profile étudiant
            $profileQuery = "SELECT * FROM student_profiles WHERE id = ?";
            $profileStmt = $this->conn->prepare($profileQuery);
            $profileStmt->execute([$id]);
            $profile = $profileStmt->fetch();
            
            if (!$profile) {
                $this->conn->rollBack();
                return [
                    'success' => false,
                    'message' => 'Profile étudiant non trouvé'
                ];
            }
            
            // Mettre à jour les informations de l'utilisateur si nécessaire
            $userFields = [];
            $userParams = [];
            
            // Champs de base de l'utilisateur
            $allowedUserFields = ['first_name', 'last_name', 'middle_name', 'email', 'phone', 'matricule', 
                                 'address', 'city', 'region', 'country', 'postal_code', 
                                 'place_of_birth', 'nationality', 'gender', 'date_of_birth', 'bio'];
            
            foreach ($data as $key => $value) {
                if (in_array($key, $allowedUserFields) && $value !== null && $value !== '') {
                    $userFields[] = "$key = ?";
                    $userParams[] = $value;
                }
            }
            
            if (!empty($userFields)) {
                $userParams[] = $profile['user_id'];
                $userQuery = "UPDATE users SET " . implode(', ', $userFields) . ", updated_at = NOW() WHERE id = ?";
                $userStmt = $this->conn->prepare($userQuery);
                $userResult = $userStmt->execute($userParams);
                
                if (!$userResult) {
                    throw new Exception("Erreur lors de la mise à jour de l'utilisateur");
                }
            }
            
            // Mettre à jour le profile étudiant
            $profileFields = [];
            $profileParams = [];
            
            // Champs du profil étudiant
            $allowedProfileFields = ['program_id', 'academic_year_id', 'current_level', 'student_status', 'gpa',
                                   'total_credits_required', 'class_rank', 'honors', 'disciplinary_records',
                                   'scholarship_status', 'scholarship_details', 'admission_type',
                                   'enrollment_date', 'expected_graduation_date', 'actual_graduation_date',
                                   'graduation_thesis_title', 'thesis_supervisor', 'thesis_defense_date'];
            
            foreach ($data as $key => $value) {
                if (in_array($key, $allowedProfileFields)) {
                    if ($value !== null && $value !== '') {
                        $profileFields[] = "$key = ?";
                        $profileParams[] = $value;
                    }
                }
            }
            
            // Gérer le cas où account_status est envoyé au lieu de student_status
            if (isset($data['account_status']) && !isset($data['student_status'])) {
                $profileFields[] = "student_status = ?";
                $profileParams[] = $data['account_status'];
            }
            
            if (!empty($profileFields)) {
                $profileParams[] = $id;
                $profileQuery = "UPDATE student_profiles SET " . implode(', ', $profileFields) . ", updated_at = NOW() WHERE id = ?";
                $profileStmt = $this->conn->prepare($profileQuery);
                $profileResult = $profileStmt->execute($profileParams);
                
                if (!$profileResult) {
                    throw new Exception("Erreur lors de la mise à jour du profile étudiant");
                }
            }
            
            // Mettre à jour les informations de contact d'urgence si elles existent
            $emergencyFields = [];
            $emergencyParams = [];
            $allowedEmergencyFields = ['emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relationship'];
            
            foreach ($data as $key => $value) {
                if (in_array($key, $allowedEmergencyFields) && $value !== null && $value !== '') {
                    $emergencyFields[] = "$key = ?";
                    $emergencyParams[] = $value;
                }
            }
            
            if (!empty($emergencyFields)) {
                $emergencyParams[] = $profile['user_id'];
                $emergencyQuery = "UPDATE users SET " . implode(', ', $emergencyFields) . " WHERE id = ?";
                $emergencyStmt = $this->conn->prepare($emergencyQuery);
                $emergencyResult = $emergencyStmt->execute($emergencyParams);
                
                if (!$emergencyResult) {
                    throw new Exception("Erreur lors de la mise à jour des contacts d'urgence");
                }
            }
            
            $this->conn->commit();
            $student = $this->getStudentById($id);
            
            return [
                'success' => true,
                'message' => 'Étudiant mis à jour avec succès',
                'data' => $student
            ];
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            error_log("Erreur dans updateStudent: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Supprimer un étudiant (désactivation)
     */
    public function deleteStudent($id) {
        try {
            $query = "UPDATE student_profiles SET student_status = 'inactive' WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $result = $stmt->execute([$id]);
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'Étudiant désactivé avec succès'
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Erreur lors de la désactivation de l\'étudiant'
                ];
            }
            
        } catch (Exception $e) {
            error_log("Erreur dans deleteStudent: " . $e->getMessage());
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
            $statusQuery = "SELECT student_status, COUNT(*) as count 
                          FROM student_profiles 
                          GROUP BY student_status";
            $statusStmt = $this->conn->prepare($statusQuery);
            $statusStmt->execute();
            $statusData = $statusStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($statusData as $row) {
                $stats['by_status'][$row['student_status']] = (int)$row['count'];
            }
            
            // Niveau
            $levelQuery = "SELECT current_level, COUNT(*) as count 
                         FROM student_profiles 
                         WHERE current_level IS NOT NULL
                         GROUP BY current_level";
            $levelStmt = $this->conn->prepare($levelQuery);
            $levelStmt->execute();
            $levelData = $levelStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_level'] = [];
            foreach ($levelData as $row) {
                $stats['by_level'][$row['current_level']] = (int)$row['count'];
            }
            
            // Total
            $totalQuery = "SELECT COUNT(*) as total FROM student_profiles";
            $totalStmt = $this->conn->prepare($totalQuery);
            $totalStmt->execute();
            $stats['total'] = (int)$totalStmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            // GPA moyen
            $gpaQuery = "SELECT AVG(gpa) as avg_gpa 
                        FROM student_profiles 
                        WHERE gpa IS NOT NULL";
            $gpaStmt = $this->conn->prepare($gpaQuery);
            $gpaStmt->execute();
            $gpaResult = $gpaStmt->fetch(PDO::FETCH_ASSOC);
            $stats['average_gpa'] = $gpaResult['avg_gpa'] ? round((float)$gpaResult['avg_gpa'], 2) : 0;
            
            return $stats;
            
        } catch (Exception $e) {
            error_log("Erreur dans getStudentStats: " . $e->getMessage());
            throw new Exception("Erreur lors de la récupération des statistiques: " . $e->getMessage());
        }
    }
    
    /**
     * Exporter les étudiants (format simplifié)
     */
    public function exportStudents() {
        try {
            $query = "SELECT 
                        u.matricule, u.first_name, u.last_name, u.email, u.phone,
                        sp.student_status, sp.current_level, sp.gpa,
                        sp.enrollment_date, sp.created_at,
                        p.name as program_name
                    FROM student_profiles sp
                    LEFT JOIN users u ON sp.user_id = u.id
                    LEFT JOIN programs p ON sp.program_id = p.id
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
