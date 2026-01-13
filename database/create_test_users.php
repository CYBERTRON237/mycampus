<?php
// Script pour insérer des utilisateurs de test pour la messagerie
$host = '127.0.0.1';
$dbname = 'mycampus';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Utilisateurs de test
    $users = [
        [
            'email' => 'marie.dupont@email.com',
            'phone' => '690123456',
            'first_name' => 'Marie',
            'last_name' => 'Dupont',
            'gender' => 'female',
            'date_of_birth' => '2002-05-15',
            'place_of_birth' => 'Douala',
            'nationality' => 'Camerounaise',
            'address' => '123 Rue Principale',
            'city' => 'Douala',
            'region' => 'Littoral',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'student',
            'level' => 'L2',
            'matricule' => 'STD2023001',
            'student_id' => 'STD2023001'
        ],
        [
            'email' => 'jean.martin@email.com',
            'phone' => '691234567',
            'first_name' => 'Jean',
            'last_name' => 'Martin',
            'gender' => 'male',
            'date_of_birth' => '2001-08-22',
            'place_of_birth' => 'Yaoundé',
            'nationality' => 'Camerounaise',
            'address' => '456 Avenue Centrale',
            'city' => 'Yaoundé',
            'region' => 'Centre',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'student',
            'level' => 'L3',
            'matricule' => 'STD2023002',
            'student_id' => 'STD2023002'
        ],
        [
            'email' => 'sophie.tant@gmail.com',
            'phone' => '692345678',
            'first_name' => 'Sophie',
            'last_name' => 'Tant',
            'gender' => 'female',
            'date_of_birth' => '2003-01-10',
            'place_of_birth' => 'Bafoussam',
            'nationality' => 'Camerounaise',
            'address' => '789 Boulevard Nord',
            'city' => 'Bafoussam',
            'region' => 'Ouest',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'student',
            'level' => 'L1',
            'matricule' => 'STD2023003',
            'student_id' => 'STD2023003'
        ],
        [
            'email' => 'pierre.ngono@yahoo.fr',
            'phone' => '693456789',
            'first_name' => 'Pierre',
            'last_name' => 'Ngono',
            'gender' => 'male',
            'date_of_birth' => '2002-11-05',
            'place_of_birth' => 'Garoua',
            'nationality' => 'Camerounaise',
            'address' => '321 Boulevard Sud',
            'city' => 'Garoua',
            'region' => 'Nord',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'student',
            'level' => 'L2',
            'matricule' => 'STD2023004',
            'student_id' => 'STD2023004'
        ],
        [
            'email' => 'isabelle.ouandi@mail.com',
            'phone' => '694567890',
            'first_name' => 'Isabelle',
            'last_name' => 'Ouan',
            'gender' => 'female',
            'date_of_birth' => '2003-03-25',
            'place_of_birth' => 'Maroua',
            'nationality' => 'Camerounaise',
            'address' => '654 Rue Est',
            'city' => 'Maroua',
            'region' => 'Extrême-Nord',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'student',
            'level' => 'L1',
            'matricule' => 'STD2023005',
            'student_id' => 'STD2023005'
        ],
        [
            'email' => 'prof.che.professeur@univ.cm',
            'phone' => '695678901',
            'first_name' => 'Joseph',
            'last_name' => 'Tchamda',
            'gender' => 'male',
            'date_of_birth' => '1975-06-12',
            'place_of_birth' => 'Bamenda',
            'nationality' => 'Camerounaise',
            'address' => 'Campus Universitaire',
            'city' => 'Bamenda',
            'region' => 'Nord-Ouest',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'teacher',
            'level' => null,
            'matricule' => 'PROF001',
            'student_id' => null
        ],
        [
            'email' => 'dr.mireille.nkodo@univ.cm',
            'phone' => '696789012',
            'first_name' => 'Mireille',
            'last_name' => 'Nkodo',
            'gender' => 'female',
            'date_of_birth' => '1980-09-18',
            'place_of_birth' => 'Dschang',
            'nationality' => 'Camerounaise',
            'address' => 'Faculté des Sciences',
            'city' => 'Dschang',
            'region' => 'Ouest',
            'country' => 'Cameroun',
            'postal_code' => '237',
            'primary_role' => 'teacher',
            'level' => null,
            'matricule' => 'PROF002',
            'student_id' => null
        ]
    ];

    $passwordHash = password_hash('password123', PASSWORD_DEFAULT);

    foreach ($users as $userData) {
        $sql = "INSERT INTO users (
            uuid, institution_id, department_id, matricule, student_id, 
            email, phone, password_hash, first_name, last_name, 
            gender, date_of_birth, place_of_birth, nationality, 
            address, city, region, country, postal_code,
            primary_role, level, account_status, is_verified, is_active, 
            language_preference, timezone, login_count, 
            created_at, updated_at
        ) VALUES (
            UUID(), 1, NULL, :matricule, :student_id,
            :email, :phone, :password_hash, :first_name, :last_name,
            :gender, :date_of_birth, :place_of_birth, :nationality,
            :address, :city, :region, :country, :postal_code,
            :primary_role, :level, 'active', 1, 1,
            'fr', 'Africa/Douala', 0,
            NOW(), NOW()
        )";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':matricule' => $userData['matricule'],
            ':student_id' => $userData['student_id'],
            ':email' => $userData['email'],
            ':phone' => $userData['phone'],
            ':password_hash' => $passwordHash,
            ':first_name' => $userData['first_name'],
            ':last_name' => $userData['last_name'],
            ':gender' => $userData['gender'],
            ':date_of_birth' => $userData['date_of_birth'],
            ':place_of_birth' => $userData['place_of_birth'],
            ':nationality' => $userData['nationality'],
            ':address' => $userData['address'],
            ':city' => $userData['city'],
            ':region' => $userData['region'],
            ':country' => $userData['country'],
            ':postal_code' => $userData['postal_code'],
            ':primary_role' => $userData['primary_role'],
            ':level' => $userData['level']
        ]);

        echo "Utilisateur créé: " . $userData['first_name'] . " " . $userData['last_name'] . "\n";
    }

    echo "\nUtilisateurs de test créés avec succès!\n";

} catch (PDOException $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
