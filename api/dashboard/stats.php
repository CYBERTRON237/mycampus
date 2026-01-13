<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
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

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Vérifier si l'utilisateur est admin (level >= 80)
    $stmt = $db->prepare("SELECT r.level FROM roles r WHERE r.name = ?");
    $stmt->execute([$user['role']]); // Utiliser 'role' au lieu de 'primary_role'
    $roleLevel = $stmt->fetchColumn();
    
    if ($roleLevel === false || $roleLevel < 80) {
        echo json_encode([
            'success' => false,
            'message' => 'Accès non autorisé - niveau insuffisant'
        ]);
        exit;
    }
    
    // Statistiques utilisateurs
    $userStats = getUserStatistics($db);
    
    // Statistiques institutions
    $institutionStats = getInstitutionStatistics($db);
    
    // Statistiques facultés
    $facultyStats = getFacultyStatistics($db);
    
    // Statistiques départements
    $departmentStats = getDepartmentStatistics($db);
    
    // Statistiques programmes
    $programStats = getProgramStatistics($db);
    
    // Statistiques cours
    $courseStats = getCourseStatistics($db);
    
    // Statistiques opportunités
    $opportunityStats = getOpportunityStatistics($db);
    
    // Activités récentes
    $recentActivities = getRecentActivities($db);
    
    // Top institutions
    $topInstitutions = getTopInstitutions($db);
    
    // Top facultés
    $topFaculties = getTopFaculties($db);
    
    // Top programmes
    $topPrograms = getTopPrograms($db);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'total_users' => $userStats['total_users'],
            'students' => $userStats['students'],
            'teachers' => $userStats['teachers'],
            'admins' => $userStats['admins'],
            'active_students' => $userStats['active_students'],
            'active_teachers' => $userStats['active_teachers'],
            'new_this_month' => $userStats['new_this_month'],
            'growth_rate' => $userStats['growth_rate'],
            
            'total' => $institutionStats['total'],
            'new_this_month' => $institutionStats['new_this_month'],
            'growth_rate' => $institutionStats['growth_rate'],
            'top_institutions' => $topInstitutions,
            
            'total' => $facultyStats['total'],
            'top_faculties' => $topFaculties,
            
            'total' => $departmentStats['total'],
            
            'total' => $programStats['total'],
            'top_programs' => $topPrograms,
            
            'total' => $courseStats['total'],
            'active_courses' => $courseStats['active_courses'],
            'new_this_month' => $courseStats['new_this_month'],
            'growth_rate' => $courseStats['growth_rate'],
            
            'total' => $opportunityStats['total'],
            'active_opportunities' => $opportunityStats['active_opportunities'],
            
            'recent_activities' => $recentActivities
        ]
    ]);
    
} catch (Exception $e) {
    error_log("Dashboard Stats Error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors du chargement des statistiques: ' . $e->getMessage()
    ]);
}

// Fonctions de statistiques
function getUserStatistics($db) {
    // Total par rôle
    $stmt = $db->query("SELECT primary_role, COUNT(*) as count FROM users GROUP BY primary_role");
    $usersByRole = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $usersByRole[$row['primary_role']] = (int)$row['count'];
    }
    
    $totalUsers = array_sum($usersByRole);
    $students = $usersByRole['student'] ?? 0;
    $teachers = $usersByRole['teacher'] ?? 0;
    $admins = ($usersByRole['admin_local'] ?? 0) + ($usersByRole['admin_national'] ?? 0) + ($usersByRole['superadmin'] ?? 0);
    
    // Utilisateurs actifs (connexion dans les 30 derniers jours)
    $stmt = $db->query("SELECT primary_role, COUNT(*) as count FROM users WHERE last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) GROUP BY primary_role");
    $activeUsersByRole = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $activeUsersByRole[$row['primary_role']] = (int)$row['count'];
    }
    
    $activeStudents = $activeUsersByRole['student'] ?? 0;
    $activeTeachers = $activeUsersByRole['teacher'] ?? 0;
    
    // Nouveaux utilisateurs ce mois
    $stmt = $db->query("SELECT COUNT(*) as count FROM users WHERE created_at >= DATE_FORMAT(NOW(), '%Y-%m-01')");
    $newThisMonth = (int)$stmt->fetchColumn();
    
    // Taux de croissance
    $stmt = $db->query("
        SELECT 
            COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as this_month,
            COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') - INTERVAL 1 MONTH 
                       AND created_at < DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as last_month
        FROM users
    ");
    $growthData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $thisMonth = (int)$growthData['this_month'];
    $lastMonth = (int)$growthData['last_month'];
    $growthRate = $lastMonth > 0 ? (($thisMonth - $lastMonth) / $lastMonth) * 100 : 0;
    
    return [
        'total_users' => $totalUsers,
        'students' => $students,
        'teachers' => $teachers,
        'admins' => $admins,
        'active_students' => $activeStudents,
        'active_teachers' => $activeTeachers,
        'new_this_month' => $newThisMonth,
        'growth_rate' => round($growthRate, 2)
    ];
}

