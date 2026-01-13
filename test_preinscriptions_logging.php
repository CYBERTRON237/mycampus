<?php
/**
 * Script de test pour vérifier le logging des erreurs de préinscriptions
 */

echo "<h1>Test du logging des erreurs de préinscriptions</h1>";

// Test 1: Appel à l'API avec des paramètres invalides
echo "<h2>Test 1: Récupération des préinscriptions avec page invalide</h2>";
$ch = curl_init("http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=-1&limit=999");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-ID: 1'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
echo "<p><strong>Réponse:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 2: Appel avec une recherche qui génère une erreur SQL
echo "<h2>Test 2: Recherche avec caractères spéciaux</h2>";
$ch = curl_init("http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?search=';DROP TABLE preinscriptions;--");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-ID: 1'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
echo "<p><strong>Réponse:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 3: Récupération d'une préinscription qui n'existe pas
echo "<h2>Test 3: Récupération d'une préinscription inexistante</h2>";
$ch = curl_init("http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions/99999");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-ID: 1'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
echo "<p><strong>Réponse:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 4: Appel sans authentification
echo "<h2>Test 4: Appel sans authentification</h2>";
$ch = curl_init("http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
echo "<p><strong>Réponse:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test 5: Statistiques sans permissions
echo "<h2>Test 5: Statistiques sans permissions (user normal)</h2>";
$ch = curl_init("http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions/stats");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-ID: 2' // ID d'un utilisateur normal
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
echo "<p><strong>Réponse:</strong></p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Afficher le contenu du fichier de log
echo "<h2>Contenu du fichier de log:</h2>";
$logFile = __DIR__ . '/logs/preinscriptions_errors.log';
if (file_exists($logFile)) {
    echo "<pre>" . htmlspecialchars(file_get_contents($logFile)) . "</pre>";
} else {
    echo "<p>Le fichier de log n'existe pas encore.</p>";
}

?>
