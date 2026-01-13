<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';

class CourseController {
    private $pdo;

    public function __construct() {
        $database = new Database();
        $this->pdo = $database->getConnection();
    }

    public function handleRequest() {
        $method = $_SERVER['REQUEST_METHOD'];
        $action = $_GET['action'] ?? '';
        $id = $_GET['id'] ?? null;

        try {
            switch ($method) {
                case 'GET':
                    if ($id) {
                        $this->getCourse($id);
                    } else {
                        $this->getCourses();
                    }
                    break;
                case 'POST':
                    $this->createCourse();
                    break;
                case 'PUT':
                    if (!$id) {
                        throw new Exception('Course ID is required for update');
                    }
                    $this->updateCourse($id);
                    break;
                case 'DELETE':
                    if (!$id) {
                        throw new Exception('Course ID is required for delete');
                    }
                    $this->deleteCourse($id);
                    break;
                case 'PATCH':
                    if (!$id) {
                        throw new Exception('Course ID is required for patch');
                    }
                    if ($action === 'toggle_status') {
                        $this->toggleCourseStatus($id);
                    } else {
                        throw new Exception('Invalid action for PATCH method');
                    }
                    break;
                default:
                    throw new Exception('Method not allowed');
            }
        } catch (Exception $e) {
            $this->sendError($e->getMessage());
        }
    }

