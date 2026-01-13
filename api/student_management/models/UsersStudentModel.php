<?php

require_once __DIR__ . '/../../config/Database.php';

class UsersStudentModel {
    private $conn;
    
    public function __construct($connection) {
        $this->conn = $connection;
    }
    
    /**
     * Récupérer tous les étudiants depuis la table users
     */
    public function getStudents($page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        try {
            // Requête directe depuis la table users
            $query = "SELECT 
                        u.id,
                        u.uuid,
                        u.matricule,
                        u.first_name,
                        u.last_name,
                        u.email,
                        u.phone,
                        u.date_of_birth,
                        u.gender,
                        u.address,
                        u.primary_role,
                        u.level,
                        u.account_status,
                        u.is_verified,
                        u.is_active,
                        u.institution_id,
                        u.created_at,
                        u.last_login_at,
                        COALESCE(i.name, 'Institution non définie') as institution_name,
                        COALESCE(i.short_name, 'Inst') as institution_short_name,
                        CASE 
                            WHEN u.level = 'L1' THEN 'Licence 1'
                            WHEN u.level = 'L2' THEN 'Licence 2'
                            WHEN u.level = 'L3' THEN 'Licence 3'
                            WHEN u.level = 'M1' THEN 'Master 1'
                            WHEN u.level = 'M2' THEN 'Master 2'
                            WHEN u.level = 'D1' THEN 'Doctorat 1'
                            WHEN u.level = 'D2' THEN 'Doctorat 2'
                            WHEN u.level = 'D3' THEN 'Doctorat 3'
                            ELSE u.level
                        END as level_display,
                        CASE 
                            WHEN u.account_status = 'active' THEN 'Actif'
                            WHEN u.account_status = 'inactive' THEN 'Inactif'
                            WHEN u.account_status = 'suspended' THEN 'Suspendu'
                            WHEN u.account_status = 'banned' THEN 'Banni'
                            WHEN u.account_status = 'pending_verification' THEN 'En attente'
                            WHEN u.account_status = 'graduated' THEN 'Diplômé'
                            ELSE 'Retiré'
                        END as status_display,
                        CASE 
                            WHEN u.is_verified = 1 THEN 'Oui'
                            ELSE 'Non'
                        END as verified_display
                    FROM users u
                    LEFT JOIN institutions i ON u.institution_id = i.id
                    WHERE u.primary_role = 'student'
                    ORDER BY u.last_name ASC, u.first_name ASC
                    LIMIT ? OFFSET ?";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $limit, PDO::PARAM_INT);
            $stmt->bindParam(2, $offset, PDO::PARAM_INT);
            $stmt->execute();
            $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Compter le total
            $countQuery = "SELECT COUNT(*) as total FROM users WHERE primary_role = 'student'";
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
     * Récupérer un étudiant par son ID avec toutes les informations
     */
    public function getStudentById($id) {
        try {
            $query = "SELECT 
                        u.*,
                        COALESCE(i.name, 'Institution non définie') as institution_name,
                        COALESCE(i.short_name, 'Inst') as institution_short_name,
                        CASE 
                            WHEN u.level = 'L1' THEN 'Licence 1'
                            WHEN u.level = 'L2' THEN 'Licence 2'
                            WHEN u.level = 'L3' THEN 'Licence 3'
                            WHEN u.level = 'M1' THEN 'Master 1'
                            WHEN u.level = 'M2' THEN 'Master 2'
                            WHEN u.level = 'D1' THEN 'Doctorat 1'
                            WHEN u.level = 'D2' THEN 'Doctorat 2'
                            WHEN u.level = 'D3' THEN 'Doctorat 3'
                            ELSE u.level
                        END as level_display
                    FROM users u
                    LEFT JOIN institutions i ON u.institution_id = i.id
                    WHERE u.id = ? AND u.primary_role = 'student'";
            
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
     * Créer un nouvel étudiant dans les tables users et student_profiles
     */
    public function createStudent($data) {
        try {
            // Commencer une transaction
            $this->conn->beginTransaction();
            
            // Vérifier si l'email existe déjà
            $checkQuery = "SELECT id FROM users WHERE email = ?";
            $checkStmt = $this->conn->prepare($checkQuery);
            $checkStmt->execute([$data['email']]);
            
            if ($checkStmt->fetch()) {
                $this->conn->rollBack();
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
            
            // Insérer dans la table users
            $query = "INSERT INTO users (
                        uuid, institution_id, matricule, email, password_hash,
                        first_name, last_name, primary_role, account_status,
                        phone, date_of_birth, gender, address, level, is_verified, is_active
                    ) VALUES (
                        UUID(), ?, ?, ?, ?, ?, ?, 'student', 'active', ?, ?, ?, ?, ?, 1, 1
                    )";
            
            $stmt = $this->conn->prepare($query);
            $result = $stmt->execute([
                $data['institution_id'] ?? 1,
                $data['matricule'],
                $data['email'],
                $passwordHash,
                $data['first_name'],
                $data['last_name'],
                $data['phone'] ?? null,
                $data['date_of_birth'] ?? null,
                $data['gender'] ?? null,
                $data['address'] ?? null,
                $data['level'] ?? 'L1'
            ]);
            
            if (!$result) {
                $this->conn->rollBack();
                return [
                    'success' => false,
                    'message' => 'Erreur lors de la création de l\'utilisateur'
                ];
            }
            
            // Récupérer l'ID de l'utilisateur créé
            $userId = $this->conn->lastInsertId();
            
            // Insérer dans la table student_profiles avec toutes les informations
            $profileQuery = "INSERT INTO student_profiles (
                user_id, uuid, matricule, institution_id, faculty_id, department_id, program_id,
                academic_year_id, current_level, admission_type, enrollment_date, expected_graduation_date,
                gpa, total_credits_required, total_credits_earned, class_rank, honors,
                disciplinary_records, scholarship_status, scholarship_details, graduation_thesis_title,
                thesis_supervisor, thesis_defense_date, student_status, created_at
            ) VALUES (
                ?, UUID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'enrolled', NOW()
            )";
            
            $profileStmt = $this->conn->prepare($profileQuery);
            $profileResult = $profileStmt->execute([
                $userId,
                $data['matricule'],
                $data['institution_id'] ?? 1,
                $data['faculty_id'] ?? null,
                $data['department_id'] ?? null,
                $data['program_id'] ?? null,
                $data['academic_year_id'] ?? 1,
                $data['level'] ?? 'L1',
                $data['admission_type'] ?? 'regular',
                $data['enrollment_date'] ?? date('Y-m-d'),
                $data['expected_graduation_date'] ?? null,
                $data['gpa'] ?? 0.0,
                $data['total_credits_required'] ?? 120,
                $data['total_credits_earned'] ?? 0,
                $data['class_rank'] ?? null,
                $data['honors'] ?? null,
                $data['disciplinary_records'] ?? null,
                $data['scholarship_status'] ?? 'none',
                $data['scholarship_details'] ?? null,
                $data['graduation_thesis_title'] ?? null,
                $data['thesis_supervisor'] ?? null,
                $data['thesis_defense_date'] ?? null
            ]);
            
            if (!$profileResult) {
                $this->conn->rollBack();
                return [
                    'success' => false,
                    'message' => 'Erreur lors de la création du profil étudiant'
                ];
            }
            
            // Valider la transaction
            $this->conn->commit();
            
            // Récupérer l'étudiant complet
            $student = $this->getStudentById($userId);
            
            return [
                'success' => true,
                'message' => 'Étudiant créé avec succès avec toutes ses informations',
                'data' => $student
            ];
            
        } catch (Exception $e) {
            // Annuler la transaction en cas d'erreur
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
            error_log("Erreur dans createStudent: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Mettre à jour un étudiant avec tous les champs de la base de données
     */
    public function updateStudent($id, $data) {
        try {
            // Commencer une transaction
            $this->conn->beginTransaction();
            
            // Champs de la table users
            $userFields = [];
            $userParams = [];
            
            // Mapping des champs Flutter vers base de données
            $fieldMapping = [
                'first_name' => 'first_name',
                'middle_name' => 'middle_name', 
                'last_name' => 'last_name',
                'email' => 'email',
                'phone' => 'phone',
                'address' => 'address',
                'city' => 'city',
                'region' => 'region',
                'country' => 'country',
                'postal_code' => 'postal_code',
                'place_of_birth' => 'place_of_birth',
                'nationality' => 'nationality',
                'bio' => 'bio',
                'matricule' => 'matricule',
                'gender' => 'gender',
                'date_of_birth' => 'date_of_birth',
                'emergency_contact_name' => 'emergency_contact_name',
                'emergency_contact_phone' => 'emergency_contact_phone',
                'emergency_contact_relationship' => 'emergency_contact_relationship',
                'account_status' => 'account_status'
            ];
            
            // Construire dynamiquement la requête pour la table users
            foreach ($data as $key => $value) {
                if (isset($fieldMapping[$key])) {
                    if ($value !== null && $value !== '') {
                        $userFields[] = $fieldMapping[$key] . " = ?";
                        $userParams[] = $value;
                    }
                    // Les champs vides sont simplement ignorés (pas de mise à jour)
                }
            }
            
            // Mettre à jour la table users si des champs sont fournis
            if (!empty($userFields)) {
                $userParams[] = $id;
                $userQuery = "UPDATE users SET " . implode(', ', $userFields) . " WHERE id = ? AND primary_role = 'student'";
                $userStmt = $this->conn->prepare($userQuery);
                $userStmt->execute($userParams);
            }
            
            // Champs de la table student_profiles
            $profileFields = [];
            $profileParams = [];
            
            $profileFieldMapping = [
                'current_level' => 'current_level',
                'admission_type' => 'admission_type',
                'enrollment_date' => 'enrollment_date',
                'expected_graduation_date' => 'expected_graduation_date',
                'actual_graduation_date' => 'actual_graduation_date',
                'gpa' => 'gpa',
                'total_credits_required' => 'total_credits_required',
                'class_rank' => 'class_rank',
                'honors' => 'honors',
                'disciplinary_records' => 'disciplinary_records',
                'scholarship_status' => 'scholarship_status',
                'scholarship_details' => 'scholarship_details',
                'graduation_thesis_title' => 'graduation_thesis_title',
                'thesis_supervisor' => 'thesis_supervisor',
                'thesis_defense_date' => 'thesis_defense_date'
            ];
            
            // Construire dynamiquement la requête pour student_profiles
            foreach ($data as $key => $value) {
                if (isset($profileFieldMapping[$key])) {
                    if ($value !== null && $value !== '') {
                        $profileFields[] = $profileFieldMapping[$key] . " = ?";
                        $profileParams[] = $value;
                    }
                    // Les champs vides sont simplement ignorés (pas de mise à jour)
                }
            }
            
            // Vérifier si le profil existe
            $profileCheckQuery = "SELECT id FROM student_profiles WHERE user_id = ?";
            $profileCheckStmt = $this->conn->prepare($profileCheckQuery);
            $profileCheckStmt->execute([$id]);
            $existingProfile = $profileCheckStmt->fetch();
            
            if (!empty($profileFields)) {
                if ($existingProfile) {
                    // Mettre à jour le profil existant
                    $profileParams[] = $id;
                    $profileQuery = "UPDATE student_profiles SET " . implode(', ', $profileFields) . " WHERE user_id = ?";
                    $profileStmt = $this->conn->prepare($profileQuery);
                    $profileStmt->execute($profileParams);
                } else {
                    // Créer un nouveau profil
                    $profileFields[] = "user_id = ?";
                    $profileParams[] = $id;
                    
                    // Ajouter les valeurs par défaut
                    $profileFields[] = "program_id = ?";
                    $profileParams[] = 1; // Valeur par défaut
                    $profileFields[] = "academic_year_id = ?";
                    $profileParams[] = 1; // Valeur par défaut
                    $profileFields[] = "student_status = ?";
                    $profileParams[] = 'enrolled'; // Valeur par défaut
                    $profileFields[] = "total_credits_earned = ?";
                    $profileParams[] = 0; // Valeur par défaut
                    
                    $profileQuery = "INSERT INTO student_profiles SET " . implode(', ', $profileFields);
                    $profileStmt = $this->conn->prepare($profileQuery);
                    $profileStmt->execute($profileParams);
                }
            }
            
            // Valider la transaction
            $this->conn->commit();
            
            // Récupérer l'étudiant mis à jour
            $student = $this->getStudentById($id);
            
            return [
                'success' => true,
                'message' => 'Étudiant mis à jour avec succès',
                'data' => $student
            ];
            
        } catch (Exception $e) {
            // Annuler la transaction en cas d'erreur
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
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
            $query = "UPDATE users SET account_status = 'inactive', is_active = 0 WHERE id = ? AND primary_role = 'student'";
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
            $statusQuery = "SELECT account_status, COUNT(*) as count 
                          FROM users 
                          WHERE primary_role = 'student'
                          GROUP BY account_status";
            $statusStmt = $this->conn->prepare($statusQuery);
            $statusStmt->execute();
            $statusData = $statusStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_status'] = [];
            foreach ($statusData as $row) {
                $stats['by_status'][$row['account_status']] = (int)$row['count'];
            }
            
            // Niveau
            $levelQuery = "SELECT level, COUNT(*) as count 
                         FROM users 
                         WHERE primary_role = 'student'
                         GROUP BY level";
            $levelStmt = $this->conn->prepare($levelQuery);
            $levelStmt->execute();
            $levelData = $levelStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['by_level'] = [];
            foreach ($levelData as $row) {
                $stats['by_level'][$row['level']] = (int)$row['count'];
            }
            
            // Total
            $totalQuery = "SELECT COUNT(*) as total FROM users WHERE primary_role = 'student'";
            $totalStmt = $this->conn->prepare($totalQuery);
            $totalStmt->execute();
            $stats['total'] = (int)$totalStmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            // Vérifiés vs non vérifiés
            $verifiedQuery = "SELECT is_verified, COUNT(*) as count 
                            FROM users 
                            WHERE primary_role = 'student'
                            GROUP BY is_verified";
            $verifiedStmt = $this->conn->prepare($verifiedQuery);
            $verifiedStmt->execute();
            $verifiedData = $verifiedStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $stats['verification'] = [];
            foreach ($verifiedData as $row) {
                $stats['verification'][$row['is_verified'] == 1 ? 'verified' : 'unverified'] = (int)$row['count'];
            }
            
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
                        matricule, first_name, last_name, email, phone,
                        primary_role, level, account_status, is_verified,
                        date_of_birth, gender, created_at
                    FROM users 
                    WHERE primary_role = 'student'
                    ORDER BY last_name ASC, first_name ASC";
            
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
