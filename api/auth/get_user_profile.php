<?php
/**
 * API Get User Profile
 * Récupération complète du profil utilisateur avec toutes les informations
 */

// Configuration des erreurs
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Configuration CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Gestion OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Chargement des dépendances
require __DIR__ . '/../../vendor/autoload.php';
require_once __DIR__ . '/../config/database.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

// Configuration
$secret_key = "YOUR_SECRET_KEY";

/**
 * Fonction pour formater les données utilisateur
 */
function formatUserData($user, $preinscription = null, $stats = null) {
    $formatted = [
        'id' => $user['id'],
        'uuid' => $user['uuid'] ?? null,
        'email' => $user['email'],
        'firstName' => $user['first_name'],
        'lastName' => $user['last_name'],
        'middleName' => $user['middle_name'] ?? null,
        'role' => $user['primary_role'],
        'phone' => $user['phone'] ?? null,
        'address' => $user['address'] ?? null,
        'bio' => $user['bio'] ?? null,
        'avatarUrl' => $user['profile_photo_url'] ?? null,
        'thumbUrl' => $user['thumb_photo_url'] ?? null,
        'dateOfBirth' => $user['date_of_birth'] ?? null,
        'placeOfBirth' => $user['place_of_birth'] ?? null,
        'gender' => $user['gender'] ?? null,
        'city' => $user['city'] ?? null,
        'region' => $user['region'] ?? null,
        'country' => $user['country'] ?? null,
        'postalCode' => $user['postal_code'] ?? null,
        'institutionId' => $user['institution_id'] ?? null,
        'institutionName' => $user['institution_name'] ?? null,
        'departmentName' => $user['department_name'] ?? null,
        'isActive' => (bool)$user['is_active'],
        'isVerified' => (bool)$user['is_verified'],
        'accountStatus' => $user['account_status'],
        'createdAt' => $user['created_at'],
        'updatedAt' => $user['updated_at'],
        'lastLogin' => $user['last_login_at'] ?? null,
        'emergencyContactName' => $user['emergency_contact_name'] ?? null,
        'emergencyContactPhone' => $user['emergency_contact_phone'] ?? null,
        'emergencyContactRelationship' => $user['emergency_contact_relationship'] ?? null,
    ];
    
    // Ajout des informations de préinscription si disponibles
    if ($preinscription) {
        $formatted['preinscription'] = [
            'id' => $preinscription['id'],
            'uniqueCode' => $preinscription['unique_code'],
            'status' => $preinscription['status'],
            'faculty' => $preinscription['faculty'],
            'studyLevel' => $preinscription['study_level'],
            'desiredProgram' => $preinscription['desired_program'],
            'specialization' => $preinscription['specialization'] ?? null,
            'admissionNumber' => $preinscription['admission_number'] ?? null,
            'submissionDate' => $preinscription['submission_date'],
            'processedAt' => $preinscription['processed_at'] ?? null,
            'isProcessed' => (bool)$preinscription['is_processed'],
            'previousDiploma' => $preinscription['previous_diploma'] ?? null,
            'previousInstitution' => $preinscription['previous_institution'] ?? null,
            'scholarshipRequested' => (bool)($preinscription['scholarship_requested'] ?? 0),
            'interviewRequired' => (bool)($preinscription['interview_required'] ?? 0),
            'registrationCompleted' => (bool)($preinscription['registration_completed'] ?? 0),
        ];
    }
    
    // Ajout des statistiques si disponibles
    if ($stats) {
        $formatted['stats'] = $stats;
    }
    
    return $formatted;
}

/**
 * Fonction pour récupérer les statistiques utilisateur
 */
function getUserStats($db, $user_id, $role) {
    $stats = [
        'coursesCount' => 0,
        'assignmentsCount' => 0,
        'gradesAverage' => 0,
        'attendanceRate' => 0,
        'completedCourses' => 0,
        'pendingAssignments' => 0,
    ];
    
    try {
        // Statistiques pour les étudiants
        if ($role === 'student') {
            // Nombre de cours
            $query = "SELECT COUNT(*) as count FROM course_enrollments WHERE student_id = :user_id AND status = 'active'";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $stats['coursesCount'] = (int)$result['count'];
            
            // Nombre de devoirs rendus
            $query = "SELECT COUNT(*) as count FROM assignments_submissions WHERE student_id = :user_id";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $stats['assignmentsCount'] = (int)$result['count'];
            
            // Moyenne générale
            $query = "SELECT AVG(grade) as average FROM grades WHERE student_id = :user_id AND grade IS NOT NULL";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $stats['gradesAverage'] = round((float)$result['average'], 2);
            
            // Taux de présence
            $query = "SELECT 
                        COUNT(CASE WHEN status = 'present' THEN 1 END) as present,
                        COUNT(*) as total
                      FROM attendance 
                      WHERE student_id = :user_id";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $total = (int)$result['total'];
            if ($total > 0) {
                $stats['attendanceRate'] = round(((int)$result['present'] / $total) * 100, 2);
            }
        }
        
        // Statistiques pour les enseignants
        if (in_array($role, ['teacher', 'professor', 'professor_titular'])) {
            // Nombre de cours enseignés
            $query = "SELECT COUNT(*) as count FROM courses WHERE teacher_id = :user_id AND status = 'active'";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $stats['coursesCount'] = (int)$result['count'];
            
            // Nombre total d'étudiants
            $query = "SELECT COUNT(DISTINCT student_id) as count 
                     FROM course_enrollments ce
                     JOIN courses c ON ce.course_id = c.id
                     WHERE c.teacher_id = :user_id AND ce.status = 'active'";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $stats['studentsCount'] = (int)$result['count'];
        }
        
    } catch (Exception $e) {
        error_log("Erreur récupération stats: " . $e->getMessage());
    }
    
    return $stats;
}

