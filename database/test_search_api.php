<?php
// Script de test pour l'API de recherche d'utilisateurs
$apiUrl = 'http://127.0.0.1/mycampus/api/messaging/users/search';

// Test de recherche avec le token existant
$token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NjUzMDg2MjIsImV4cCI6MTc2NTM5NTAyMiwiaXNzIjoibXljYW1wdXMiLCJkYXRhIjp7ImlkIjoxLCJlbWFpbCI6ImpvcmVzdHNhbW80N0BnbWFpbC5jb20iLCJpcCI6IjEyNy4wLjAuMSJ9fQ.CR1yKaRXdt9OqyomDl-RpPkLU_8p5yT6uJ3fput7pmc';

// Test de recherche "Marie"
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl . '?q=Marie');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Recherche 'Marie' - HTTP Code: $httpCode\n";
echo "Réponse: " . $response . "\n\n";

// Test de recherche "Jean"
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl . '?q=Jean');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Recherche 'Jean' - HTTP Code: $httpCode\n";
echo "Réponse: " . $response . "\n\n";

// Test de recherche "prof"
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl . '?q=prof');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Recherche 'prof' - HTTP Code: $httpCode\n";
echo "Réponse: " . $response . "\n";
?>
