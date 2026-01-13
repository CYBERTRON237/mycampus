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

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        echo json_encode(['success' => false, 'message' => 'Données JSON invalides']);
        exit;
    }
    
    // Validation des champs requis
    $required = ['faculty', 'lastName', 'firstName', 'dateOfBirth', 'placeOfBirth', 
                 'gender', 'residenceAddress', 'maritalStatus', 'phoneNumber', 'email'];
    
    $missing = [];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            $missing[] = $field;
        }
    }
    
    if (!empty($missing)) {
        echo json_encode([
            'success' => false, 
            'message' => 'Champs requis manquants',
            'missing' => $missing,
            'received' => array_keys($input)
        ]);
        exit;
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Données reçues avec succès',
        'data' => $input
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
