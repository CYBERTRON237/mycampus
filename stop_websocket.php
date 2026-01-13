<?php
// Script pour arrêter le serveur WebSocket

$pid_file = __DIR__ . '/websocket_server.pid';

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

// Fonction pour tuer un processus (compatible Windows/Linux)
function killProcess($pid) {
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        // Windows: utiliser taskkill
        $result = shell_exec("taskkill /PID $pid /F 2>NUL");
        return strpos($result, "terminé") !== false || strpos($result, "terminated") !== false;
    } else {
        // Linux/Unix: utiliser posix_kill
        return function_exists('posix_kill') ? posix_kill($pid, 15) : false;
    }
}

if (!file_exists($pid_file)) {
    echo "Le serveur WebSocket n'est pas en cours d'exécution\n";
    exit(0);
}

$pid = file_get_contents($pid_file);

if (isProcessRunning($pid)) {
    if (killProcess($pid)) {
        echo "Serveur WebSocket arrêté (PID: $pid)\n";
        unlink($pid_file);
    } else {
        echo "Erreur lors de l'arrêt du serveur WebSocket\n";
        exit(1);
    }
} else {
    echo "Le processus du serveur WebSocket n'existe pas\n";
    unlink($pid_file);
}

?>
