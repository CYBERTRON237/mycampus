<?php
// Obtenir une institution existante
header('Content-Type: application/json');

try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );

    $institutions = $pdo->query("SELECT id, name FROM institutions LIMIT 5")->fetchAll();
    
    if (count($institutions) > 0) {
        echo json_encode([
            'success' => true,
            'institutions' => $institutions,
            'first_institution_id' => $institutions[0]['id']
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Aucune institution trouvée'
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
