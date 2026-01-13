<?php
// Script pour démarrer le serveur WebSocket en arrière-plan

$websocket_file = __DIR__ . '/api/messaging/websocket/server_basic.php';
$pid_file = __DIR__ . '/websocket_server.pid';
$log_file = __DIR__ . '/websocket_server.log';

// Fonction pour vérifier si un processus est en cours d'exécution (compatible Windows/Linux)
function isProcessRunning($pid) {
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        // Windows: utiliser tasklist
        $result = shell_exec("tasklist /FI \"PID eq $pid\" 2>NUL");
        return strpos($result, $pid) !== false;
    } else {
        // Linux/Unix: utiliser posix_kill
        return function_exists('posix_kill') ? posix_kill($pid, 0) : false;
    }
}

// Vérifier si le serveur est déjà en cours d'exécution
if (file_exists($pid_file)) {
    $pid = file_get_contents($pid_file);
    if (isProcessRunning($pid)) {
        echo "Le serveur WebSocket est déjà en cours d'exécution (PID: $pid)\n";
        exit(0);
    } else {
        // Le processus n'existe plus, supprimer le fichier PID
        unlink($pid_file);
    }
}

// Démarrer le serveur WebSocket en arrière-plan
echo "Démarrage du serveur WebSocket...\n";

if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    // Windows: utiliser start /B avec des guillemets pour les chemins avec espaces
    $websocket_file_escaped = str_replace(' ', '" "', $websocket_file);
    $command = "start /B php \"$websocket_file\" > \"$log_file\" 2>&1";
    $output = [];
    exec($command, $output);
    
    echo "Commande exécutée: $command\n";
    echo "Fichier WebSocket: $websocket_file\n";
    echo "Fichier log: $log_file\n";
    
    // Récupérer le PID (méthode alternative pour Windows)
    sleep(3); // Attendre un peu plus longtemps
    
    // Chercher tous les processus PHP
    $pid_output = shell_exec("wmic process where \"name='php.exe'\" get processid,commandline /format:csv 2>NUL");
    echo "Recherche PID:\n$pid_output\n";
    
    $lines = explode("\n", trim($pid_output));
    $pid = 0;
    
    foreach ($lines as $line) {
        if (strpos($line, $websocket_file) !== false) {
            $parts = explode(',', $line);
            if (count($parts) >= 2) {
                $pid = trim($parts[1]);
                if (is_numeric($pid)) {
                    break;
                }
            }
        }
    }
    
    if ($pid > 0) {
        file_put_contents($pid_file, $pid);
        echo "Serveur WebSocket démarré avec succès (PID: $pid)\n";
    } else {
        echo "Erreur: Impossible de récupérer le PID du processus\n";
        echo "Vérifiez manuellement si le processus est en cours d'exécution\n";
    }
} else {
    // Linux/Unix: utiliser nohup
    $pid = exec("nohup php $websocket_file > $log_file 2>&1 & echo $!");
    file_put_contents($pid_file, $pid);
    echo "Serveur WebSocket démarré avec succès (PID: $pid)\n";
}
?>
