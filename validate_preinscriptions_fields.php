<?php
// Script de validation pour vérifier que tous les champs de la table préinscriptions sont gérés

header('Content-Type: text/plain; charset=utf-8');

// Connexion à la base de données
try {
    $host = '127.0.0.1';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
} catch (PDOException $e) {
    echo "Erreur de connexion: " . $e->getMessage() . "\n";
    exit;
}

echo "=== VALIDATION DES CHAMPS DE LA TABLE PREINSCRIPTIONS ===\n\n";

// 1. Récupérer la structure de la table
echo "1. Structure de la table préinscriptions:\n";
$stmt = $pdo->prepare("DESCRIBE preinscriptions");
$stmt->execute();
$columns = $stmt->fetchAll();

foreach ($columns as $column) {
    echo "- {$column['Field']} ({$column['Type']}) " . ($column['Null'] === 'NO' ? 'NOT NULL' : 'NULL') . " Default: {$column['Default']}\n";
}

echo "\n";

// 2. Vérifier les données existantes
echo "2. Vérification des données existantes:\n";
$stmt = $pdo->prepare("SELECT COUNT(*) as total FROM preinscriptions WHERE deleted_at IS NULL");
$stmt->execute();
$total = $stmt->fetch()['total'];
echo "Total des préinscriptions actives: $total\n\n";

// 3. Analyser quelques enregistrements
echo "3. Analyse des 3 premiers enregistrements:\n";
$stmt = $pdo->prepare("SELECT * FROM preinscriptions WHERE deleted_at IS NULL ORDER BY id DESC LIMIT 3");
$stmt->execute();
$records = $stmt->fetchAll();

foreach ($records as $i => $record) {
    echo "\n--- Enregistrement #" . ($i + 1) . " (ID: {$record['id']}) ---\n";
    
    // Champs importants à vérifier
    $importantFields = [
        'id', 'uuid', 'unique_code', 'faculty', 'last_name', 'first_name', 
        'email', 'phone_number', 'status', 'payment_status', 'submission_date'
    ];
    
    foreach ($importantFields as $field) {
        $value = $record[$field] ?? 'NULL';
        echo "  $field: $value\n";
    }
}

echo "\n";

// 4. Vérifier la cohérence des statuts
echo "4. Distribution des statuts:\n";
$stmt = $pdo->prepare("SELECT status, COUNT(*) as count FROM preinscriptions WHERE deleted_at IS NULL GROUP BY status");
$stmt->execute();
$statusStats = $stmt->fetchAll();

foreach ($statusStats as $stat) {
    echo "- {$stat['status']}: {$stat['count']}\n";
}

echo "\n";

// 5. Vérifier la cohérence des statuts de paiement
echo "5. Distribution des statuts de paiement:\n";
$stmt = $pdo->prepare("SELECT payment_status, COUNT(*) as count FROM preinscriptions WHERE deleted_at IS NULL GROUP BY payment_status");
$stmt->execute();
$paymentStats = $stmt->fetchAll();

foreach ($paymentStats as $stat) {
    echo "- {$stat['payment_status']}: {$stat['count']}\n";
}

echo "\n";

// 6. Vérifier les facultés
echo "6. Distribution par faculté:\n";
$stmt = $pdo->prepare("SELECT faculty, COUNT(*) as count FROM preinscriptions WHERE deleted_at IS NULL GROUP BY faculty ORDER BY count DESC");
$stmt->execute();
$facultyStats = $stmt->fetchAll();

foreach ($facultyStats as $stat) {
    echo "- {$stat['faculty']}: {$stat['count']}\n";
}

echo "\n";

// 7. Tester l'API directement
echo "7. Test de l'API REST:\n";

// Configuration cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=1&limit=2');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'X-User-ID: 1'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Status Code: $httpCode\n";
if ($httpCode == 200) {
    $data = json_decode($response, true);
    if ($data && $data['success']) {
        echo "API Response: SUCCESS\n";
        echo "Nombre d'enregistrements retournés: " . count($data['data']) . "\n";
        
        // Vérifier que les champs sont présents
        if (!empty($data['data'])) {
            $firstRecord = $data['data'][0];
            echo "Champs retournés par l'API:\n";
            foreach (array_keys($firstRecord) as $field) {
                echo "  - $field\n";
            }
        }
    } else {
        echo "API Response: ERROR - " . ($data['message'] ?? 'Unknown error') . "\n";
    }
} else {
    echo "API Error: HTTP $httpCode\n";
}

echo "\n=== FIN DE LA VALIDATION ===\n";
?>
