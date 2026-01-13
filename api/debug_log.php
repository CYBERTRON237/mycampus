<?php
function debug_log($message, $data = null) {
    $logFile = __DIR__ . '/../logs/api_debug.log';
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message";
    
    if ($data !== null) {
        $logMessage .= ' ' . (is_string($data) ? $data : json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }
    
    $logMessage .= "\n";
    
    // Créer le dossier de logs s'il n'existe pas
    $logDir = dirname($logFile);
    if (!file_exists($logDir)) {
        mkdir($logDir, 0777, true);
    }
    
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}

// Démarrer le log de la requête
debug_log('\n=== NOUVELLE REQUÊTE ===');
debug_log('Méthode:', $_SERVER['REQUEST_METHOD']);
debug_log('URL:', $_SERVER['REQUEST_URI']);
debug_log('En-têtes:', getallheaders());
debug_log('Données POST:', $_POST);
debug_log('Données GET:', $_GET);

// Lire le contenu brut (pour les requêtes JSON)
$input = file_get_contents('php://input');
if (!empty($input)) {
    $jsonData = json_decode($input, true);
    debug_log('Données brutes (JSON):', $jsonData !== null ? $jsonData : $input);
}
?>
