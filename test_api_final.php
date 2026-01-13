<?php
// Test final sans output avant les headers
error_reporting(E_ALL);
ini_set('display_errors', 0); // Désactiver l'affichage des erreurs pour éviter les problèmes de headers

// Simuler une requête à l'API
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/user_management/users';
$_SERVER['HTTP_HOST'] = '127.0.0.1';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . base64_encode(json_encode(['user_id' => 1]));

ob_start();
try {
    include 'api/user_management/routes/api.php';
    $output = ob_get_clean();
    
    // Enlever les warnings s'il y en a
    $output = preg_replace('/Warning:.*?\n/', '', $output);
    $output = preg_replace('/Notice:.*?\n/', '', $output);
    
    echo "=== Test de l'API User Management ===\n";
    echo "URL: http://127.0.0.1/mycampus/api/user_management/users\n";
    echo "Méthode: GET\n";
    echo "Auth: Bearer token (user_id: 1)\n\n";
    echo "Réponse de l'API:\n";
    echo $output . "\n";
    
} catch (Exception $e) {
    ob_end_clean();
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
