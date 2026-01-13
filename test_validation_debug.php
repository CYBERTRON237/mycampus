<?php
// Script de test pour diagnostiquer l'erreur 400 de validation
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Connexion à la base de données
try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    exit;
}

// Récupérer les données POST
$data = json_decode(file_get_contents('php://input'), true);

echo json_encode([
    'success' => true,
    'debug_info' => [
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'not set',
        'post_data' => $data,
        'headers' => getallheaders(),
        'php_input_raw' => file_get_contents('php://input')
    ],
    'test_queries' => [
        'preinscriptions_count' => $pdo->query("SELECT COUNT(*) as count FROM preinscriptions")->fetch()['count'],
        'users_count' => $pdo->query("SELECT COUNT(*) as count FROM users")->fetch()['count'],
        'pending_preinscriptions' => $pdo->query("SELECT COUNT(*) as count FROM preinscriptions WHERE status IN ('pending', 'under_review')")->fetch()['count']
    ]
]);
?>
