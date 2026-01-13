<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../../logs/php_errors.log');

require __DIR__ . '/../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

$secret_key = "YOUR_SECRET_KEY";

if (!file_exists(__DIR__ . '/../../logs')) {
    mkdir(__DIR__ . '/../../logs', 0777, true);
}

require_once __DIR__.'/../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Authorization, Content-Type");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

function debug_log($message, $data = null) {
    $logFile = __DIR__ . '/../../logs/api_debug.log';
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message" . PHP_EOL;

    if ($data !== null) {
        $logMessage .= 'Data: ' . print_r($data, true) . PHP_EOL;
    }

    file_put_contents($logFile, $logMessage, FILE_APPEND);
}

function getToken() {
    $headers = getallheaders();
    debug_log('En-têtes de la requête:', $headers);

    $authHeader = null;
    foreach ($headers as $key => $value) {
        if (strtolower($key) === 'authorization') {
            $authHeader = $value;
            break;
        }
    }

    if ($authHeader === null && isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    }

    if (empty($authHeader) && isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }

    debug_log('En-tête d\'autorisation brut:', $authHeader);

    if (empty($authHeader)) {
        debug_log('Aucun en-tête d\'autorisation trouvé');
        return null;
    }

    if (preg_match('/^(Bearer|Token)[\s]+(.*)$/i', $authHeader, $matches)) {
        $token = trim($matches[2]);
        debug_log('Token extrait:', $token);
        return $token;
    }

    debug_log('Format d\'en-tête d\'autorisation non reconnu');
    return null;
}

try {
    $token = getToken();
    debug_log('Token final:', $token);

    if (empty($token)) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Token manquant ou invalide',
            'debug' => [
                'headers' => getallheaders(),
                'server' => [
                    'HTTP_AUTHORIZATION' => $_SERVER['HTTP_AUTHORIZATION'] ?? 'Non défini',
                    'REDIRECT_HTTP_AUTHORIZATION' => $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? 'Non défini',
                ]
            ]
        ]);
        exit;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur interne',
        'debug' => [
            'error' => $e->getMessage(),
        ]
    ]);
    exit;
}

