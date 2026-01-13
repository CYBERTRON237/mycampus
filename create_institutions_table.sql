-- Création de la table institutions pour le module de gestion des universités
-- Basée sur le modèle UniversityModel du code Flutter

CREATE TABLE IF NOT EXISTS `institutions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('public','private','confessional') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public',
  `status` enum('active','inactive','suspended','pending') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Cameroun',
  `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_primary` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_secondary` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_official` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_admin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `banner_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `founded_year` int DEFAULT NULL,
  `rector_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_students` int NOT NULL DEFAULT 0,
  `total_staff` int NOT NULL DEFAULT 0,
  `is_national_hub` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sync_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `last_sync_at` timestamp NULL DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_code` (`code`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_country` (`country`),
  KEY `idx_region` (`region`),
  KEY `idx_city` (`city`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_is_national_hub` (`is_national_hub`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des données de test (universités camerounaises)
INSERT INTO `institutions` (`uuid`, `code`, `name`, `short_name`, `type`, `status`, `country`, `region`, `city`, `description`, `founded_year`, `is_active`, `created_at`, `updated_at`) VALUES
(UUID(), 'UY1', 'Université de Yaoundé I', 'UY1', 'public', 'active', 'Cameroun', 'Centre', 'Yaoundé', 'Première université d\'État du Cameroun', 1962, 1, NOW(), NOW()),
(UUID(), 'UY2', 'Université de Yaoundé II', 'UY2', 'public', 'active', 'Cameroun', 'Centre', 'Yaoundé', 'Université spécialisée en sciences sociales et humaines', 1993, 1, NOW(), NOW()),
(UUID(), 'UDLA', 'Université de Douala', 'UDLA', 'public', 'active', 'Cameroun', 'Littoral', 'Douala', 'Université portuaire et industrielle', 1977, 1, NOW(), NOW()),
(UUID(), 'UDS', 'Université de Dschang', 'UDS', 'public', 'active', 'Cameroun', 'Ouest', 'Dschang', 'Université agricole et technologique', 1993, 1, NOW(), NOW()),
(UUID(), 'UN', 'Université de Ngaoundéré', 'UN', 'public', 'active', 'Cameroun', 'Adamaoua', 'Ngaoundéré', 'Université du nord Cameroun', 1982, 1, NOW(), NOW()),
(UUID(), 'UB', 'Université de Buéa', 'UB', 'public', 'active', 'Cameroun', 'Sud-Ouest', 'Buéa', 'Première université anglophone', 1992, 1, NOW(), NOW()),
(UUID(), 'UBA', 'Université de Bamenda', 'UBA', 'public', 'active', 'Cameroun', 'Nord-Ouest', 'Bamenda', 'Université du nord-ouest Cameroun', 2010, 1, NOW(), NOW()),
(UUID(), 'UM', 'Université de Maroua', 'UM', 'public', 'active', 'Cameroun', 'Extrême-Nord', 'Maroua', 'Université de l\'extrême-nord', 2008, 1, NOW(), NOW()),
(UUID(), 'UST', 'Université des Sciences et Techniques', 'UST', 'public', 'active', 'Cameroun', 'Centre', 'Yaoundé', 'Université technologique', 2015, 1, NOW(), NOW()),
(UUID(), 'INA', 'Institut National d\'Agriculture', 'INA', 'public', 'active', 'Cameroun', 'Centre', 'Yaoundé', 'Institut agricole spécialisé', 2011, 1, NOW(), NOW());

-- Trigger pour générer automatiquement le UUID si non fourni
DELIMITER $$
CREATE TRIGGER before_institutions_insert 
BEFORE INSERT ON institutions
FOR EACH ROW
BEGIN
    IF NEW.uuid IS NULL OR NEW.uuid = '' THEN
        SET NEW.uuid = UUID();
    END IF;
END$$
DELIMITER ;
