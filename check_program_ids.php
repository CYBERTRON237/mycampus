<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    echo "Tous les programmes disponibles:\n";
    $stmt = $pdo->query('SELECT id, name, department_id FROM programs ORDER BY id');
    $programs = $stmt->fetchAll();
    foreach ($programs as $prog) {
        echo "- ID: {$prog['id']} - {$prog['name']} (Dept: {$prog['department_id']})\n";
    }
    
    echo "\nPremier programme disponible:\n";
    $stmt = $pdo->query('SELECT id, name FROM programs ORDER BY id LIMIT 1');
    $firstProgram = $stmt->fetch();
    if ($firstProgram) {
        echo "- ID: {$firstProgram['id']} - {$firstProgram['name']}\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
