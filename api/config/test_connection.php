<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

try {
    require_once 'database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        echo json_encode([
            "success" => true,
            "message" => "Connexion à la base de données réussie",
            "database_info" => [
                "host" => $database->host,
                "database" => $database->db_name
            ]
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Échec de la connexion à la base de données"
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur: " . $e->getMessage()
    ]);
}
?>