// Vérification de la méthode
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée. Utilisez GET.'
    ]);
    exit();
}

// Récupération du token JWT
$headers = getallheaders();
$jwt = null;

if (isset($headers['Authorization'])) {
    if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
        $jwt = $matches[1];
    }
}

// Vérification alternative via GET
if (!$jwt && isset($_GET['token'])) {
    $jwt = $_GET['token'];
}

// Récupération du user_id depuis les paramètres (optionnel, pour admin)
$requested_user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

if (!$jwt) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Token d\'authentification manquant.'
    ]);
    exit();
}

try {
    // Décodage du token
    $decoded = JWT::decode($jwt, new Key($secret_key, 'HS256'));
    $current_user_id = $decoded->data->id;
    $current_user_role = $decoded->data->role ?? 'user';
    
    // Détermination de l'utilisateur à récupérer
    $target_user_id = $requested_user_id ?? $current_user_id;
    
    // Vérification des permissions (seuls les admins peuvent voir d'autres profils)
    if ($target_user_id !== $current_user_id) {
        $admin_roles = ['admin', 'superadmin', 'admin_local', 'admin_national', 'recteur', 'rector'];
        if (!in_array($current_user_role, $admin_roles)) {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Accès non autorisé. Vous ne pouvez consulter que votre propre profil.'
            ]);
            exit();
        }
    }
    
    // Connexion à la base de données
    $database = new Database();
    $db = $database->getConnection();
    
    // Récupération complète du profil utilisateur
    $query = "SELECT 
                u.id,
                u.uuid,
                u.email,
                u.first_name,
                u.last_name,
                u.middle_name,
                u.primary_role,
                u.phone,
                u.address,
                u.bio,
                u.profile_photo_url,
                u.thumb_photo_url,
                u.date_of_birth,
                u.place_of_birth,
                u.gender,
                u.city,
                u.region,
                u.country,
                u.postal_code,
                u.institution_id,
                u.is_active,
                u.is_verified,
                u.account_status,
                u.created_at,
                u.updated_at,
                u.last_login_at,
                u.emergency_contact_name,
                u.emergency_contact_phone,
                u.emergency_contact_relationship,
                i.name as institution_name,
                d.name as department_name
              FROM users u
              LEFT JOIN institutions i ON u.institution_id = i.id
              LEFT JOIN departments d ON u.department_id = d.id
              WHERE u.id = :user_id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $target_user_id);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Utilisateur non trouvé.'
        ]);
        exit();
    }
    
    // Récupération de la préinscription si disponible
    $preinscription = null;
    $preinscription_query = "SELECT * FROM preinscriptions WHERE email = :email ORDER BY submission_date DESC LIMIT 1";
    $preinscription_stmt = $db->prepare($preinscription_query);
    $preinscription_stmt->bindParam(':email', $user['email']);
    $preinscription_stmt->execute();
    $preinscription = $preinscription_stmt->fetch(PDO::FETCH_ASSOC);
    
    // Récupération des statistiques
    $stats = getUserStats($db, $target_user_id, $user['primary_role']);
    
    // Formatage des données
    $formatted_user = formatUserData($user, $preinscription, $stats);
    
    // Récupération de l'historique des photos de profil (5 dernières)
    $history_query = "SELECT photo_url, uploaded_at 
                     FROM profile_photo_history 
                     WHERE user_id = :user_id 
                     ORDER BY uploaded_at DESC 
                     LIMIT 5";
    $history_stmt = $db->prepare($history_query);
    $history_stmt->bindParam(':user_id', $target_user_id);
    $history_stmt->execute();
    $photo_history = $history_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Réponse réussie
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Profil récupéré avec succès.',
        'user' => $formatted_user,
        'photoHistory' => $photo_history,
        'permissions' => [
            'canEdit' => $target_user_id === $current_user_id,
            'canDelete' => $target_user_id === $current_user_id,
            'canViewFull' => true
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur d\'authentification.',
        'error' => $e->getMessage()
    ]);
}
?>
