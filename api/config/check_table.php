<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

try {
    require_once 'database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    // Vérifier si la table preinscriptions existe
    $stmt = $db->query("SHOW TABLES LIKE 'preinscriptions'");
    $tableExists = $stmt->rowCount() > 0;
    
    if (!$tableExists) {
        // Créer la table
        $createTableSQL = "
        CREATE TABLE IF NOT EXISTS `preinscriptions` (
          `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
          `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
          `faculty` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          
          -- Informations personnelles
          `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `middle_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
          
          -- Informations de naissance
          `date_of_birth` date NOT NULL,
          `is_birth_date_on_certificate` tinyint(1) NOT NULL DEFAULT 1,
          `place_of_birth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `gender` enum('MASCULIN','FEMININ') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `cni_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
          
          -- Coordonnées
          `residence_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `marital_status` enum('CELIBATAIRE','MARIE(E)','DIVORCE(E)') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          
          -- Informations additionnelles
          `first_language` enum('FRANÇAIS','ANGLAIS') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `professional_situation` enum('SANS EMPLOI','SALARIE(E)','EN AUTO-EMPLOI') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          
          -- Statut et suivi
          `status` enum('pending','confirmed','rejected','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
          `payment_status` enum('pending','paid','confirmed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
          `documents_status` enum('pending','submitted','verified','incomplete') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
          
          -- Timestamps
          `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
          `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          
          PRIMARY KEY (`id`),
          UNIQUE KEY `unique_code` (`unique_code`),
          UNIQUE KEY `uuid` (`uuid`),
          KEY `idx_status` (`status`),
          KEY `idx_payment_status` (`payment_status`),
          KEY `idx_created_at` (`created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ";
        
        $db->exec($createTableSQL);
        
        echo json_encode([
            "success" => true,
            "message" => "Table preinscriptions créée avec succès"
        ]);
    } else {
        echo json_encode([
            "success" => true,
            "message" => "Table preinscriptions existe déjà"
        ]);
    }
    
    // Vérifier la structure de la table
    $stmt = $db->query("DESCRIBE preinscriptions");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        "success" => true,
        "message" => "Table preinscriptions vérifiée",
        "table_exists" => $tableExists,
        "columns" => $columns
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur: " . $e->getMessage()
    ]);
}
?>
