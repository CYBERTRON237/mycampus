<?php
require_once 'config/database.php';

try {
    $database = new Database();
    $conn = $database->getConnection();
    
    // Check if table exists
    $stmt = $conn->prepare("DESCRIBE announcements");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Table 'announcements' existe!\n";
    echo "Structure:\n";
    foreach ($result as $column) {
        echo "- {$column['Field']} ({$column['Type']})\n";
    }
    
    // Check if table has data
    $stmt = $conn->prepare("SELECT COUNT(*) as count FROM announcements");
    $stmt->execute();
    $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "\nNombre d'annonces: $count\n";
    
} catch (PDOException $e) {
    echo "Erreur PDO: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
