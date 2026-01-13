<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// Connexion directe à la base de données
$host = 'localhost';
$dbname = 'mycampus';
$username = 'root';
$password = '';

try {
    // Get user ID from query parameter
    $userId = $_GET['user_id'] ?? null;

    if (!$userId) {
        throw new Exception('User ID is required');
    }

    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get user information
    $query = "SELECT id, first_name, last_name, email, phone, address, bio, profile_photo_url, role, institution_id, created_at, updated_at 
              FROM users 
              WHERE id = :user_id";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':user_id', $userId);
    $stmt->execute();

    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        throw new Exception('User not found');
    }

    // Format response for Flutter app
    $response = [
        'success' => true,
        'user' => [
            'id' => $user['id'],
            'first_name' => $user['first_name'],
            'last_name' => $user['last_name'],
            'email' => $user['email'],
            'phone' => $user['phone'],
            'address' => $user['address'],
            'bio' => $user['bio'],
            'profile_photo_url' => $user['profile_photo_url'], // Utiliser le bon champ
            'avatar' => $user['profile_photo_url'], // Pour compatibilité
            'avatar_url' => $user['profile_photo_url'], // Pour compatibilité
            'role' => $user['role'],
            'institution_id' => $user['institution_id'],
            'created_at' => $user['created_at'],
            'updated_at' => $user['updated_at']
        ]
    ];

    echo json_encode($response);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
} catch (Error $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error occurred'
    ]);
}
?>
