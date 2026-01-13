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

class CourseStatisticsController {
    private $pdo;

    public function __construct() {
        $database = new Database();
        $this->pdo = $database->getConnection();
    }

    public function handleRequest() {
        try {
            $programId = $_GET['program_id'] ?? null;
            $departmentId = $_GET['department_id'] ?? null;
            $facultyId = $_GET['faculty_id'] ?? null;
            $institutionId = $_GET['institution_id'] ?? null;

            $statistics = $this->getStatistics($programId, $departmentId, $facultyId, $institutionId);
            $this->sendSuccess($statistics);
        } catch (Exception $e) {
            $this->sendError($e->getMessage());
        }
    }

    private function getStatistics($programId, $departmentId, $facultyId, $institutionId) {
        $whereClause = "WHERE 1=1";
        $params = [];

        if ($programId) {
            $whereClause .= " AND c.program_id = ?";
            $params[] = $programId;
        }

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

        // Total courses
        $sql = "SELECT COUNT(*) as total 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        // Courses by status
        $sql = "SELECT c.status, COUNT(*) as count 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY c.status";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $byStatus = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byStatus[$row['status']] = (int)$row['count'];
        }

        // Courses by level
        $sql = "SELECT c.level, COUNT(*) as count 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY c.level";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $byLevel = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $byLevel[$row['level']] = (int)$row['count'];
        }

        // Courses by semester
        $sql = "SELECT c.semester, COUNT(*) as count 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                GROUP BY c.semester";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $bySemester = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $bySemester[$row['semester']] = (int)$row['count'];
        }

        // Courses by program (if not filtered by program)
        $byProgram = [];
        if (!$programId) {
            $sql = "SELECT p.id, p.name, COUNT(*) as count 
                    FROM courses c 
                    LEFT JOIN programs p ON c.program_id = p.id 
                    LEFT JOIN departments d ON p.department_id = d.id 
                    LEFT JOIN faculties f ON d.faculty_id = f.id 
                    $whereClause 
                    GROUP BY p.id, p.name 
                    ORDER BY count DESC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $byProgram[$row['name']] = (int)$row['count'];
            }
        }

        // Courses by department (if not filtered by department)
        $byDepartment = [];
        if (!$departmentId) {
            $sql = "SELECT d.id, d.name, COUNT(*) as count 
                    FROM courses c 
                    LEFT JOIN programs p ON c.program_id = p.id 
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

        // Courses by faculty (if not filtered by faculty)
        $byFaculty = [];
        if (!$facultyId) {
            $sql = "SELECT f.id, f.name, COUNT(*) as count 
                    FROM courses c 
                    LEFT JOIN programs p ON c.program_id = p.id 
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

        // Courses by institution (if not filtered by institution)
        $byInstitution = [];
        if (!$institutionId) {
            $sql = "SELECT i.id, i.name, COUNT(*) as count 
                    FROM courses c 
                    LEFT JOIN programs p ON c.program_id = p.id 
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

        // Average credits
        $sql = "SELECT AVG(c.credits) as avg_credits 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $avgCreditsResult = $stmt->fetchColumn();
        $avgCredits = $avgCreditsResult ? round($avgCreditsResult, 2) : 0;

        // Courses with instructor
        $sql = "SELECT COUNT(*) as with_instructor 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                AND c.instructor IS NOT NULL AND c.instructor != ''";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $withInstructor = $stmt->fetchColumn();

        // Courses with instructor email
        $sql = "SELECT COUNT(*) as with_instructor_email 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause 
                AND c.instructor_email IS NOT NULL AND c.instructor_email != ''";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $withInstructorEmail = $stmt->fetchColumn();

        // Total credits
        $sql = "SELECT SUM(c.credits) as total_credits 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                $whereClause";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $totalCredits = $stmt->fetchColumn();

        return [
            'total' => (int)$total,
            'by_status' => $byStatus,
            'by_level' => $byLevel,
            'by_semester' => $bySemester,
            'by_program' => $byProgram,
            'by_department' => $byDepartment,
            'by_faculty' => $byFaculty,
            'by_institution' => $byInstitution,
            'active_courses' => $byStatus['active'] ?? 0,
            'inactive_courses' => $byStatus['inactive'] ?? 0,
            'suspended_courses' => $byStatus['suspended'] ?? 0,
            'undergraduate_courses' => $byLevel['undergraduate'] ?? 0,
            'graduate_courses' => $byLevel['graduate'] ?? 0,
            'postgraduate_courses' => $byLevel['postgraduate'] ?? 0,
            'average_credits' => $avgCredits,
            'total_credits' => (int)$totalCredits,
            'courses_with_instructor' => (int)$withInstructor,
            'courses_with_instructor_email' => (int)$withInstructorEmail,
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
$controller = new CourseStatisticsController();
$controller->handleRequest();
?>
