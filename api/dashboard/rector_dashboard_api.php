<?php
/**
 * API Dashboard Rector - MyCampus
 * Récupère toutes les données nécessaires pour le dashboard du recteur
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../vendor/autoload.php';
require_once '../../config/database.php';

class RectorDashboardAPI {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    /**
     * Récupère toutes les statistiques pour le dashboard rector
     */
    public function getDashboardStats() {
        try {
            $stats = [
                'preinscriptions' => $this->getPreinscriptionsStats(),
                'students' => $this->getStudentsStats(),
                'staff' => $this->getStaffStats(),
                'faculties' => $this->getFacultiesStats(),
                'departments' => $this->getDepartmentsStats(),
                'programs' => $this->getProgramsStats(),
                'courses' => $this->getCoursesStats(),
                'institutions' => $this->getInstitutionsStats(),
                'academic_oversight' => $this->getAcademicOversightStats(),
                'recent_activities' => $this->getRecentActivities(),
                'compliance_reports' => $this->getComplianceReportsStats()
            ];
            
            return $this->success('Statistiques récupérées avec succès', $stats);
            
        } catch (Exception $e) {
            return $this->error('Erreur lors de la récupération des statistiques: ' . $e->getMessage());
        }
    }
    
    /**
     * Statistiques des préinscriptions
     */
    private function getPreinscriptionsStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted,
                SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
                SUM(CASE WHEN status = 'under_review' THEN 1 ELSE 0 END) as under_review,
                SUM(CASE WHEN DATE(created_at) = CURDATE() THEN 1 ELSE 0 END) as today,
                SUM(CASE WHEN DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 ELSE 0 END) as this_week,
                SUM(CASE WHEN DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as this_month
            FROM preinscriptions 
            WHERE deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Répartition par faculté
        $facultyQuery = "
            SELECT faculty, COUNT(*) as count
            FROM preinscriptions 
            WHERE deleted_at IS NULL
            GROUP BY faculty
            ORDER BY count DESC
        ";
        $facultyStmt = $this->pdo->query($facultyQuery);
        $result['by_faculty'] = $facultyStmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $result;
    }
    
    /**
     * Statistiques des étudiants
     */
    private function getStudentsStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN account_status = 'active' THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN account_status = 'pending_verification' THEN 1 ELSE 0 END) as pending,
                SUM(CASE WHEN account_status = 'suspended' THEN 1 ELSE 0 END) as suspended,
                SUM(CASE WHEN account_status = 'graduated' THEN 1 ELSE 0 END) as graduated,
                SUM(CASE WHEN DATE(created_at) = CURDATE() THEN 1 ELSE 0 END) as today,
                SUM(CASE WHEN DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 ELSE 0 END) as this_week,
                SUM(CASE WHEN DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as this_month
            FROM users 
            WHERE primary_role = 'student' 
            AND deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Répartition par niveau
        $levelQuery = "
            SELECT level, COUNT(*) as count
            FROM users 
            WHERE primary_role = 'student' 
            AND deleted_at IS NULL
            GROUP BY level
            ORDER BY count DESC
        ";
        $levelStmt = $this->pdo->query($levelQuery);
        $result['by_level'] = $levelStmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $result;
    }
    
    /**
     * Statistiques du personnel
     */
    private function getStaffStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN primary_role IN ('teacher', 'professor_titular', 'professor_associate', 'master_conference', 'course_holder', 'assistant', 'monitor') THEN 1 ELSE 0 END) as teaching_staff,
                SUM(CASE WHEN primary_role IN ('admin_local', 'admin_national', 'superadmin', 'rector', 'vice_rector', 'secretary_general', 'dean', 'school_director', 'institute_director', 'department_head', 'section_head', 'program_coordinator') THEN 1 ELSE 0 END) as administrative_staff,
                SUM(CASE WHEN primary_role IN ('staff', 'administrative_agent', 'secretary', 'accountant', 'librarian', 'lab_technician', 'maintenance_engineer', 'security_agent', 'cleaning_staff', 'driver', 'it_support') THEN 1 ELSE 0 END) as support_staff,
                SUM(CASE WHEN account_status = 'active' THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN account_status = 'inactive' THEN 1 ELSE 0 END) as inactive
            FROM users 
            WHERE primary_role != 'student' 
            AND primary_role != 'invite'
            AND deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Répartition par rôle
        $roleQuery = "
            SELECT primary_role, COUNT(*) as count
            FROM users 
            WHERE primary_role != 'student' 
            AND primary_role != 'invite'
            AND deleted_at IS NULL
            GROUP BY primary_role
            ORDER BY count DESC
            LIMIT 10
        ";
        $roleStmt = $this->pdo->query($roleQuery);
        $result['by_role'] = $roleStmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $result;
    }
    
    /**
     * Statistiques des facultés
     */
    private function getFacultiesStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive
            FROM faculties 
            WHERE deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Liste des facultés avec nombre d'étudiants
        $facultyDetailsQuery = "
            SELECT 
                f.id, f.name, f.code, f.is_active,
                COUNT(u.id) as student_count
            FROM faculties f
            LEFT JOIN users u ON f.id = u.department_id 
                AND u.primary_role = 'student' 
                AND u.deleted_at IS NULL
            WHERE f.deleted_at IS NULL
            GROUP BY f.id, f.name, f.code, f.is_active
            ORDER BY student_count DESC
        ";
        $facultyDetailsStmt = $this->pdo->query($facultyDetailsQuery);
        $result['faculties_details'] = $facultyDetailsStmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $result;
    }
    
    /**
     * Statistiques des départements
     */
    private function getDepartmentsStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive
            FROM departments 
            WHERE deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Statistiques des programmes
     */
    private function getProgramsStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive,
                SUM(CASE WHEN type = 'LICENCE' THEN 1 ELSE 0 END) as licence,
                SUM(CASE WHEN type = 'MASTER' THEN 1 ELSE 0 END) as master,
                SUM(CASE WHEN type = 'DOCTORAT' THEN 1 ELSE 0 END) as doctorat,
                SUM(CASE WHEN type = 'DUT' THEN 1 ELSE 0 END) as dut,
                SUM(CASE WHEN type = 'BTS' THEN 1 ELSE 0 END) as bts
            FROM programs 
            WHERE deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Programmes par faculté
        $programsByFacultyQuery = "
            SELECT 
                f.name as faculty_name,
                COUNT(p.id) as program_count
            FROM programs p
            JOIN faculties f ON p.faculty_id = f.id
            WHERE p.deleted_at IS NULL AND f.deleted_at IS NULL
            GROUP BY f.id, f.name
            ORDER BY program_count DESC
        ";
        $programsByFacultyStmt = $this->pdo->query($programsByFacultyQuery);
        $result['by_faculty'] = $programsByFacultyStmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $result;
    }
    
    /**
     * Statistiques des cours
     */
    private function getCoursesStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive,
                SUM(CASE WHEN credit_hours > 0 THEN credit_hours ELSE 0 END) as total_credit_hours
            FROM courses 
            WHERE deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Statistiques des institutions
     */
    private function getInstitutionsStats() {
        $query = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active,
                SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive,
                SUM(CASE WHEN type = 'UNIVERSITY' THEN 1 ELSE 0 END) as universities,
                SUM(CASE WHEN type = 'INSTITUTE' THEN 1 ELSE 0 END) as institutes,
                SUM(CASE WHEN type = 'SCHOOL' THEN 1 ELSE 0 END) as schools
            FROM institutions 
            WHERE deleted_at IS NULL
        ";
        
        $stmt = $this->pdo->query($query);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Statistiques de supervision académique
     */
    private function getAcademicOversightStats() {
        return [
            'active_programs' => $this->getActiveProgramsCount(),
            'research_projects' => $this->getResearchProjectsCount(),
            'international_partnerships' => $this->getInternationalPartnershipsCount(),
            'accreditations' => $this->getAccreditationsCount()
        ];
    }
    
    private function getActiveProgramsCount() {
        $stmt = $this->pdo->query("SELECT COUNT(*) as count FROM programs WHERE is_active = 1 AND deleted_at IS NULL");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['count'] ?? 15; // Valeur par défaut si pas de données
    }
    
    private function getResearchProjectsCount() {
        // Pour l'instant, valeur simulée - à implémenter avec une table research_projects
        return 42;
    }
    
    private function getInternationalPartnershipsCount() {
        // Pour l'instant, valeur simulée - à implémenter avec une table partnerships
        return 28;
    }
    
    private function getAccreditationsCount() {
        // Pour l'instant, valeur simulée - à implémenter avec une table accreditations
        return 12;
    }
    
    /**
     * Activités récentes
     */
    private function getRecentActivities() {
        $activities = [];
        
        // Préinscriptions récentes
        $preinscriptionsQuery = "
            SELECT 'Nouvelles préinscriptions' as title,
                   COUNT(*) as count,
                   'en attente de validation' as description,
                   'person_add' as icon,
                   'orange' as color
            FROM preinscriptions 
            WHERE status = 'pending' 
            AND deleted_at IS NULL
            AND DATE(created_at) = CURDATE()
        ";
        $stmt = $this->pdo->query($preinscriptionsQuery);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result['count'] > 0) {
            $activities[] = $result;
        }
        
        // Réunions planifiées (simulé)
        $activities[] = [
            'title' => 'Réunion du Conseil',
            'count' => 1,
            'description' => 'Prévue le 25 Décembre 2024',
            'icon' => 'groups',
            'color' => 'blue'
        ];
        
        // Audits planifiés (simulé)
        $activities[] = [
            'title' => 'Audit Ministériel',
            'count' => 1,
            'description' => 'Visite prévue le 2 Janvier 2025',
            'icon' => 'verified',
            'color' => 'green'
        ];
        
        // Nouveaux programmes en attente
        $programsQuery = "
            SELECT 'Nouveaux programmes' as title,
                   COUNT(*) as count,
                   'en cours d\'approbation' as description,
                   'menu_book' as icon,
                   'purple' as color
            FROM programs 
            WHERE is_active = 0 
            AND deleted_at IS NULL
        ";
        $stmt = $this->pdo->query($programsQuery);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result['count'] > 0) {
            $activities[] = $result;
        }
        
        return $activities;
    }
    
    /**
     * Statistiques des rapports de conformité
     */
    private function getComplianceReportsStats() {
        return [
            'annual_report' => [
                'title' => 'Rapport Annuel',
                'description' => 'État des lieux de l\'université',
                'icon' => 'description',
                'status' => 'available'
            ],
            'financial_audit' => [
                'title' => 'Audit Financier',
                'description' => 'Validation des comptes et budgets',
                'icon' => 'account_balance_wallet',
                'status' => 'in_progress'
            ],
            'academic_performance' => [
                'title' => 'Performance Académique',
                'description' => 'Statistiques et indicateurs',
                'icon' => 'analytics',
                'status' => 'available'
            ],
            'regulatory_compliance' => [
                'title' => 'Conformité Réglementaire',
                'description' => 'Respect des normes ministérielles',
                'icon' => 'gavel',
                'status' => 'pending'
  '
            ]

       flutter: ' ],
       诸 '-subsection ' ];
    }
    
    /**
     * Réponse de succès
     */
    private function success($message, $data = null) {
        http_response_code(200);
        return [
            'success' => true,
            'message' => $message,
            'data' => $data,
            'timestamp' => date('Y-m-d H:i:s')
        ];
    }
    
    /**
     * Réponse d'erreur
     */
    private function error($message) {
        http_response_code(500);
        return [
            'success' => false,
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];
    }
}

// Vérification de la méthode HTTP
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

try {
    // Connexion à la base de données
    $database = new Database();
    $pdo = $database->getConnection();
    
    // Création de l'instance API
    $api = new RectorDashboardAPI($pdo);
    
    // Récupération des statistiques
    $response = $api->getDashboardStats();
    
    // Envoi de la réponse
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
?>
