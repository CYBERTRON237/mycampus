<?php
// Version simplifiée qui fonctionne
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    require_once '../config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception('Erreur de connexion à la base de données');
    }
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Méthode non autorisée');
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Données JSON invalides');
    }
    
    // Validation simplifiée
    $required_fields = ['unique_code', 'faculty', 'last_name', 'first_name'];
    
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            throw new Exception("Le champ '$field' est obligatoire");
        }
    }
    
    // Vérifier si le code unique existe déjà
    $check_query = "SELECT id FROM preinscriptions WHERE unique_code = :unique_code";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(':unique_code', $input['unique_code']);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() > 0) {
        throw new Exception('Ce code unique existe déjà');
    }
    
    // Insertion simplifiée avec les champs de base
    $query = "INSERT INTO preinscriptions (
        uuid, unique_code, faculty, last_name, first_name, 
        date_of_birth, gender, email, phone_number, status
    ) VALUES (
        UUID(), :unique_code, :faculty, :last_name, :first_name,
        :date_of_birth, :gender, :email, :phone_number, 'pending'
    )";
    
    $stmt = $db->prepare($query);
    
    $stmt->bindParam(':unique_code', $input['unique_code']);
    $stmt->bindParam(':faculty', $input['faculty']);
    $stmt->bindParam(':last_name', $input['last_name']);
    $stmt->bindParam(':first_name', $input['first_name']);
    
    $date_of_birth = $input['date_of_birth'] ?? '2000-01-01';
    $stmt->bindParam(':date_of_birth', $date_of_birth);
    
    $gender = $input['gender'] ?? 'MASCULIN';
    $stmt->bindParam(':gender', $gender);
    
    $email = $input['email'] ?? 'test@example.com';
    $stmt->bindParam(':email', $email);
    
    $phone_number = $input['phone_number'] ?? '0000000000';
    $stmt->bindParam(':phone_number', $phone_number);
    
    if ($stmt->execute()) {
        $preinscription_id = $db->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription enregistrée avec succès',
            'data' => [
                'id' => $preinscription_id,
                'unique_code' => $input['unique_code']
            ]
        ]);
    } else {
        throw new Exception('Erreur lors de l\'enregistrement: ' . implode(', ', $stmt->errorInfo()));
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error_details' => $e->getTraceAsString()
    ]);
}
?>
