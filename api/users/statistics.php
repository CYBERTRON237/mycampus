<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';

class UserStatisticsController {
    private $pdo;

    public function __construct() {
        $database = new Database();
        $this->pdo = $database->getConnection();
    }

    public function handleRequest() {
        try {
            $statistics = $this->getStatistics();
            $this->sendSuccess($statistics);
        } catch (Exception $e) {
            $this->sendError($e->getMessage());
        }
    }

    private function getStatistics() {
        // Total users by role
        $sql = "SELECT primary_role, COUNT(*) as count FROM users GROUP BY primary_role";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $usersByRole = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $usersByRole[$row['primary_role']] = (int)$row['count'];
        }

        $totalUsers = array_sum($usersByRole);
        $totalStudents = $usersByRole['student'] ?? 0;
        $totalTeachers = $usersByRole['teacher'] ?? 0;
        $totalAdmins = ($usersByRole['admin_local'] ?? 0) + ($usersByRole['admin_national'] ?? 0) + ($usersByRole['superadmin'] ?? 0);

        // Active users (logged in within last 30 days)
        $sql = "SELECT primary_role, COUNT(*) as count 
                FROM users 
                WHERE last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) 
                GROUP BY primary_role";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $activeUsersByRole = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $activeUsersByRole[$row['primary_role']] = (int)$row['count'];
        }

        $activeStudents = $activeUsersByRole['student'] ?? 0;
        $activeTeachers = $activeUsersByRole['teacher'] ?? 0;

        // New users this month
        $sql = "SELECT COUNT(*) as count FROM users WHERE created_at >= DATE_FORMAT(NOW(), '%Y-%m-01')";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $newUsersThisMonth = (int)$stmt->fetchColumn();

        // Growth rate (users this month vs last month)
        $sql = "SELECT 
                  COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as this_month,
                  COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') - INTERVAL 1 MONTH 
                             AND created_at < DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as last_month
                FROM users";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $growthData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $thisMonth = (int)$growthData['this_month'];
        $lastMonth = (int)$growthData['last_month'];
        $userGrowthRate = $lastMonth > 0 ? (($thisMonth - $lastMonth) / $lastMonth) * 100 : 0;

        // Recent activities (last 10 user registrations)
        $sql = "SELECT u.id, u.first_name, u.last_name, u.email, u.primary_role, u.created_at,
                       CASE u.primary_role 
                           WHEN 'student' THEN 'Étudiant'
                           WHEN 'teacher' THEN 'Enseignant'
                           WHEN 'admin_local' THEN 'Administrateur Local'
                           WHEN 'admin_national' THEN 'Administrateur National'
                           WHEN 'superadmin' THEN 'Super Administrateur'
                           ELSE u.primary_role
                       END as role_display
                FROM users u 
                ORDER BY u.created_at DESC 
                LIMIT 10";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $recentActivities = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $recentActivities[] = [
                'id' => (string)$row['id'],
                'first_name' => $row['first_name'],
                'last_name' => $row['last_name'],
                'email' => $row['email'],
                'role' => $row['primary_role'],
                'role_display' => $row['role_display'],
                'created_at' => date('Y-m-d H:i:s', strtotime($row['created_at'])),
                'type' => 'user_registration',
                'description' => "{$row['role_display']} {$row['first_name']} {$row['last_name']} a rejoint la plateforme"
            ];
        }

        return [
            'total_users' => $totalUsers,
            'students' => $totalStudents,
            'teachers' => $totalTeachers,
            'admins' => $totalAdmins,
            'active_students' => $activeStudents,
            'active_teachers' => $activeTeachers,
            'new_this_month' => $newUsersThisMonth,
            'growth_rate' => round($userGrowthRate, 2),
            'recent_activities' => $recentActivities,
            'users_by_role' => $usersByRole,
            'active_users_by_role' => $activeUsersByRole,
        ];
    }

    private function sendSuccess($data, $message = 'Success') {
        $response = [
            'success' => true,
            'message' => $message,
            'data' => $data
        ];
        echo json_encode($response);
        exit;
    }

    private function sendError($message, $code = 400) {
        http_response_code($code);
        echo json_encode([
            'success' => false,
            'message' => $message
        ]);
        exit;
    }
}

// Handle request
$controller = new UserStatisticsController();
$controller->handleRequest();
?>
