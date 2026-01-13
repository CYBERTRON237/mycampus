<?php
// Test simple pour l'API de messagerie

// Test 1: Récupérer l'ID de conversation
echo "=== Test 1: Get Conversation ID ===\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/messaging/messages/get_conversation_id.php?user_id=1&participant_id=2");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-User-Id: 1']);
$response = curl_exec($ch);
curl_close($ch);
echo "Response: " . $response . "\n\n";

$data = json_decode($response, true);
$conversationId = $data['conversation_id'] ?? 1;

// Test 2: Envoyer un message
echo "=== Test 2: Send Message ===\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/messaging/messages/send_message.php");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-Id: 1'
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'receiver_id' => 2,
    'content' => 'Test message from API test',
    'type' => 'text'
]));
$response = curl_exec($ch);
curl_close($ch);
echo "Response: " . $response . "\n\n";

// Test 3: Récupérer les messages
echo "=== Test 3: Get Messages ===\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/messaging/messages/get_messages.php?id=$conversationId");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-User-Id: 1']);
$response = curl_exec($ch);
curl_close($ch);
echo "Response: " . $response . "\n\n";

?>
