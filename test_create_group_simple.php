<?php
// Test simple de création de groupe avec institution_id
$data = [
    'name' => 'Groupe Test API',
    'description' => 'Un groupe de test pour verifier que l\'API fonctionne',
    'group_type' => 'study',
    'visibility' => 'public',
    'institution_id' => 1
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/mycampus/api/groups/create');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-Id: 1'
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n";
?>
