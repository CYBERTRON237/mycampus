<?php
// Script pour tester l'API user_management
$host = '127.0.0.1';
$dbname = 'mycampus';
$username = 'root';
$password = '';

// Simuler une requête à l'API
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/user_management/users';
$_SERVER['HTTP_HOST'] = '127.0.0.1';

// Simuler des headers pour l'authentification (token JWT fictif)
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.signature';

echo "Test de l'API user_management\n";
echo "URL: http://127.0.0.1/mycampus/api/user_management/users\n\n";

try {
    // Inclure le fichier de l'API
    ob_start();
    include 'api/user_management/routes/api.php';
    $output = ob_get_clean();
    
    echo "Réponse de l'API:\n";
    echo $output . "\n";
    
} catch (Exception $e) {
    echo "Erreur lors du test: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
?>
