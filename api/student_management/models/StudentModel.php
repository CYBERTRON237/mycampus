<?php

class StudentModel {
    private $conn;
    
    public function __construct($connection) {
        $this->conn = $connection;
    }
    
    /**
     * Récupérer tous les étudiants avec filtres et pagination
     */
    public function getStudents($institutionId = null, $facultyId = null, $departmentId = null, 
                               $programId = null, $level = null, $status = null, $search = null, 
                               $page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        $conditions = [];
        $params = [];
        $types = '';
        
        // Construction des conditions
        if ($institutionId) {
            $conditions[] = "u.institution_id = ?";
            $params[] = $institutionId;
            $types .= 'i';
        }
        
        if ($facultyId) {
            $conditions[] = "f.id = ?";
            $params[] = $facultyId;
            $types .= 'i';
        }
        
        if ($departmentId) {
            $conditions[] = "d.id = ?";
            $params[] = $departmentId;
            $types .= 'i';
        }
        
        if ($programId) {
            $conditions[] = "p.id = ?";
            $params[] = $programId;
            $types .= 'i';
        }
        
        if ($level) {
            $conditions[] = "sp.current_level = ?";
            $params[] = $level;
            $types .= 's';
        }
        
        if ($status) {
            $conditions[] = "sp.student_status = ?";
            $params[] = $status;
            $types .= 's';
        }
        
        if ($search) {
            $conditions[] = "(u.first_name LIKE ? OR u.last_name LIKE ? OR u.email LIKE ? OR u.matricule LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
            $types .= 'ssss';
        }
        
        $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
        
        // Requête principale
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
                    u.account_status,
                    u.created_at,
                    u.last_login_at,
                    sp.id as profile_id,
                    sp.current_level,
                    sp.enrollment_date,
                    sp.expected_graduation_date,
                    sp.student_status,
                    sp.admission_type,
                    sp.gpa,
                    sp.total_credits_earned,
                    sp.total_credits_required,
                    sp.class_rank,
                    i.name as institution_name,
                    i.short_name as institution_short_name,
                    f.name as faculty_name,
                    f.short_name as faculty_short_name,
                    d.name as department_name,
                    d.short_name as department_short_name,
                    p.name as program_name,
                    p.short_name as program_short_name,
                    p.degree_level,
                    ay.year_code as academic_year,
                    CASE 
                        WHEN sp.gpa >= 3.5 THEN 'Excellent'
                        WHEN sp.gpa >= 3.0 THEN 'Bon'
                        WHEN sp.gpa >= 2.5 THEN 'Passable'
                        WHEN sp.gpa >= 2.0 THEN 'Moyen'
                        ELSE 'Insuffisant'
                    END as academic_performance
                FROM users u
                INNER JOIN student_profiles sp ON u.id = sp.user_id
                INNER JOIN institutions i ON u.institution_id = i.id
                INNER JOIN faculties f ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id IN (
                        SELECT id FROM departments WHERE faculty_id = f.id
                    )
                )
                INNER JOIN departments d ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id = d.id
                )
                INNER JOIN programs p ON sp.program_id = p.id
                INNER JOIN academic_years ay ON sp.academic_year_id = ay.id
                $whereClause
                ORDER BY u.last_name ASC, u.first_name ASC
                LIMIT ? OFFSET ?";
        
        $params[] = $limit;
        $params[] = $offset;
        $types .= 'ii';
        
        $stmt = $this->conn->prepare($query);
        if (!empty($params)) {
            $stmt->execute($params);
        } else {
            $stmt->execute();
        }
        $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Compter le total
        $countQuery = "SELECT COUNT(DISTINCT u.id) as total
                      FROM users u
                      INNER JOIN student_profiles sp ON u.id = sp.user_id
                      INNER JOIN institutions i ON u.institution_id = i.id
                      INNER JOIN faculties f ON sp.program_id IN (
                          SELECT id FROM programs WHERE department_id IN (
                              SELECT id FROM departments WHERE faculty_id = f.id
                          )
                      )
                      INNER JOIN departments d ON sp.program_id IN (
                          SELECT id FROM programs WHERE department_id = d.id
                      )
                      INNER JOIN programs p ON sp.program_id = p.id
                      $whereClause";
        
        $countParams = array_slice($params, 0, -2); // Retirer limit et offset
        $countTypes = substr($types, 0, -2);
        
        $countStmt = $this->conn->prepare($countQuery);
        if (!empty($countParams)) {
            $countStmt->execute($countParams); // Exclure limit et offset
        } else {
            $countStmt->execute();
        }
        $total = $countStmt->fetchColumn();
        
        return [
            'students' => $students,
            'total' => $total
        ];
    }
    
    /**
     * Récupérer un étudiant par son ID avec toutes les informations
     */
    public function getStudentById($id) {
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
                    u.account_status,
                    u.created_at,
                    u.last_login_at,
                    sp.id as profile_id,
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
                    i.name as institution_name,
                    i.short_name as institution_short_name,
                    i.type as institution_type,
                    i.country,
                    i.region,
                    i.city,
                    f.name as faculty_name,
                    f.short_name as faculty_short_name,
                    d.name as department_name,
                    d.short_name as department_short_name,
                    p.name as program_name,
                    p.short_name as program_short_name,
                    p.degree_level,
                    p.duration_years,
                    ay.year_code as academic_year,
                    ay.start_date as academic_year_start,
                    ay.end_date as academic_year_end
                FROM users u
                INNER JOIN student_profiles sp ON u.id = sp.user_id
                INNER JOIN institutions i ON u.institution_id = i.id
                INNER JOIN faculties f ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id IN (
                        SELECT id FROM departments WHERE faculty_id = f.id
                    )
                )
                INNER JOIN departments d ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id = d.id
                )
                INNER JOIN programs p ON sp.program_id = p.id
                INNER JOIN academic_years ay ON sp.academic_year_id = ay.id
                WHERE u.id = ?";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$id]);
        
        $student = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($student) {
            // Récupérer les inscriptions
            $student['enrollments'] = $this->getStudentEnrollments($id);
            
            // Récupérer les résultats académiques
            $student['academic_records'] = $this->getStudentAcademicRecords($id);
            
            // Récupérer les documents
            $student['documents'] = $this->getStudentDocuments($id);
            
            // Récupérer les bourses
            $student['scholarships'] = $this->getStudentScholarships($id);
            
            // Récupérer les incidents disciplinaires
            $student['discipline_records'] = $this->getStudentDisciplineRecords($id);
        }
        
        return $student;
    }
    
    /**
     * Créer un nouvel étudiant
     */
    public function createStudent($data) {
        try {
            $this->conn->beginTransaction();
            
            // Générer un matricule unique
            $matricule = $this->generateMatricule($data['institution_id']);
            
            // Créer l'utilisateur
            $userQuery = "INSERT INTO users (
                uuid, institution_id, matricule, email, password_hash,
                first_name, last_name, phone, date_of_birth, gender,
                address, primary_role, account_status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'student', 'active')";
            
            $uuid = $this->generateUUID();
            $passwordHash = password_hash($data['password'] ?? 'default123', PASSWORD_DEFAULT);
            
            $stmt = $this->conn->prepare($userQuery);
            $stmt->execute([
                $uuid, $data['institution_id'], $matricule, $data['email'], $passwordHash,
                $data['first_name'], $data['last_name'], $data['phone'] ?? null, 
                $data['date_of_birth'] ?? null, $data['gender'] ?? null, 
                $data['address'] ?? null
            ]);
            
            $userId = $this->conn->lastInsertId();
            
            // Créer le profil étudiant
            $profileQuery = "INSERT INTO student_profiles (
                user_id, program_id, academic_year_id, current_level,
                enrollment_date, expected_graduation_date, admission_type,
                scholarship_status, total_credits_required
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            $expectedGraduation = $this->calculateExpectedGraduation($data['level'], $data['enrollment_date'] ?? date('Y-m-d'));
            $creditsRequired = $this->getCreditsRequired($data['level']);
            
            $stmt = $this->conn->prepare($profileQuery);
            $stmt->execute([
                $userId, $data['program_id'], $data['academic_year_id'], $data['level'],
                $data['enrollment_date'] ?? date('Y-m-d'), $expectedGraduation,
                $data['admission_type'] ?? 'regular', $data['scholarship_status'] ?? 'none',
                $creditsRequired
            ]);
            
            // Créer les paramètres utilisateur
            $settingsQuery = "INSERT INTO user_settings (user_id) VALUES (?)";
            $stmt = $this->conn->prepare($settingsQuery);
            $stmt->execute([$userId]);
            
            $this->conn->commit();
            
            return [
                'success' => true,
                'message' => 'Étudiant créé avec succès',
                'data' => [
                    'user_id' => $userId,
                    'matricule' => $matricule,
                    'uuid' => $uuid
                ]
            ];
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Mettre à jour un étudiant
     */
    public function updateStudent($id, $data) {
        try {
            $this->conn->beginTransaction();
            
            // Mettre à jour l'utilisateur
            $userFields = [];
            $userParams = [];
            $types = '';
            
            $updatableUserFields = ['first_name', 'last_name', 'email', 'phone', 'date_of_birth', 'gender', 'address'];
            foreach ($updatableUserFields as $field) {
                if (isset($data[$field])) {
                    $userFields[] = "$field = ?";
                    $userParams[] = $data[$field];
                    $types .= 's';
                }
            }
            
            if (!empty($userFields)) {
                $userQuery = "UPDATE users SET " . implode(', ', $userFields) . " WHERE id = ?";
                $userParams[] = $id;
                $types .= 'i';
                
                $stmt = $this->conn->prepare($userQuery);
                $stmt->execute($userParams);
            }
            
            // Mettre à jour le profil étudiant
            $profileFields = [];
            $profileParams = [];
            $types = '';
            
            $updatableProfileFields = ['current_level', 'student_status', 'admission_type', 'scholarship_status', 
                                      'scholarship_details', 'gpa', 'total_credits_earned', 'class_rank', 
                                      'honors', 'disciplinary_records', 'graduation_thesis_title', 'thesis_supervisor'];
            foreach ($updatableProfileFields as $field) {
                if (isset($data[$field])) {
                    $profileFields[] = "$field = ?";
                    $profileParams[] = $data[$field];
                    $types .= 's';
                }
            }
            
            if (!empty($profileFields)) {
                $profileQuery = "UPDATE student_profiles SET " . implode(', ', $profileFields) . " WHERE user_id = ?";
                $profileParams[] = $id;
                $types .= 'i';
                
                $stmt = $this->conn->prepare($profileQuery);
                $stmt->execute($profileParams);
            }
            
            $this->conn->commit();
            
            return [
                'success' => true,
                'message' => 'Étudiant mis à jour avec succès',
                'data' => $this->getStudentById($id)
            ];
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Supprimer/désactiver un étudiant
     */
    public function deleteStudent($id) {
        try {
            $this->conn->beginTransaction();
            
            // Désactiver le compte utilisateur
            $query = "UPDATE users SET account_status = 'deleted', deleted_at = NOW() WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id]);
            
            $this->conn->commit();
            
            return [
                'success' => true,
                'message' => 'Étudiant supprimé avec succès'
            ];
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Récupérer les statistiques des étudiants
     */
    public function getStudentStats($institutionId = null, $facultyId = null, $departmentId = null, 
                                 $programId = null, $academicYearId = null) {
        $conditions = [];
        $params = [];
        $types = '';
        
        if ($institutionId) {
            $conditions[] = "u.institution_id = ?";
            $params[] = $institutionId;
            $types .= 'i';
        }
        
        if ($facultyId) {
            $conditions[] = "f.id = ?";
            $params[] = $facultyId;
            $types .= 'i';
        }
        
        if ($departmentId) {
            $conditions[] = "d.id = ?";
            $params[] = $departmentId;
            $types .= 'i';
        }
        
        if ($programId) {
            $conditions[] = "p.id = ?";
            $params[] = $programId;
            $types .= 'i';
        }
        
        if ($academicYearId) {
            $conditions[] = "sp.academic_year_id = ?";
            $params[] = $academicYearId;
            $types .= 'i';
        }
        
        $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
        
        $query = "SELECT 
                    COUNT(*) as total_students,
                    COUNT(CASE WHEN sp.student_status = 'enrolled' THEN 1 END) as enrolled_students,
                    COUNT(CASE WHEN sp.student_status = 'graduated' THEN 1 END) as graduated_students,
                    COUNT(CASE WHEN sp.student_status = 'withdrawn' THEN 1 END) as withdrawn_students,
                    COUNT(CASE WHEN sp.student_status = 'suspended' THEN 1 END) as suspended_students,
                    COUNT(CASE WHEN sp.student_status = 'deferred' THEN 1 END) as deferred_students,
                    AVG(sp.gpa) as average_gpa,
                    COUNT(CASE WHEN sp.gpa >= 3.5 THEN 1 END) as excellent_students,
                    COUNT(CASE WHEN sp.gpa >= 3.0 AND sp.gpa < 3.5 THEN 1 END) as good_students,
                    COUNT(CASE WHEN sp.gpa >= 2.5 AND sp.gpa < 3.0 THEN 1 END) as average_students,
                    COUNT(CASE WHEN sp.gpa < 2.5 THEN 1 END) as poor_students,
                    COUNT(CASE WHEN u.gender = 'male' THEN 1 END) as male_students,
                    COUNT(CASE WHEN u.gender = 'female' THEN 1 END) as female_students,
                    COUNT(CASE WHEN sp.scholarship_status != 'none' THEN 1 END) as scholarship_students,
                    COUNT(CASE WHEN sp.current_level LIKE 'licence%' THEN 1 END) as undergraduate_students,
                    COUNT(CASE WHEN sp.current_level LIKE 'master%' THEN 1 END) as graduate_students,
                    COUNT(CASE WHEN sp.current_level LIKE 'doctorat%' THEN 1 END) as doctoral_students
                FROM users u
                INNER JOIN student_profiles sp ON u.id = sp.user_id
                INNER JOIN institutions i ON u.institution_id = i.id
                INNER JOIN faculties f ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id IN (
                        SELECT id FROM departments WHERE faculty_id = f.id
                    )
                )
                INNER JOIN departments d ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id = d.id
                )
                INNER JOIN programs p ON sp.program_id = p.id
                $whereClause";
        
        $stmt = $this->conn->prepare($query);
        if (!empty($params)) {
            $stmt->execute($params);
        } else {
            $stmt->execute();
        }
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Récupérer les inscriptions d'un étudiant
     */
    public function getStudentEnrollments($studentId) {
        $query = "SELECT 
                    se.*,
                    p.name as program_name,
                    p.short_name as program_short_name,
                    ay.year_code as academic_year,
                    ay.start_date as academic_year_start,
                    ay.end_date as academic_year_end
                FROM student_enrollments se
                INNER JOIN programs p ON se.program_id = p.id
                INNER JOIN academic_years ay ON se.academic_year_id = ay.id
                WHERE se.student_profile_id = (SELECT id FROM student_profiles WHERE user_id = ?)
                ORDER BY se.academic_year_id DESC, se.semester DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$studentId]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Récupérer les résultats académiques d'un étudiant
     */
    public function getStudentAcademicRecords($studentId) {
        $query = "SELECT 
                    ar.*,
                    ay.year_code as academic_year
                FROM academic_records ar
                INNER JOIN academic_years ay ON ar.academic_year_id = ay.id
                WHERE ar.student_profile_id = (SELECT id FROM student_profiles WHERE user_id = ?)
                ORDER BY ar.academic_year_id DESC, ar.semester DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$studentId]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Récupérer les documents d'un étudiant
     */
    public function getStudentDocuments($studentId) {
        $query = "SELECT 
                    sd.*,
                    CONCAT(u.first_name, ' ', u.last_name) as verified_by_name
                FROM student_documents sd
                LEFT JOIN users u ON sd.verified_by = u.id
                WHERE sd.student_profile_id = (SELECT id FROM student_profiles WHERE user_id = ?)
                ORDER BY sd.upload_date DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$studentId]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Récupérer les bourses d'un étudiant
     */
    public function getStudentScholarships($studentId) {
        $query = "SELECT *
                FROM student_scholarships
                WHERE student_profile_id = (SELECT id FROM student_profiles WHERE user_id = ?)
                ORDER BY created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$studentId]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Récupérer les incidents disciplinaires d'un étudiant
     */
    public function getStudentDisciplineRecords($studentId) {
        $query = "SELECT 
                    sd.*,
                    CONCAT(u.first_name, ' ', u.last_name) as reported_by_name
                FROM student_discipline sd
                LEFT JOIN users u ON sd.reported_by = u.id
                WHERE sd.student_profile_id = (SELECT id FROM student_profiles WHERE user_id = ?)
                ORDER BY sd.incident_date DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$studentId]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Exporter les étudiants pour CSV
     */
    public function exportStudents($institutionId = null, $facultyId = null, $departmentId = null, 
                                 $programId = null, $level = null, $status = null) {
        $conditions = [];
        $params = [];
        $types = '';
        
        // Même logique de filtres que getStudents()
        if ($institutionId) {
            $conditions[] = "u.institution_id = ?";
            $params[] = $institutionId;
            $types .= 'i';
        }
        
        if ($facultyId) {
            $conditions[] = "f.id = ?";
            $params[] = $facultyId;
            $types .= 'i';
        }
        
        if ($departmentId) {
            $conditions[] = "d.id = ?";
            $params[] = $departmentId;
            $types .= 'i';
        }
        
        if ($programId) {
            $conditions[] = "p.id = ?";
            $params[] = $programId;
            $types .= 'i';
        }
        
        if ($level) {
            $conditions[] = "sp.current_level = ?";
            $params[] = $level;
            $types .= 's';
        }
        
        if ($status) {
            $conditions[] = "sp.student_status = ?";
            $params[] = $status;
            $types .= 's';
        }
        
        $whereClause = !empty($conditions) ? 'WHERE ' . implode(' AND ', $conditions) : '';
        
        $query = "SELECT 
                    u.matricule,
                    u.last_name,
                    u.first_name,
                    u.email,
                    i.name as institution_name,
                    f.name as faculty_name,
                    d.name as department_name,
                    p.name as program_name,
                    sp.current_level,
                    sp.student_status,
                    sp.enrollment_date,
                    sp.gpa
                FROM users u
                INNER JOIN student_profiles sp ON u.id = sp.user_id
                INNER JOIN institutions i ON u.institution_id = i.id
                INNER JOIN faculties f ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id IN (
                        SELECT id FROM departments WHERE faculty_id = f.id
                    )
                )
                INNER JOIN departments d ON sp.program_id IN (
                    SELECT id FROM programs WHERE department_id = d.id
                )
                INNER JOIN programs p ON sp.program_id = p.id
                $whereClause
                ORDER BY u.last_name ASC, u.first_name ASC";
        
        $stmt = $this->conn->prepare($query);
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Générer un matricule unique
     */
    private function generateMatricule($institutionId) {
        do {
            $year = date('Y');
            $random = str_pad(mt_rand(1, 99999), 5, '0', STR_PAD_LEFT);
            $matricule = "STU{$year}{$random}";
            
            $query = "SELECT id FROM users WHERE matricule = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$matricule]);
            
            $exists = $stmt->rowCount() > 0;
        } while ($exists);
        
        return $matricule;
    }
    
    /**
     * Calculer la date d'obtention attendue
     */
    private function calculateExpectedGraduation($level, $enrollmentDate) {
        $durations = [
            'licence1' => 3,
            'licence2' => 2,
            'licence3' => 1,
            'master1' => 2,
            'master2' => 1,
            'doctorat1' => 3,
            'doctorat2' => 2,
            'doctorat3' => 1
        ];
        
        $duration = $durations[$level] ?? 3;
        return date('Y-m-d', strtotime($enrollmentDate . " +{$duration} years"));
    }
    
    /**
     * Obtenir le nombre de crédits requis par niveau
     */
    private function getCreditsRequired($level) {
        $credits = [
            'licence1' => 180,
            'licence2' => 120,
            'licence3' => 60,
            'master1' => 120,
            'master2' => 60,
            'doctorat1' => 180,
            'doctorat2' => 120,
            'doctorat3' => 60
        ];
        
        return $credits[$level] ?? 180;
    }
    
    /**
     * Générer un UUID
     */
    private function generateUUID() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
}
?>
