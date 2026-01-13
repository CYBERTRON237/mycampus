<?php
// Test avec vérification des logs d'erreurs
error_reporting(E_ALL);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/debug.log');

// Créer un token simple
$payload = ['user_id' => 1, 'exp' => time() + 3600];
$token = base64_encode(json_encode($payload)) . '.test';

echo "Token créé: " . $token . "\n";
echo "Fichier de log: " . __DIR__ . '/debug.log' . "\n\n";

// Simuler une requête à l'API
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/user_management/users';
$_SERVER['HTTP_HOST'] = '127.0.0.1';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $token;

// Vider le fichier de log
file_put_contents(__DIR__ . '/debug.log', '');

ob_start();
try {
    include 'api/user_management/routes/api.php';
    $output = ob_get_clean();
    $output = preg_replace('/Warning:.*?\n/', '', $output);
    echo "Réponse API: " . $output . "\n\n";
} catch (Exception $e) {
    ob_end_clean();
    echo "Erreur API: " . $e->getMessage() . "\n";
}

// Lire et afficher les logs
if (file_exists(__DIR__ . '/debug.log')) {
    echo "=== Logs de debug ===\n";
    $logs = file_get_contents(__DIR__ . '/debug.log');
    if (!empty($logs)) {
        echo $logs . "\n";
    } else {
        echo "Aucun log trouvé\n";
    }
} else {
    echo "Fichier de log non trouvé\n";
}
?>
