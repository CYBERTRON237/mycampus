<?php
// Serveur WebSocket simplifié et robuste

error_reporting(E_ALL);
ini_set('display_errors', 1);
set_time_limit(0);
ob_implicit_flush();

$host = '127.0.0.1';
$port = 8080;

echo "Serveur WebSocket MyCampus simplifié démarré sur ws://{$host}:{$port}\n";
echo "Appuyez sur Ctrl+C pour arrêter\n\n";

// Créer le socket serveur
$socket = stream_socket_server("tcp://{$host}:{$port}", $errno, $errstr);
if (!$socket) {
    echo "Erreur: $errstr ($errno)\n";
    exit(1);
}

echo "Serveur démarré avec succès - en attente de connexions...\n";

$clients = [];

while (true) {
    // Accepter les nouvelles connexions
    $read = [$socket];
    foreach ($clients as $client) {
        if (is_resource($client)) {
            $read[] = $client;
        }
    }
    
    $write = [];
    $except = [];
    
    // Attendre une activité avec timeout
    if (stream_select($read, $write, $except, 5) > 0) {
        // Nouvelle connexion
        if (in_array($socket, $read)) {
            $client = stream_socket_accept($socket, 1);
            if ($client) {
                $clients[] = $client;
                echo "Nouveau client connecté\n";
                
                $welcome = json_encode([
                    'type' => 'connection',
                    'message' => 'Connecté au serveur WebSocket MyCampus'
                ]);
                fwrite($client, $welcome . "\n");
            }
            unset($read[array_search($socket, $read)]);
        }
        
        // Messages des clients
        foreach ($read as $client) {
            if (!is_resource($client)) continue;
            
            $data = fread($client, 1024);
            if ($data === false || strlen($data) === 0) {
                // Client déconnecté
                fclose($client);
                $key = array_search($client, $clients);
                if ($key !== false) {
                    unset($clients[$key]);
                    $clients = array_values($clients); // Réindexer
                }
                echo "Client déconnecté\n";
                continue;
            }
            
            try {
                $message = json_decode(trim($data), true);
                if ($message && isset($message['type'])) {
                    echo "Message reçu: " . $message['type'] . "\n";
                    
                    // Diffuser aux autres clients
                    if (isset($message['room'])) {
                        foreach ($clients as $otherClient) {
                            if ($otherClient !== $client && is_resource($otherClient)) {
                                fwrite($otherClient, $data . "\n");
                            }
                        }
                    }
                }
            } catch (Exception $e) {
                echo "Erreur traitement message: " . $e->getMessage() . "\n";
            }
        }
    }
    
    // Nettoyer les clients déconnectés
    $activeClients = [];
    foreach ($clients as $client) {
        if (is_resource($client)) {
            $activeClients[] = $client;
        }
    }
    $clients = $activeClients;
}
?>
