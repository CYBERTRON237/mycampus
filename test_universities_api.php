<?php
// Simple test to check universities API
require_once 'api/config/database.php';
require_once 'api/universities/models/Institution.php';
require_once 'api/universities/controllers/InstitutionController.php';

echo "=== Universities API Test ===\n";

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check current count
    $stmt = $db->query('SELECT COUNT(*) as count FROM institutions');
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Current institutions count: " . $result['count'] . "\n";
    
    if ($result['count'] == 0) {
        echo "No institutions found. Inserting sample data...\n";
        
        // Insert sample universities directly
        $sample_universities = [
            [
                'uuid' => 'uy1-uuid-' . uniqid(),
                'code' => 'UY1',
                'name' => 'Université de Yaoundé I',
                'short_name' => 'UY1',
                'type' => 'public',
                'status' => 'active',
                'country' => 'Cameroun',
                'region' => 'Centre',
                'city' => 'Yaoundé',
                'description' => 'Première université d\'État du Cameroun',
                'founded_year' => 1962,
                'is_active' => 1
            ],
            [
                'uuid' => 'udla-uuid-' . uniqid(),
                'code' => 'UDLA',
                'name' => 'Université de Douala',
                'short_name' => 'UDLA',
                'type' => 'public',
                'status' => 'active',
                'country' => 'Cameroun',
                'region' => 'Littoral',
                'city' => 'Douala',
                'description' => 'Université portuaire et industrielle',
                'founded_year' => 1977,
                'is_active' => 1
            ],
            [
                'uuid' => 'uds-uuid-' . uniqid(),
                'code' => 'UDS',
                'name' => 'Université de Dschang',
                'short_name' => 'UDS',
                'type' => 'public',
                'status' => 'active',
                'country' => 'Cameroun',
                'region' => 'Ouest',
                'city' => 'Dschang',
                'description' => 'Université agricole et technologique',
                'founded_year' => 1993,
                'is_active' => 1
            ]
        ];
        
        foreach ($sample_universities as $university) {
            $query = "INSERT INTO institutions (uuid, code, name, short_name, type, status, country, region, city, description, founded_year, is_active, created_at, updated_at) 
                     VALUES (:uuid, :code, :name, :short_name, :type, :status, :country, :region, :city, :description, :founded_year, :is_active, NOW(), NOW())";
            
            $stmt = $db->prepare($query);
            $stmt->execute($university);
            echo "Inserted: " . $university['name'] . "\n";
        }
        
        echo "Sample data inserted successfully!\n";
    }
    
    // Test the API directly
    echo "\n=== Testing API ===\n";
    $institution = new Institution($db);
    $controller = new InstitutionController($institution);
    
    // Simulate GET request parameters
    $_GET['page'] = 1;
    $_GET['limit'] = 50;
    $_GET['type'] = 'university';
    $_GET['status'] = 'active';
    
    echo "Calling getInstitutions()...\n";
    $controller->getInstitutions();
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
