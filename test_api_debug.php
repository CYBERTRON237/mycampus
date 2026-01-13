<?php
// Test avec debug pour comprendre l'authentification
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Créer un token simple
$payload = ['user_id' => 1, 'exp' => time() + 3600];
$token = base64_encode(json_encode($payload)) . '.test';

echo "Token créé: " . $token . "\n";
echo "Payload: " . json_encode($payload) . "\n\n";

// Simuler une requête à l'API
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/user_management/users';
$_SERVER['HTTP_HOST'] = '127.0.0.1';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . $token;

echo "Headers HTTP simulés:\n";
echo "REQUEST_METHOD: " . $_SERVER['REQUEST_METHOD'] . "\n";
echo "REQUEST_URI: " . $_SERVER['REQUEST_URI'] . "\n";
echo "HTTP_AUTHORIZATION: " . ($_SERVER['HTTP_AUTHORIZATION'] ?? 'non défini') . "\n\n";

// Test direct de la fonction decodeJWT
class TestJWT {
    public function decodeJWT(string $token): array {
        $parts = explode('.', $token);
        
        if (count($parts) >= 1) {
            $payload = json_decode(base64_decode($parts[0]), true);
            if ($payload && isset($payload['user_id'])) {
                return $payload;
            }
        }
        
        if (count($parts) === 3) {
            $payload = json_decode(base64_decode($parts[1]), true);
            if ($payload && isset($payload['user_id'])) {
                return $payload;
            }
        }
        
        throw new \InvalidArgumentException('Token JWT invalide');
    }
}

$jwt = new TestJWT();
try {
    $decoded = $jwt->decodeJWT($token);
    echo "Token décodé avec succès: " . json_encode($decoded) . "\n";
} catch (Exception $e) {
    echo "Erreur de décodage: " . $e->getMessage() . "\n";
}

echo "\n=== Test de l'API complète ===\n";

ob_start();
try {
    include 'api/user_management/routes/api.php';
    $output = ob_get_clean();
    $output = preg_replace('/Warning:.*?\n/', '', $output);
    echo "Réponse API: " . $output . "\n";
} catch (Exception $e) {
    ob_end_clean();
    echo "Erreur API: " . $e->getMessage() . "\n";
}
?>
