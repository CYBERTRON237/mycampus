<?php
// Vérifier la structure exacte de la table preinscriptions
header('Content-Type: application/json');

try {
    $conn = new PDO(
        "mysql:host=localhost;dbname=mycampus;charset=utf8mb4",
        "root",
        "",
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // Récupérer une préinscription existante comme modèle
    $result = $conn->query("SELECT * FROM preinscriptions LIMIT 1");
    $preinscription = $result->fetch();
    
    if ($preinscription) {
        // Afficher les colonnes disponibles
        $columns = array_keys($preinscription);
        
        echo json_encode([
            'success' => true,
            'columns' => $columns,
            'sample_preinscription' => $preinscription
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Aucune préinscription trouvée'
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
