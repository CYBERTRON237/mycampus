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

class OpportunityStatisticsController {
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
        // Total opportunities
        $sql = "SELECT COUNT(*) as total FROM opportunities";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $total = (int)$stmt->fetchColumn();

        // Active opportunities
        $sql = "SELECT COUNT(*) as count FROM opportunities WHERE status = 'active'";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $activeOpportunities = (int)$stmt->fetchColumn();

        // New opportunities this month
        $sql = "SELECT COUNT(*) as count FROM opportunities WHERE created_at >= DATE_FORMAT(NOW(), '%Y-%m-01')";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $newThisMonth = (int)$stmt->fetchColumn();

        // Growth rate
        $sql = "SELECT 
                  COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as this_month,
                  COUNT(CASE WHEN created_at >= DATE_FORMAT(NOW(), '%Y-%m-01') - INTERVAL 1 MONTH 
                             AND created_at < DATE_FORMAT(NOW(), '%Y-%m-01') THEN 1 END) as last_month
                FROM opportunities";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $growthData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $thisMonth = (int)$growthData['this_month'];
        $lastMonth = (int)$growthData['last_month'];
        $growthRate = $lastMonth > 0 ? (($thisMonth - $lastMonth) / $lastMonth) * 100 : 0;

        // Opportunities by type
        $sql = "SELECT type, COUNT(*) as count FROM opportunities GROUP BY type";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $byType = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byType[$row['type']] = (int)$row['count'];
        }

        // Opportunities by scope
        $sql = "SELECT scope, COUNT(*) as count FROM opportunities GROUP BY scope";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        $byScope = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byScope[$row['scope']] = (int)$row['count'];
        }

        return [
            'total' => $total,
            'active_opportunities' => $activeOpportunities,
            'new_this_month' => $newThisMonth,
            'growth_rate' => round($growthRate, 2),
            'by_type' => $byType,
            'by_scope' => $byScope,
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
$controller = new OpportunityStatisticsController();
$controller->handleRequest();
?>
