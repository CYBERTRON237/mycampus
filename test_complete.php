<?php
// Test complet du système de profil étudiant
header('Content-Type: application/json');

// Connexion BDD
try {
    $pdo = new PDO("mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4", 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Connexion BDD échouée: ' . $e->getMessage()]);
    exit;
}

echo "=== TEST COMPLET PROFIL ÉTUDIANT ===\n\n";

// Test 1: Vérifier utilisateur 42
echo "1. UTILISATEUR 42:\n";
$stmt = $pdo->prepare("SELECT id, email, role, first_name, last_name FROM users WHERE id = 42");
$stmt->execute([42]);
$user = $stmt->fetch();

if ($user) {
    echo "- ID: {$user['id']}\n";
    echo "- Email: {$user['email']}\n";
    echo "- Rôle: {$user['role']}\n";
    echo "- Nom: {$user['first_name']} {$user['last_name']}\n";
} else {
    echo "- ERREUR: Utilisateur 42 non trouvé!\n";
    exit;
}

echo "\n";

// Test 2: Chercher sa préinscription par email
echo "2. PRÉINSCRIPTION PAR EMAIL:\n";
$stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE email = ? AND status IN ('accepted', 'confirmed') ORDER BY created_at DESC LIMIT 1");
$stmt->execute([$user['email']]);
$preinsc = $stmt->fetch();

if ($preinsc) {
    echo "- ID: {$preinsc['id']}\n";
    echo "- Code Unique: {$preinsc['unique_code']}\n";
    echo "- Statut: {$preinsc['status']}\n";
    echo "- Faculté: {$preinsc['faculty']}\n";
    echo "- Programme: {$preinsc['desired_program']}\n";
    echo "- Niveau: {$preinsc['study_level']}\n";
    echo "- Spécialisation: {$preinsc['specialization']}\n";
    echo "- Nom Parent: {$preinsc['parent_name']}\n";
    echo "- Téléphone Parent: {$preinsc['parent_phone']}\n";
    echo "- Relation Parent: {$preinsc['parent_relationship']}\n";
    echo "- Adresse: {$preinsc['residence_address']}\n";
    echo "- Date Soumission: {$preinsc['submission_date']}\n";
} else {
    echo "- ERREUR: Aucune préinscription validée trouvée!\n";
}

echo "\n";

// Test 3: Test API endpoint
echo "3. TEST API ENDPOINT:\n";
$api_url = 'http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription_by_email.php';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $api_url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['email' => $user['email']]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "- HTTP Status: $http_code\n";
echo "- Response: $response\n";

echo "\n=== FIN DES TESTS ===\n";
?>
