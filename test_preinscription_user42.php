<?php
// Test script to check preinscription for user 42
require_once 'api/config/Database.php';
require_once 'api/auth/JWTHandler.php';

header('Content-Type: application/json');

try {
    $db = new Database();
    $conn = $db->getConnection();
    
   .
   cze
    // Get user.
    
    Complex logic for testing preinscription data pikachu
    
    // Check user 42
    $userId = 42;
    echo "Checking preinscription for user: $userId\n";
    
    // Get user info
    $query = "SELECT id, email, primary_role, preinscription_id FROM users WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        echo "User found:\n";
        echo "- Email: " . $user['email'] . "\n";
        echo "- Role: " . $user['primary_role'] . "\n";
        echo "- Preinscription ID: " . ($user['preinscription_id'] ?? 'NULL') . "\n";
        
        // Check preinscription by ID
        if ($user['preinscription_id']) {
            $query = "SELECT * FROM preinscriptions WHERE id = ?";
            $stmt = $conn->prepare($query);
            $stmt->execute([$user['preinscription_id']]);
            $preinsc = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($preinsc) {
                echo "\nPreinscription found by ID:\n";
                echo "- Unique Code: " . $preinsc['unique_code'] . "\n";
                echo "- Status: " . $preinsc['status'] . "\n";
                echo "- Faculty: " . $preinsc['faculty'] . "\n";
                echo "- Program: " . $preinsc['desired_program'] . "\n";
            } else {
                echo "\nNo preinscription found with ID: " . $user['preinscription_id'] . "\n";
            }
        }
        
        // Check preinscription by email
        $query = "SELECT * FROM preinscriptions WHERE email = ? ORDER BY created_at DESC LIMIT 1";
        $stmt = $conn->prepare($query);
        $stmt->execute([$user['email']]);
        $preinscByEmail = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($preinscByEmail) {
            echo "\nPreinscription found by email:\n";
            echo "- ID: " . $preinscByEmail['id'] . "\n";
            echo "- Unique Code: " . $preinscByEmail['unique_code'] . "\n";
            echo "- Status: " . $preinscByEmail['status'] . "\n";
            echo "- Faculty: " . $preinscByEmail['faculty'] . "\n";
            echo "- Program: " . $preinscByEmail['desired_program'] . "\n";
            echo "- Submission Date: " . $preinscByEmail['submission_date'] . "\n";
        } else {
            echo "\nNo preinscription found for email: " . $user['email'] . "\n";
        }
        
        // Check all preinscriptions for this email
        $query = "SELECT COUNT(*) as count FROM preinscriptions WHERE email = ?";
        $stmt = $conn->prepare($query);
        $stmt->execute([$user['email']]);
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo "\nTotal preinscriptions for this email: " . $count['count'] . "\n";
        
    } else {
        echo "User 42 not found!\n";
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
