<?php
// Test de récupération des préinscriptions depuis la BD

header('Content-Type: application/json');

// Connexion directe à la base de données
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
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage()
    ]);
    exit;
}

echo "=== TEST DE RÉCUPÉRATION DES PRÉINSCRIPTIONS ===\n\n";

// Test 1: Vérifier si la table existe et compter les enregistrements
echo "1. Vérification de la table preinscriptions:\n";
try {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM preinscriptions");
    $result = $stmt->fetch();
    echo "Total des préinscriptions: " . $result['total'] . "\n\n";
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n\n";
}

// Test 2: Structure de la table
echo "2. Structure de la table preinscriptions:\n";
try {
    $stmt = $pdo->query("DESCRIBE preinscriptions");
    $columns = $stmt->fetchAll();
    echo "Colonnes trouvées: " . count($columns) . "\n";
    foreach ($columns as $column) {
        echo "- {$column['Field']} ({$column['Type']})\n";
    }
    echo "\n";
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n\n";
}

// Test 3: Récupération des 5 premières préinscriptions
echo "3. 5 premières préinscriptions:\n";
try {
    $sql = "SELECT id, unique_code, first_name, last_name, email, faculty, status, payment_status, submission_date 
            FROM preinscriptions 
            WHERE deleted_at IS NULL 
            ORDER BY submission_date DESC 
            LIMIT 5";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $preinscriptions = $stmt->fetchAll();
    
    echo "Résultats trouvés: " . count($preinscriptions) . "\n";
    foreach ($preinscriptions as $preinscription) {
        echo "ID: {$preinscription['id']} | Code: {$preinscription['unique_code']} | ";
        echo "Nom: {$preinscription['first_name']} {$preinscription['last_name']} | ";
        echo "Email: {$preinscription['email']} | Faculté: {$preinscription['faculty']} | ";
        echo "Statut: {$preinscription['status']} | Paiement: {$preinscription['payment_status']} | ";
        echo "Date: {$preinscription['submission_date']}\n";
    }
    echo "\n";
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n\n";
}

// Test 4: Statistiques par statut
echo "4. Statistiques par statut:\n";
try {
    $sql = "SELECT status, COUNT(*) as count 
            FROM preinscriptions 
            WHERE deleted_at IS NULL 
            GROUP BY status";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $stats = $stmt->fetchAll();
    
    foreach ($stats as $stat) {
        echo "- {$stat['status']}: {$stat['count']}\n";
    }
    echo "\n";
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n\n";
}

// Test 5: Statistiques par faculté
echo "5. Statistiques par faculté:\n";
try {
    $sql = "SELECT faculty, COUNT(*) as count 
            FROM preinscriptions 
            WHERE deleted_at IS NULL 
            GROUP BY faculty";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $stats = $stmt->fetchAll();
    
    foreach ($stats as $stat) {
        echo "- {$stat['faculty']}: {$stat['count']}\n";
    }
    echo "\n";
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n\n";
}

// Test 6: Recherche test
echo "6. Test de recherche (nom contient 'Jean'):\n";
try {
    $sql = "SELECT id, unique_code, first_name, last_name, email 
            FROM preinscriptions 
            WHERE deleted_at IS NULL 
            AND (first_name LIKE ? OR last_name LIKE ? OR email LIKE ?)
            LIMIT 3";
    
    $searchParam = "%Jean%";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$searchParam, $searchParam, $searchParam]);
    $results = $stmt->fetchAll();
    
    echo "Résultats trouvés: " . count($results) . "\n";
    foreach ($results as $result) {
        echo "- ID: {$result['id']} | {$result['first_name']} {$result['last_name']} | {$result['email']}\n";
    }
    echo "\n";
} catch (Exception $e) {
    echo "ERREUR: " . $e->getMessage() . "\n\n";
}

echo "=== FIN DES TESTS ===\n";
?>
