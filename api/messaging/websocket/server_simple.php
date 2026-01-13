<?php

require_once __DIR__ . '/../../../vendor/autoload.php';

// Déclarations use au début
use MyCampus\WebSocket\ChatServer;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

// Vérifier si Ratchet est disponible
if (!class_exists('Ratchet\Server\IoServer')) {
    echo "ERREUR: Ratchet n'est pas installé. Utilisation d'un serveur WebSocket simple...\n\n";
    
    // Serveur WebSocket simple basé sur stream_socket_server
    $host = '127.0.0.1';
    $port = 8080;
    
    echo "Serveur WebSocket simple démarré sur ws://{$host}:{$port}\n";
    echo "Appuyez sur Ctrl+C pour arrêter\n\n";
    
    $socket = stream_socket_server("tcp://{$host}:{$port}", $errno, $errstr);
    if (!$socket) {
        echo "Erreur: $errstr ($errno)\n";
        exit(1);
    }
    
    $clients = [];
    
    while (true) {
        $read = [$socket];
        $write = $except = null;
        
        // Ajouter tous les clients au read set
        foreach ($clients as $client) {
            $read[] = $client;
        }
        
        if (stream_select($read, $write, $except, null) > 0) {
            // Nouvelle connexion
            if (in_array($socket, $read)) {
                $new_client = stream_socket_accept($socket);
                if ($new_client) {
                    // Lire le handshake
                    $handshake = fread($new_client, 2048);
                    if ($handshake) {
                        $clients[] = $new_client;
                        echo "Nouveau client connecté\n";
                        
                        // Parser le handshake WebSocket
                        $headers = explode("\r\n", $handshake);
                        $key = '';
                        foreach ($headers as $header) {
                            if (strpos($header, 'Sec-WebSocket-Key:') !== false) {
                                $key = trim(substr($header, 19));
                                break;
                            }
                        }
                        
                        if ($key) {
                            $acceptKey = base64_encode(sha1($key . "258EAFA5-E914-47DA-95CA-C5AB0DC85B11", true));
                            
                            $response = "HTTP/1.1 101 Switching Protocols\r\n";
                            $response .= "Upgrade: websocket\r\n";
                            $response .= "Connection: Upgrade\r\n";
                            $response .= "Sec-WebSocket-Accept: $acceptKey\r\n";
                            $response .= "\r\n";
                            
                            fwrite($new_client, $response);
                            echo "Handshake WebSocket complété\n";
                        }
                    }
                }
                unset($read[array_search($socket, $read)]);
            }
            
            // Messages des clients
            foreach ($read as $client) {
                $data = fread($client, 1024);
                if ($data === false) {
                    // Client déconnecté
                    unset($clients[array_search($client, $clients)]);
                    echo "Client déconnecté\n";
                    continue;
                }
                
                echo "Message reçu: " . $data . "\n";
                
                // Echo simple du message
                foreach ($clients as $other_client) {
                    if ($other_client !== $client) {
                        fwrite($other_client, $data);
                    }
                }
            }
        }
    }
    
} else {
    // Utiliser Ratchet si disponible
    require_once __DIR__ . '/src/ChatServer.php';
    
    $host = '127.0.0.1';
    $port = 8080;
    
    echo "Démarrage du serveur WebSocket MyCampus avec Ratchet...\n";
    echo "Adresse: ws://{$host}:{$port}\n";
    echo "Appuyez sur Ctrl+C pour arrêter\n\n";
    
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
}
