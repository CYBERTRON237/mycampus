<?php
// Test de la logique de profil

// Connexion à la base de données
$pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '');

// Test 1: Récupérer une préinscription avec statut 'accepted'
echo "=== Test 1: Préinscription ACCEPTED ===\n";
$stmt = $pdo->prepare("SELECT email, status, first_name, last_name, faculty, desired_program FROM preinscriptions WHERE status = 'accepted' LIMIT 1");
$stmt->execute();
$accepted = $stmt->fetch();
if ($accepted) {
    echo "Email: {$accepted['email']}, Status: {$accepted['status']}, Faculty: {$accepted['faculty']}\n";
    
    // Test API
    $body = json_encode(['email' => $accepted['email']]);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/mycampus/api/preinscriptions/get_my_preinscription.php');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    
    $data = json_decode($response, true);
    echo "API Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
    if ($data['success']) {
        echo "Status retourné: {$data['data']['status']}\n";
    }
} else {
    echo "Aucune préinscription acceptée trouvée\n";
}

echo "\n=== Test 2: Préinscription PENDING ===\n";
$stmt = $pdo->prepare("SELECT email, status, first_name, last_name, faculty, desired_program FROM preinscriptions WHERE status = 'pending' LIMIT 1");
$stmt->execute();
$pending = $stmt->fetch();
if ($pending) {
    echo "Email: {$pending['email']}, Status: {$pending['status']}, Faculty: {$pending['faculty']}\n";
    
    // Test API
    $body = json_encode(['email' => $pending['email']]);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/mycampus/api/preinscriptions/get_my_preinscription.php');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    
    $data = json_decode($response, true);
    echo "API Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
    if ($data['success']) {
        echo "Status retourné: {$data['data']['status']}\n";
    }
} else {
    echo "Aucune préinscription en attente trouvée\n";
}

echo "\n=== Test terminé ===\n";
?>
