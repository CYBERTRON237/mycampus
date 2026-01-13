<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/twilio.php';

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
if (empty($data['phone'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Le numéro de téléphone est requis']);
    exit();
}

$phone = $data['phone'];
$purpose = $data['purpose'] ?? 'verification';

// Nettoyer et formater le numéro
$phone = preg_replace('/[^0-9+]/', '', $phone);
if (strpos($phone, '+') !== 0) {
    $phone = '+' . $phone;
}

// En mode développement, on valide automatiquement
$response = [
    'success' => true,
    'message' => 'Vérification automatique en mode développement',
    'debug' => [
        'code' => '123456',  // Code factice pour le débogage
        'phone' => $phone,
        'auto_verified' => true
    ]
];

echo json_encode($response);
