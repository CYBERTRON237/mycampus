<?php
// Test script for preinscription API
$email = "ulrich@gmail.com";

// Test data
$postData = json_encode(['email' => $email]);

// Make request
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription_by_email.php");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($postData)
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "=== API TEST RESULTS ===\n";
echo "HTTP Status: $httpCode\n";
echo "Response Length: " . strlen($response) . " bytes\n\n";

echo "RAW RESPONSE:\n";
echo $response . "\n\n";

// Parse and analyze
$data = json_decode($response, true);
if ($data && isset($data['data'])) {
    echo "PARSED DATA ANALYSIS:\n";
    foreach ($data['data'] as $key => $value) {
        $type = gettype($value);
        $displayValue = is_null($value) ? 'NULL' : (is_bool($value) ? ($value ? 'true' : 'false') : $value);
        echo "  $key: $type = $displayValue\n";
    }
} else {
    echo "FAILED TO PARSE JSON RESPONSE\n";
}
?>
