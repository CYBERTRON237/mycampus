<?php
/**
 * Test API Dashboard Rector
 * Fichier de test pour vérifier le bon fonctionnement de l'API
 */

// Configuration des headers pour les tests
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config/database.php';

class RectorDashboardTest {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    /**
     * Test de connexion à la base de données
     */
    public function testDatabaseConnection() {
        try {
            $stmt = $this->pdo->query("SELECT 1 as test");
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return [
                'success' => true,
                'message' => 'Connexion à la base de données réussie',
                'data' => $result
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Erreur de connexion: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Test des statistiques des préinscriptions
     */
    public function testPreinscriptionsStats() {
        try {
            $query = "
                SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                    SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted,
                    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected
                FROM preinscriptions 
                WHERE deleted_at IS NULL
            ";
            
            $stmt = $this->pdo->query($query);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return [
                'success' => true,
                'message' => 'Statistiques préinscriptions récupérées',
                'data' => $result
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Erreur préinscriptions: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Test des statistiques des utilisateurs
     */
    public function testUsersStats() {
        try {
            $query = "
                SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN primary_role = 'student' THEN 1 ELSE 0 END) as students,
                    SUM(CASE WHEN primary_role IN ('teacher', 'professor_titular', 'professor_associate', 'master_conference', 'course_holder', 'assistant', 'monitor') THEN 1 ELSE 0 END) as teaching_staff,
                    SUM(CASE WHEN primary_role IN ('admin_local', 'admin_national', 'superadmin', 'rector', 'vice_rector', 'secretary_general', 'dean', 'school_director', 'institute_director', 'department_head', 'section_head', 'program_coordinator') THEN 1 ELSE 0 END) as administrative_staff
                FROM users 
                WHERE deleted_at IS NULL
            ";
            
            $stmt = $this->pdo->query($query);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return [
                'success' => true,
                'message' => 'Statistiques utilisateurs récupérées',
                'data' => $result
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Erreur utilisateurs: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Test des statistiques des facultés
     */
    public function testFacultiesStats() {
        try {
            $query = "
                SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active
                FROM faculties 
                WHERE deleted_at IS NULL
            ";
            
            $stmt = $this->pdo->query($query);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return [
                'success' => true,
                'message' => 'Statistiques facultés récupérées',
                'data' => $result
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Erreur facultés: ' . $e->getMessage()
            ];
        }
    }
    
    /**
     * Test de l'API complète
     */
    public function runFullTest() {
        $results = [];
        
        // Test connexion BDD
        $results['database_connection'] = $this->testDatabaseConnection();
        
        // Test préinscriptions
        $results['preinscriptions'] = $this->testPreinscriptionsStats();
        
        // Test utilisateurs
        $results['users'] = $this->testUsersStats();
        
        // Test facultés
        $results['faculties'] = $this->testFacultiesStats();
        
        // Calcul du succès global
        $successCount = 0;
        $totalCount = count($results);
        
        foreach ($results as $test) {
            if ($test['success']) {
                $successCount++;
            }
        }
        
        return [
            'success' => $successCount === $totalCount,
            'message' => "Tests terminés: $successCount/$totalCount réussis",
            'summary' => [
                'total_tests' => $totalCount,
                'successful_tests' => $successCount,
                'failed_tests' => $totalCount - $successCount,
                'success_rate' => $totalCount > 0 ? round(($successCount / $totalCount) * 100, 2) : 0
            ],
            'results' => $results,
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
    
    // Création de l'instance de test
    $tester = new RectorDashboardTest($pdo);
    
    // Exécution des tests
    $testResults = $tester->runFullTest();
    
    // Envoi des résultats
    echo json_encode($testResults, JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
?>
