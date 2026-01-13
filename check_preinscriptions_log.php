<?php
/**
 * Script simple pour vérifier le logging des préinscriptions
 */

echo "<h1>Vérification du système de logging des préinscriptions</h1>";

// Test de la fonction de logging directement
function logPreinscriptionError($message, $error = null, $context = []) {
    $logFile = __DIR__ . '/logs/preinscriptions_errors.log';
    $timestamp = date('Y-m-d H:i:s');
    $contextStr = !empty($context) ? ' | Context: ' . json_encode($context) : '';
    $errorStr = $error ? " | Error: $error" : '';
    $logEntry = "[$timestamp] $message$errorStr$contextStr" . PHP_EOL;
    
    // Ajouter au fichier de log
    $result = file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
    
    echo "<p>Entrée de log ajoutée: " . htmlspecialchars($logEntry) . "</p>";
    echo "<p>Résultat de l'écriture: " . ($result !== false ? "Succès ($result octets)" : "Échec") . "</p>";
    
    return $result !== false;
}

// Tester le logging
echo "<h2>Test de la fonction de logging</h2>";
$success = logPreinscriptionError(
    "Test de logging des préinscriptions", 
    "Erreur de test", 
    ['test' => true, 'timestamp' => time()]
);

echo "<p><strong>Résultat du test:</strong> " . ($success ? "Succès" : "Échec") . "</p>";

// Vérifier le contenu du fichier de log
echo "<h2>Contenu actuel du fichier de log:</h2>";
$logFile = __DIR__ . '/logs/preinscriptions_errors.log';
if (file_exists($logFile)) {
    $content = file_get_contents($logFile);
    if (!empty($content)) {
        echo "<pre style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc;'>" . htmlspecialchars($content) . "</pre>";
        echo "<p><strong>Taille du fichier:</strong> " . filesize($logFile) . " octets</p>";
    } else {
        echo "<p>Le fichier de log existe mais est vide.</p>";
    }
} else {
    echo "<p>Le fichier de log n'existe pas.</p>";
}

// Vérifier les permissions
echo "<h2>Vérification des permissions:</h2>";
if (file_exists($logFile)) {
    $perms = fileperms($logFile);
    echo "<p>Permissions: " . substr(sprintf('%o', fileperms($logFile)), -4) . "</p>";
    echo "<p>Readable: " . (is_readable($logFile) ? "Oui" : "Non") . "</p>";
    echo "<p>Writable: " . (is_writable($logFile) ? "Oui" : "Non") . "</p>";
}

// Test d'appel à l'API
echo "<h2>Test d'appel à l'API</h2>";
$apiUrl = "http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=1&limit=5";
$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-ID: 1'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p><strong>URL:</strong> $apiUrl</p>";
echo "<p><strong>Code HTTP:</strong> $httpCode</p>";
echo "<p><strong>Réponse:</strong></p>";
echo "<pre style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc;'>" . htmlspecialchars($response) . "</pre>";

echo "<h2>Contenu du fichier de log après l'appel API:</h2>";
if (file_exists($logFile)) {
    $content = file_get_contents($logFile);
    echo "<pre style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc;'>" . htmlspecialchars($content) . "</pre>";
}

?>
