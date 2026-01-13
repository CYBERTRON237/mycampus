<?php
// Test propre de l'API sans output avant les headers
ob_start();

// Simuler une requête à l'API
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/user_management/users';
$_SERVER['HTTP_HOST'] = '127.0.0.1';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.signature';

try {
    // Inclure le fichier de l'API
    include 'api/user_management/routes/api.php';
    $output = ob_get_clean();
    
    // Nettoyer les warnings des headers
    $output = preg_replace('/Warning:.*?\n/', '', $output);
    
    echo "Test de l'API user_management\n";
    echo "URL: http://127.0.0.1/mycampus/api/user_management/users\n\n";
    echo "Réponse de l'API:\n";
    echo $output . "\n";
    
} catch (Exception $e) {
    ob_end_clean();
    echo "Erreur lors du test: " . $e->getMessage() . "\n";
}
?>
