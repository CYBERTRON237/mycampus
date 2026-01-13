<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    $stmt = $pdo->query('SHOW TABLES LIKE "%student%"');
    $tables = $stmt->fetchAll();
    echo "Tables containing 'student':\n";
    foreach ($tables as $table) {
        echo "- " . implode(', ', $table) . "\n";
    }
    
    // Vérifier la structure de la table student_profiles si elle existe
    $stmt = $pdo->query("SHOW TABLES LIKE 'student_profiles'");
    if ($stmt->rowCount() > 0) {
        echo "\nStructure of student_profiles table:\n";
        $stmt = $pdo->query('DESCRIBE student_profiles');
        $columns = $stmt->fetchAll();
        foreach ($columns as $column) {
            echo "- {$column['Field']} ({$column['Type']})\n";
        }
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
