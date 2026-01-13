<?php
/**
 * Test script for complete profile editing functionality
 * Tests both users_api.php and user_roles_api.php endpoints
 */

// Configuration
$baseUrl = 'http://127.0.0.1/mycampus/api/user_management';

echo "=== Test Complete Profile Edit ===\n\n";

// Test 1: Get all available roles
echo "1. Testing GET /roles - Get all available roles\n";
$ch = curl_init("$baseUrl/roles");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: " . substr($response, 0, 500) . "...\n\n";

// Test 2: Get a test user (ID = 1)
echo "2. Testing GET /users/1 - Get test user\n";
$ch = curl_init("$baseUrl/users/1");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: " . substr($response, 0, 500) . "...\n\n";

// Test 3: Get user roles
echo "3. Testing GET /user_roles/1 - Get user roles\n";
$ch = curl_init("$baseUrl/user_roles/1");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: " . substr($response, 0, 500) . "...\n\n";

// Test 4: Update user profile (complete)
echo "4. Testing PUT /users/1 - Update complete profile\n";
$updateData = [
    'first_name' => 'Jores Updated',
    'last_name' => 'Tsamo Updated',
    'middle_name' => 'CYBERTRON',
    'phone' => '680682468',
    'gender' => 'male',
    'bio' => 'Test bio updated',
    'address' => 'Emana, Yaoundé',
    'city' => 'Yaoundé',
    'region' => 'Centre',
    'country' => 'Cameroun',
    'nationality' => 'Camerounaise',
    'language_preference' => 'fr',
    'timezone' => 'Africa/Douala',
    'emergency_contact_name' => 'Ngoumezong Tsamo Ulrich',
    'emergency_contact_phone' => '693290232',
    'emergency_contact_relationship' => 'frere'
];

$ch = curl_init("$baseUrl/users/1");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($updateData));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: " . substr($response, 0, 500) . "...\n\n";

// Test 5: Assign additional role to user
echo "5. Testing POST /user_roles - Assign role to user\n";
$roleData = [
    'user_id' => 1,
    'role_id' => 15, // Professor Titular
    'scope' => 'institution',
    'scope_id' => 1,
    'granted_by' => 1
];

$ch = curl_init("$baseUrl/user_roles");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($roleData));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: " . substr($response, 0, 500) . "...\n\n";

// Test 6: Verify user roles after assignment
echo "6. Testing GET /user_roles/1 - Verify user roles after assignment\n";
$ch = curl_init("$baseUrl/user_roles/1");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: " . substr($response, 0, 500) . "...\n\n";

echo "=== Test Complete ===\n";
echo "If all tests return HTTP 200 with success: true, the complete profile edit system is working!\n";
?>
