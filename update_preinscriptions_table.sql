-- Mise à jour complète de la table preinscriptions avec tous les champs essentiels
-- Exécuter cette requête pour améliorer la structure de la table

ALTER TABLE `preinscriptions` 
ADD COLUMN `previous_diploma` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Diplôme précédent (BAC, GCE, etc.)',
ADD COLUMN `previous_institution` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Établissement précédent',
ADD COLUMN `graduation_year` int(4) NULL COMMENT 'Année d\'obtention du diplôme',
ADD COLUMN `desired_program` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Programme souhaité',
ADD COLUMN `study_level` enum('LICENCE','MASTER','DOCTORAT','DUT','BTS','AUTRE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Niveau d\'études visé',
ADD COLUMN `series_bac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Série du BAC (C, D, E, etc.)',
ADD COLUMN `bac_year` int(4) NULL COMMENT 'Année du BAC',
ADD COLUMN `bac_center` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Centre d\'examen BAC',
ADD COLUMN `birth_certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin certificat naissance',
ADD COLUMN `cni_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin CNI/PI',
ADD COLUMN `diploma_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin diplôme',
ADD COLUMN `transcript_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin relevé de notes',
ADD COLUMN `photo_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin photo d\'identité',
ADD COLUMN `parent_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Nom complet du parent/tuteur',
ADD COLUMN `parent_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Téléphone du parent',
ADD COLUMN `parent_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Email du parent',
ADD COLUMN `parent_occupation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Profession du parent',
ADD COLUMN `parent_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Adresse du parent',
ADD COLUMN `payment_method` enum('ORANGE_MONEY','MTN_MONEY','BANK_TRANSFER','CASH','MOBILE_MONEY','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Méthode de paiement',
ADD COLUMN `payment_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Référence de paiement',
ADD COLUMN `payment_amount` decimal(10,2) NULL COMMENT 'Montant payé',
ADD COLUMN `payment_date` timestamp NULL COMMENT 'Date de paiement',
ADD COLUMN `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Adresse IP de soumission',
ADD COLUMN `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Navigateur utilisé',
ADD COLUMN `reviewed_by` bigint UNSIGNED NULL COMMENT 'ID de l\'administrateur qui a validé',
ADD COLUMN `review_date` timestamp NULL COMMENT 'Date de validation/rejet',
ADD COLUMN `interview_date` timestamp NULL COMMENT 'Date d\'entretien si prévu',
ADD COLUMN `interview_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Lieu d\'entretien',
ADD COLUMN `admission_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Numéro d\'admission si accepté',
ADD COLUMN `registration_deadline` date NULL COMMENT 'Date limite pour inscription définitive';

-- Ajout d'index pour optimiser les performances
ALTER TABLE `preinscriptions` 
ADD INDEX `idx_desired_program` (`desired_program`),
ADD INDEX `idx_study_level` (`study_level`),
ADD INDEX `idx_graduation_year` (`graduation_year`),
ADD INDEX `idx_payment_method` (`payment_method`),
ADD INDEX `idx_review_date` (`review_date`),
ADD INDEX `idx_reviewed_by` (`reviewed_by`),
ADD INDEX `idx_payment_date` (`payment_date`);

-- Ajout de contraintes de vérification pour les années (version corrigée pour MySQL)
ALTER TABLE `preinscriptions` 
ADD CONSTRAINT `chk_graduation_year` CHECK (`graduation_year` >= 1900 AND `graduation_year` <= 2100),
ADD CONSTRAINT `chk_bac_year` CHECK (`bac_year` >= 1900 AND `bac_year` <= 2100),
ADD CONSTRAINT `chk_payment_amount` CHECK (`payment_amount` >= 0);

-- Mise à jour des commentaires de la table
ALTER TABLE `preinscriptions` COMMENT = 'Table complète des préinscriptions universitaires avec tous les champs nécessaires';
