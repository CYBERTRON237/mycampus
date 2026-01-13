<?php
// Version de test pour afficher les erreurs
error_reporting(E_ALL);
ini_set('display_errors', 1);

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
    echo "Connexion BD réussie\n";
} catch (PDOException $e) {
    echo "Erreur BD: " . $e->getMessage() . "\n";
    exit;
}

// Test simple d'insertion
$sql = "INSERT INTO preinscriptions (
    uuid, unique_code, faculty, last_name, first_name, middle_name,
    date_of_birth, is_birth_date_on_certificate, place_of_birth, gender,
    cni_number, residence_address, marital_status, phone_number, email,
    first_language, professional_situation
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

echo "SQL: $sql\n";
echo "Nombre de ?: " . substr_count($sql, '?') . "\n";

$params = [
    'test-uuid-12345',
    'TEST123',
    'UY1',
    'Test',
    'User',
    null,
    '2000-01-01',
    1,
    'Yaounde',
    'MASCULIN',
    null,
    'Test Address',
    'CELIBATAIRE',
    '698765432',
    'test@example.com',
    'FRANCAIS',
    'SANS EMPLOI'
];

echo "Nombre de paramètres: " . count($params) . "\n";

try {
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute($params);
    
    if ($result) {
        echo "Insertion réussie!\n";
    } else {
        echo "Insertion échouée\n";
        $errorInfo = $stmt->errorInfo();
        print_r($errorInfo);
    }
} catch (Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
?>
