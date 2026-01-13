<?php
// Script de test pour l'API de préinscriptions
header("Content-Type: text/plain");

echo "=== Test des endpoints de préinscriptions ===\n\n";

$baseUrl = "http://127.0.0.1/mycampus/api/preinscriptions";

// Test 1: Lister les préinscriptions
echo "1. Test de l'endpoint list_preinscriptions.php:\n";
$context = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode(['page' => 1, 'limit' => 5])
    ]
]);

$response = file_get_contents("$baseUrl/list_preinscriptions.php", false, $context);
if ($response) {
    $data = json_decode($response, true);
    echo "Statut: " . ($data['success'] ? 'SUCCÈS' : 'ERREUR') . "\n";
    echo "Message: " . ($data['message'] ?? 'N/A') . "\n";
    echo "Nombre de préinscriptions: " . count($data['data'] ?? []) . "\n";
} else {
    echo "ERREUR: Impossible de contacter l'endpoint\n";
}
echo "\n";

// Test 2: Récupérer une préinscription spécifique
echo "2. Test de l'endpoint get_preinscription.php:\n";
$context = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode(['unique_code' => 'PRE2025000417'])
    ]
]);

$response = file_get_contents("$baseUrl/get_preinscription.php", false, $context);
if ($response) {
    $data = json_decode($response, true);
    echo "Statut: " . ($data['success'] ? 'SUCCÈS' : 'ERREUR') . "\n";
    echo "Message: " . ($data['message'] ?? 'N/A') . "\n";
    if ($data['success']) {
        echo "Préinscription trouvée: " . ($data['data']['first_name'] ?? '') . " " . ($data['data']['last_name'] ?? '') . "\n";
    }
} else {
    echo "ERREUR: Impossible de contacter l'endpoint\n";
}
echo "\n";

// Test 3: Vérifier les headers CORS
echo "3. Test des headers CORS:\n";
$context = stream_context_create([
    'http' => [
        'method' => 'OPTIONS',
        'header' => 'Content-Type: application/json'
    ]
]);

$response = file_get_contents("$baseUrl/list_preinscriptions.php", false, $context);
$headers = $http_response_header ?? [];
$corsHeaders = [];
foreach ($headers as $header) {
    if (stripos($header, 'Access-Control') === 0) {
        $corsHeaders[] = $header;
    }
}
if (!empty($corsHeaders)) {
    echo "Headers CORS présents:\n";
    foreach ($corsHeaders as $header) {
        echo "  $header\n";
    }
} else {
    echo "ATTENTION: Aucun header CORS détecté\n";
}

echo "\n=== Fin des tests ===\n";
?>
