<?php
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    echo "Vérification des clés étrangères:\n\n";
    
    // Institutions
    echo "Institutions disponibles:\n";
    $stmt = $pdo->query('SELECT id, name FROM institutions LIMIT 5');
    $institutions = $stmt->fetchAll();
    foreach ($institutions as $inst) {
        echo "- ID: {$inst['id']} - {$inst['name']}\n";
    }
    if (empty($institutions)) {
        echo "Aucune institution trouvée\n";
    }
    
    // Departments
    echo "\nDepartements disponibles:\n";
    $stmt = $pdo->query('SELECT id, name FROM departments LIMIT 5');
    $departments = $stmt->fetchAll();
    foreach ($departments as $dept) {
        echo "- ID: {$dept['id']} - {$dept['name']}\n";
    }
    if (empty($departments)) {
        echo "Aucun département trouvé\n";
    }
    
    // Programs
    echo "\nProgrammes disponibles:\n";
    $stmt = $pdo->query('SELECT id, name FROM programs LIMIT 5');
    $programs = $stmt->fetchAll();
    foreach ($programs as $prog) {
        echo "- ID: {$prog['id']} - {$prog['name']}\n";
    }
    if (empty($programs)) {
        echo "Aucun programme trouvé\n";
    }
    
    // Academic Years
    echo "\nAnnées académiques disponibles:\n";
    $stmt = $pdo->query('SELECT id, year_code FROM academic_years LIMIT 5');
    $years = $stmt->fetchAll();
    foreach ($years as $year) {
        echo "- ID: {$year['id']} - {$year['year_code']}\n";
    }
    if (empty($years)) {
        echo "Aucune année académique trouvée\n";
        
        // Créer une année académique par défaut
        echo "\nCréation d'une année académique par défaut...\n";
        $insert = $pdo->prepare("INSERT INTO academic_years (institution_id, year_code, start_date, end_date, is_current, status, created_at, updated_at) VALUES (?, ?, ?, ?, 1, 'active', NOW(), NOW())");
        $result = $insert->execute([1, '2024-2025', '2024-09-01', '2025-08-31']);
        if ($result) {
            echo "Année académique 2024-2025 créée avec succès\n";
        }
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
