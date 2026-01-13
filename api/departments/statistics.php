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

class DepartmentStatisticsController {
    private $pdo;

    public function __construct() {
        $database = new Database();
        $this->pdo = $database->getConnection();
    }

    public function handleRequest() {
        try {
            $facultyId = $_GET['faculty_id'] ?? null;
            $institutionId = $_GET['institution_id'] ?? null;

            $statistics = $this->getStatistics($facultyId, $institutionId);
            $this->sendSuccess($statistics);
        } catch (Exception $e) {
            $this->sendError($e->getMessage());
        }
    }

    private function getStatistics($facultyId, $institutionId) {
        $whereClause = "WHERE 1=1";
        $params = [];

        if ($facultyId) {
            $whereClause .= " AND d.faculty_id = ?";
            $params[] = $facultyId;
        }

        if ($institutionId) {
            $whereClause .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }

        // Total departments
        $sql = "SELECT COUNT(*) as total 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        // Departments by status
        $sql = "SELECT d.status, COUNT(*) as count 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY d.status";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $byStatus = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byStatus[$row['status']] = (int)$row['count'];
        }

        // Departments by level
        $sql = "SELECT d.level, COUNT(*) as count 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY d.level";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $byLevel = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byLevel[$row['level']] = (int)$row['count'];
        }

        // Departments by faculty (if not filtered by faculty)
        $byFaculty = [];
        if (!$facultyId) {
            $sql = "SELECT f.id, f.name, COUNT(*) as count 
                    FROM departments d 
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

        // Departments by institution (if not filtered by institution)
        $byInstitution = [];
        if (!$institutionId) {
            $sql = "SELECT i.id, i.name, COUNT(*) as count 
                    FROM departments d 
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

        // Departments with head of department
        $sql = "SELECT COUNT(*) as with_hod 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                AND d.head_of_department IS NOT NULL AND d.head_of_department != ''";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $withHod = $stmt->fetchColumn();

        // Departments with HOD email
        $sql = "SELECT COUNT(*) as with_hod_email 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                AND d.hod_email IS NOT NULL AND d.hod_email != ''";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $withHodEmail = $stmt->fetchColumn();

        // Departments with HOD phone
        $sql = "SELECT COUNT(*) as with_hod_phone 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                AND d.hod_phone IS NOT NULL AND d.hod_phone != ''";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $withHodPhone = $stmt->fetchColumn();

        return [
            'total' => (int)$total,
            'by_status' => $byStatus,
            'by_level' => $byLevel,
            'by_faculty' => $byFaculty,
            'by_institution' => $byInstitution,
            'active_departments' => $byStatus['active'] ?? 0,
            'inactive_departments' => $byStatus['inactive'] ?? 0,
            'undergraduate_departments' => $byLevel['undergraduate'] ?? 0,
            'graduate_departments' => $byLevel['graduate'] ?? 0,
            'postgraduate_departments' => $byLevel['postgraduate'] ?? 0,
            'departments_with_head' => (int)$withHod,
            'departments_with_head_email' => (int)$withHodEmail,
            'departments_with_head_phone' => (int)$withHodPhone,
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
$controller = new DepartmentStatisticsController();
$controller->handleRequest();
?>