    private function getCourses() {
        $programId = $_GET['program_id'] ?? null;
        $departmentId = $_GET['department_id'] ?? null;
        $facultyId = $_GET['faculty_id'] ?? null;
        $institutionId = $_GET['institution_id'] ?? null;
        $search = $_GET['search'] ?? null;
        $level = $_GET['level'] ?? null;
        $semester = $_GET['semester'] ?? null;
        $status = $_GET['status'] ?? null;
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, min(100, intval($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $sql = "SELECT c.*, p.name as program_name, p.department_id, d.name as department_name, d.faculty_id, f.name as faculty_name, f.institution_id, i.name as institution_name 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE 1=1";
        
        $params = [];

        if ($programId) {
            $sql .= " AND c.program_id = ?";
            $params[] = $programId;
        }

        if ($departmentId) {
            $sql .= " AND p.department_id = ?";
            $params[] = $departmentId;
        }

        if ($facultyId) {
            $sql .= " AND d.faculty_id = ?";
            $params[] = $facultyId;
        }

        if ($institutionId) {
            $sql .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }

        if ($search) {
            $sql .= " AND (c.name LIKE ? OR c.short_name LIKE ? OR c.code LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
        }

        if ($level) {
            $sql .= " AND c.level = ?";
            $params[] = $level;
        }

        if ($semester) {
            $sql .= " AND c.semester = ?";
            $params[] = $semester;
        }

        if ($status) {
            $sql .= " AND c.status = ?";
            $params[] = $status;
        }

        // Count total
        $countSql = str_replace("SELECT c.*, p.name as program_name, p.department_id, d.name as department_name, d.faculty_id, f.name as faculty_name, f.institution_id, i.name as institution_name", "SELECT COUNT(*)", $sql);
        $stmt = $this->pdo->prepare($countSql);
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        // Get data with pagination
        $sql .= " ORDER BY c.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Format response
        foreach ($courses as &$course) {
            $course['id'] = (string)$course['id'];
            $course['program_id'] = (string)$course['program_id'];
            $course['department_id'] = $course['department_id'] ? (string)$course['department_id'] : null;
            $course['faculty_id'] = $course['faculty_id'] ? (string)$course['faculty_id'] : null;
            $course['institution_id'] = $course['institution_id'] ? (string)$course['institution_id'] : null;
            $course['credits'] = (int)$course['credits'];
            $course['created_at'] = date('Y-m-d\TH:i:s', strtotime($course['created_at']));
            $course['updated_at'] = date('Y-m-d\TH:i:s', strtotime($course['updated_at']));
        }

        $this->sendSuccess($courses, [
            'total' => (int)$total,
            'page' => $page,
            'limit' => $limit,
            'total_pages' => ceil($total / $limit)
        ]);
    }

    private function getCourse($id) {
        $sql = "SELECT c.*, p.name as program_name, p.department_id, d.name as department_name, d.faculty_id, f.name as faculty_name, f.institution_id, i.name as institution_name 
                FROM courses c 
                LEFT JOIN programs p ON c.program_id = p.id 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE c.id = ?";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$id]);
        $course = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$course) {
            throw new Exception('Course not found');
        }

        $course['id'] = (string)$course['id'];
        $course['program_id'] = (string)$course['program_id'];
        $course['department_id'] = $course['department_id'] ? (string)$course['department_id'] : null;
        $course['faculty_id'] = $course['faculty_id'] ? (string)$course['faculty_id'] : null;
        $course['institution_id'] = $course['institution_id'] ? (string)$course['institution_id'] : null;
        $course['credits'] = (int)$course['credits'];
        $course['created_at'] = date('Y-m-d\TH:i:s', strtotime($course['created_at']));
        $course['updated_at'] = date('Y-m-d\TH:i:s', strtotime($course['updated_at']));

        $this->sendSuccess($course);
    }

    private function createCourse() {
        $data = $this->getJsonInput();

        // Validate required fields
        $required = ['program_id', 'code', 'name', 'short_name'];
        foreach ($required as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                throw new Exception("Field '$field' is required");
            }
        }

        // Check if course code already exists for this program
        $stmt = $this->pdo->prepare("SELECT id FROM courses WHERE program_id = ? AND code = ?");
        $stmt->execute([$data['program_id'], $data['code']]);
        if ($stmt->fetch()) {
            throw new Exception('Course code already exists for this program');
        }

        // Validate level
        $validLevels = ['undergraduate', 'graduate', 'postgraduate'];
        $level = $data['level'] ?? 'undergraduate';
        if (!in_array($level, $validLevels)) {
            throw new Exception('Invalid level');
        }

        // Validate semester
        $validSemesters = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'];
        $semester = $data['semester'] ?? 'S1';
        if (!in_array($semester, $validSemesters)) {
            throw new Exception('Invalid semester');
        }

        // Validate status
        $validStatuses = ['active', 'inactive', 'suspended'];
        $status = $data['status'] ?? 'active';
        if (!in_array($status, $validStatuses)) {
            throw new Exception('Invalid status');
        }

        // Validate credits
        $credits = isset($data['credits']) ? (int)$data['credits'] : 3;
        if ($credits < 1 || $credits > 10) {
            throw new Exception('Credits must be between 1 and 10');
        }

        // Generate UUID
        $uuid = $this->generateUuid();

        $sql = "INSERT INTO courses (uuid, program_id, code, name, short_name, description, credits, semester, level, instructor, instructor_email, instructor_phone, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $params = [
            $uuid,
            $data['program_id'],
            $data['code'],
            $data['name'],
            $data['short_name'],
            $data['description'] ?? null,
            $credits,
            $semester,
            $level,
            $data['instructor'] ?? null,
            $data['instructor_email'] ?? null,
            $data['instructor_phone'] ?? null,
            $status
        ];

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $id = $this->pdo->lastInsertId();
        $this->getCourse($id);
    }

    private function updateCourse($id) {
        $data = $this->getJsonInput();

        // Check if course exists
        $stmt = $this->pdo->prepare("SELECT id FROM courses WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Course not found');
        }

        // Check if course code already exists for this program (excluding current)
        if (isset($data['code'])) {
            $stmt = $this->pdo->prepare("SELECT id FROM courses WHERE program_id = ? AND code = ? AND id != ?");
            $stmt->execute([$data['program_id'], $data['code'], $id]);
            if ($stmt->fetch()) {
                throw new Exception('Course code already exists for this program');
            }
        }

        // Validate level if provided
        if (isset($data['level'])) {
            $validLevels = ['undergraduate', 'graduate', 'postgraduate'];
            if (!in_array($data['level'], $validLevels)) {
                throw new Exception('Invalid level');
            }
        }

        // Validate semester if provided
        if (isset($data['semester'])) {
            $validSemesters = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'];
            if (!in_array($data['semester'], $validSemesters)) {
                throw new Exception('Invalid semester');
            }
        }

        // Validate status if provided
        if (isset($data['status'])) {
            $validStatuses = ['active', 'inactive', 'suspended'];
            if (!in_array($data['status'], $validStatuses)) {
                throw new Exception('Invalid status');
            }
        }

        // Validate credits if provided
        if (isset($data['credits'])) {
            $credits = (int)$data['credits'];
            if ($credits < 1 || $credits > 10) {
                throw new Exception('Credits must be between 1 and 10');
            }
        }

        $setClauses = [];
        $params = [];

        $updatableFields = ['program_id', 'code', 'name', 'short_name', 'description', 'credits', 'semester', 'level', 'instructor', 'instructor_email', 'instructor_phone', 'status'];
        
        foreach ($updatableFields as $field) {
            if (isset($data[$field])) {
                $setClauses[] = "$field = ?";
                $params[] = $data[$field];
            }
        }

        if (empty($setClauses)) {
            throw new Exception('No valid fields to update');
        }

        $setClauses[] = "updated_at = CURRENT_TIMESTAMP";
        $params[] = $id;

        $sql = "UPDATE courses SET " . implode(', ', $setClauses) . " WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $this->getCourse($id);
    }

    private function deleteCourse($id) {
        // Check if course exists
        $stmt = $this->pdo->prepare("SELECT id FROM courses WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Course not found');
        }

        $stmt = $this->pdo->prepare("DELETE FROM courses WHERE id = ?");
        $stmt->execute([$id]);

        $this->sendSuccess(null, 'Course deleted successfully');
    }

    private function toggleCourseStatus($id) {
        $data = $this->getJsonInput();
        
        if (!isset($data['status'])) {
            throw new Exception('Status is required');
        }

        $validStatuses = ['active', 'inactive', 'suspended'];
        if (!in_array($data['status'], $validStatuses)) {
            throw new Exception('Invalid status');
        }

        // Check if course exists
        $stmt = $this->pdo->prepare("SELECT id FROM courses WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Course not found');
        }

        $sql = "UPDATE courses SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$data['status'], $id]);

        $this->sendSuccess(null, 'Course status updated successfully');
    }

    private function getJsonInput() {
        $json = file_get_contents('php://input');
        if ($json === false) {
            throw new Exception('Invalid JSON input');
        }
        
        $data = json_decode($json, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON: ' . json_last_error_msg());
        }
        
        return $data;
    }

    private function generateUuid() {
        return sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
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
$controller = new CourseController();
$controller->handleRequest();
?>
