<?php
/**
 * Point d'entrée API Dashboard Rector
 * MyCampus - Système de Gestion Universitaire
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Router simple pour les endpoints dashboard
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);

// Nettoyage du chemin
$path = str_replace('/mycampus/api/dashboard', '', $path);
$path = trim($path, '/');

try {
    switch ($path) {
        case 'rector':
        case 'rector/stats':
        case '':
            // Inclure le fichier API principal du rector
            require_once 'rector_dashboard_api.php';
            break;
            
        default:
            // Pour les autres endpoints, utiliser le dashboard général existant
            require_once '../../config/database.php';
            require_once '../../vendor/autoload.php';
            require_once '../middleware/auth.php';
            
            // Vérifier l'authentification
            $auth = new Auth();
            $user = $auth->getCurrentUser();
            
            if (!$user) {
                echo json_encode([
                    'success' => false,
                    'message' => 'Non authentifié'
                ]);
                exit;
            }
            
            $database = new Database();
            $db = $database->getConnection();
            
            // Données de l'utilisateur actuel
            $userData = [
                'id' => $user['id'],
                'uuid' => $user['uuid'],
                'email' => $user['email'],
                'first_name' => $user['first_name'],
                'last_name' => $user['last_name'],
                'primary_role' => $user['primary_role'],
                'account_status' => $user['account_status'],
                'institution_id' => $user['institution_id'],
                'department_id' => $user['department_id'],
                'last_login_at' => $user['last_login_at'],
                'is_active' => $user['is_active']
            ];
            
            // Statistiques simples
            $stats = [
                'total_users' => getTotalUsers($db),
                'active_users' => getActiveUsers($db),
                'total_students' => getTotalStudents($db),
                'total_teachers' => getTotalTeachers($db),
                'total_admins' => getTotalAdmins($db),
                'new_users_today' => getNewUsersToday($db)
            ];
            
            // Activités récentes
            $recentActivities = getRecentActivities($db, 10);
            
            echo json_encode([
                'success' => true,
                'message' => 'Dashboard chargé avec succès',
                'user' => $userData,
                'stats' => $stats,
                'recent_activities' => $recentActivities,
                'active_groups' => [],
                'recent_opportunities' => []
            ]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}

// Fonctions utilitaires pour le dashboard général
function getTotalUsers($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM users");
    return $stmt->fetch(PDO::FETCH_ASSOC)['count'];
}

function getActiveUsers($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM users WHERE is_active = 1 AND account_status = 'active'");
    return $stmt->fetch(PDO::FETCH_ASSOC)['count'];
}

function getTotalStudents($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM users WHERE primary_role = 'student'");
    return $stmt->fetch(PDO::FETCH_ASSOC)['count'];
}

function getTotalTeachers($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM users WHERE primary_role = 'teacher'");
    return $stmt->fetch(PDO::FETCH_ASSOC)['count'];
}

function getTotalAdmins($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM users WHERE primary_role IN ('admin_local', 'admin_national', 'superadmin')");
    return $stmt->fetch(PDO::FETCH_ASSOC)['count'];
}

function getNewUsersToday($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM users WHERE DATE(created_at) = CURDATE()");
    return $stmt->fetch(PDO::FETCH_ASSOC)['count'];
}

function getRecentActivities($db, $limit = 10) {
    // Simuler des activités récentes
    $activities = [];
    $types = ['connexion', 'inscription', 'modification', 'suppression'];
    $descriptions = [
        'connexion' => 's\'est connecté',
        'inscription' => 'a créé un compte',
        'modification' => 'a modifié son profil',
        'suppression' => 'a supprimé un élément'
    ];
    
    for ($i = 0; $i < min($limit, 5); $i++) {
        $type = $types[array_rand($types)];
        $activities[] = [
            'id' => $i + 1,
            'type' => $type,
            'description' => $descriptions[$type],
            'user_name' => 'Utilisateur ' . ($i + 1),
            'created_at' => date('Y-m-d H:i:s', strtotime('-' . ($i * 2) . ' hours')),
            'icon' => 'person'
        ];
    }
    
    return $activities;
}
?>
