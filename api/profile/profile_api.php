<?php
// Profile API - Complete User Profile Management
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/Database.php';
require_once '../auth/JWTHandler.php';

class ProfileAPI {
    private $db;
    private $jwt;
    
    public function __construct() {
        $this->db = new Database();
        $this->jwt = new JWTHandler();
    }
    
    public function handleRequest() {
        $method = $_SERVER['REQUEST_METHOD'];
        $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        
        // Debug: Log the received path
        error_log("Profile API - Received path: " . $path);
        error_log("Profile API - Request URI: " . $_SERVER['REQUEST_URI']);
        
        $pathParts = explode('/', trim($path, '/'));
        
        // Debug: Log path parts
        error_log("Profile API - Path parts: " . json_encode($pathParts));
        
        // Find 'api' and 'profile' indices and remove everything before them
        $apiIndex = array_search('api', $pathParts);
        $profileIndex = array_search('profile', $pathParts);
        
        if ($apiIndex !== false && $profileIndex !== false) {
            // Remove everything up to and including 'profile'
            $pathParts = array_slice($pathParts, $profileIndex + 1);
        }
        
        error_log("Profile API - Final path parts: " . json_encode($pathParts));
        
        $endpoint = $pathParts[0] ?? '';
        $id = $pathParts[1] ?? null;
        
        error_log("Profile API - Endpoint: " . $endpoint . ", ID: " . $id);
        
        try {
            // Authenticate user (except for public endpoints)
            $user = $this->authenticate();
            
            switch ($endpoint) {
                case '':
                case 'me':
                    $this->getMyProfile($user);
                    break;
                    
                case 'user':
                    if ($id) {
                        $this->getUserProfile($id, $user);
                    } else {
                        $this->updateMyProfile($user);
                    }
                    break;
                    
                case 'preinscription':
                    $this->getMyPreinscription($user);
                    break;
                    
                case 'academic':
                    $this->getAcademicProfile($user);
                    break;
                    
                case 'professional':
                    $this->getProfessionalProfile($user);
                    break;
                    
                case 'stats':
                    $this->getProfileStats($user);
                    break;
                    
                case 'photo':
                    $this->updateProfilePhoto($user);
                    break;
                    
                default:
                    $this->sendResponse(404, 'Endpoint not found');
                    break;
            }
        } catch (Exception $e) {
            $this->sendResponse(500, 'Server error: ' . $e->getMessage());
        }
    }
    
    private function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        
        error_log("Auth header: " . substr($authHeader, 0, 50) . "...");
        
