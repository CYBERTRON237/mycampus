<?php
// Test de validation de la correction du profil

echo "=== Test de validation du profil ===\n\n";

// Test 1: Vérifier qu'une préinscription acceptée existe bien
echo "1. Test: Préinscription acceptée dans la base de données\n";
$pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '');
$stmt = $pdo->prepare("SELECT COUNT(*) as count FROM preinscriptions WHERE status = 'accepted'");
$stmt->execute();
$result = $stmt->fetch();
echo "   Nombre de préinscriptions acceptées: {$result['count']}\n";

if ($result['count'] > 0) {
    $stmt = $pdo->prepare("SELECT email, status, faculty, desired_program, admission_number FROM preinscriptions WHERE status = 'accepted' LIMIT 1");
    $stmt->execute();
    $accepted = $stmt->fetch();
    echo "   Exemple - Email: {$accepted['email']}, Statut: {$accepted['status']}, Faculté: {$accepted['faculty']}\n";
    echo "   Numéro d'admission: " . ($accepted['admission_number'] ?? 'Non attribué') . "\n";
}

// Test 2: Vérifier les utilisateurs avec rôle 'student'
echo "\n2. Test: Utilisateurs avec rôle student\n";
$stmt = $pdo->prepare("SELECT COUNT(*) as count FROM users WHERE primary_role = 'student'");
$stmt->execute();
$result = $stmt->fetch();
echo "   Nombre d'utilisateurs avec rôle student: {$result['count']}\n";

// Test 3: Vérifier la cohérence entre users et preinscriptions
echo "\n3. Test: Cohérence users-préinscriptions\n";
$stmt = $pdo->prepare("
    SELECT u.email, u.primary_role, p.status, p.unique_code 
    FROM users u 
    LEFT JOIN preinscriptions p ON u.email = p.email 
    WHERE u.primary_role = 'student' OR p.status = 'accepted'
    LIMIT 5
");
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($users as $user) {
    echo "   Email: {$user['email']}, Rôle: {$user['primary_role']}, Préinscription: {$user['status']}, Code: {$user['unique_code']}\n";
}

// Test 4: Test de l'API de profil
echo "\n4. Test: API de profil\n";
if ($result['count'] > 0) {
    // Récupérer un email de test
    $stmt = $pdo->prepare("SELECT email FROM users WHERE primary_role = 'student' LIMIT 1");
    $stmt->execute();
    $user = $stmt->fetch();
    
    if ($user) {
        $body = json_encode(['email' => $user['email']]);
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/mycampus/api/preinscriptions/get_my_preinscription.php');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "   API Test - HTTP Code: $httpCode\n";
        if ($httpCode == 200) {
            $data = json_decode($response, true);
            echo "   API Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
            if ($data['success']) {
                echo "   Statut retourné: {$data['data']['status']}\n";
                echo "   Faculté: {$data['data']['faculty']}\n";
            }
        } else {
            echo "   API Error: $response\n";
        }
    }
}

echo "\n=== Test terminé ===\n";
echo "\nRésumé de la correction:\n";
echo "- Le ProfileProvider a été corrigé pour afficher le bon rôle 'student' quand la préinscription est acceptée\n";
echo "- La page ProfessionalProfilePage affiche maintenant le bon statut (ÉTUDIANT au lieu de EN ATTENTE)\n";
echo "- La logique des getters a été simplifiée pour utiliser directement les données de préinscription\n";
echo "- Le badge de statut s'adapte dynamiquement selon le rôle et le statut de préinscription\n";
?>
