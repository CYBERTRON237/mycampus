<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
        throw new Exception('Méthode non autorisée');
    }
    
    // Get unique code from query parameter
    if (!isset($_GET['code']) || empty($_GET['code'])) {
        throw new Exception('Code unique requis');
    }
    
    $unique_code = $_GET['code'];
    
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Données JSON invalides');
    }
    
    // Check if preinscription exists
    $check_query = "SELECT id FROM preinscriptions WHERE unique_code = :unique_code";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(':unique_code', $unique_code);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() === 0) {
        throw new Exception('Préinscription non trouvée');
    }
    
    // Build update query dynamically
    $update_fields = [];
    $params = [];
    
    $allowed_fields = [
        'faculty', 'last_name', 'first_name', 'middle_name', 'date_of_birth',
        'is_birth_date_on_certificate', 'place_of_birth', 'gender', 'cni_number',
        'residence_address', 'marital_status', 'phone_number', 'email',
        'first_language', 'professional_situation', 'status', 'payment_status',
        'documents_status', 'notes', 'admin_notes'
    ];
    
    foreach ($allowed_fields as $field) {
        if (isset($input[$field])) {
            $update_fields[] = "$field = :$field";
            $params[$field] = $input[$field];
        }
    }
    
    if (empty($update_fields)) {
        throw new Exception('Aucun champ à mettre à jour');
    }
    
    // Add last_updated field
    $update_fields[] = "last_updated = CURRENT_TIMESTAMP";
    
    $query = "UPDATE preinscriptions SET " . implode(', ', $update_fields) . " WHERE unique_code = :unique_code";
    
    $stmt = $db->prepare($query);
    
    // Bind parameters
    foreach ($params as $field => $value) {
        $stmt->bindParam(":$field", $params[$field]);
    }
    $stmt->bindParam(':unique_code', $unique_code);
    
    if ($stmt->execute()) {
        // Get the updated record
        $select_query = "SELECT * FROM preinscriptions WHERE unique_code = :unique_code";
        $select_stmt = $db->prepare($select_query);
        $select_stmt->bindParam(':unique_code', $unique_code);
        $select_stmt->execute();
        
        $preinscription = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Préinscription mise à jour avec succès',
            'data' => $preinscription
        ]);
    } else {
        throw new Exception('Erreur lors de la mise à jour de la préinscription');
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
