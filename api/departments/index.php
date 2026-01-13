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

class DepartmentController {
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
                        $this->getDepartment($id);
                    } else {
                        $this->getDepartments();
                    }
                    break;
                case 'POST':
                    $this->createDepartment();
                    break;
                case 'PUT':
                    if (!$id) {
                        throw new Exception('Department ID is required for update');
                    }
                    $this->updateDepartment($id);
                    break;
                case 'DELETE':
                    if (!$id) {
                        throw new Exception('Department ID is required for delete');
                    }
                    $this->deleteDepartment($id);
                    break;
                case 'PATCH':
                    if (!$id) {
                        throw new Exception('Department ID is required for patch');
                    }
                    if ($action === 'toggle_status') {
                        $this->toggleDepartmentStatus($id);
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

    private function getDepartments() {
        $facultyId = $_GET['faculty_id'] ?? null;
        $institutionId = $_GET['institution_id'] ?? null;
        $search = $_GET['search'] ?? null;
        $level = $_GET['level'] ?? null;
        $status = $_GET['status'] ?? null;
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, min(100, intval($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $sql = "SELECT d.*, f.name as faculty_name, f.institution_id, i.name as institution_name 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE 1=1";
        
        $params = [];

        if ($facultyId) {
            $sql .= " AND d.faculty_id = ?";
            $params[] = $facultyId;
        }

        if ($institutionId) {
            $sql .= " AND f.institution_id = ?";
            $params[] = $institutionId;
        }

        if ($search) {
            $sql .= " AND (d.name LIKE ? OR d.short_name LIKE ? OR d.code LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
        }

        if ($level) {
            $sql .= " AND d.level = ?";
            $params[] = $level;
        }

        if ($status) {
            $sql .= " AND d.status = ?";
            $params[] = $status;
        }

        // Count total
        $countSql = str_replace("SELECT d.*, f.name as faculty_name, f.institution_id, i.name as institution_name", "SELECT COUNT(*)", $sql);
        $stmt = $this->pdo->prepare($countSql);
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        // Get data with pagination
        $sql .= " ORDER BY d.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $departments = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Format response
        foreach ($departments as &$department) {
            $department['id'] = (string)$department['id'];
            $department['faculty_id'] = (string)$department['faculty_id'];
            $department['institution_id'] = $department['institution_id'] ? (string)$department['institution_id'] : null;
            $department['is_active'] = (bool)$department['is_active'];
            $department['created_at'] = date('Y-m-d\TH:i:s', strtotime($department['created_at']));
            $department['updated_at'] = date('Y-m-d\TH:i:s', strtotime($department['updated_at']));
        }

        $this->sendSuccess($departments, [
            'total' => (int)$total,
            'page' => $page,
            'limit' => $limit,
            'total_pages' => ceil($total / $limit)
        ]);
    }

    private function getDepartment($id) {
        $sql = "SELECT d.*, f.name as faculty_name, f.institution_id, i.name as institution_name 
                FROM departments d 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE d.id = ?";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$id]);
        $department = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$department) {
            throw new Exception('Department not found');
        }

        $department['id'] = (string)$department['id'];
        $department['faculty_id'] = (string)$department['faculty_id'];
        $department['institution_id'] = $department['institution_id'] ? (string)$department['institution_id'] : null;
        $department['is_active'] = (bool)$department['is_active'];
        $department['created_at'] = date('Y-m-d\TH:i:s', strtotime($department['created_at']));
        $department['updated_at'] = date('Y-m-d\TH:i:s', strtotime($department['updated_at']));

        $this->sendSuccess($department);
    }

    private function createDepartment() {
        $data = $this->getJsonInput();

        // Validate required fields
        $required = ['faculty_id', 'code', 'name', 'short_name'];
        foreach ($required as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                throw new Exception("Field '$field' is required");
            }
        }

        // Check if department code already exists for this faculty
        $stmt = $this->pdo->prepare("SELECT id FROM departments WHERE faculty_id = ? AND code = ?");
        $stmt->execute([$data['faculty_id'], $data['code']]);
        if ($stmt->fetch()) {
            throw new Exception('Department code already exists for this faculty');
        }

        // Validate level
        $validLevels = ['undergraduate', 'graduate', 'postgraduate'];
        $level = $data['level'] ?? 'undergraduate';
        if (!in_array($level, $validLevels)) {
            throw new Exception('Invalid level');
        }

        // Validate status
        $validStatuses = ['active', 'inactive'];
        $status = $data['status'] ?? 'active';
        if (!in_array($status, $validStatuses)) {
            throw new Exception('Invalid status');
        }

        // Generate UUID
        $uuid = $this->generateUuid();

        $sql = "INSERT INTO departments (uuid, faculty_id, code, name, short_name, description, head_of_department, hod_email, hod_phone, level, status, is_active) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $params = [
            $uuid,
            $data['faculty_id'],
            $data['code'],
            $data['name'],
            $data['short_name'],
            $data['description'] ?? null,
            $data['head_of_department'] ?? null,
            $data['hod_email'] ?? null,
            $data['hod_phone'] ?? null,
            $level,
            $status,
            $status === 'active' ? 1 : 0
        ];

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $id = $this->pdo->lastInsertId();
        $this->getDepartment($id);
    }

    private function updateDepartment($id) {
        $data = $this->getJsonInput();

        // Check if department exists
        $stmt = $this->pdo->prepare("SELECT id FROM departments WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Department not found');
        }

        // Check if department code already exists for this faculty (excluding current)
        if (isset($data['code'])) {
            $stmt = $this->pdo->prepare("SELECT id FROM departments WHERE faculty_id = ? AND code = ? AND id != ?");
            $stmt->execute([$data['faculty_id'], $data['code'], $id]);
            if ($stmt->fetch()) {
                throw new Exception('Department code already exists for this faculty');
            }
        }

        // Validate level if provided
        if (isset($data['level'])) {
            $validLevels = ['undergraduate', 'graduate', 'postgraduate'];
            if (!in_array($data['level'], $validLevels)) {
                throw new Exception('Invalid level');
            }
        }

        // Validate status if provided
        if (isset($data['status'])) {
            $validStatuses = ['active', 'inactive'];
            if (!in_array($data['status'], $validStatuses)) {
                throw new Exception('Invalid status');
            }
        }

        $setClauses = [];
        $params = [];

        $updatableFields = ['faculty_id', 'code', 'name', 'short_name', 'description', 'head_of_department', 'hod_email', 'hod_phone', 'level', 'status'];
        
        foreach ($updatableFields as $field) {
            if (isset($data[$field])) {
                $setClauses[] = "$field = ?";
                $params[] = $data[$field];
            }
        }

        if (empty($setClauses)) {
            throw new Exception('No valid fields to update');
        }

        // Update is_active based on status if status is provided
        if (isset($data['status'])) {
            $setClauses[] = "is_active = ?";
            $params[] = $data['status'] === 'active' ? 1 : 0;
        }

        $setClauses[] = "updated_at = CURRENT_TIMESTAMP";
        $params[] = $id;

        $sql = "UPDATE departments SET " . implode(', ', $setClauses) . " WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $this->getDepartment($id);
    }

    private function deleteDepartment($id) {
        // Check if department exists
        $stmt = $this->pdo->prepare("SELECT id FROM departments WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Department not found');
        }

        // Check if department has related programs
        $stmt = $this->pdo->prepare("SELECT COUNT(*) FROM programs WHERE department_id = ?");
        $stmt->execute([$id]);
        $programCount = $stmt->fetchColumn();
        
        if ($programCount > 0) {
            throw new Exception('Cannot delete department with existing programs');
        }

        $stmt = $this->pdo->prepare("DELETE FROM departments WHERE id = ?");
        $stmt->execute([$id]);

        $this->sendSuccess(null, 'Department deleted successfully');
    }

    private function toggleDepartmentStatus($id) {
        $data = $this->getJsonInput();
        
        if (!isset($data['status'])) {
            throw new Exception('Status is required');
        }

        $validStatuses = ['active', 'inactive'];
        if (!in_array($data['status'], $validStatuses)) {
            throw new Exception('Invalid status');
        }

        // Check if department exists
        $stmt = $this->pdo->prepare("SELECT id FROM departments WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Department not found');
        }

        $sql = "UPDATE departments SET status = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([
            $data['status'], 
            $data['status'] === 'active' ? 1 : 0, 
            $id
        ]);

        $this->sendSuccess(null, 'Department status updated successfully');
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
$controller = new DepartmentController();
$controller->handleRequest();
?>
