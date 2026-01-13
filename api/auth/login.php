<?php
// Activer l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Charger l'autoloader de Composer
require __DIR__ . '/../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

// Activer la journalisation des erreurs
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../../logs/php_errors.log');

// Créer le répertoire de logs s'il n'existe pas
if (!file_exists(__DIR__ . '/../../logs')) {
    mkdir(__DIR__ . '/../../logs', 0777, true);
}

// Fonction pour logger les erreurs dans un fichier spécifique
function log_debug($message, $data = null) {
    $logFile = __DIR__ . '/../../logs/api_debug.log';
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message" . PHP_EOL;
    
    if ($data !== null) {
        $logMessage .= 'Data: ' . print_r($data, true) . PHP_EOL;
    }
    
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}

// Démarrer la journalisation
error_log("=== Début de la requête de connexion ===");
log_debug("Début de la requête de connexion");

// Log des informations du serveur et des en-têtes
log_debug("Informations du serveur", [
    'PHP Version' => phpversion(),
    'SAPI' => php_sapi_name(),
    'Document Root' => $_SERVER['DOCUMENT_ROOT'] ?? 'Non défini',
    'Script Filename' => $_SERVER['SCRIPT_FILENAME'] ?? 'Non défini',
    'Request Method' => $_SERVER['REQUEST_METHOD'] ?? 'Non défini',
    'Content Type' => $_SERVER['CONTENT_TYPE'] ?? 'Non défini',
    'Headers' => getallheaders()
]);

// Vérifier si les extensions PDO et PDO_MySQL sont chargées
log_debug("Extensions PHP chargées", [
    'PDO' => extension_loaded('pdo') ? 'Oui' : 'Non',
    'PDO_MySQL' => extension_loaded('pdo_mysql') ? 'Oui' : 'Non',
    'JSON' => extension_loaded('json') ? 'Oui' : 'Non',
    'OpenSSL' => extension_loaded('openssl') ? 'Oui' : 'Non'
]);

// Vérifier les permissions du répertoire
log_debug("Permissions du répertoire", [
    'Répertoire courant' => getcwd(),
    'Est accessible en écriture' => is_writable('.') ? 'Oui' : 'Non',
    'Espace disque disponible' => disk_free_space('.') . ' octets'
]);

// Désactiver Xdebug pour les requêtes API si présent
if (function_exists('xdebug_disable')) {
    xdebug_disable();
}

session_start();
require_once '../config/database.php';

// ------------------- Buffering et handlers -------------------
// Démarrer le buffer pour capturer toute sortie HTML non voulue
ob_start();

// Fonction pour logger les erreurs dans les logs
function log_message($data) {
    $output = is_array($data) ? json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) : $data;
    error_log('Login: ' . $output);
}

// Fonction utilitaire pour tronquer du texte
function _truncate($text, $max = 2000) {
    if ($text === null) return null;
    if (mb_strlen($text) <= $max) return $text;
    return mb_substr($text, 0, $max) . '... (truncated)';
}

// Répondre systématiquement en JSON et inclure tout output HTML capturé
function respondJson(array $payload, int $httpStatus = 200) {
    // Récupérer et nettoyer le buffer de sortie
    $extraOutput = trim(ob_get_clean() ?? '');
    // Détecter si l'output contient du HTML/DOCTYPES ou balises probables
    if (!empty($extraOutput) && preg_match('/(<\s*html|<!DOCTYPE|<\s*script|<\s*body|<\s*div)/i', $extraOutput)) {
        // Log du HTML complet (attention aux logs volumineux)
        log_message("Sortie HTML détectée (début): " . _truncate($extraOutput, 2000));
        // Ajouter au payload une version tronquée pour le client
        $payload['server_debug_html'] = _truncate($extraOutput, 2000);
        $payload['server_debug_html_detected'] = true;
    } elseif (!empty($extraOutput)) {
        // Si output non vide mais pas manifestement du HTML, logguer quand même
        log_message("Sortie inattendue détectée (non-HTML) : " . _truncate($extraOutput, 2000));
        $payload['server_debug_output'] = _truncate($extraOutput, 2000);
    }

    // Forcer l'en-tête JSON
    if (!headers_sent()) {
        header("Content-Type: application/json; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: POST, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");
    }
    http_response_code($httpStatus);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    // S'assurer que rien d'autre ne s'affiche
    exit();
}

