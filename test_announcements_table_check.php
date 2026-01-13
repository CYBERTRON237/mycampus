<?php
// Test script to check if announcements table exists
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once 'api/config/database.php';

try {
    $database = new Database();
    $conn = $database->getConnection();
    
    // Check if table exists
    $stmt = $conn->prepare("SHOW TABLES LIKE 'announcements'");
    $stmt->execute();
    $table_exists = $stmt->rowCount() > 0;
    
    if ($table_exists) {
        // Get table structure
        $stmt = $conn->prepare("DESCRIBE announcements");
        $stmt->execute();
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Count records
        $stmt = $conn->prepare("SELECT COUNT(*) as count FROM announcements");
        $stmt->execute();
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        echo json_encode([
            'success' => true,
            'message' => 'Table announcements exists',
            'columns_count' => count($columns),
            'records_count' => $count,
            'columns' => array_map(function($col) {
                return [
                    'field' => $col['Field'],
                    'type' => $col['Type'],
                    'null' => $col['Null'],
                    'key' => $col['Key'],
                    'default' => $col['Default']
                ];
            }, $columns)
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Table announcements does not exist'
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error checking table',
        'error' => $e->getMessage()
    ]);
}
?>