function getInstitutionStatistics($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM institutions");
    $total = (int)$stmt->fetchColumn();
    
    $stmt = $db->query("SELECT COUNT(*) as count FROM institutions WHERE created_at >= DATE_FORMAT(NOW(), '%Y-%m-01')");
    $newThisMonth = (int)$stmt->fetchColumn();
    
    return [
        'total' => $total,
        'new_this_month' => $newThisMonth,
        'growth_rate' => 0.0 // Simplifié
    ];
}

function getFacultyStatistics($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM faculties");
    $total = (int)$stmt->fetchColumn();
    
    return ['total' => $total];
}

function getDepartmentStatistics($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM departments");
    $total = (int)$stmt->fetchColumn();
    
    return ['total' => $total];
}

function getProgramStatistics($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM programs");
    $total = (int)$stmt->fetchColumn();
    
    return ['total' => $total];
}

function getCourseStatistics($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM courses");
    $total = (int)$stmt->fetchColumn();
    
    $stmt = $db->query("SELECT COUNT(*) as count FROM courses WHERE is_active = 1");
    $activeCourses = (int)$stmt->fetchColumn();
    
    $stmt = $db->query("SELECT COUNT(*) as count FROM courses WHERE created_at >= DATE_FORMAT(NOW(), '%Y-%m-01')");
    $newThisMonth = (int)$stmt->fetchColumn();
    
    return [
        'total' => $total,
        'active_courses' => $activeCourses,
        'new_this_month' => $newThisMonth,
        'growth_rate' => 0.0 // Simplifié
    ];
}

function getOpportunityStatistics($db) {
    $stmt = $db->query("SELECT COUNT(*) as count FROM opportunities");
    $total = (int)$stmt->fetchColumn();
    
    $stmt = $db->query("SELECT COUNT(*) as count FROM opportunities WHERE status = 'active'");
    $activeOpportunities = (int)$stmt->fetchColumn();
    
    return [
        'total' => $total,
        'active_opportunities' => $activeOpportunities
    ];
}

function getRecentActivities($db) {
    $activities = [];
    
    // Récupérer les 10 dernières inscriptions
    $stmt = $db->prepare("
        SELECT u.id, u.first_name, u.last_name, u.email, u.primary_role, u.created_at
        FROM users u 
        ORDER BY u.created_at DESC 
        LIMIT 10
    ");
    $stmt->execute();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $activities[] = [
            'id' => (string)$row['id'],
            'description' => "Nouvel utilisateur: {$row['first_name']} {$row['last_name']}",
            'created_at' => date('Y-m-d H:i:s', strtotime($row['created_at']))
        ];
    }
    
    return $activities;
}

function getTopInstitutions($db) {
    $institutions = [];
    
    $stmt = $db->prepare("
        SELECT i.id, i.name, COUNT(f.id) as faculty_count
        FROM institutions i
        LEFT JOIN faculties f ON i.id = f.institution_id
        GROUP BY i.id, i.name
        ORDER BY faculty_count DESC
        LIMIT 5
    ");
    $stmt->execute();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $institutions[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'count' => (int)$row['faculty_count']
        ];
    }
    
    return $institutions;
}

function getTopFaculties($db) {
    $faculties = [];
    
    $stmt = $db->prepare("
        SELECT f.id, f.name, COUNT(p.id) as program_count
        FROM faculties f
        LEFT JOIN programs p ON f.id = p.faculty_id
        GROUP BY f.id, f.name
        ORDER BY program_count DESC
        LIMIT 5
    ");
    $stmt->execute();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $faculties[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'count' => (int)$row['program_count']
        ];
    }
    
    return $faculties;
}

function getTopPrograms($db) {
    $programs = [];
    
    $stmt = $db->prepare("
        SELECT p.id, p.name, COUNT(u.id) as student_count
        FROM programs p
        LEFT JOIN users u ON p.id = u.program_id
        GROUP BY p.id, p.name
        ORDER BY student_count DESC
        LIMIT 5
    ");
    $stmt->execute();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $programs[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'count' => (int)$row['student_count']
        ];
    }
    
    return $programs;
}
?>
