<?php

require_once __DIR__ . '/../../../vendor/autoload.php';
require_once __DIR__ . '/src/ChatServer.php';

use MyCampus\WebSocket\ChatServer;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

// Configuration
$host = '127.0.0.1';
$port = 8080;

echo "Démarrage du serveur WebSocket MyCampus...\n";
echo "Adresse: ws://{$host}:{$port}\n";
echo "Appuyez sur Ctrl+C pour arrêter\n\n";

// Création du serveur
$server = IoServer::factory(
    new HttpServer(
        new WsServer(
            new ChatServer()
        )
    ),
    $port,
    $host
);

try {
    $server->run();
} catch (Exception $e) {
    echo "Erreur serveur: " . $e->getMessage() . "\n";
}
