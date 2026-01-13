<?php
// Test script for notifications API
echo "<h1>Test API Notifications</h1>";

// Test GET /notifications
echo "<h2>1. Test GET /notifications</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/notifications/notifications");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p>HTTP Status: $http_code</p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test GET /notifications/unread-count
echo "<h2>2. Test GET /notifications/unread-count</h2>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/notifications/notifications/unread-count");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p>HTTP Status: $http_code</p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Test POST /notifications (create)
echo "<h2>3. Test POST /notifications (create)</h2>";
$test_notification = [
    'user_id' => 1,
    'title' => 'Test Notification',
    'content' => 'Ceci est une notification de test',
    'type' => 'system',
    'category' => 'system',
    'priority' => 'normal'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/notifications/notifications");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($test_notification));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "<p>HTTP Status: $http_code</p>";
echo "<pre>" . htmlspecialchars($response) . "</pre>";

// Parse response to get notification ID for further tests
$notif_data = json_decode($response, true);
$notif_id = null;
if ($notif_data && $notif_data['success'] && isset($notif_data['data']['id'])) {
    $notif_id = $notif_data['data']['id'];
    echo "<p>Created notification ID: $notif_id</p>";
    
    // Test PUT /notifications/{id}/read
    echo "<h2>4. Test PUT /notifications/$notif_id/read</h2>";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/notifications/notifications/$notif_id/read");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    echo "<p>HTTP Status: $http_code</p>";
    echo "<pre>" . htmlspecialchars($response) . "</pre>";
    
    // Test DELETE /notifications/{id}
    echo "<h2>5. Test DELETE /notifications/$notif_id</h2>";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/notifications/notifications/$notif_id");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    echo "<p>HTTP Status: $http_code</p>";
    echo "<pre>" . htmlspecialchars($response) . "</pre>";
}

echo "<h2>Tests terminés</h2>";
?>
