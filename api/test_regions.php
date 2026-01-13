<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "Test direct de l'API regions<br>";

try {
    require_once 'config/database.php';
    require_once 'jwt/jwt_utils.php';
    require_once 'universities/models/University.php';
    require_once 'universities/controllers/UniversityController.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    $university = new University($db);
    $controller = new UniversityController($university);
    
    echo "Appel de getRegions()<br>";
    $controller->getRegions();
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "<br>";
    echo "File: " . $e->getFile() . " Line: " . $e->getLine() . "<br>";
    echo "Trace: " . $e->getTraceAsString() . "<br>";
}
?>
