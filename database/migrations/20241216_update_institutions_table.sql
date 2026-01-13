-- Mise à jour de la table institutions pour correspondre au modèle UniversityModel
-- Ajout des champs manquants pour le support complet du modèle

ALTER TABLE `institutions` 
ADD COLUMN IF NOT EXISTS `uuid` VARCHAR(36) NOT NULL DEFAULT '' AFTER `id`,
ADD COLUMN IF NOT EXISTS `code` VARCHAR(20) NOT NULL DEFAULT '' AFTER `uuid`,
ADD COLUMN IF NOT EXISTS `short_name` VARCHAR(100) NOT NULL DEFAULT '' AFTER `name`,
ADD COLUMN IF NOT EXISTS `status` VARCHAR(20) NOT NULL DEFAULT 'active' AFTER `type`,
ADD COLUMN IF NOT EXISTS `region` VARCHAR(100) DEFAULT NULL AFTER `country`,
ADD COLUMN IF NOT EXISTS `phone_primary` VARCHAR(50) DEFAULT NULL AFTER `phone`,
ADD COLUMN IF NOT EXISTS `phone_secondary` VARCHAR(50) DEFAULT NULL AFTER `phone_primary`,
ADD COLUMN IF NOT EXISTS `email_official` VARCHAR(255) DEFAULT NULL AFTER `email`,
ADD COLUMN IF NOT EXISTS `email_admin` VARCHAR(255) DEFAULT NULL AFTER `email_official`,
ADD COLUMN IF NOT EXISTS `banner_url` VARCHAR(512) DEFAULT NULL AFTER `logo_url`,
ADD COLUMN IF NOT EXISTS `founded_year` INT DEFAULT NULL AFTER `description`,
ADD COLUMN IF NOT EXISTS `rector_name` VARCHAR(255) DEFAULT NULL AFTER `founded_year`,
ADD COLUMN IF NOT EXISTS `total_students` INT NOT NULL DEFAULT 0 AFTER `student_count`,
ADD COLUMN IF NOT EXISTS `total_staff` INT NOT NULL DEFAULT 0 AFTER `teacher_count`,
ADD COLUMN IF NOT EXISTS `is_national_hub` TINYINT(1) NOT NULL DEFAULT 0 AFTER `total_staff`,
ADD COLUMN IF NOT EXISTS `sync_enabled` TINYINT(1) NOT NULL DEFAULT 1 AFTER `is_national_hub`,
ADD COLUMN IF NOT EXISTS `last_sync_at` TIMESTAMP NULL DEFAULT NULL AFTER `sync_enabled`;

-- Supprimer les anciens champs s'ils existent et sont en double
ALTER TABLE `institutions` 
DROP COLUMN IF EXISTS `student_count`,
DROP COLUMN IF EXISTS `teacher_count`,
DROP COLUMN IF EXISTS `programs`,
DROP COLUMN IF EXISTS `facilities`;

-- Ajout d'index pour les nouveaux champs
ALTER TABLE `institutions` 
ADD UNIQUE KEY IF NOT EXISTS `idx_uuid` (`uuid`),
ADD UNIQUE KEY IF NOT EXISTS `idx_code` (`code`),
ADD KEY IF NOT EXISTS `idx_short_name` (`short_name`),
ADD KEY IF NOT EXISTS `idx_status` (`status`),
ADD KEY IF NOT EXISTS `idx_region` (`region`),
ADD KEY IF NOT EXISTS `idx_is_national_hub` (`is_national_hub`),
ADD KEY IF NOT EXISTS `idx_sync_enabled` (`sync_enabled`);

-- Mettre à jour les UUID existants
UPDATE `institutions` SET `uuid` = CONCAT('univ_', id, '_', UNIX_TIMESTAMP()) WHERE `uuid` = '';

-- Mettre à jour les codes existants
UPDATE `institutions` SET `code` = UPPER(SUBSTRING(`short_name`, 1, 3)) WHERE `code` = '' AND `short_name` != '';
UPDATE `institutions` SET `code` = UPPER(SUBSTRING(`name`, 1, 3)) WHERE `code` = '';

-- Mettre à jour les short_name s'ils sont vides
UPDATE `institutions` SET `short_name` = SUBSTRING(`name`, 1, 50) WHERE `short_name` = '';

-- Mettre à jour le statut par défaut
UPDATE `institutions` SET `status` = 'active' WHERE `status` = '' OR `status` IS NULL;

-- Mettre à jour les noms de champs pour correspondre au modèle
ALTER TABLE `institutions` 
CHANGE COLUMN `phone` `phone_primary` VARCHAR(50) DEFAULT NULL,
CHANGE COLUMN `email` `email_official` VARCHAR(255) DEFAULT NULL;
