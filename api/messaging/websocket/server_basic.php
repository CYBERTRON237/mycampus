<?php
// Serveur WebSocket avec protocole WebSocket complet

// Activer le mode non bloquant et gestion des timeouts
set_time_limit(0);
ob_implicit_flush();

$host = '127.0.0.1';
$port = 8080;

echo "Serveur WebSocket MyCampus démarré sur ws://{$host}:{$port}\n";
echo "Appuyez sur Ctrl+C pour arrêter\n\n";

// Créer le socket serveur
$socket = stream_socket_server("tcp://{$host}:{$port}", $errno, $errstr);
if (!$socket) {
    echo "Erreur: $errstr ($errno)\n";
    exit(1);
}

// Configuration du socket pour le non-bloquant
stream_set_blocking($socket, 0);

$clients = [];
$rooms = [];

echo "Serveur démarré avec succès\n";

function performWebSocketHandshake($client, $headers) {
    // Extraire la clé WebSocket
    $key = '';
    foreach ($headers as $header) {
        if (strpos($header, 'Sec-WebSocket-Key:') !== false) {
            $key = trim(substr($header, 19));
            break;
        }
    }
    
    if (empty($key)) {
        echo "Clé WebSocket non trouvée\n";
        fclose($client);
        return false;
    }
    
    // Calculer la clé de réponse
    $acceptKey = base64_encode(pack('H*', sha1($key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));
    
    // Envoyer la réponse de handshake
    $response = "HTTP/1.1 101 Switching Protocols\r\n" .
               "Upgrade: websocket\r\n" .
               "Connection: Upgrade\r\n" .
               "Sec-WebSocket-Accept: $acceptKey\r\n" .
               "\r\n";
    
    fwrite($client, $response);
    echo "Handshake WebSocket réussi\n";
    return true;
}

function decodeWebSocketFrame($data) {
    if (strlen($data) < 2) {
        return false;
    }
    
    $firstByte = ord($data[0]);
    $secondByte = ord($data[1]);
    
    $fin = ($firstByte & 0x80) >> 7;
    $opcode = $firstByte & 0x0F;
    $masked = ($secondByte & 0x80) >> 7;
    $payloadLength = $secondByte & 0x7F;
    
    $offset = 2;
    
    // Gérer les longueurs de payload étendues
    if ($payloadLength === 126) {
        if (strlen($data) < 4) return false;
        $payloadLength = (ord($data[2]) << 8) | ord($data[3]);
        $offset = 4;
    } elseif ($payloadLength === 127) {
        if (strlen($data) < 10) return false;
        $payloadLength = 0;
        for ($i = 0; $i < 8; $i++) {
            $payloadLength = ($payloadLength << 8) | ord($data[$offset + $i]);
        }
        $offset = 10;
    }
    
    // Gérer le masque
    if ($masked) {
        if (strlen($data) < $offset + 4 + $payloadLength) return false;
        $mask = str_split(substr($data, $offset, 4));
        $offset += 4;
        $payload = substr($data, $offset, $payloadLength);
        
        // Démasquer le payload
        for ($i = 0; $i < $payloadLength; $i++) {
            $payload[$i] = $payload[$i] ^ $mask[$i % 4];
        }
    } else {
        if (strlen($data) < $offset + $payloadLength) return false;
        $payload = substr($data, $offset, $payloadLength);
    }
    
    return [
        'fin' => $fin,
        'opcode' => $opcode,
        'payload' => $payload
    ];
}

function encodeWebSocketFrame($payload, $opcode = 0x1) {
    $frame = chr(0x80 | $opcode); // FIN=1, opcode
    
    $payloadLength = strlen($payload);
    
    if ($payloadLength < 126) {
        $frame .= chr($payloadLength);
    } elseif ($payloadLength < 65536) {
        $frame .= chr(126) . pack('n', $payloadLength);
    } else {
        $frame .= chr(127) . pack('NN', 0, $payloadLength);
    }
    
    $frame .= $payload;
    return $frame;
}

while (true) {
    // Lire les sockets des clients
    $read = [$socket];
    foreach ($clients as $client) {
        $read[] = $client;
    }
    
    $write = [];
    $except = [];
    
    if (stream_select($read, $write, $except, 1) > 0) {
        // Nouvelle connexion
        if (in_array($socket, $read)) {
            $client = stream_socket_accept($socket, 1);
            if ($client) {
                stream_set_blocking($client, 0);
                
                // Lire les headers HTTP pour le handshake
                $headers = [];
                $handshakeComplete = false;
                
                // Attendre les headers avec un timeout
                $timeout = time() + 5;
                while (time() < $timeout && !$handshakeComplete) {
                    $data = fread($client, 1024);
                    if ($data === false || strlen($data) === 0) {
                        break;
                    }
                    
                    $lines = explode("\r\n", $data);
                    foreach ($lines as $line) {
                        if (empty(trim($line))) {
                            // Fin des headers, effectuer le handshake
                            if (performWebSocketHandshake($client, $headers)) {
                                $clients[] = $client;
                                echo "Nouveau client WebSocket connecté\n";
                                
                                // Envoyer un message de bienvenue
                                $welcome = json_encode([
                                    'type' => 'connection',
                                    'message' => 'Connecté au serveur WebSocket MyCampus'
                                ]);
                                fwrite($client, encodeWebSocketFrame($welcome));
                            }
                            $handshakeComplete = true;
                            break;
                        }
                        $headers[] = $line;
                    }
                }
                
                if (!$handshakeComplete) {
                    fclose($client);
                    echo "Échec du handshake WebSocket\n";
                }
            }
            unset($read[array_search($socket, $read)]);
        }
        
        // Messages des clients
        foreach ($read as $client) {
            $data = fread($client, 1024);
            if ($data === false || strlen($data) === 0) {
                // Client déconnecté
                fclose($client);
                unset($clients[array_search($client, $clients)]);
                echo "Client déconnecté\n";
                continue;
            }
            
            // Décoder la trame WebSocket
            $frame = decodeWebSocketFrame($data);
            if ($frame === false) {
                continue;
            }
            
            // Traiter les messages texte (opcode 0x1)
            if ($frame['opcode'] === 0x1) {
                try {
                    $message = json_decode($frame['payload'], true);
                    if ($message && isset($message['type'])) {
                        echo "Message reçu: " . $message['type'] . "\n";
                        
                        // Diffuser le message aux autres clients
                        foreach ($clients as $otherClient) {
                            if ($otherClient !== $client) {
                                fwrite($otherClient, encodeWebSocketFrame($frame['payload']));
                            }
                        }
                    }
                } catch (Exception $e) {
                    echo "Erreur de traitement du message: " . $e->getMessage() . "\n";
                }
            }
        }
    }
}
