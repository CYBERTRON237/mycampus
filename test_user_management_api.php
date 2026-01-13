<?php
// Script de test pour l'API de gestion des utilisateurs

// Configuration
$baseUrl = 'http://127.0.0.1/mycampus/api/user_management';

// Fonction pour faire des requêtes HTTP
function makeRequest($url, $method = 'GET', $data = null) {
    $ch = curl_init();
    
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'Accept: application/json'
        ],
    ]);
    
    if ($data && ($method === 'POST' || $method === 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'status_code' => $httpCode,
        'response' => json_decode($response, true),
        'raw_response' => $response
    ];
}

echo "<h1>Test de l'API de Gestion des Utilisateurs</h1>";

// Test 1: GET /users (récupérer tous les utilisateurs)
echo "<h2>1. GET /users - Récupérer tous les utilisateurs</h2>";
$result = makeRequest("$baseUrl/users");
echo "<p>Status Code: {$result['status_code']}</p>";
echo "<pre>" . json_encode($result['response'], JSON_PRETTY_PRINT) . "</pre>";
echo "<hr>";

// Test 2: GET /users/{id} (récupérer un utilisateur spécifique)
if (isset($result['response']['data']) && !empty($result['response']['data'])) {
    $firstUserId = $result['response']['data'][0]['id'];
    echo "<h2>2. GET /users/$firstUserId - Récupérer un utilisateur spécifique</h2>";
    $result = makeRequest("$baseUrl/users/$firstUserId");
    echo "<p>Status Code: {$result['status_code']}</p>";
    echo "<pre>" . json_encode($result['response'], JSON_PRETTY_PRINT) . "</pre>";
    echo "<hr>";
    
    // Test 3: PUT /users/{id} (mettre à jour un utilisateur)
    echo "<h2>3. PUT /users/$firstUserId - Mettre à jour un utilisateur</h2>";
    $updateData = [
        'first_name' => 'Test Updated',
        'last_name' => 'User Updated',
        'email' => 'test.updated@example.com'
    ];
    $result = makeRequest("$baseUrl/users/$firstUserId", 'PUT', $updateData);
    echo "<p>Status Code: {$result['status_code']}</p>";
    echo "<pre>" . json_encode($result['response'], JSON_PRETTY_PRINT) . "</pre>";
    echo "<hr>";
}

// Test 4: POST /users (créer un utilisateur)
echo "<h2>4. POST /users - Créer un utilisateur</h2>";
$createData = [
    'first_name' => 'Test',
    'last_name' => 'User',
    'email' => 'test.user.' . time() . '@example.com',
    'primary_role' => 'student',
    'password' => 'password123'
];
$result = makeRequest("$baseUrl/users", 'POST', $createData);
echo "<p>Status Code: {$result['status_code']}</p>";
echo "<pre>" . json_encode($result['response'], JSON_PRETTY_PRINT) . "</pre>";
echo "<hr>";

// Test 5: POST /users avec validation
echo "<h2>5. POST /users - Test de validation (email manquant)</h2>";
$invalidData = [
    'first_name' => 'Test',
    'last_name' => 'User',
    'primary_role' => 'student'
];
$result = makeRequest("$baseUrl/users", 'POST', $invalidData);
echo "<p>Status Code: {$result['status_code']}</p>";
echo "<pre>" . json_encode($result['response'], JSON_PRETTY_PRINT) . "</pre>";
echo "<hr>";

echo "<h1>Tests terminés!</h1>";
?>
