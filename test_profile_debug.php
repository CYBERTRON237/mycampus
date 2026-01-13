<?php
// Test script to debug profile API
require_once 'api/config/Database.php';
require_once 'api/auth/JWTHandler.php';

header('Content-Type: application/json');

try {
    $db = new Database();
    $jwt = new JWTHandler();
    
    // Test database connection
    $conn = $db->getConnection();
    if (!$conn) {
        echo json_encode(['error' => 'Database connection failed']);
        exit;
    }
    
    // Test if user table exists
    $result = $conn->query("SHOW TABLES LIKE 'users'");
    if ($result->num_rows === 0) {
        echo json_encode(['error' => 'Users table does not exist']);
        exit;
    }
    
    // Check if there are users
    $result = $conn->query("SELECT COUNT(*) as count FROM users");
    $row = $result->fetch_assoc();
    $userCount = $row['count'];
    
    // Get sample user
    $result = $conn->query("SELECT id, email, primary_role FROM users LIMIT 1");
    $sampleUser = $result->fetch_assoc();
    
    echo json_encode([
        'success' => true,
        'database_connected' => true,
        'users_table_exists' => true,
        'user_count' => $userCount,
        'sample_user' => $sampleUser,
        'message' => 'Database and tables are ready'
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
