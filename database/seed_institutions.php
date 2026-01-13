<?php
// Script pour peupler la table institutions avec des données d'exemple
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'api/config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Connexion à la base de données établie<br>";
    
    // Vérifier si la table institutions existe
    $checkTable = $db->query("SHOW TABLES LIKE 'institutions'");
    if ($checkTable->rowCount() == 0) {
        echo "La table 'institutions' n'existe pas. Création en cours...<br>";
        
        // Créer la table avec la structure complète
        $createTableSQL = "
        CREATE TABLE `institutions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `uuid` varchar(36) NOT NULL DEFAULT '',
            `code` varchar(20) NOT NULL DEFAULT '',
            `name` varchar(255) NOT NULL,
            `short_name` varchar(100) NOT NULL DEFAULT '',
            `type` varchar(20) NOT NULL DEFAULT 'university',
            `status` varchar(20) NOT NULL DEFAULT 'active',
            `country` varchar(100) DEFAULT NULL,
            `region` varchar(100) DEFAULT NULL,
            `city` varchar(100) DEFAULT NULL,
            `address` varchar(512) DEFAULT NULL,
            `postal_code` varchar(20) DEFAULT NULL,
            `phone_primary` varchar(50) DEFAULT NULL,
            `phone_secondary` varchar(50) DEFAULT NULL,
            `email_official` varchar(255) DEFAULT NULL,
            `email_admin` varchar(255) DEFAULT NULL,
            `website` varchar(255) DEFAULT NULL,
            `logo_url` varchar(512) DEFAULT NULL,
            `banner_url` varchar(512) DEFAULT NULL,
            `description` text DEFAULT NULL,
            `founded_year` int DEFAULT NULL,
            `rector_name` varchar(255) DEFAULT NULL,
            `total_students` int NOT NULL DEFAULT 0,
            `total_staff` int NOT NULL DEFAULT 0,
            `is_national_hub` tinyint(1) NOT NULL DEFAULT 0,
            `is_active` tinyint(1) NOT NULL DEFAULT 1,
            `sync_enabled` tinyint(1) NOT NULL DEFAULT 1,
            `last_sync_at` timestamp NULL DEFAULT NULL,
            `metadata` text DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`),
            UNIQUE KEY `idx_uuid` (`uuid`),
            UNIQUE KEY `idx_code` (`code`),
            KEY `idx_name` (`name`),
            KEY `idx_short_name` (`short_name`),
            KEY `idx_type` (`type`),
            KEY `idx_status` (`status`),
            KEY `idx_country` (`country`),
            KEY `idx_region` (`region`),
            KEY `idx_city` (`city`),
            KEY `idx_is_active` (`is_active`),
            KEY `idx_is_national_hub` (`is_national_hub`),
            KEY `idx_sync_enabled` (`sync_enabled`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ";
        
        $db->exec($createTableSQL);
        echo "Table 'institutions' créée avec succès<br>";
    }
    
    // Insérer des universités d'exemple
    $universities = [
        [
            'uuid' => 'univ_uy1_2024',
            'code' => 'UY1',
            'name' => 'Université de Yaoundé I',
            'short_name' => 'UY1',
            'type' => 'university',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Centre',
            'city' => 'Yaoundé',
            'address' => 'BP 337, Yaoundé, Cameroun',
            'postal_code' => 'Messa',
            'phone_primary' => '+237 222 22 01 58',
            'phone_secondary' => '+237 699 99 99 99',
            'email_official' => 'recteur@uy1.cm',
            'email_admin' => 'admin@uy1.cm',
            'website' => 'https://www.uy1.cm',
            'description' => 'Première université camerounaise, créée en 1962, centre d\'excellence académique',
            'founded_year' => 1962,
            'rector_name' => 'Prof. Maurice Aurélien Sosso',
            'total_students' => 45000,
            'total_staff' => 2500,
            'is_national_hub' => 1,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'univ_uy2_2024',
            'code' => 'UY2',
            'name' => 'Université de Yaoundé II',
            'short_name' => 'UY2',
            'type' => 'university',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Centre',
            'city' => 'Yaoundé',
            'address' => 'BP 1365, Yaoundé, Cameroun',
            'postal_code' => 'Soa',
            'phone_primary' => '+237 222 22 02 12',
            'phone_secondary' => '+237 698 88 88 88',
            'email_official' => 'recteur@uy2.cm',
            'email_admin' => 'admin@uy2.cm',
            'website' => 'https://www.uy2.cm',
            'description' => 'Université spécialisée en sciences sociales et humaines',
            'founded_year' => 1993,
            'rector_name' => 'Prof. Adolphe Minkoa She',
            'total_students' => 35000,
            'total_staff' => 1800,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'univ_uds_2024',
            'code' => 'UDS',
            'name' => 'Université de Douala',
            'short_name' => 'UDS',
            'type' => 'university',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Littoral',
            'city' => 'Douala',
            'address' => 'BP 2701, Douala, Cameroun',
            'postal_code' => 'Akwa',
            'phone_primary' => '+237 233 42 32 12',
            'phone_secondary' => '+237 697 77 77 77',
            'email_official' => 'recteur@udouala.cm',
            'email_admin' => 'admin@udouala.cm',
            'website' => 'https://www.univ-douala.cm',
            'description' => 'Université spécialisée en sciences et technologies',
            'founded_year' => 1993,
            'rector_name' => 'Prof. Pierre Oumarou',
            'total_students' => 40000,
            'total_staff' => 2200,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'univ_ub_2024',
            'code' => 'UB',
            'name' => 'Université de Buéa',
            'short_name' => 'UB',
            'type' => 'university',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Sud-Ouest',
            'city' => 'Buéa',
            'address' => 'BP 63, Buéa, Cameroun',
            'postal_code' => 'Molyko',
            'phone_primary' => '+237 233 32 22 33',
            'phone_secondary' => '+237 696 66 66 66',
            'email_official' => 'recteur@ubuea.cm',
            'email_admin' => 'admin@ubuea.cm',
            'website' => 'https://www.ubuea.cm',
            'description' => 'Première université anglophone du Cameroun',
            'founded_year' => 1993,
            'rector_name' => 'Prof. Horace Ngomo Manga',
            'total_students' => 25000,
            'total_staff' => 1500,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'univ_uma_2024',
            'code' => 'UMA',
            'name' => 'Université des Montagnes',
            'short_name' => 'UMA',
            'type' => 'university',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Ouest',
            'city' => 'Bamenda',
            'address' => 'BP 104, Bamenda, Cameroun',
            'postal_code' => 'Bamenda',
            'phone_primary' => '+237 233 44 33 22',
            'phone_secondary' => '+237 695 55 55 55',
            'email_official' => 'recteur@umont.cm',
            'email_admin' => 'admin@umont.cm',
            'website' => 'https://www.univ-mont.cm',
            'description' => 'Université privée d\'excellence dans la région des montagnes',
            'founded_year' => 2000,
            'rector_name' => 'Dr. Roger Tsafack',
            'total_students' => 8000,
            'total_staff' => 500,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'inst_enspy_2024',
            'code' => 'ENSPY',
            'name' => 'École Normale Supérieure de Yaoundé',
            'short_name' => 'ENSPY',
            'type' => 'school',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Centre',
            'city' => 'Yaoundé',
            'address' => 'BP 47, Yaoundé, Cameroun',
            'postal_code' => 'Yaoundé',
            'phone_primary' => '+237 222 22 03 45',
            'phone_secondary' => '+237 694 44 44 44',
            'email_official' => 'directeur@enspy.cm',
            'email_admin' => 'admin@enspy.cm',
            'website' => 'https://www.enspy.cm',
            'description' => 'École de formation des enseignants du secondaire',
            'founded_year' => 1965,
            'rector_name' => 'Prof. Samuel Epee',
            'total_students' => 5000,
            'total_staff' => 300,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'inst_iut_2024',
            'code' => 'IUT',
            'name' => 'Institut Universitaire de Technologie',
            'short_name' => 'IUT',
            'type' => 'institution',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Littoral',
            'city' => 'Douala',
            'address' => 'BP 777, Douala, Cameroun',
            'postal_code' => 'Douala',
            'phone_primary' => '+237 233 55 44 33',
            'phone_secondary' => '+237 693 33 33 33',
            'email_official' => 'directeur@iut-douala.cm',
            'email_admin' => 'admin@iut-douala.cm',
            'website' => 'https://www.iut-douala.cm',
            'description' => 'Institut de formation technologique et professionnelle',
            'founded_year' => 1979,
            'rector_name' => 'Dr. Jean Pierre Tchamie',
            'total_students' => 12000,
            'total_staff' => 600,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'inst_fslash_2024',
            'code' => 'FALASH',
            'name' => 'Faculté des Arts, Lettres et Sciences Humaines',
            'short_name' => 'FALASH',
            'type' => 'school',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Centre',
            'city' => 'Yaoundé',
            'address' => 'BP 1365, Yaoundé, Cameroun',
            'postal_code' => 'Yaoundé',
            'phone_primary' => '+237 222 22 05 67',
            'phone_secondary' => '+237 692 22 22 22',
            'email_official' => 'doyen@flash-uy2.cm',
            'email_admin' => 'admin@flash-uy2.cm',
            'website' => 'https://www.flash-uy2.cm',
            'description' => 'Faculté spécialisée en arts, lettres et sciences humaines',
            'founded_year' => 1993,
            'rector_name' => 'Prof. Mathieu Owona',
            'total_students' => 15000,
            'total_staff' => 800,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'inst_fs_2024',
            'code' => 'FS',
            'name' => 'Faculté des Sciences',
            'short_name' => 'FS',
            'type' => 'school',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Centre',
            'city' => 'Yaoundé',
            'address' => 'BP 812, Yaoundé, Cameroun',
            'postal_code' => 'Yaoundé',
            'phone_primary' => '+237 222 22 07 89',
            'phone_secondary' => '+237 691 11 11 11',
            'email_official' => 'doyen@fs-uy1.cm',
            'email_admin' => 'admin@fs-uy1.cm',
            'website' => 'https://www.fs-uy1.cm',
            'description' => 'Faculté des sciences fondamentales et appliquées',
            'founded_year' => 1962,
            'rector_name' => 'Prof. Emmanuel Ndjock',
            'total_students' => 18000,
            'total_staff' => 900,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ],
        [
            'uuid' => 'inst_fse_2024',
            'code' => 'FSE',
            'name' => 'Faculté des Sciences de l\'Éducation',
            'short_name' => 'FSE',
            'type' => 'school',
            'status' => 'active',
            'country' => 'Cameroun',
            'region' => 'Centre',
            'city' => 'Yaoundé',
            'address' => 'BP 47, Yaoundé, Cameroun',
            'postal_code' => 'Yaoundé',
            'phone_primary' => '+237 222 22 09 01',
            'phone_secondary' => '+237 690 00 00 00',
            'email_official' => 'doyen@fse-uy1.cm',
            'email_admin' => 'admin@fse-uy1.cm',
            'website' => 'https://www.fse-uy1.cm',
            'description' => 'Faculté spécialisée en sciences de l\'éducation',
            'founded_year' => 1977,
            'rector_name' => 'Prof. Laurent Ewane',
            'total_students' => 12000,
            'total_staff' => 600,
            'is_national_hub' => 0,
            'is_active' => 1,
            'sync_enabled' => 1
        ]
    ];
    
    echo "Insertion des universités d'exemple...<br>";
    
    $insertSQL = "INSERT INTO institutions (
        uuid, code, name, short_name, type, status, country, region, city, 
        address, postal_code, phone_primary, phone_secondary, email_official, 
        email_admin, website, description, founded_year, rector_name, 
        total_students, total_staff, is_national_hub, is_active, sync_enabled
    ) VALUES (
        :uuid, :code, :name, :short_name, :type, :status, :country, :region, :city,
        :address, :postal_code, :phone_primary, :phone_secondary, :email_official,
        :email_admin, :website, :description, :founded_year, :rector_name,
        :total_students, :total_staff, :is_national_hub, :is_active, :sync_enabled
    ) ON DUPLICATE KEY UPDATE 
        name = VALUES(name),
        short_name = VALUES(short_name),
        description = VALUES(description),
        total_students = VALUES(total_students),
        total_staff = VALUES(total_staff)";
    
    $stmt = $db->prepare($insertSQL);
    
    foreach ($universities as $university) {
        $stmt->execute($university);
        echo "Université '{$university['name']}' insérée/mise à jour<br>";
    }
    
    echo "<br><strong>Succès!</strong> " . count($universities) . " universités/institutions ont été ajoutées à la base de données.<br>";
    
    // Vérifier le nombre total d'institutions
    $count = $db->query("SELECT COUNT(*) as total FROM institutions")->fetch(PDO::FETCH_ASSOC)['total'];
    echo "Total des institutions dans la base: $count<br>";
    
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "<br>";
    echo "Trace: " . $e->getTraceAsString() . "<br>";
}
?>
