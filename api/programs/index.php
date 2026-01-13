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

class ProgramController {
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
                        $this->getProgram($id);
                    } else {
                        $this->getPrograms();
                    }
                    break;
                case 'POST':
                    $this->createProgram();
                    break;
                case 'PUT':
                    if (!$id) {
                        throw new Exception('Program ID is required for update');
                    }
                    $this->updateProgram($id);
                    break;
                case 'DELETE':
                    if (!$id) {
                        throw new Exception('Program ID is required for delete');
                    }
                    $this->deleteProgram($id);
                    break;
                case 'PATCH':
                    if (!$id) {
                        throw new Exception('Program ID is required for patch');
                    }
                    if ($action === 'toggle_status') {
                        $this->toggleProgramStatus($id);
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

    private function getPrograms() {
        $departmentId = $_GET['department_id'] ?? null;
        $facultyId = $_GET['faculty_id'] ?? null;
        $institutionId = $_GET['institution_id'] ?? null;
        $search = $_GET['search'] ?? null;
        $degreeLevel = $_GET['degree_level'] ?? null;
        $status = $_GET['status'] ?? null;
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, min(100, intval($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $sql = "SELECT p.*, d.name as department_name, d.faculty_id, f.name as faculty_name, f.institution_id, i.name as institution_name 
                FROM programs p 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE 1=1";
        
        $params = [];

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
            $sql .= " AND (p.name LIKE ? OR p.short_name LIKE ? OR p.code LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
        }

        if ($degreeLevel) {
            $sql .= " AND p.degree_level = ?";
            $params[] = $degreeLevel;
        }

        if ($status) {
            $sql .= " AND p.status = ?";
            $params[] = $status;
        }

        // Count total
        $countSql = str_replace("SELECT p.*, d.name as department_name, d.faculty_id, f.name as faculty_name, f.institution_id, i.name as institution_name", "SELECT COUNT(*)", $sql);
        $stmt = $this->pdo->prepare($countSql);
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        // Get data with pagination
        $sql .= " ORDER BY p.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $programs = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Format response
        foreach ($programs as &$program) {
            $program['id'] = (string)$program['id'];
            $program['department_id'] = (string)$program['department_id'];
            $program['faculty_id'] = $program['faculty_id'] ? (string)$program['faculty_id'] : null;
            $program['institution_id'] = $program['institution_id'] ? (string)$program['institution_id'] : null;
            $program['duration_years'] = (int)$program['duration_years'];
            $program['created_at'] = date('Y-m-d\TH:i:s', strtotime($program['created_at']));
            $program['updated_at'] = date('Y-m-d\TH:i:s', strtotime($program['updated_at']));
        }

        $this->sendSuccess($programs, [
            'total' => (int)$total,
            'page' => $page,
            'limit' => $limit,
            'total_pages' => ceil($total / $limit)
        ]);
    }

    private function getProgram($id) {
        $sql = "SELECT p.*, d.name as department_name, d.faculty_id, f.name as faculty_name, f.institution_id, i.name as institution_name 
                FROM programs p 
                LEFT JOIN departments d ON p.department_id = d.id 
                LEFT JOIN faculties f ON d.faculty_id = f.id 
                LEFT JOIN institutions i ON f.institution_id = i.id 
                WHERE p.id = ?";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$id]);
        $program = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$program) {
            throw new Exception('Program not found');
        }

        $program['id'] = (string)$program['id'];
        $program['department_id'] = (string)$program['department_id'];
        $program['faculty_id'] = $program['faculty_id'] ? (string)$program['faculty_id'] : null;
        $program['institution_id'] = $program['institution_id'] ? (string)$program['institution_id'] : null;
        $program['duration_years'] = (int)$program['duration_years'];
        $program['created_at'] = date('Y-m-d\TH:i:s', strtotime($program['created_at']));
        $program['updated_at'] = date('Y-m-d\TH:i:s', strtotime($program['updated_at']));

        $this->sendSuccess($program);
    }

    private function createProgram() {
        $data = $this->getJsonInput();

        // Validate required fields
        $required = ['department_id', 'code', 'name', 'short_name', 'degree_level', 'duration_years'];
        foreach ($required as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                throw new Exception("Field '$field' is required");
            }
        }

        // Check if program code already exists for this department
        $stmt = $this->pdo->prepare("SELECT id FROM programs WHERE department_id = ? AND code = ?");
        $stmt->execute([$data['department_id'], $data['code']]);
        if ($stmt->fetch()) {
            throw new Exception('Program code already exists for this department');
        }

        // Validate degree level
        $validLevels = ['licence1', 'licence2', 'licence3', 'master1', 'master2', 'doctorat', 'ingenieur', 'bts', 'professional'];
        if (!in_array($data['degree_level'], $validLevels)) {
            throw new Exception('Invalid degree level');
        }

        // Validate status
        $validStatuses = ['active', 'inactive', 'suspended'];
        $status = $data['status'] ?? 'active';
        if (!in_array($status, $validStatuses)) {
            throw new Exception('Invalid status');
        }

        $sql = "INSERT INTO programs (department_id, code, name, short_name, degree_level, duration_years, description, admission_requirements, career_prospects, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $params = [
            $data['department_id'],
            $data['code'],
            $data['name'],
            $data['short_name'],
            $data['degree_level'],
            (int)$data['duration_years'],
            $data['description'] ?? null,
            $data['admission_requirements'] ?? null,
            $data['career_prospects'] ?? null,
            $status
        ];

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $id = $this->pdo->lastInsertId();
        $this->getProgram($id);
    }

    private function updateProgram($id) {
        $data = $this->getJsonInput();

        // Check if program exists
        $stmt = $this->pdo->prepare("SELECT id FROM programs WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Program not found');
        }

        // Check if program code already exists for this department (excluding current)
        if (isset($data['code'])) {
            $stmt = $this->pdo->prepare("SELECT id FROM programs WHERE department_id = ? AND code = ? AND id != ?");
            $stmt->execute([$data['department_id'], $data['code'], $id]);
            if ($stmt->fetch()) {
                throw new Exception('Program code already exists for this department');
            }
        }

        // Validate degree level if provided
        if (isset($data['degree_level'])) {
            $validLevels = ['licence1', 'licence2', 'licence3', 'master1', 'master2', 'doctorat', 'ingenieur', 'bts', 'professional'];
            if (!in_array($data['degree_level'], $validLevels)) {
                throw new Exception('Invalid degree level');
            }
        }

        // Validate status if provided
        if (isset($data['status'])) {
            $validStatuses = ['active', 'inactive', 'suspended'];
            if (!in_array($data['status'], $validStatuses)) {
                throw new Exception('Invalid status');
            }
        }

        $setClauses = [];
        $params = [];

        $updatableFields = ['department_id', 'code', 'name', 'short_name', 'degree_level', 'duration_years', 'description', 'admission_requirements', 'career_prospects', 'status'];
        
        foreach ($updatableFields as $field) {
            if (isset($data[$field])) {
                $setClauses[] = "$field = ?";
                if ($field === 'duration_years') {
                    $params[] = (int)$data[$field];
                } else {
                    $params[] = $data[$field];
                }
            }
        }

        if (empty($setClauses)) {
            throw new Exception('No valid fields to update');
        }

        $setClauses[] = "updated_at = CURRENT_TIMESTAMP";
        $params[] = $id;

        $sql = "UPDATE programs SET " . implode(', ', $setClauses) . " WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        $this->getProgram($id);
    }

    private function deleteProgram($id) {
        // Check if program exists
        $stmt = $this->pdo->prepare("SELECT id FROM programs WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Program not found');
        }

        // Check if program has related records (you might want to add this check)
        // For now, we'll allow deletion

        $stmt = $this->pdo->prepare("DELETE FROM programs WHERE id = ?");
        $stmt->execute([$id]);

        $this->sendSuccess(null, 'Program deleted successfully');
    }

    private function toggleProgramStatus($id) {
        $data = $this->getJsonInput();
        
        if (!isset($data['status'])) {
            throw new Exception('Status is required');
        }

        $validStatuses = ['active', 'inactive', 'suspended'];
        if (!in_array($data['status'], $validStatuses)) {
            throw new Exception('Invalid status');
        }

        // Check if program exists
        $stmt = $this->pdo->prepare("SELECT id FROM programs WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            throw new Exception('Program not found');
        }

        $sql = "UPDATE programs SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$data['status'], $id]);

        $this->sendSuccess(null, 'Program status updated successfully');
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
$controller = new ProgramController();
$controller->handleRequest();
?>
