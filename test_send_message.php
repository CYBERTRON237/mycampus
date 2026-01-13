<?php
// Script de test pour l'envoi de messages
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Test d'envoi de message</h1>";

// URL de l'API
$url = 'http://127.0.0.1/mycampus/api/messaging/messages/send_message.php';

// Données de test
$data = [
    'receiver_id' => 2,
    'content' => 'Message de test ' . date('H:i:s'),
    'type' => 'text'
];

// Headers
$headers = [
    'Content-Type: application/json',
    'X-User-Id: 1'
];

echo "<h2>Données envoyées:</h2>";
echo "<pre>" . json_encode($data, JSON_PRETTY_PRINT) . "</pre>";

echo "<h2>Headers:</h2>";
echo "<pre>" . implode("\n", $headers) . "</pre>";

// Initialiser cURL
$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => json_encode($data),
    CURLOPT_HTTPHEADER => $headers,
    CURLOPT_HEADER => true,
    CURLOPT_VERBOSE => true
]);

// Exécuter la requête
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

echo "<h2>Résultat:</h2>";
echo "<p><strong>Code HTTP:</strong> $httpCode</p>";

if ($error) {
    echo "<p><strong>Erreur cURL:</strong> $error</p>";
}

// Séparer headers et body
$headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
$responseHeaders = substr($response, 0, $headerSize);
$responseBody = substr($response, $headerSize);

echo "<h2>Headers de réponse:</h2>";
echo "<pre>" . htmlspecialchars($responseHeaders) . "</pre>";

echo "<h2>Corps de la réponse:</h2>";
echo "<pre>" . htmlspecialchars($responseBody) . "</pre>";

// Essayer de décoder le JSON
$responseData = json_decode($responseBody, true);
if ($responseData !== null) {
    echo "<h2>Données décodées:</h2>";
    echo "<pre>" . print_r($responseData, true) . "</pre>";
} else {
    echo "<p style='color: red;'>La réponse n'est pas du JSON valide</p>";
}
?>
