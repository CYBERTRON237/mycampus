<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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
    // Get posted data
    $userId = $_POST['user_id'] ?? null;
    $action = $_POST['action'] ?? null;

    if (!$userId) {
        throw new Exception('Missing required parameter: user_id');
    }
    
    if ($action !== 'upload_avatar') {
        throw new Exception('Invalid action. Expected: upload_avatar, Got: ' . ($action ?? 'null'));
    }
    
    // Validate user_id is numeric
    if (!is_numeric($userId)) {
        throw new Exception('Invalid user_id. Must be numeric, Got: ' . $userId);
    }

    // Check if file was uploaded
    if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
        throw new Exception('No file uploaded or upload error');
    }

    $file = $_FILES['avatar'];
    
    // Validate file
    $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    $maxFileSize = 5 * 1024 * 1024; // 5MB

    if (!in_array($file['type'], $allowedTypes)) {
        throw new Exception('Invalid file type. Only JPEG, PNG, and GIF are allowed');
    }

    if ($file['size'] > $maxFileSize) {
        throw new Exception('File too large. Maximum size is 5MB');
    }

    // Create uploads directory if it doesn't exist
    $uploadsDir = '../uploads/avatars';
    if (!is_dir($uploadsDir)) {
        if (!mkdir($uploadsDir, 0755, true)) {
            throw new Exception('Failed to create uploads directory');
        }
    }

    // Generate unique filename
    $fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = $userId . '_avatar_' . time() . '.' . $fileExtension;
    $filepath = $uploadsDir . '/' . $filename;

    // Move uploaded file
    if (!move_uploaded_file($file['tmp_name'], $filepath)) {
        throw new Exception('Failed to move uploaded file');
    }

    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Update user's profile_photo_url in database (utiliser le bon champ)
    $avatarUrl = '/uploads/avatars/' . $filename;
    
    // First check if user exists
    $checkQuery = "SELECT id FROM users WHERE id = :user_id";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->bindParam(':user_id', $userId);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() === 0) {
        // Remove uploaded file if user doesn't exist
        unlink($filepath);
        throw new Exception('User with ID ' . $userId . ' does not exist');
    }
    
    // Update the user's avatar
    $query = "UPDATE users SET profile_photo_url = :profile_photo_url, updated_at = NOW() WHERE id = :user_id";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':profile_photo_url', $avatarUrl);
    $stmt->bindParam(':user_id', $userId);

    if (!$stmt->execute()) {
        // Remove uploaded file if database update fails
        unlink($filepath);
        $errorInfo = $stmt->errorInfo();
        throw new Exception('Failed to update database: ' . $errorInfo[2]);
    }

    // Return success response
    echo json_encode([
        'success' => true,
        'message' => 'Avatar uploaded successfully',
        'avatar_url' => $avatarUrl,
        'profile_photo_url' => $avatarUrl,
        'filename' => $filename
    ]);

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
