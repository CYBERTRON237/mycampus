<?php
header('Content-Type: application/json');

// Test direct de l'API pour vérifier les vrais étudiants
try {
    $url = 'http://127.0.0.1/mycampus/api/student_management/students?page=1&limit=10';
    
    $context = stream_context_create([
        'http' => [
            'header' => "Content-Type: application/json\r\nAccept: application/json\r\n",
            'method' => 'GET',
            'ignore_errors' => true
        ]
    ]);
    
    $response = file_get_contents($url, false, $context);
    $data = json_decode($response, true);
    
    echo json_encode([
        'success' => true,
        'message' => 'Test des étudiants réels',
        'url_tested' => $url,
        'response' => $data,
        'expected_students' => [
            'Djeugnia Berryl',
            'Jean Martin', 
            'Sophie Tant',
            'Pierre Ngono',
            'Isabelle Ouan'
        ],
        'total_expected' => 32
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
