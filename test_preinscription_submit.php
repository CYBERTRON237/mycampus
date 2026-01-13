<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Méthode non autorisée');
    }
    
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Données JSON invalides');
    }
    
    // Log des données reçues pour débogage
    error_log('Données reçues: ' . print_r($input, true));
    
    // Validate required fields
    $required_fields = [
        'unique_code', 'faculty', 'last_name', 'first_name', 'date_of_birth',
        'place_of_birth', 'gender', 'residence_address', 'marital_status',
        'phone_number', 'email', 'first_language', 'professional_situation'
    ];
    
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            throw new Exception("Le champ '$field' est obligatoire");
        }
    }
    
    // Check if unique code already exists
    $check_query = "SELECT id FROM preinscriptions WHERE unique_code = :unique_code";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(':unique_code', $input['unique_code']);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() > 0) {
        throw new Exception('Ce code unique existe déjà');
    }
    
    // Insert preinscription
    $query = "INSERT INTO preinscriptions (
        uuid, unique_code, faculty, last_name, first_name, middle_name,
        date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
        cni_number, residence_address, marital_status, phone_number, email,
        first_language, professional_situation, status, payment_status, documents_status
    ) VALUES (
        UUID(), :unique_code, :faculty, :last_name, :first_name, :middle_name,
        :date_of_birth, :is_birth_date_on_certificate, :place_of_birth, :gender,
        :cni_number, :residence_address, :marital_status, :phone_number, :email,
        :first_language, :professional_situation, 'pending', 'pending', 'pending'
    )";
    
    $stmt = $db->prepare($query);
    
    // Bind parameters
    $stmt->bindParam(':unique_code', $input['unique_code']);
    $stmt->bindParam(':faculty', $input['faculty']);
    $stmt->bindParam(':last_name', $input['last_name']);
    $stmt->bindParam(':first_name', $input['first_name']);
    $stmt->bindParam(':middle_name', $input['middle_name'] ?? null);
    $stmt->bindParam(':date_of_birth', $input['date_of_birth']);
    $stmt->bindParam(':is_birth_date_on_certificate', $input['is_birth_date_on_certificate']);
    $stmt->bindParam(':place_of_birth', $input['place_of_birth']);
    $stmt->bindParam(':gender', $input['gender']);
    $stmt->bindParam(':cni_number', $input['cni_number'] ?? null);
    $stmt->bindParam(':residence_address', $input['residence_address']);
    $stmt->bindParam(':marital_status', $input['marital_status']);
    $stmt->bindParam(':phone_number', $input['phone_number']);
    $stmt->bindParam(':email', $input['email']);
    $stmt->bindParam(':first_language', $input['first_language']);
    $stmt->bindParam(':professional_situation', $input['professional_situation']);
    
    if ($stmt->execute()) {
        $preinscription_id = $db->lastInsertId();
        
        // Get the created record
        $select_query = "SELECT * FROM preinscriptions WHERE id = :id";
        $select_stmt = $db->prepare($select_query);
        $select_stmt->bindParam(':id', $preinscription_id);
        $select_stmt->execute();
        
        $preinscription = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription enregistrée avec succès',
            'data' => $preinscription
        ]);
    } else {
        throw new Exception('Erreur lors de l\'enregistrement de la préinscription');
    }
    
} catch (Exception $e) {
    error_log('Erreur dans submit.php: ' . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