try {
    $database = new Database();
    $db = $database->getConnection();

    if ($db === null) {
        throw new Exception('Impossible de se connecter à la base de données');
    }

    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    debug_log('Connexion à la base de données établie avec succès');
    debug_log('Validation du token JWT...');

    try {
        $decoded = JWT::decode($token, new Key($secret_key, 'HS256'));

        $user_id = $decoded->data->id;
        $user_email = $decoded->data->email;

        debug_log('Token JWT validé avec succès', [
            'user_id' => $user_id,
            'email' => $user_email,
            'expires_at' => date('Y-m-d H:i:s', $decoded->exp)
        ]);

        $stmt = $db->prepare("
            SELECT
                u.*,
                i.name as institution_name,
                d.name as department_name
            FROM users u
            LEFT JOIN institutions i ON i.id = u.institution_id
            LEFT JOIN departments d ON d.id = u.department_id
            WHERE u.id = :user_id
            AND u.is_active = 1
            AND u.account_status = 'active'
            LIMIT 1
        ");

        $stmt->execute([':user_id' => $user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            debug_log('Aucun utilisateur actif trouvé avec cet ID', ['user_id' => $user_id]);
            throw new Exception('Utilisateur non trouvé ou compte inactif');
        }

        if ($user['email'] !== $user_email) {
            debug_log('Email du token ne correspond pas à celui de l\'utilisateur', [
                'token_email' => $user_email,
                'db_email' => $user['email']
            ]);
            throw new Exception('Token invalide');
        }

        $user['institution_name'] = $user['institution_name'] ?? null;
        $user['department_name'] = $user['department_name'] ?? null;

    } catch (Exception $e) {
        debug_log('Erreur lors de la validation du token JWT: ' . $e->getMessage());

        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Token invalide ou expiré',
            'error' => $e->getMessage(),
            'debug' => [
                'token_length' => strlen($token),
                'token_prefix' => substr($token, 0, 5) . '...' . substr($token, -5)
            ]
        ]);
        exit;
    }

    debug_log('Utilisateur trouvé et authentifié avec succès', [
        'user_id' => $user['id'],
        'email' => $user['email'],
        'role' => $user['primary_role'] ?? 'unknown',
        'institution' => $user['institution_name'] ?? 'unknown'
    ]);

} catch (PDOException $e) {
    $error_message = 'Erreur de base de données: ' . $e->getMessage();
    debug_log($error_message, ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de base de données',
        'debug' => [
            'error' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
    exit;

} catch (Exception $e) {
    $error_message = 'Erreur inattendue: ' . $e->getMessage();
    debug_log($error_message, ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur inattendue',
        'debug' => [
            'error' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
    exit;
}

$stats = [];
$instId = $user['institution_id'];
$uid = $user['id'];
$role = $user['primary_role'];

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM users WHERE primary_role = 'student' AND institution_id = ? AND is_active = 1");
    $stmt->execute([$instId]);
    $stats['total_students'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['total_students'] = 0;
    debug_log('Erreur lors du comptage des étudiants: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM users WHERE primary_role = 'teacher' AND institution_id = ? AND is_active = 1");
    $stmt->execute([$instId]);
    $stats['total_teachers'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['total_teachers'] = 0;
    debug_log('Erreur lors du comptage des enseignants: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM user_groups WHERE institution_id = ? AND status = 'active'");
    $stmt->execute([$instId]);
    $stats['groups'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['groups'] = 0;
    debug_log('Erreur lors du comptage des groupes: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM announcements WHERE institution_id = ? AND status = 'published'");
    $stmt->execute([$instId]);
    $stats['announcements'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['announcements'] = 0;
    debug_log('Erreur lors du comptage des annonces: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM opportunities WHERE institution_id = ? AND status = 'published'");
    $stmt->execute([$instId]);
    $stats['opportunities'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['opportunities'] = 0;
    debug_log('Erreur lors du comptage des opportunités: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM messages WHERE sender_id = ?");
    $stmt->execute([$uid]);
    $stats['messages_sent'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['messages_sent'] = 0;
    debug_log('Erreur lors du comptage des messages: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("
        SELECT COUNT(DISTINCT ug.id)
        FROM user_groups ug
        INNER JOIN group_members gm ON gm.group_id = ug.id
        WHERE gm.user_id = ? AND gm.status = 'active'
    ");
    $stmt->execute([$uid]);
    $stats['user_groups'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['user_groups'] = 0;
    debug_log('Erreur lors du comptage de la participation aux groupes: ' . $e->getMessage());
}

try {
    $stmt = $db->prepare("SELECT COUNT(*) FROM programs p INNER JOIN departments d ON p.department_id = d.id INNER JOIN faculties f ON d.faculty_id = f.id WHERE f.institution_id = ?");
    $stmt->execute([$instId]);
    $stats['total_courses'] = (int)$stmt->fetchColumn();
} catch (PDOException $e) {
    $stats['total_courses'] = 0;
    debug_log('Erreur lors du comptage des cours: ' . $e->getMessage());
}

$logs = [];
try {
    $stmt = $db->prepare("
        SELECT
            event_type,
            description,
            DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as created_at
        FROM security_logs
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT 10
    ");
    $stmt->execute([$uid]);
    $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $logs = [];
    debug_log('Erreur lors de la récupération des logs: ' . $e->getMessage());
}

$events = [];
try {
    $stmt = $db->prepare("
        SELECT
            id,
            title,
            DATE_FORMAT(start_date, '%Y-%m-%d') as start_date,
            DATE_FORMAT(end_date, '%Y-%m-%d') as end_date,
            location
        FROM events
        WHERE institution_id = ?
        AND start_date >= CURDATE()
        ORDER BY start_date ASC
        LIMIT 10
    ");
    $stmt->execute([$instId]);
    $events = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $events = [];
    debug_log('Erreur lors de la récupération des événements: ' . $e->getMessage());
}

$activities = [];
try {
    $stmt = $db->prepare("
        SELECT
            al.id,
            al.action as type,
            al.description,
            DATE_FORMAT(al.created_at, '%Y-%m-%d %H:%i') as created_at,
            u.first_name,
            u.last_name,
            u.profile_photo_url as avatar
        FROM activity_logs al
        JOIN users u ON al.user_id = u.id
        WHERE u.institution_id = ?
        ORDER BY al.created_at DESC
        LIMIT 20
    ");
    $stmt->execute([$instId]);
    $activities = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $activities = [];
    debug_log('Erreur lors de la récupération des activités: ' . $e->getMessage());
}

$recentAnnouncements = [];
try {
    $stmt = $db->prepare("
        SELECT
            id,
            uuid,
            title,
            content,
            priority,
            category,
            DATE_FORMAT(published_at, '%Y-%m-%d %H:%i') as created_at
        FROM announcements
        WHERE institution_id = ?
        AND status = 'published'
        ORDER BY published_at DESC
        LIMIT 10
    ");
    $stmt->execute([$instId]);
    $recentAnnouncements = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $recentAnnouncements = [];
    debug_log('Erreur lors de la récupération des annonces: ' . $e->getMessage());
}

$activeGroups = [];
try {
    $stmt = $db->prepare("
        SELECT
            ug.id,
            ug.uuid,
            ug.name,
            ug.description,
            ug.group_type,
            ug.current_members_count as members_count,
            ug.cover_image_url
        FROM user_groups ug
        INNER JOIN group_members gm ON ug.id = gm.group_id
        WHERE ug.institution_id = ?
        AND ug.status = 'active'
        AND gm.user_id = ?
        AND gm.status = 'active'
        ORDER BY ug.created_at DESC
        LIMIT 12
    ");
    $stmt->execute([$instId, $uid]);
    $activeGroups = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $activeGroups = [];
    debug_log('Erreur lors de la récupération des groupes: ' . $e->getMessage());
}

$recentOpportunities = [];
try {
    $stmt = $db->prepare("
        SELECT
            id,
            uuid,
            title,
            description,
            type,
            company_name,
            location,
            is_featured,
            DATE_FORMAT(application_deadline, '%Y-%m-%d') as deadline,
            DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as created_at
        FROM opportunities
        WHERE (institution_id = ? OR scope = 'national')
        AND status = 'published'
        AND (application_deadline >= CURDATE() OR application_deadline IS NULL)
        ORDER BY is_featured DESC, created_at DESC
        LIMIT 15
    ");
    $stmt->execute([$instId]);
    $recentOpportunities = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $recentOpportunities = [];
    debug_log('Erreur lors de la récupération des opportunités: ' . $e->getMessage());
}

$userStats = [];
try {
    $stmt = $db->prepare("
        SELECT
            COUNT(DISTINCT p.id) as posts_count,
            COUNT(DISTINCT c.id) as comments_count,
            COUNT(DISTINCT m.id) as messages_count
        FROM users u
        LEFT JOIN posts p ON u.id = p.author_id AND p.status = 'published'
        LEFT JOIN comments c ON u.id = c.author_id AND c.status = 'published'
        LEFT JOIN messages m ON u.id = m.sender_id
        WHERE u.id = ?
    ");
    $stmt->execute([$uid]);
    $userStats = $stmt->fetch(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $userStats = [
        'posts_count' => 0,
        'comments_count' => 0,
        'messages_count' => 0
    ];
    debug_log('Erreur lors de la récupération des statistiques utilisateur: ' . $e->getMessage());
}

$institutionStats = [];
if (in_array($role, ['admin_local', 'admin_national', 'superadmin'])) {
    try {
        $stmt = $db->prepare("
            SELECT
                COUNT(DISTINCT ug.id) as total_groups,
                COUNT(DISTINCT a.id) as total_announcements,
                COUNT(DISTINCT o.id) as total_opportunities,
                COUNT(DISTINCT p.id) as total_posts
            FROM institutions i
            LEFT JOIN user_groups ug ON i.id = ug.institution_id AND ug.status = 'active'
            LEFT JOIN announcements a ON i.id = a.institution_id AND a.status = 'published'
            LEFT JOIN opportunities o ON i.id = o.institution_id AND o.status = 'published'
            LEFT JOIN posts p ON ug.id = p.group_id AND p.status = 'published'
            WHERE i.id = ?
        ");
        $stmt->execute([$instId]);
        $institutionStats = $stmt->fetch(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        $institutionStats = [];
        debug_log('Erreur lors de la récupération des stats institution: ' . $e->getMessage());
    }
}

$response = [
    'success' => true,
    'user' => [
        'id' => $user['id'] ?? null,
        'email' => $user['email'] ?? null,
        'first_name' => $user['first_name'] ?? null,
        'last_name' => $user['last_name'] ?? null,
        'role' => $user['primary_role'] ?? 'user',
        'phone' => $user['phone'] ?? null,
        'avatar_url' => $user['profile_photo_url'] ?? null,
        'institution_name' => $user['institution_name'] ?? null,
        'department_name' => $user['department_name'] ?? null,
        'account_status' => $user['account_status'] ?? 'active',
        'last_login' => $user['last_login_at'] ?? null,
        'is_active' => $user['is_active'] ?? 1,
        'level' => $user['level'] ?? null,
        'matricule' => $user['matricule'] ?? null,
    ],
    'stats' => array_merge($stats, $userStats, $institutionStats),
    'recent_logs' => $logs,
    'recent_activities' => $activities,
    'upcoming_events' => $events,
    'recent_announcements' => $recentAnnouncements,
    'active_groups' => $activeGroups,
    'recent_opportunities' => $recentOpportunities,
    'timestamp' => gmdate('c'),
    'server_time' => date('Y-m-d H:i:s'),
];

debug_log('Réponse finale générée avec succès', [
    'user_id' => $user['id'],
    'stats_count' => count($stats),
    'activities_count' => count($activities),
    'events_count' => count($events),
    'logs_count' => count($logs),
    'announcements_count' => count($recentAnnouncements),
    'groups_count' => count($activeGroups),
    'opportunities_count' => count($recentOpportunities),
]);

echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
