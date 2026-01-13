<?php
/**
 * Script pour tester le logging des routes de préinscriptions
 */

echo "<h1>Test du logging des routes de préinscriptions</h1>";

// Fonction pour tester une URL et logger les résultats
function testRoute($url, $description, $headers = []) {
    echo "<h2>$description</h2>";
    echo "<p><strong>URL:</strong> $url</p>";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array_merge([
        'Content-Type: application/json',
        'Accept: application/json'
    ], $headers));
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
    echo "<p><strong>Réponse:</strong></p>";
    echo "<pre style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc; max-height: 300px; overflow-y: auto;'>" . htmlspecialchars($response) . "</pre>";
    echo "<hr>";
}

// Tests des différentes routes

// Test 1: Route correcte - Liste des préinscriptions
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=1&limit=5",
    "Test 1: Route correcte - Liste des préinscriptions",
    ['X-User-ID: 1']
);

// Test 2: Route incorrecte - Ce qui génère "Route not found"
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/gestion",
    "Test 2: Route incorrecte - 'gestion' (devrait générer Route not found)",
    ['X-User-ID: 1']
);

// Test 3: Route avec gestion dans le chemin
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions/gestion",
    "Test 3: Route avec 'gestion' dans le chemin",
    ['X-User-ID: 1']
);

// Test 4: Route sans authentification
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions",
    "Test 4: Route sans authentification (devrait générer erreur d'auth)"
);

// Test 5: Route avec paramètres invalides
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=abc&limit=xyz",
    "Test 5: Route avec paramètres invalides",
    ['X-User-ID: 1']
);

// Test 6: Route statistiques
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions/stats",
    "Test 6: Route statistiques",
    ['X-User-ID: 1']
);

// Test 7: Route pour une préinscription spécifique
testRoute(
    "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions/1",
    "Test 7: Récupération préinscription spécifique",
    ['X-User-ID: 1']
);

// Afficher le contenu du fichier de log
echo "<h1>Contenu du fichier de log complet:</h1>";
$logFile = __DIR__ . '/logs/preinscriptions_errors.log';
if (file_exists($logFile)) {
    $content = file_get_contents($logFile);
    if (!empty($content)) {
        $lines = explode("\n", trim($content));
        echo "<p><strong>Nombre d'entrées:</strong> " . count($lines) . "</p>";
        echo "<div style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc; max-height: 500px; overflow-y: auto;'>";
        echo "<pre>" . htmlspecialchars($content) . "</pre>";
        echo "</div>";
    } else {
        echo "<p>Le fichier de log existe mais est vide.</p>";
    }
} else {
    echo "<p>Le fichier de log n'existe pas.</p>";
}

// Afficher les dernières entrées du log
echo "<h1>Dernières entrées du log:</h1>";
if (file_exists($logFile) && !empty(file_get_contents($logFile))) {
    $lines = array_slice(explode("\n", trim(file_get_contents($logFile))), -10);
    echo "<div style='background: #fff3cd; padding: 10px; border: 1px solid #ffeaa7;'>";
    foreach ($lines as $line) {
        if (!empty($line)) {
            echo "<div style='margin-bottom: 5px; padding: 5px; background: white; border-left: 3px solid #f39c12;'>" . htmlspecialchars($line) . "</div>";
        }
    }
    echo "</div>";
}

?>
