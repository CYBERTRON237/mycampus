<?php
// Test pour vérifier que l'API fonctionne avec les requêtes Flutter
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Créer un token simple pour l'authentification
$payload = ['user_id' => 1, 'exp' => time() + 3600];
$token = base64_encode(json_encode($payload)) . '.test';

echo "=== Test de connexion Flutter vers Backend ===\n\n";

// Test 1: GET /api/user_management/users (liste des utilisateurs)
echo "1. Test GET /api/user_management/users\n";
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/user_management/users';
$_SERVER['HTTP_HOST'] = '127.0.0.1';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $token;

ob_start();
include 'api/user_management/routes/api.php';
$response1 = ob_get_clean();
$response1 = preg_replace('/Warning:.*?\n/', '', $response1);

$data1 = json_decode($response1, true);
echo "Status: " . ($data1['success'] ? 'SUCCESS' : 'FAILED') . "\n";
echo "Utilisateurs trouvés: " . count($data1['data'] ?? []) . "\n\n";

// Test 2: GET /api/user_management/users/current (utilisateur courant)
echo "2. Test GET /api/user_management/users/current\n";
$_SERVER['REQUEST_URI'] = '/api/user_management/users/current';

ob_start();
include 'api/user_management/routes/api.php';
$response2 = ob_get_clean();
$response2 = preg_replace('/Warning:.*?\n/', '', $response2);

$data2 = json_decode($response2, true);
echo "Status: " . ($data2['success'] ? 'SUCCESS' : 'FAILED') . "\n";
if ($data2['success']) {
    echo "Utilisateur: " . $data2['data']['user']['first_name'] . " " . $data2['data']['user']['last_name'] . "\n";
    echo "Niveau: " . $data2['data']['highest_level'] . "\n";
}
echo "\n";

// Test 3: GET /api/user_management/users/stats (statistiques)
echo "3. Test GET /api/user_management/users/stats\n";
$_SERVER['REQUEST_URI'] = '/api/user_management/users/stats';

ob_start();
include 'api/user_management/routes/api.php';
$response3 = ob_get_clean();
$response3 = preg_replace('/Warning:.*?\n/', '', $response3);

$data3 = json_decode($response3, true);
echo "Status: " . ($data3['success'] ? 'SUCCESS' : 'FAILED') . "\n";
if ($data3['success']) {
    echo "Statistiques disponibles: " . count($data3['data'] ?? []) . "\n";
}
echo "\n";

// Test 4: POST /api/user_management/users/search (recherche)
echo "4. Test POST /api/user_management/users/search\n";
$_SERVER['REQUEST_METHOD'] = 'POST';
$_SERVER['REQUEST_URI'] = '/api/user_management/users/search';

// Simuler un body JSON
$_POST = ['search' => 'Jores', 'page' => 1, 'limit' => 10];

ob_start();
include 'api/user_management/routes/api.php';
$response4 = ob_get_clean();
$response4 = preg_replace('/Warning:.*?\n/', '', $response4);

$data4 = json_decode($response4, true);
echo "Status: " . ($data4['success'] ? 'SUCCESS' : 'FAILED') . "\n";
echo "Résultats de recherche: " . count($data4['data'] ?? []) . "\n\n";

echo "=== Tests terminés ===\n";
echo "L'API est prête pour la connexion Flutter !\n";
?>
