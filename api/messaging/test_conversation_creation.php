<?php
// Script de test pour vérifier la création automatique de conversations
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-User-Id');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Simuler l'ID utilisateur pour les tests
$_SERVER['HTTP_X_USER_ID'] = '1';

require_once 'controllers/SimpleMessageController.php';

$controller = new SimpleMessageController();

echo json_encode([
    'success' => true,
    'message' => 'Test de création de conversation',
    'test_cases' => [
        [
            'name' => 'Créer conversation entre utilisateur 1 et 3',
            'url' => '/api/messaging/messages/get_conversation_id.php?participant_id=3',
            'method' => 'GET',
            'expected' => 'Nouvelle conversation créée ou existante retournée'
        ],
        [
            'name' => 'Envoyer un message entre utilisateur 1 et 3',
            'url' => '/api/messaging/messages/send_message.php',
            'method' => 'POST',
            'data' => [
                'receiver_id' => 3,
                'content' => 'Bonjour, ceci est un test de conversation automatique!',
                'type' => 'text'
            ],
            'expected' => 'Message envoyé et conversation mise à jour'
        ],
        [
            'name' => 'Vérifier les conversations de l\'utilisateur 1',
            'url' => '/api/messaging/messages/get_conversations.php',
            'method' => 'GET',
            'expected' => 'Liste des conversations avec la nouvelle conversation visible'
        ]
    ]
]);
?>