// Gestionnaire d'exceptions pour renvoyer du JSON en cas d'exception non attrapée
set_exception_handler(function ($e) {
    $err = 'Exception non gérée: ' . $e->getMessage() . ' en ' . $e->getFile() . ' ligne ' . $e->getLine();
    log_message($err);
    log_message('Trace: ' . $e->getTraceAsString());
    respondJson([
        'success' => false,
        'message' => 'Erreur serveur inattendue (exception)',
        'error' => $err,
        'trace' => $e->getTraceAsString()
    ], 500);
});

// Catcher les erreurs fatales à la fin de l'exécution
register_shutdown_function(function () {
    $lastError = error_get_last();
    if ($lastError !== null && in_array($lastError['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR, E_PARSE])) {
        $err = 'Erreur fatale: ' . $lastError['message'] . ' en ' . $lastError['file'] . ' ligne ' . $lastError['line'];
        log_message($err);
        respondJson([
            'success' => false,
            'message' => 'Erreur serveur fatale',
            'error' => $err
        ], 500);
    }
});

// ------------------- Fin buffering & handlers -------------------

// Gestion des requêtes OPTIONS (pré-vol)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    respondJson(['success' => true, 'message' => 'OK (preflight)'], 200);
}

// Vérification de la méthode HTTP
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respondJson(['success' => false, 'message' => 'Méthode non autorisée'], 405);
}

// Connexion à la base de données
try {
    log_message('Tentative de connexion à la base de données...');
    log_debug('Connexion à la base de données', [
        'host' => 'localhost',
        'dbname' => 'mycampus',
        'username' => 'root',
        'password' => '(masqué)'
    ]);
    
    $database = new Database();
    $pdo = $database->getConnection();
    
    // Vérifier si la connexion est établie
    if ($pdo === null) {
        log_debug('Échec de la connexion à la base de données: $pdo est null');
        throw new Exception('Impossible de se connecter à la base de données: connexion nulle');
    }
    
    // Tester la connexion avec une requête simple
    $testQuery = $pdo->query('SELECT 1');
    if ($testQuery === false) {
        $errorInfo = $pdo->errorInfo();
        log_debug('Échec de la requête de test', [
            'error' => $errorInfo
        ]);
        throw new Exception('Erreur lors de la vérification de la connexion: ' . ($errorInfo[2] ?? 'Inconnue'));
    }
    
    log_message('Connexion à la base de données établie avec succès');
    log_debug('Connexion à la base de données établie avec succès');
} catch (Exception $e) {
    $errorMsg = 'Erreur de connexion à la base de données: ' . $e->getMessage();
    log_message($errorMsg);
    respondJson(['success' => false, 'message' => 'Erreur de connexion à la base de données', 'error' => $errorMsg], 500);
}

// Récupération des données de la requête
$rawInput = file_get_contents("php://input");
$jsonData = json_decode($rawInput, true);

// Log des données brutes (sensible, à désactiver en production si nécessaire)
log_message('Données brutes reçues: ' . _truncate($rawInput, 2000));

if (json_last_error() !== JSON_ERROR_NONE) {
    $errorMsg = 'Erreur de décodage JSON: ' . json_last_error_msg() . ' - Données reçues: ' . _truncate($rawInput, 2000);
    log_message($errorMsg);
    respondJson(['success' => false, 'message' => 'Format de données invalide', 'error' => $errorMsg], 400);
}

// Validation des entrées
log_message('Validation des entrées...');
$email = $jsonData['email'] ?? null;
$password = $jsonData['password'] ?? null;
log_message('Email: ' . ($email ?? 'non défini'));
log_message('Mot de passe: ' . (isset($password) ? 'défini' : 'non défini'));

if (empty($email) || empty($password)) {
    log_message('Email et mot de passe requis');
    respondJson(['success' => false, 'message' => 'Email et mot de passe requis'], 400);
}

// Vérification du format de l'email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    log_message('Format d\'email invalide');
    respondJson(['success' => false, 'message' => 'Format d\'email invalide'], 400);
}

