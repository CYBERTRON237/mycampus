<?php
/**
 * Test simple du logging
 */

echo "<h1>Test simple du logging</h1>";

$logFile = __DIR__ . '/logs/preinscriptions_errors.log';
$timestamp = date('Y-m-d H:i:s');
$message = "[$timestamp] Test de logging simple" . PHP_EOL;

echo "<p>Fichier de log: $logFile</p>";
echo "<p>Message: " . htmlspecialchars($message) . "</p>";

// Test 1: Vérifier si le dossier existe
if (!is_dir(dirname($logFile))) {
    echo "<p style='color: red;'>Le dossier de logs n'existe pas.</p>";
} else {
    echo "<p style='color: green;'>Le dossier de logs existe.</p>";
}

// Test 2: Vérifier les permissions du dossier
$dir = dirname($logFile);
if (is_readable($dir)) {
    echo "<p style='color: green;'>Dossier lisible.</p>";
} else {
    echo "<p style='color: red;'>Dossier non lisible.</p>";
}

if (is_writable($dir)) {
    echo "<p style='color: green;'>Dossier inscriptible.</p>";
} else {
    echo "<p style='color: red;'>Dossier non inscriptible.</p>";
}

// Test 3: Essayer d'écrire dans le fichier
echo "<h2>Test d'écriture directe</h2>";
try {
    $result = file_put_contents($logFile, $message, FILE_APPEND | LOCK_EX);
    if ($result !== false) {
        echo "<p style='color: green;'>Écriture réussie: $result octets écrits.</p>";
    } else {
        echo "<p style='color: red;'>Écriture échouée.</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>Exception: " . htmlspecialchars($e->getMessage()) . "</p>";
}

// Test 4: Vérifier le contenu du fichier
echo "<h2>Contenu du fichier</h2>";
if (file_exists($logFile)) {
    $content = file_get_contents($logFile);
    if (!empty($content)) {
        echo "<p style='color: green;'>Fichier existe et contient:</p>";
        echo "<pre style='background: #f5f5f5; padding: 10px; border: 1px solid #ccc;'>" . htmlspecialchars($content) . "</pre>";
    } else {
        echo "<p style='color: orange;'>Fichier existe mais est vide.</p>";
    }
} else {
    echo "<p style='color: red;'>Fichier n'existe pas.</p>";
}

// Test 5: Essayer avec error_log
echo "<h2>Test avec error_log</h2>";
$testMessage = "Test error_log: " . date('Y-m-d H:i:s');
error_log($testMessage);
echo "<p>Message envoyé à error_log: " . htmlspecialchars($testMessage) . "</p>";

?>
