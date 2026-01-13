<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Test de l'endpoint student management
try {
    // Simuler l'appel à l'API
    $url = 'http://127.0.0.1/mycampus/api/student_management/student_management_api.php?path=students&page=1&limit=5';
    
    $options = [
        'http' => [
            'header' => "Content-Type: application/json\r\n" .
                        "Accept: application/json\r\n",
            'method' => 'GET',
            'ignore_errors' => true
        ]
    ];
    
    $context = stream_context_create($options);
    $response = file_get_contents($url, false, $context);
    
    // Récupérer les headers
    $headers = $http_response_header ?? [];
    
    echo json_encode([
        'success' => true,
        'message' => 'Test de l\'endpoint student management',
        'endpoint_url' => $url,
        'response_headers' => $headers,
        'response_body' => json_decode($response, true),
        'flutter_endpoint' => 'http://127.0.0.1/mycampus/api/student_management/students'
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'endpoint_tested' => 'http://127.0.0.1/mycampus/api/student_management/students'
    ]);
}
?>
