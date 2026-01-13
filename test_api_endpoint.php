<?php
/**
 * Test de l'endpoint API complet avec simulation de requête HTTP
 */

// Simuler l'environnement HTTP
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/mycampus/api/messaging/groups/my';
$_SERVER['HTTP_X_USER_ID'] = '39';
$_SERVER['HTTP_CONTENT_TYPE'] = 'application/json';

// Désactiver l'affichage des erreurs pour éviter les problèmes de headers
error_reporting(E_ERROR);
ini_set('display_errors', 0);

// Capturer la sortie
ob_start();

try {
    // Inclure l'API
    require_once __DIR__ . '/api/messaging/index.php';
    $response = ob_get_contents();
    
    // Nettoyer les warnings et afficher seulement le JSON
    $lines = explode("\n", $response);
    $jsonResponse = '';
    foreach ($lines as $line) {
        $line = trim($line);
        if ($line && $line[0] === '{') {
            $jsonResponse = $line;
            break;
        }
    }
    
    if ($jsonResponse) {
        $data = json_decode($jsonResponse, true);
        if ($data && isset($data['success']) && $data['success']) {
            echo json_encode([
                'success' => true,
                'message' => 'Endpoint GET /api/messaging/groups/my fonctionne parfaitement',
                'api_response' => $data,
                'timestamp' => date('Y-m-d H:i:s')
            ], JSON_PRETTY_PRINT);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'L\'API a répondu mais avec une erreur',
                'api_response' => $data,
                'raw_response' => $response,
                'timestamp' => date('Y-m-d H:i:s')
            ], JSON_PRETTY_PRINT);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Pas de réponse JSON valide trouvée',
            'raw_response' => $response,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_PRETTY_PRINT);
    }
    
} catch (Exception $e) {
    $response = ob_get_contents();
    echo json_encode([
        'success' => false,
        'message' => 'Exception: ' . $e->getMessage(),
        'response' => $response,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT);
}

ob_end_clean();
?>
