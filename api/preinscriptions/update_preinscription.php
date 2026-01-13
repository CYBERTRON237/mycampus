<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';
require_once '../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['unique_code']) || empty($data['unique_code'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Code unique requis'
        ]);
        exit();
    }
    
    $unique_code = $data['unique_code'];
    
    // Get current preinscription data
    $stmt = $db->prepare("SELECT * FROM preinscriptions WHERE unique_code = :unique_code");
    $stmt->bindParam(':unique_code', $unique_code);
    $stmt->execute();
    
    $current = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$current) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Préinscription non trouvée'
        ]);
        exit();
    }
    
    // Build update query dynamically
    $update_fields = [];
    $params = [':unique_code' => $unique_code];
    
    $allowed_fields = [
        'first_name', 'last_name', 'middle_name', 'date_of_birth',
        'place_of_birth', 'gender', 'marital_status', 'phone_number',
        'email', 'first_language', 'professional_situation', 'residence_address',
        'faculty', 'previous_diploma', 'previous_institution', 'graduation_year',
        'graduation_month', 'desired_program', 'study_level', 'specialization',
        'gpa_score', 'rank_in_class', 'series_bac', 'bac_year',
        'bac_center', 'bac_mention', 'parent_name', 'parent_phone',
        'parent_email', 'parent_occupation', 'parent_relationship',
        'parent_income_level', 'parent_address', 'payment_method',
        'payment_reference', 'payment_amount', 'payment_status',
        'scholarship_requested', 'scholarship_type'
    ];
    
    foreach ($allowed_fields as $field) {
        if (isset($data[$field])) {
            $update_fields[] = "$field = :$field";
            $params[":$field"] = $data[$field];
        }
    }
    
    if (empty($update_fields)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Aucune donnée à mettre à jour'
        ]);
        exit();
    }
    
    // Add updated_at timestamp
    $update_fields[] = "last_updated = NOW()";
    
    $sql = "UPDATE preinscriptions SET " . implode(', ', $update_fields) . " WHERE unique_code = :unique_code";
    
    $stmt = $db->prepare($sql);
    
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    
    if ($stmt->execute()) {
        // Get updated data
        $stmt = $db->prepare("SELECT * FROM preinscriptions WHERE unique_code = :unique_code");
        $stmt->bindParam(':unique_code', $unique_code);
        $stmt->execute();
        
        $updated_data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Informations mises à jour avec succès',
            'data' => $updated_data
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour: ' . $stmt->errorInfo()[2]
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage()
    ]);
}
?>
