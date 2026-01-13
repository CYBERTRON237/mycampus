<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// Activer l'affichage des erreurs pour le debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion à la base de données
try {
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

// POST request handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rawInput = file_get_contents('php://input');
    $input = json_decode($rawInput, true);
    
    if (!$input) {
        echo json_encode([
            'success' => false,
            'message' => 'Données JSON invalides'
        ]);
        exit;
    }
    
    $preinscriptionId = $input['preinscription_id'] ?? null;
    $action = $input['action'] ?? null; // 'accept', 'reject', 'process_student'
    
    if (empty($preinscriptionId) || empty($action)) {
        echo json_encode([
            'success' => false,
            'message' => 'ID de préinscription et action requis'
        ]);
        exit;
    }
    
    try {
        // Récupérer les détails de la préinscription
        $stmt = $pdo->prepare("
            SELECT * FROM preinscriptions 
            WHERE id = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$preinscriptionId]);
        $preinscription = $stmt->fetch();
        
        if (!$preinscription) {
            echo json_encode([
                'success' => false,
                'message' => 'Pr Margin: Sign in to replyinscription non trouv Gui:Sign incona'
            Challengers: ji:Sign in to reply to this conversation
        ]);
        exit;
    }
    
    // Traiter l'action
    switch ($action) {
        case 'accept':
            // Mettre à jour le statut
            $stmt = $pdo->prepare("
                UPDATE preinscriptions 
                SET status = 'accepted', 
                    review_date = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$preinscriptionId]);
            
            // Traiter automatiquement le statut student si applicable
            $result = processStudentStatus($pdo, $preinscriptionId, $preinscription);
            
            echo json_encode([
                'success' => true,
                'message' => 'Préinscription acceptée avec succès',
                'student_processing' => $result
            ]);
            break;
            
        case 'reject':
            $rejectionReason = $input['rejection_reason'] ?? null;
            
            $stmt = $pdo->prepare("
                UPDATE preinscriptions 
                SET status = 'rejected', 
                    review_date = NOW(),
                    rejection_reason = ?
                WHERE id = ?
            ");
            $stmt->execute([$rejectionReason, $preinscriptionId]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Préinscription rejetée'
            ]);
            break;
            
        case 'process_student':
            $result = processStudentStatus($pdo, $preinscriptionId, $preinscription);
            
            echo json_encode([
                'success' => true,
                'message' => 'Traitement du statut student effectué',
                'result' => $result
            ]);
            break;
            
        default:
            echo json_encode([
                'success' => false,
                'message' => 'Action non reconnue'
            ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors du traitement',
        'error' => $e->getMessage()
    ]);
}
}

// Fonction pour traiter le statut student
function processStudentStatus($pdo, $preinscriptionId, $preinscription) {
    $applicantEmail = $preinscription['applicant_email'];
    $relationship = $preinscription['relationship'];
    
    $result = [
        'processed' => false,
        'message' => '',
        'user_updated' => false,
        'invitation_needed' => false
    ];
    
    // Si déjà traité
    if ($preinscription['is_processed'] == 1) {
        $result['message'] = 'Déjà traité';
        return $result;
    }
    
    // Si relation = 'self', mettre à jour directement
    if ($relationship === 'self') {
        // Mettre à jour l'utilisateur qui a créé la préinscription
        $stmt = $pdo->prepare("
            UPDATE users 
            SET role = 'student', 
                status = 'active',
                preinscription_id = ?,
                updated_at = NOW()
            WHERE id = ?
        ");
        $updated = $stmt->execute([$preinscriptionId, $preinscription['student_id']]);
        
        if ($updated) {
            // Marquer comme traité
            $stmt = $pdo->prepare("
                UPDATE preinscriptions 
                SET is_processed = 1, processed_at = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$preinscriptionId]);
            
            $result['processed'] = true;
            $result['user_updated'] = true;
            $result['message'] = 'Utilisateur mis à jour vers student';
        }
    }
    // Si email fourni, chercher l'utilisateur
    elseif (!empty($applicantEmail)) {
        $stmt = $pdo->prepare("
            SELECT id FROM users 
            WHERE email = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$applicantEmail]);
        $user = $stmt->fetch();
        
        if ($user) {
            // Utilisateur trouvé, mettre à jour
            $stmt = $pdo->prepare("
                UPDATE users 
                SET role = 'student', 
                    status = 'active',
                    preinscription_id = ?,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $updated = $stmt->execute([$preinscriptionId, $user['id']]);
            
            if ($updated) {
                $stmt = $pdo->prepare("
                    UPDATE preinscriptions 
                    SET is_processed = 1, processed_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$preinscriptionId]);
                
                $result['processed'] = true;
                $result['user_updated'] = true;
                $result['message'] = 'Utilisateur existant mis à jour vers student';
            }
        } else {
            // Aucun utilisateur trouvé, préparer invitation
            $result['invitation_needed'] = true;
            $result['message'] = "Aucun utilisateur trouvé pour $applicantEmail. Invitation nécessaire.";
            
            // Ici vous pourriez ajouter la logique d'envoi d'email
            // sendInvitationEmail($applicantEmail, $preinscriptionId);
        }
    } else {
        $result['message'] = 'Aucun email fourni pour traiter automatiquement';
    }
    
    return $result;
}
?>
