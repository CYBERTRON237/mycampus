<?php
// Headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

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

function generateUUID() {
    return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

function generateMatricule() {
    return 'PRE' . date('Y') . str_pad(mt_rand(1, 99999), 5, '0', STR_PAD_LEFT);
}

// POST request handling
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données JSON invalides']);
        exit;
    }
    
    try {
        // Validation des champs requis
        $required = ['lastName', 'firstName', 'email'];
        
        foreach ($required as $field) {
            if (empty($input[$field])) {
                echo json_encode(['success' => false, 'message' => "Le champ $field est requis"]);
                exit;
            }
        }
        
        // Vérifier si l'email existe déjà pour une préinscription active
        $stmt = $pdo->prepare("SELECT id FROM pre_registrations WHERE email = ? AND status NOT IN ('rejected', 'archived')");
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'Cet email a déjà une préinscription active']);
            exit;
        }
        
        $uuid = generateUUID();
        $matricule = generateMatricule();
        
        // Insertion simple avec les champs de base uniquement
        $sql = "INSERT INTO pre_registrations (
            uuid, user_id, institution_id,
            candidate_first_name, candidate_last_name, candidate_middle_name,
            email, phone, birth_date, birth_place, nationality,
            matricule,
            status, payment_status, notes,
            created_at, updated_at
        ) VALUES (
            ?, ?, ?,
            ?, ?, ?,
            ?, ?, ?, ?, ?,
            ?,
            ?, ?, ?,
            NOW(), NOW()
        )";
        
        $stmt = $pdo->prepare($sql);
        $result = $stmt->execute([
            $uuid,
            1, // user_id (simplifié)
            1, // institution_id (simplifié)
            $input['firstName'] ?? '',
            $input['lastName'] ?? '',
            $input['middleName'] ?? null,
            $input['email'] ?? '',
            $input['phoneNumber'] ?? null,
            $input['dateOfBirth'] ?? null,
            $input['placeOfBirth'] ?? null,
            $input['nationality'] ?? 'Camerounaise',
            $matricule,
            'submitted',
            'pending',
            json_encode($input) // toutes les données dans notes
        ]);
        
        if ($result) {
            echo json_encode([
                'success' => true,
                'message' => 'Préinscription créée avec succès',
                'uuid' => $uuid,
                'matricule' => $matricule,
                'data' => [
                    'uuid' => $uuid,
                    'matricule' => $matricule,
                    'firstName' => $input['firstName'],
                    'lastName' => $input['lastName'],
                    'email' => $input['email'],
                    'faculty' => $input['faculty'] ?? null
                ]
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Erreur lors de l\'insertion'
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la création de la préinscription',
            'error' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée',
        'method' => $_SERVER['REQUEST_METHOD']
    ]);
}
?>
