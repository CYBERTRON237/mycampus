<?php
// Script de démarrage complet pour MyCampus avec WebSocket

echo "=== Démarrage de MyCampus avec WebSocket ===\n";

// 1. Démarrer le serveur WebSocket
echo "1. Démarrage du serveur WebSocket...\n";
$websocket_output = [];
$websocket_return = 0;

exec('php start_websocket.php 2>&1', $websocket_output, $websocket_return);

if ($websocket_return === 0) {
    echo "✓ Serveur WebSocket démarré avec succès\n";
} else {
    echo "✗ Erreur lors du démarrage du serveur WebSocket:\n";
    echo implode("\n", $websocket_output) . "\n";
}

// 2. Vérifier que le serveur fonctionne
echo "\n2. Vérification du serveur WebSocket...\n";
sleep(3);

$pid_file = __DIR__ . '/websocket_server.pid';
if (file_exists($pid_file)) {
    $pid = file_get_contents($pid_file);
    if (function_exists('posix_kill') && posix_kill($pid, 0)) {
        echo "✓ Serveur WebSocket en cours d'exécution (PID: $pid)\n";
    } else {
        echo "✗ Le serveur WebSocket ne semble pas fonctionner correctement\n";
    }
} else {
    echo "✗ Fichier PID du serveur WebSocket introuvable\n";
}

// 3. Instructions pour l'utilisateur
echo "\n=== Instructions ===\n";
echo "• Le serveur WebSocket écoute sur: ws://127.0.0.1:8080\n";
echo "• Lancez votre application Flutter maintenant\n";
echo "• Les messages devraient s'envoyer et s'afficher en temps réel\n";
echo "• Pour arrêter le serveur: php stop_websocket.php\n";
echo "• Logs du serveur: websocket_server.log\n";

?>