// Protection contre les attaques par force brute
if (isset($_SESSION['login_attempts']) && $_SESSION['login_attempts'] >= 5) {
    $lastAttempt = $_SESSION['last_login_attempt'] ?? 0;
    $waitTime = 300 - (time() - $lastAttempt); // 5 minutes d'attente
    
    if ($waitTime > 0) {
        respondJson([
            'success' => false, 
            'message' => 'Trop de tentatives de connexion. Veuillez réessayer dans ' . ceil($waitTime/60) . ' minutes.'
        ], 429);
    } else {
        // Réinitialiser le compteur après la période d'attente
        unset($_SESSION['login_attempts']);
        unset($_SESSION['last_login_attempt']);
    }
}

// Vérification de l'utilisateur dans la base de données
$query = "SELECT 
            u.id, 
            u.email, 
            u.password_hash as password, 
            u.is_active, 
            u.first_name, 
            u.last_name,
            u.institution_id,
            u.primary_role as role,
            u.phone,
            u.profile_photo_url as avatar_url,
            u.last_login_at as last_login,
            u.last_login_at as last_attempt,
            u.failed_login_attempts as login_attempts,
            u.is_verified,
            u.account_status,
            u.is_active,
            u.created_at,
            u.updated_at,
            i.name as institution_name 
          FROM users u 
          LEFT JOIN institutions i ON u.institution_id = i.id 
          WHERE u.email = :email 
          LIMIT 1";
    
