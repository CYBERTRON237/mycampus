<?php

require_once __DIR__ . '/../../config/Database.php';
require_once __DIR__ . '/../models/UsersStudentModel.php';

class StudentController {
    private $db;
    private $studentModel;
    
    public function __construct($pdo) {
        $this->db = new Database();
        $this->studentModel = new UsersStudentModel($pdo);
    }
    
    /**
     * Récupérer tous les étudiants avec pagination
     */
    public function getStudents() {
        try {
            $page = max(1, intval($_GET['page'] ?? 1));
            $limit = max(1, min(100, intval($_GET['limit'] ?? 20)));
            
            $result = $this->studentModel->getStudents($page, $limit);
            
            $this->sendJsonResponse([
                'success' => true,
                'data' => $result['students'],
                'pagination' => [
                    'current_page' => $page,
                    'per_page' => $limit,
                    'total' => $result['total'],
                    'total_pages' => ceil($result['total'] / $limit)
                ]
            ]);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la récupération des étudiants: ' . $e->getMessage());
        }
    }
    
    /**
     * Récupérer un étudiant par son ID
     */
    public function getStudent($id) {
        try {
            $student = $this->studentModel->getStudentById($id);
            
            if (!$student) {
                $this->sendErrorResponse('Étudiant non trouvé', 404);
                return;
            }
            
            $this->sendJsonResponse([
                'success' => true,
                'data' => $student
            ]);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la récupération de l\'étudiant: ' . $e->getMessage());
        }
    }
    
    /**
     * Créer un nouvel étudiant
     */
    public function createStudent() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!$data) {
                $this->sendErrorResponse('Données invalides', 400);
                return;
            }
            
            // Validation des données requises
            $requiredFields = ['first_name', 'last_name', 'email'];
            foreach ($requiredFields as $field) {
                if (empty($data[$field])) {
                    $this->sendErrorResponse("Le champ '$field' est requis", 400);
                    return;
                }
            }
            
            $result = $this->studentModel->createStudent($data);
            
            if ($result['success']) {
                $this->sendJsonResponse([
                    'success' => true,
                    'message' => $result['message'],
                    'data' => $result['data']
                ], 201);
            } else {
                $this->sendErrorResponse($result['message'], 400);
            }
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la création de l\'étudiant: ' . $e->getMessage());
        }
    }
    
    /**
     * Mettre à jour un étudiant
     */
    public function updateStudent($id) {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!$data) {
                $this->sendErrorResponse('Données invalides', 400);
                return;
            }
            
            $result = $this->studentModel->updateStudent($id, $data);
            
            if ($result['success']) {
                $this->sendJsonResponse([
                    'success' => true,
                    'message' => $result['message'],
                    'data' => $result['data']
                ]);
            } else {
                $this->sendErrorResponse($result['message'], 400);
            }
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la mise à jour de l\'étudiant: ' . $e->getMessage());
        }
    }
    
    /**
     * Supprimer un étudiant (désactivation)
     */
    public function deleteStudent($id) {
        try {
            $result = $this->studentModel->deleteStudent($id);
            
            if ($result['success']) {
                $this->sendJsonResponse([
                    'success' => true,
                    'message' => $result['message']
                ]);
            } else {
                $this->sendErrorResponse($result['message'], 400);
            }
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la suppression de l\'étudiant: ' . $e->getMessage());
        }
    }
    
    /**
     * Récupérer les statistiques des étudiants
     */
    public function getStudentStats() {
        try {
            $stats = $this->studentModel->getStudentStats();
            
            $this->sendJsonResponse([
                'success' => true,
                'data' => $stats
            ]);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la récupération des statistiques: ' . $e->getMessage());
        }
    }
    
    /**
     * Récupérer les inscriptions d'un étudiant
     */
    public function getStudentEnrollments($studentId) {
        try {
            $enrollments = $this->studentModel->getStudentEnrollments($studentId);
            
            $this->sendJsonResponse([
                'success' => true,
                'data' => $enrollments
            ]);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la récupération des inscriptions: ' . $e->getMessage());
        }
    }
    
    /**
     * Récupérer les résultats académiques d'un étudiant
     */
    public function getStudentAcademicRecords($studentId) {
        try {
            $records = $this->studentModel->getStudentAcademicRecords($studentId);
            
            $this->sendJsonResponse([
                'success' => true,
                'data' => $records
            ]);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la récupération des résultats académiques: ' . $e->getMessage());
        }
    }
    
    /**
     * Récupérer les documents d'un étudiant
     */
    public function getStudentDocuments($studentId) {
        try {
            $documents = $this->studentModel->getStudentDocuments($studentId);
            
            $this->sendJsonResponse([
                'success' => true,
                'data' => $documents
            ]);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de la récupération des documents: ' . $e->getMessage());
        }
    }
    
    /**
     * Exporter les étudiants en CSV
     */
    public function exportStudents() {
        try {
            $students = $this->studentModel->exportStudents();
            
            header('Content-Type: text/csv');
            header('Content-Disposition: attachment; filename="students_' . date('Y-m-d') . '.csv"');
            
            $output = fopen('php://output', 'w');
            
            // En-tête CSV
            fputcsv($output, [
                'Matricule',
                'Nom',
                'Prénom',
                'Email',
                'Téléphone',
                'Statut',
                'Niveau',
                'Moyenne',
                'Date de création'
            ]);
            
            // Données
            foreach ($students as $student) {
                fputcsv($output, [
                    $student['matricule'] ?? '',
                    $student['last_name'] ?? '',
                    $student['first_name'] ?? '',
                    $student['email'] ?? '',
                    $student['phone'] ?? '',
                    $student['student_status'] ?? '',
                    $student['current_level'] ?? '',
                    $student['current_gpa'] ?? '',
                    $student['created_at'] ?? ''
                ]);
            }
            
            fclose($output);
        } catch (Exception $e) {
            $this->sendErrorResponse('Erreur lors de l\'exportation: ' . $e->getMessage());
        }
    }
    
    /**
     * Envoyer une réponse JSON
     */
    private function sendJsonResponse($data, $statusCode = 200) {
        header('Content-Type: application/json');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        
        http_response_code($statusCode);
        echo json_encode($data);
        exit;
    }
    
    /**
     * Envoyer une réponse d'erreur
     */
    private function sendErrorResponse($message, $statusCode = 500) {
        $this->sendJsonResponse([
            'success' => false,
            'error' => $message
        ], $statusCode);
    }
}
?>
