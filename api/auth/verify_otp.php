<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../config/database.php';

// Autoriser les requêtes CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Gérer les requêtes OPTIONS pour CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Vérifier si la requête est de type POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    exit();
}

// Récupérer les données de la requête
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Valider les données
if (empty($data['phone']) || empty($data['code'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Le numéro de téléphone et le code sont requis']);
    exit();
}

$phone = $data['phone'];
$code = $data['code'];
$purpose = $data['purpose'] ?? 'verification';

// Nettoyer et formater le numéro
$phone = preg_replace('/[^0-9+]/', '', $phone);
if (strpos($phone, '+') !== 0) {
    $phone = '+' . $phone;
}

try {
    $pdo = getPDO();
    
    // Vérifier le code
    $stmt = $pdo->prepare("
        SELECT id FROM otp_codes 
        WHERE phone = ? 
        AND code = ? 
        AND purpose = ?
        AND verified = 0 
        AND expires_at > NOW()
        LIMIT 1
    ");
    
    $stmt->execute([$phone, $code, $purpose]);
    
    if ($stmt->rowCount() > 0) {
        // Marquer le code comme vérifié
        $stmt = $pdo->prepare("
            UPDATE otp_codes 
            SET verified = 1, verified_at = NOW()
            WHERE phone = ? AND code = ? AND purpose = ?
        ");
        $stmt->execute([$phone, $code, $purpose]);
        
        // Supprimer les anciens codes pour ce numéro
        $pdo->prepare("DELETE FROM otp_codes WHERE phone = ? AND purpose = ? AND verified = 0")
           ->execute([$phone, $purpose]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Code vérifié avec succès',
            'data' => [
                'phone' => $phone,
                'purpose' => $purpose
            ]
        ]);
    } else {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'message' => 'Code invalide ou expiré'
        ]);
    }
    
} catch (Exception $e) {
    error_log("Erreur lors de la vérification de l'OTP: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Erreur lors de la vérification du code: ' . $e->getMessage()
    ]);
}