try {
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        log_message('Aucun utilisateur trouvé avec cet email: ' . $email);
        respondJson([
            'success' => false,
            'message' => 'Identifiants incorrects',
            'error' => 'Aucun utilisateur trouvé avec cet email'
        ], 401);
    }

    // Vérification du statut du compte
    if ($user['is_active'] != 1) {
        respondJson(['success' => false, 'message' => 'Ce compte est désactivé. Veuillez contacter l\'administrateur.'], 403);
    }

    // Vérification du mot de passe
    $debug_info = [];
    
    // Récupération de la structure de la table users (utile pour debug)
    try {
        $stmtCols = $pdo->query("SHOW COLUMNS FROM users");
        $columns = $stmtCols->fetchAll(PDO::FETCH_ASSOC);
        $debug_info['structure_table'] = $columns;
    } catch (Exception $e) {
        $debug_info['structure_table_error'] = $e->getMessage();
        log_message('Impossible d\'obtenir la structure de la table users: ' . $e->getMessage());
    }
    
    $debug_info['mot_de_passe_fourni'] = _truncate($password, 200);
    $debug_info['hachage_stocke'] = _truncate($user['password'], 200);
    // Ne pas logguer le hash du mot de passe fourni (on le calcule ci-dessous si besoin)
    
    if (!password_verify($password, $user['password'])) {
        $debug_info['verification'] = 'echec';
        log_message('Mot de passe incorrect pour l\'utilisateur: ' . $user['email']);
        
        // Mise à jour de la dernière tentative (sans login_attempts qui n'existe pas)
        try {
            $updateStmt = $pdo->prepare("UPDATE users SET last_attempt = NOW() WHERE id = :id");
            $updateStmt->execute([':id' => $user['id']]);
        } catch (PDOException $e) {
            // Ignorer l'erreur si la colonne n'existe pas
            log_message('Erreur lors de la mise à jour de last_attempt: ' . $e->getMessage());
        }
        
        respondJson([
            'success' => false,
            'message' => 'Identifiants incorrects',
            'error' => 'Mot de passe incorrect',
            'attempts' => 1,
            'debug' => $debug_info
        ], 401);
    }

    // Réinitialiser le compteur de tentatives en cas de succès
    unset($_SESSION['login_attempts']);
    unset($_SESSION['last_login_attempt']);

    // Si on arrive ici, la connexion est réussie
    // Vérifier si le compte est actif et vérifié
    if ($user['account_status'] !== 'active' || !$user['is_verified']) {
        log_message('Tentative de connexion avec un compte non actif ou non vérifié', [
            'user_id' => $user['id'],
            'account_status' => $user['account_status'],
            'is_verified' => $user['is_verified']
        ]);
        
        // Activer et vérifier le compte automatiquement pour la première connexion
        $user['account_status'] = 'active';
        $user['is_verified'] = 1;
        $accountActivated = true;
    } else {
        $accountActivated = false;
    }
    
    // Générer un token JWT
    $secret_key = "YOUR_SECRET_KEY"; // Utilisez la même clé que dans me.php
    $issuedAt = time();
    $expirationTime = $issuedAt + 86400; // valide pour 24 heures
    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    
    // Données à inclure dans le token
    $tokenData = [
        'iat'  => $issuedAt,         // Heure d'émission
        'exp'  => $expirationTime,   // Heure d'expiration
        'iss'  => 'mycampus',        // Émetteur
        'data' => [                  // Données personnalisées
            'id' => $user['id'],
            'email' => $user['email'],
            'ip' => $ipAddress
        ]
    ];
    
    // Générer le token JWT
    $jwt = JWT::encode($tokenData, $secret_key, 'HS256');
    
    // Pour la rétrocompatibilité, on garde le hachage du token pour la base de données
    $hashedToken = hash('sha256', $jwt);
    $expiresAt = date('Y-m-d H:i:s', $expirationTime);
    
    log_message('Connexion réussie pour l\'utilisateur ID: ' . $user['id']);
    log_message('JWT généré: ' . $jwt);
    log_message('Token haché: ' . $hashedToken);
    log_message('Nouveau statut du compte:', [
        'account_status' => $user['account_status'],
        'is_verified' => $user['is_verified']
    ]);
    
    // Mise à jour des informations de connexion ET présence en ligne
    try {
        // Démarrer une transaction pour s'assurer que toutes les mises à jour sont effectuées
        $pdo->beginTransaction();
        
        // 1. Mettre à jour la présence en ligne
        $presenceQuery = "INSERT INTO user_presence (user_id, is_online, status, last_seen, created_at) 
                         VALUES (:userId, 1, 'online', NOW(), NOW())
                         ON DUPLICATE KEY UPDATE 
                         is_online = 1, 
                         status = 'online', 
                         last_seen = NOW()";
        
        $presenceStmt = $pdo->prepare($presenceQuery);
        $presenceStmt->execute([':userId' => $user['id']]);
        
        // 2. Préparer la requête de mise à jour
        $updateFields = [
            'last_login_at = NOW()',
            'last_attempted_at = NOW()',
            'auth_token = :hashedToken',
            'token_expires_at = :expiresAt',
            'login_count = IFNULL(login_count, 0) + 1',
            'last_login_ip = :ipAddress',
            'failed_login_attempts = 0',
            'locked_until = NULL'
        ];
        
        $params = [
            ':id' => $user['id'],
            ':hashedToken' => $hashedToken,
            ':expiresAt' => $expiresAt,
            ':ipAddress' => $ipAddress
        ];
        
        // Ajouter les champs de statut de compte si nécessaire
        if ($accountActivated) {
            $updateFields[] = 'account_status = :accountStatus';
            $updateFields[] = 'is_verified = :isVerified';
            $params[':accountStatus'] = $user['account_status'];
            $params[':isVerified'] = $user['is_verified'];
        }
        
        // Construire et exécuter la requête
        $updateQuery = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = :id";
        
        log_message('Requête de mise à jour:', [
            'query' => $updateQuery,
            'params' => $params
        ]);
        
        $updateStmt = $pdo->prepare($updateQuery);
        
        try {
            $updateResult = $updateStmt->execute($params);
            
            if ($updateResult) {
                $pdo->commit();
                log_message('Mise à jour réussie dans la base de données');
                
                // Vérifier que le token a bien été enregistré
                $checkStmt = $pdo->prepare("SELECT auth_token, token_expires_at, account_status, is_verified FROM users WHERE id = ?");
                $checkStmt->execute([$user['id']]);
                $result = $checkStmt->fetch(PDO::FETCH_ASSOC);
                $storedToken = $result['auth_token'] ?? null;
                
                log_message('Vérification du stockage du token:');
                log_message('- Token stocké: ' . ($storedToken ? 'Oui (' . strlen($storedToken) . ' caractères)' : 'Non'));
                log_message('- Token attendu: ' . $hashedToken);
                log_message('- Statut du compte: ' . ($result['account_status'] ?? 'inconnu'));
                log_message('- Vérifié: ' . ($result['is_verified'] ?? 'inconnu'));
                
                if ($storedToken) {
                    $tokenMatch = hash_equals($storedToken, $hashedToken) ? 'OUI' : 'NON';
                    log_message('- Correspondance des tokens: ' . $tokenMatch);
                    
                    if ($tokenMatch === 'NON') {
                        log_message('ERREUR: Le token stocké ne correspond pas au token généré!');
                    }
                } else {
                    log_message('ERREUR: Aucun token n\'a été stocké dans la base de données');
                    throw new Exception('Échec du stockage du token d\'authentification');
                }
            } else {
                $errorInfo = $updateStmt->errorInfo();
                log_message('Erreur lors de la mise à jour de l\'utilisateur:', [
                    'code' => $errorInfo[0],
                    'message' => $errorInfo[2] ?? 'Aucun message d\'erreur',
                    'sqlstate' => $errorInfo[0] ?? 'N/A'
                ]);
                throw new Exception('Échec de la mise à jour de l\'utilisateur dans la base de données');
            }
        } catch (PDOException $e) {
            $pdo->rollBack();
            log_message('Erreur PDO lors de la mise à jour: ' . $e->getMessage());
            log_message('Code d\'erreur: ' . $e->getCode());
            log_message('Fichier: ' . $e->getFile() . ' ligne ' . $e->getLine());
            throw new Exception('Erreur lors de la mise à jour des informations de connexion');
        }
    } catch (PDOException $e) {
        log_message('Erreur lors de la mise à jour des informations de connexion: ' . $e->getMessage());
        // On continue malgré l'erreur car la connexion est valide
    }
    
    // Préparer les données utilisateur à renvoyer
    unset($user['password_hash'], $user['password'], $user['auth_token']);
    
    $response = [
        'success' => true,
        'message' => $accountActivated ? 'Compte activé avec succès' : 'Connexion réussie',
        'token' => $jwt, // On renvoie le JWT au client
        'token_type' => 'bearer',
        'expires_in' => 86400, // 24 heures en secondes
        'expires_at' => $expiresAt,
        'user' => [
            'id' => $user['id'],
            'email' => $user['email'],
            'first_name' => $user['first_name'] ?? '',
            'last_name' => $user['last_name'] ?? '',
            'role' => $user['primary_role'] ?? 'user',
            'is_active' => true, // Toujours vrai car la connexion a réussi
            'is_verified' => (bool)($user['is_verified'] ?? false),
            'account_status' => $user['account_status'] ?? 'active',
            'profile_photo_url' => $user['profile_photo_url'] ?? null,
            'institution_id' => $user['institution_id'] ?? null,
            'last_login' => date('Y-m-d H:i:s'), // Utiliser l'heure actuelle
            'account_activated' => $accountActivated // Indique si le compte vient d'être activé
        ]
    ];
    
    // Ajouter un message supplémentaire si le compte vient d'être activé
    if ($accountActivated) {
        $response['user']['welcome_message'] = 'Votre compte a été activé avec succès !';
    }
    
    log_message('Envoi de la réponse de succès');
    respondJson($response, 200);

} catch (PDOException $e) {
    $errorMsg = 'Erreur de base de données: ' . $e->getMessage() . ' dans ' . $e->getFile() . ' à la ligne ' . $e->getLine();
    log_message($errorMsg);
    log_message('Trace de la pile: ' . $e->getTraceAsString());
    respondJson([
        'success' => false, 
        'message' => 'Erreur de serveur. Veuillez réessayer plus tard.',
        'error' => $errorMsg,
        'trace' => $e->getTraceAsString()
    ], 500);
} catch (Exception $e) {
    $errorMsg = 'Erreur inattendue: ' . $e->getMessage() . ' dans ' . $e->getFile() . ' à la ligne ' . $e->getLine();
    log_message($errorMsg);
    log_message('Trace de la pile: ' . $e->getTraceAsString());
    respondJson([
        'success' => false, 
        'message' => 'Une erreur inattendue est survenue.',
        'error' => $errorMsg
    ], 500);
}
?>
