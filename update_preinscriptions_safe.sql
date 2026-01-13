-- Version sécurisée qui vérifie l'existence des champs avant de les ajouter
-- Exécuter cette requête pour améliorer la structure de la table

-- Ajouter seulement les champs qui n'existent pas encore
ALTER TABLE `preinscriptions` 
ADD COLUMN IF NOT EXISTS `previous_institution` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Établissement précédent',
ADD COLUMN IF NOT EXISTS `graduation_year` int(4) NULL COMMENT 'Année d\'obtention du diplôme',
ADD COLUMN IF NOT EXISTS `desired_program` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Programme souhaité',
ADD COLUMN IF NOT EXISTS `study_level` enum('LICENCE','MASTER','DOCTORAT','DUT','BTS','AUTRE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Niveau d\'études visé',
ADD COLUMN IF NOT EXISTS `series_bac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Série du BAC (C, D, E, etc.)',
ADD COLUMN IF NOT EXISTS `bac_year` int(4) NULL COMMENT 'Année du BAC',
ADD COLUMN IF NOT EXISTS `bac_center` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Centre d\'examen BAC',
ADD COLUMN IF NOT EXISTS `birth_certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin certificat naissance',
ADD COLUMN IF NOT EXISTS `cni_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin CNI/PI',
ADD COLUMN IF NOT EXISTS `diploma_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin diplôme',
ADD COLUMN IF NOT EXISTS `transcript_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin relevé de notes',
ADD COLUMN IF NOT EXISTS `photo_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin photo d\'identité',
ADD COLUMN IF NOT EXISTS `parent_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Nom complet du parent/tuteur',
ADD COLUMN IF NOT EXISTS `parent_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Téléphone du parent',
ADD COLUMN IF NOT EXISTS `parent_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Email du parent',
ADD COLUMN IF NOT EXISTS `parent_occupation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Profession du parent',
ADD COLUMN IF NOT EXISTS `parent_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Adresse du parent',
ADD COLUMN IF NOT EXISTS `payment_method` enum('ORANGE_MONEY','MTN_MONEY','BANK_TRANSFER','CASH','MOBILE_MONEY','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Méthode de paiement',
ADD COLUMN IF NOT EXISTS `payment_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Référence de paiement',
ADD COLUMN IF NOT EXISTS `payment_amount` decimal(10,2) NULL COMMENT 'Montant payé',
ADD COLUMN IF NOT EXISTS `payment_date` timestamp NULL COMMENT 'Date de paiement',
ADD COLUMN IF NOT EXISTS `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Adresse IP de soumission',
ADD COLUMN IF NOT EXISTS `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Navigateur utilisé',
ADD COLUMN IF NOT EXISTS `reviewed_by` bigint UNSIGNED NULL COMMENT 'ID de l\'administrateur qui a validé',
ADD COLUMN IF NOT EXISTS `review_date` timestamp NULL COMMENT 'Date de validation/rejet',
ADD COLUMN IF NOT EXISTS `interview_date` timestamp NULL COMMENT 'Date d\'entretien si prévu',
ADD COLUMN IF NOT EXISTS `interview_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Lieu d\'entretien',
ADD COLUMN IF NOT EXISTS `admission_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Numéro d\'admission si accepté',
ADD COLUMN IF NOT EXISTS `registration_deadline` date NULL COMMENT 'Date limite pour inscription définitive';

-- Ajout d'index pour optimiser les performances (seulement s'ils n'existent pas)
ALTER TABLE `preinscriptions` 
ADD INDEX IF NOT EXISTS `idx_desired_program` (`desired_program`),
ADD INDEX IF NOT EXISTS `idx_study_level` (`study_level`),
ADD INDEX IF NOT EXISTS `idx_graduation_year` (`graduation_year`),
ADD INDEX IF NOT EXISTS `idx_payment_method` (`payment_method`),
ADD INDEX IF NOT EXISTS `idx_review_date` (`review_date`),
ADD INDEX IF NOT EXISTS `idx_reviewed_by` (`reviewed_by`),
ADD INDEX IF NOT EXISTS `idx_payment_date` (`payment_date`);

-- Ajout de contraintes de vérification pour les années (version corrigée pour MySQL)
ALTER TABLE `preinscriptions` 
ADD CONSTRAINT IF NOT EXISTS `chk_graduation_year` CHECK (`graduation_year` >= 1900 AND `graduation_year` <= 2100),
ADD CONSTRAINT IF NOT EXISTS `chk_bac_year` CHECK (`bac_year` >= 1900 AND `bac_year` <= 2100),
ADD CONSTRAINT IF NOT EXISTS `chk_payment_amount` CHECK (`payment_amount` >= 0);

-- Mise à jour des commentaires de la table
ALTER TABLE `preinscriptions` COMMENT = 'Table complète des préinscriptions universitaires avec tous les champs nécessaires';
