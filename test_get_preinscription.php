<?php
// Test de l'API de récupération de préinscription

echo "=== TEST API RÉCUPÉRATION PRÉINSCRIPTION ===\n\n";

// Test 1: Rechercher une préinscription existante
echo "1. Test avec un code valide (si existe):\n";
$testData = [
    'unique_code' => 'PRE2025839403' // Utiliser un code qui existe dans la base
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Code HTTP: $httpCode\n";
echo "Réponse: " . substr($response, 0, 200) . "...\n\n";

$result = json_decode($response, true);
if ($result && isset($result['success'])) {
    if ($result['success']) {
        echo "✅ SUCCÈS: Préinscription trouvée\n";
        echo "Code unique: " . ($result['data']['unique_code'] ?? 'N/A') . "\n";
        echo "Nom: " . ($result['data']['first_name'] ?? 'N/A') . " " . ($result['data']['last_name'] ?? 'N/A') . "\n";
        echo "Faculté: " . ($result['data']['faculty'] ?? 'N/A') . "\n";
        echo "Statut: " . ($result['data']['status'] ?? 'N/A') . "\n";
        echo "Nombre de champs retournés: " . count($result['data']) . "\n";
    } else {
        echo "❌ ERREUR: " . ($result['message'] ?? 'Erreur inconnue') . "\n";
    }
} else {
    echo "❌ ERREUR: Réponse JSON invalide\n";
}

echo "\n" . str_repeat("=", 60) . "\n\n";

// Test 2: Rechercher une préinscription inexistante
echo "2. Test avec un code invalide:\n";
$testData2 = [
    'unique_code' => 'PRE999999999' // Code qui n'existe probablement pas
];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData2));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response2 = curl_exec($ch);
$httpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Code HTTP: $httpCode2\n";
echo "Réponse: $response2\n\n";

$result2 = json_decode($response2, true);
if ($result2 && isset($result2['success'])) {
    if (!$result2['success']) {
        echo "✅ SUCCÈS: L'API rejette correctement les codes invalides\n";
        echo "Message d'erreur: " . ($result2['message'] ?? 'N/A') . "\n";
    } else {
        echo "❌ ERREUR: L'API aurait dû rejeter ce code\n";
    }
} else {
    echo "❌ ERREUR: Réponse JSON invalide\n";
}

echo "\n" . str_repeat("=", 60) . "\n\n";

// Test 3: Test sans code
echo "3. Test sans code unique:\n";
$testData3 = [];

$ch = curl_init('http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData3));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response3 = curl_exec($ch);
$httpCode3 = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Code HTTP: $httpCode3\n";
echo "Réponse: $response3\n\n";

$result3 = json_decode($response3, true);
if ($result3 && isset($result3['success'])) {
    if (!$result3['success']) {
        echo "✅ SUCCÈS: L'API requiert correctement le code unique\n";
        echo "Message d'erreur: " . ($result3['message'] ?? 'N/A') . "\n";
    } else {
        echo "❌ ERREUR: L'API aurait dû requérir le code unique\n";
    }
} else {
    echo "❌ ERREUR: Réponse JSON invalide\n";
}

echo "\n=== FIN DES TESTS ===\n";
?>
