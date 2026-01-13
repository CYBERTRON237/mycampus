-- Création de la table des préinscriptions
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
  
  -- Métadonnées
  `submission_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `admin_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_code` (`unique_code`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `idx_faculty` (`faculty`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_submission_date` (`submission_date`),
  KEY `idx_email` (`email`),
  KEY `idx_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des données de test
INSERT INTO `preinscriptions` (
  `uuid`, `unique_code`, `faculty`, `last_name`, `first_name`, `date_of_birth`,
  `place_of_birth`, `gender`, `residence_address`, `marital_status`,
  `phone_number`, `email`, `first_language`, `professional_situation`
) VALUES 
(
  UUID(), '20251216001', 'Faculté des Sciences (FS)', 'TCHUENTE', 'Jean',
  '2000-05-15', 'Yaoundé', 'MASCULIN', 'Mfoundi, Yaoundé', 'CELIBATAIRE',
  '655123456', 'jean.tchuente@email.com', 'FRANÇAIS', 'SANS EMPLOI'
),
(
  UUID(), '20251216002', 'Faculté des Arts et Lettres (FALSH)', 'FOUDA', 'Marie',
  '2001-03-20', 'Douala', 'FEMININ', 'Bassa, Douala', 'CELIBATAIRE',
  '698787654', 'marie.fouda@email.com', 'FRANÇAIS', 'SANS EMPLOI'
);
