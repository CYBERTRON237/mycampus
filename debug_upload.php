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

// Debug information
$debug = [
    'post_data' => $_POST,
    'files_data' => $_FILES,
    'server_info' => [
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'not set',
        'content_length' => $_SERVER['CONTENT_LENGTH'] ?? 'not set',
    ]
];

// Check if file was uploaded
if (!isset($_FILES['avatar'])) {
    echo json_encode([
        'success' => false, 
        'message' => 'No file uploaded',
        'debug' => $debug
    ]);
    exit();
}

$file = $_FILES['avatar'];
$debug['file_details'] = [
    'name' => $file['name'],
    'type' => $file['type'],
    'size' => $file['size'],
    'error' => $file['error'],
    'tmp_name' => $file['tmp_name']
];

if ($file['error'] !== UPLOAD_ERR_OK) {
    $errorMessages = [
        UPLOAD_ERR_INI_SIZE => 'File exceeds upload_max_filesize directive',
        UPLOAD_ERR_FORM_SIZE => 'File exceeds MAX_FILE_SIZE directive',
        UPLOAD_ERR_PARTIAL => 'File was only partially uploaded',
        UPLOAD_ERR_NO_FILE => 'No file was uploaded',
        UPLOAD_ERR_NO_TMP_DIR => 'Missing temporary folder',
        UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
        UPLOAD_ERR_EXTENSION => 'A PHP extension stopped the file upload',
    ];
    
    echo json_encode([
        'success' => false,
        'message' => $errorMessages[$file['error']] ?? 'Unknown upload error',
        'debug' => $debug
    ]);
    exit();
}

// Test database connection
try {
    $host = 'localhost';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Test if the column exists
    $stmt = $pdo->prepare("DESCRIBE users");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    $debug['database'] = [
        'connection' => 'success',
        'profile_photo_url_exists' => in_array('profile_photo_url', $columns),
        'available_columns' => $columns
    ];
    
    if (!in_array('profile_photo_url', $columns)) {
        echo json_encode([
            'success' => false,
            'message' => 'Column profile_photo_url does not exist in users table',
            'debug' => $debug
        ]);
        exit();
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage(),
        'debug' => $debug
    ]);
    exit();
}

echo json_encode([
    'success' => true,
    'message' => 'Debug information - all checks passed',
    'debug' => $debug
]);
?>
