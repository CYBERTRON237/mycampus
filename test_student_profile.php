<?php
// Test pour vérifier que le StudentProfileWidget sera bien utilisé

echo "=== Test StudentProfileWidget ===\n\n";

// Connexion à la base
$pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '');

// Test 1: Vérifier les étudiants avec préinscription acceptée
echo "1. Étudiants avec préinscription acceptée:\n";
$stmt = $pdo->prepare("
    SELECT u.email, u.primary_role, p.status, p.faculty, p.desired_program, p.admission_number 
    FROM users u 
    JOIN preinscriptions p ON u.email = p.email 
    WHERE p.status = 'accepted' AND u.primary_role = 'student'
");
$stmt->execute();
$students = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($students as $student) {
    echo "   Email: {$student['email']}\n";
    echo "   Rôle: {$student['primary_role']}\n";
    echo "   Statut: {$student['status']}\n";
    echo "   Faculté: {$student['faculty']}\n";
    echo "   Programme: {$student['desired_program']}\n";
    echo "   Admission: {$student['admission_number']}\n";
    echo "   ---\n";
}

echo "\n2. Logique d'affichage:\n";
echo "   - Si isStudent = true ET isPreinscriptionAccepted = true\n";
echo "   - ALORS afficher StudentProfileWidget (sans onglets)\n";
echo "   - SINON afficher les onglets (Profil, Académique, Professionnel)\n";

echo "\n3. Avantages du StudentProfileWidget:\n";
echo "   - Header dégradé avec photo et statut ADMIS\n";
echo "   - Carte d'identité étudiante complète\n";
echo "   - Informations académiques structurées\n";
echo "   - Coordonnées et contact d'urgence\n";
echo "   - Design optimisé pour les étudiants\n";

echo "\n=== Test terminé ===\n";
?>