        if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            error_log("No valid authorization header found");
            throw new Exception('Authorization token required');
        }
        
        $token = $matches[1];
        error_log("Token extracted: " . substr($token, 0, 30) . "...");
        
        $payload = $this->jwt->validateToken($token);
        
        if (!$payload) {
            error_log("Token validation failed");
            throw new Exception('Invalid token');
        }
        
        error_log("Authentication successful for user: " . json_encode($payload));
        return $payload;
    }
    
    private function getMyProfile($user) {
        $userId = $user->user_id;
        
        // Get user basic info
        $query = "SELECT u.*, 
                    i.name as institution_name, 
                    d.name as department_name,
                    p.unique_code as preinscription_code,
                    p.status as preinscription_status,
                    p.faculty,
                    p.study_level,
                    p.desired_program,
                    p.submission_date as preinscription_date
                  FROM users u 
                  LEFT JOIN institutions i ON u.institution_id = i.id
                  LEFT JOIN departments d ON u.department_id = d.id  
                  LEFT JOIN preinscriptions p ON u.preinscription_id = p.id
                  WHERE u.id = ?";
                  
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$userData) {
            $this->sendResponse(404, 'User not found');
            return;
        }
        
        // Format response
        $profile = $this->formatProfileData($userData);
        
        $this->sendResponse(200, 'Profile retrieved successfully', $profile);
    }
    
    private function getUserProfile($targetUserId, $currentUser) {
        // Check if user can view this profile (admin or own profile)
        if ($currentUser->user_id != $targetUserId && $currentUser->primary_role !== 'superadmin' && $currentUser->primary_role !== 'admin_national' && $currentUser->primary_role !== 'admin_local') {
            $this->sendResponse(403, 'Access denied');
            return;
        }
        
        $query = "SELECT u.*, 
                    i.name as institution_name, 
                    d.name as department_name,
                    p.unique_code as preinscription_code,
                    p.status as preinscription_status,
                    p.faculty,
                    p.study_level,
                    p.desired_program,
                    p.submission_date as preinscription_date
                  FROM users u 
                  LEFT JOIN institutions i ON u.institution_id = i.id
                  LEFT JOIN departments d ON u.department_id = d.id  
                  LEFT JOIN preinscriptions p ON u.preinscription_id = p.id
                  WHERE u.id = ?";
                  
        $stmt = $this->db->prepare($query);
        $stmt->execute([$targetUserId]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$userData) {
            $this->sendResponse(404, 'User not found');
            return;
        }
        
        $profile = $this->formatProfileData($userData);
        
        $this->sendResponse(200, 'Profile retrieved successfully', $profile);
    }
    
    private function getMyPreinscription($user) {
        $userId = $user->user_id;
        
        error_log("getMyPreinscription called for user ID: $userId");
        
        // LOGIQUE SIMPLE : Si user est étudiant, il a forcément une préinscription validée
        // On récupère la préinscription par email de l'utilisateur
        
        // Get user info for email
        $query = "SELECT email, role FROM users WHERE id = ?";
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId]);
        $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        error_log("User info: " . json_encode($userInfo));
        
        if ($userInfo && ($userInfo['role'] === 'student' || $userInfo['role'] === 'user') && $userInfo['email']) {
            error_log("User is student/user, searching preinscription by email: " . $userInfo['email']);
            
            // Récupérer la préinscription validée par email
            $query = "SELECT * FROM preinscriptions 
                      WHERE email = ? AND status IN ('accepted', 'confirmed') 
                      ORDER BY created_at DESC LIMIT 1";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$userInfo['email']]);
            $preinscription = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($preinscription) {
                error_log("Preinscription trouvée: " . json_encode($preinscription));
                $this->sendResponse(200, 'Preinscription trouvée', $preinscription);
                return;
            } else {
                error_log("ERREUR : Étudiant sans préinscription validée pour email: " . $userInfo['email']);
                $this->sendResponse(404, 'Étudiant sans préinscription validée');
                return;
            }
        } else {
            error_log("User n'est pas étudiant/user ou email manquant");
            $this->sendResponse(404, 'Utilisateur non étudiant');
        }
    }
    
    private function getAcademicProfile($user) {
        $userId = $user->user_id;
        
        if ($user->primary_role === 'student' && $user->preinscription_id) {
            // Get academic info from preinscription
            $query = "SELECT p.*, i.name as institution_name
                      FROM preinscriptions p
                      LEFT JOIN institutions i ON i.name = ?
                      WHERE p.id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute(['Université de Yaoundé I', $user->preinscription_id]);
            $academicData = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($academicData) {
                $academicProfile = [
                    'faculty' => $academicData['faculty'],
                    'study_level' => $academicData['study_level'],
                    'desired_program' => $academicData['desired_program'],
                    'previous_diploma' => $academicData['previous_diploma'],
                    'previous_institution' => $academicData['previous_institution'],
                    'institution_name' => $academicData['institution_name'] ?? 'Université de Yaoundé I',
                    'admission_number' => $academicData['admission_number'],
                    'registration_date' => $academicData['submission_date']
                ];
                
                $this->sendResponse(200, 'Academic profile retrieved', $academicProfile);
                return;
            }
        }
        
        // Get basic academic info from users table
        $query = "SELECT u.level, u.academic_year, u.matricule, u.student_id,
                    i.name as institution_name, d.name as department_name
                  FROM users u
                  LEFT JOIN institutions i ON u.institution_id = i.id
                  LEFT JOIN departments d ON u.department_id = d.id
                  WHERE u.id = ?";
                  
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId]);
        $academicData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($academicData) {
            $this->sendResponse(200, 'Academic profile retrieved', $academicData);
        } else {
            $this->sendResponse(404, 'No academic information found');
        }
    }
    
    private function getProfessionalProfile($user) {
        $userId = $user->user_id;
        
        // Get professional info from preinscription if student
        if ($user->primary_role === 'student' && $user->preinscription_id) {
            $query = "SELECT professional_situation, first_language, 
                        residence_address, marital_status, phone_number
                      FROM preinscriptions 
                      WHERE id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$user->preinscription_id]);
            $profData = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($profData) {
                $this->sendResponse(200, 'Professional profile retrieved', $profData);
                return;
            }
        }
        
        // Get professional info from users table
        $query = "SELECT bio, address, city, region, country, postal_code,
                    emergency_contact_name, emergency_contact_phone, emergency_contact_relationship,
                    profile_photo_url, phone
                  FROM users 
                  WHERE id = ?";
                  
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId]);
        $profData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($profData) {
            $this->sendResponse(200, 'Professional profile retrieved', $profData);
        } else {
            $this->sendResponse(404, 'No professional information found');
        }
    }
    
    private function getProfileStats($user) {
        $userId = $user->user_id;
        
        $stats = [];
        
        // Get basic stats
        $stats['account_info'] = [
            'role' => $user->primary_role,
            'account_status' => $user->account_status ?? 'active',
            'is_verified' => $user->is_verified ?? false,
            'member_since' => $user->created_at ?? null,
            'last_login' => $user->last_login_at ?? null
        ];
        
        // Get preinscription status if applicable
        if ($user->primary_role === 'student') {
            $query = "SELECT status, submission_date FROM preinscriptions 
                      WHERE id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$user->preinscription_id]);
            $preinsc = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($preinsc) {
                $stats['preinscription'] = [
                    'status' => $preinsc['status'],
                    'submission_date' => $preinsc['submission_date'],
                    'has_valid_preinscription' => in_array($preinsc['status'], ['accepted', 'confirmed'])
                ];
            }
        }
        
        $this->sendResponse(200, 'Profile stats retrieved', $stats);
    }
    
    private function updateMyProfile($user) {
        $userId = $user->user_id;
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            $this->sendResponse(400, 'Invalid JSON input');
            return;
        }
        
        // Allowed fields for update
        $allowedFields = [
            'first_name', 'last_name', 'middle_name', 'phone', 'bio', 
            'address', 'city', 'region', 'country', 'postal_code',
            'emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relationship'
        ];
        
        $updateFields = [];
        $updateValues = [];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updateFields[] = "$field = ?";
                $updateValues[] = $input[$field];
            }
        }
        
        if (empty($updateFields)) {
            $this->sendResponse(400, 'No valid fields to update');
            return;
        }
        
        $updateValues[] = $userId;
        
        $query = "UPDATE users SET " . implode(', ', $updateFields) . ", updated_at = NOW() WHERE id = ?";
        $stmt = $this->db->prepare($query);
        
        if ($stmt->execute($updateValues)) {
            $this->sendResponse(200, 'Profile updated successfully');
        } else {
            $this->sendResponse(500, 'Failed to update profile');
        }
    }
    
    private function updateProfilePhoto($user) {
        $userId = $user->user_id;
        
        // Check if file was uploaded
        if (!isset($_FILES['profile_photo']) || $_FILES['profile_photo']['error'] !== UPLOAD_ERR_OK) {
            $this->sendResponse(400, 'No file uploaded or upload error');
            return;
        }
        
        $file = $_FILES['profile_photo'];
        
        // Validate file
        $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
        $maxFileSize = 5 * 1024 * 1024; // 5MB
        
        if (!in_array($file['type'], $allowedTypes)) {
            $this->sendResponse(400, 'Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed');
            return;
        }
        
        if ($file['size'] > $maxFileSize) {
            $this->sendResponse(400, 'File too large. Maximum size is 5MB');
            return;
        }
        
        // Create upload directory if it doesn't exist
        $uploadDir = __DIR__ . '/../../uploads/avatars/';
        if (!file_exists($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                $this->sendResponse(500, 'Failed to create upload directory');
                return;
            }
        }
        
        // Generate unique filename
        $fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'avatar_' . $userId . '_' . uniqid() . '.' . $fileExtension;
        $filepath = $uploadDir . $filename;
        
        // Move uploaded file
        if (!move_uploaded_file($file['tmp_name'], $filepath)) {
            $this->sendResponse(500, 'Failed to move uploaded file');
            return;
        }
        
        // Create different sizes of the image
        $this->createImageSizes($filepath, $uploadDir, $userId, $fileExtension);
        
        // Generate public URL
        $publicUrl = '/uploads/avatars/' . $filename;
        
        // Update database
        $query = "UPDATE users SET profile_photo_url = ?, updated_at = NOW() WHERE id = ?";
        $stmt = $this->db->prepare($query);
        
        if ($stmt->execute([$publicUrl, $userId])) {
            // Get updated user info
            $userQuery = "SELECT profile_photo_url FROM users WHERE id = ?";
            $userStmt = $this->db->prepare($userQuery);
            $userStmt->execute([$userId]);
            $updatedUser = $userStmt->fetch(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, 'Profile photo updated successfully', [
                'profile_photo_url' => $updatedUser['profile_photo_url'],
                'full_url' => $publicUrl
            ]);
        } else {
            // Delete uploaded file if database update failed
            unlink($filepath);
            $this->sendResponse(500, 'Failed to update database');
        }
    }
    
    private function createImageSizes($originalPath, $uploadDir, $userId, $extension) {
        // This is a simplified version - in production, you'd want to use proper image processing
        // For now, we'll just create the original size
        
        // Create thumbnail (150x150)
        $thumbFilename = 'avatar_' . $userId . '_thumb_' . uniqid() . '.' . $extension;
        $thumbPath = $uploadDir . $thumbFilename;
        
        // Simple copy for now - in production, use GD or ImageMagick for resizing
        if (file_exists($originalPath)) {
            copy($originalPath, $thumbPath);
        }
        
        // Create medium size (300x300)
        $mediumFilename = 'avatar_' . $userId . '_medium_' . uniqid() . '.' . $extension;
        $mediumPath = $uploadDir . $mediumFilename;
        
        if (file_exists($originalPath)) {
            copy($originalPath, $mediumPath);
        }
    }
    
    private function formatProfileData($userData) {
        return [
            'basic_info' => [
                'id' => $userData['id'],
                'uuid' => $userData['uuid'],
                'email' => $userData['email'],
                'first_name' => $userData['first_name'],
                'last_name' => $userData['last_name'],
                'middle_name' => $userData['middle_name'],
                'phone' => $userData['phone'],
                'date_of_birth' => $userData['date_of_birth'],
                'place_of_birth' => $userData['place_of_birth'],
                'gender' => $userData['gender'],
                'profile_photo_url' => $userData['profile_photo_url']
            ],
            'academic_info' => [
                'role' => $userData['primary_role'],
                'institution_name' => $userData['institution_name'],
                'department_name' => $userData['department_name'],
                'matricule' => $userData['matricule'],
                'student_id' => $userData['student_id'],
                'level' => $userData['level'],
                'academic_year' => $userData['academic_year'],
                'preinscription_code' => $userData['preinscription_code'],
                'preinscription_status' => $userData['preinscription_status'],
                'faculty' => $userData['faculty'],
                'study_level' => $userData['study_level'],
                'desired_program' => $userData['desired_program']
            ],
            'professional_info' => [
                'bio' => $userData['bio'],
                'address' => $userData['address'],
                'city' => $userData['city'],
                'region' => $userData['region'],
                'country' => $userData['country'],
                'postal_code' => $userData['postal_code'],
                'emergency_contact' => [
                    'name' => $userData['emergency_contact_name'],
                    'phone' => $userData['emergency_contact_phone'],
                    'relationship' => $userData['emergency_contact_relationship']
                ]
            ],
            'account_info' => [
                'account_status' => $userData['account_status'],
                'is_verified' => $userData['is_verified'],
                'is_active' => $userData['is_active'],
                'created_at' => $userData['created_at'],
                'updated_at' => $userData['updated_at'],
                'last_login_at' => $userData['last_login_at']
            ]
        ];
    }
    
    private function sendResponse($statusCode, $message, $data = null) {
        http_response_code($statusCode);
        
        $response = [
            'success' => $statusCode >= 200 && $statusCode < 300,
            'message' => $message
        ];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        echo json_encode($response);
        exit;
    }
}

// Handle the request
$api = new ProfileAPI();
$api->handleRequest();
