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

class ProgramStatisticsController {
    private $pdo;

    public function __construct() {
        $database = new Database();
        $this->pdo = $database->getConnection();
    }

    public function handleRequest() {
        try {
            $departmentId = $_GET['department_id'] ?? null;
            $facultyId = $_GET['faculty_id'] ?? null;
            $institutionId = $_GET['institution_id'] ?? null;

            $statistics = $this->getStatistics($departmentId, $facultyId, $institutionId);
            $this->sendSuccess($statistics);
        } catch (Exception $e) {
            $this->sendError($e->getMessage());
        }
    }

    private function getStatistics($departmentId, $facultyId, $institutionId) {
        $whereClause = "WHERE 1=1";
        $params = [];

        if ($departmentId) {
            $whereClause .= " AND p.department_id = ?";
            $params[] = $departmentId;
        }

        if ($facultyId) {
            $whereClause .= " AND d.faculty_id = ?";
            $params[] = $facultyId;
        }

        if ($institutionId) {
            $whereClause .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }

        // Total programs
        $sql = "SELECT COUNT(*) as total 
                FROM programs p 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        // Programs by status
        $sql = "SELECT p.status, COUNT(*) as count 
                FROM programs p 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY p.status";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $byStatus = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byStatus[$row['status']] = (int)$row['count'];
        }

        // Programs by degree level
        $sql = "SELECT p.degree_level, COUNT(*) as count 
                FROM programs p 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY p.degree_level";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $byDegreeLevel = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byDegreeLevel[$row['degree_level']] = (int)$row['count'];
        }

        // Programs by department (if not filtered by department)
        $byDepartment = [];
        if (!$departmentId) {
            $sql = "SELECT d.id, d.name, COUNT(*) as count 
                    FROM programs p 
                    LEFT JOIN departments d ON p.department_id = d.id 
                    LEFT JOIN faculties f ON d.faculty_id = f.id 
                    $whereClause 
                    GROUP BY d.id, d.name 
                    ORDER BY count DESC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $byDepartment[$row['name']] = (int)$row['count'];
            }
        }

        // Programs by faculty (if not filtered by faculty)
        $byFaculty = [];
        if (!$facultyId) {
            $sql = "SELECT f.id, f.name, COUNT(*) as count 
                    FROM programs p 
                    LEFT JOIN departments d ON p.department_id = d.id 
                    LEFT JOIN faculties f ON d.faculty_id = f.id 
                    $whereClause 
                    GROUP BY f.id, f.name 
                    ORDER BY count DESC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $byFaculty[$row['name']] = (int)$row['count'];
            }
        }

        // Programs by institution (if not filtered by institution)
        $byInstitution = [];
        if (!$institutionId) {
            $sql = "SELECT i.id, i.name, COUNT(*) as count 
                    FROM programs p 
                    LEFT JOIN departments d ON p.department_id = d.id 
                    LEFT JOIN faculties f ON d.faculty_id = f.id 
                    LEFT JOIN institutions i ON f.institution_id = i.id 
                    $whereClause 
                    GROUP BY i.id, i.name 
                    ORDER BY count DESC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $byInstitution[$row['name']] = (int)$row['count'];
            }
        }

        // Average duration
        $sql = "SELECT AVG(p.duration_years) as avg_duration 
                FROM programs p 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $avgDuration = $stmt->fetchColumn() ?: 0;

        return [
            'total' => (int)$total,
            'by_status' => $byStatus,
            'by_degree_level' => $byDegreeLevel,
            'by_department' => $byDepartment,
            'by_faculty' => $byFaculty,
            'by_institution' => $byInstitution,
            'average_duration_years' => round((float)$avgDuration, 1),
            'active_programs' => $byStatus['active'] ?? 0,
            'inactive_programs' => $byStatus['inactive'] ?? 0,
            'suspended_programs' => $byStatus['suspended'] ?? 0,
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
$controller = new ProgramStatisticsController();
$controller->handleRequest();
?>
