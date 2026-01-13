<?php
require_once 'api/config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check if institutions table exists and has data
    $stmt = $db->query('SELECT COUNT(*) as count FROM institutions');
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo 'Institutions count: ' . $result['count'] . PHP_EOL;
    
    // Show sample data if exists
    if ($result['count'] > 0) {
        $stmt = $db->query('SELECT id, name, type, status FROM institutions LIMIT 5');
        $institutions = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo 'Sample institutions:' . PHP_EOL;
        foreach ($institutions as $inst) {
            echo '- ID: ' . $inst['id'] . ', Name: ' . $inst['name'] . ', Type: ' . $inst['type'] . ', Status: ' . $inst['status'] . PHP_EOL;
        }
    }
    
    // Check table structure
    $stmt = $db->query('DESCRIBE institutions');
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo PHP_EOL . 'Table structure:' . PHP_EOL;
    foreach ($columns as $col) {
        echo '- ' . $col['Field'] . ' (' . $col['Type'] . ')' . PHP_EOL;
    }
    
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage() . PHP_EOL;
}
?>
