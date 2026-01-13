<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "Test de l'API universités<br>";

try {
    require_once 'config/database.php';
    echo "Database config loaded<br>";
    
    $database = new Database();
    $db = $database->getConnection();
    echo "Database connection established<br>";
    
    require_once 'universities/models/University.php';
    echo "University model loaded<br>";
    
    $university = new University($db);
    echo "University object created<br>";
    
    $regions = $university->getRegions();
    echo "Regions fetched: ";
    print_r($regions);
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "<br>";
    echo "Trace: " . $e->getTraceAsString() . "<br>";
}
?>
