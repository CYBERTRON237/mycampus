-- Migration pour ajouter les champs de gestion des préinscriptions pour tiers
-- Basée sur email/téléphone pour identifier les personnes concernées

-- 1. Ajouter les champs à la table preinscriptions
ALTER TABLE `preinscriptions` 
ADD COLUMN `applicant_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email de la personne concernée (si différent du créateur)',
ADD COLUMN `applicant_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Téléphone de la personne concernée (si différent du créateur)',
ADD COLUMN `relationship` enum('self', 'parent', 'tutor', 'other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'self' COMMENT 'Relation entre créateur et personne concernée',
ADD COLUMN `is_processed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Indique si la préinscription a été traitée pour mise à jour du statut utilisateur',
ADD COLUMN `processed_at` timestamp NULL DEFAULT NULL COMMENT 'Date de traitement automatique du statut utilisateur';

-- 2. Ajouter des index pour optimiser les recherches
ALTER TABLE `preinscriptions` 
ADD INDEX `idx_applicant_email` (`applicant_email`(191)),
ADD INDEX `idx_applicant_phone` (`applicant_phone`),
ADD INDEX `idx_relationship` (`relationship`),
ADD INDEX `idx_is_processed` (`is_processed`),
ADD INDEX `idx_processed_at` (`processed_at`);

-- 3. Ajouter un champ à la table users pour suivre la préinscription associée
ALTER TABLE `users` 
ADD COLUMN `preinscription_id` bigint UNSIGNED DEFAULT NULL COMMENT 'ID de la préinscription validée associée à cet utilisateur',
ADD COLUMN `preinscription_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Code unique de la préinscription validée';

-- 4. Ajouter les contraintes et index pour la table users
ALTER TABLE `users` 
ADD INDEX `idx_preinscription_id` (`preinscription_id`),
ADD INDEX `idx_preinscription_unique_code` (`preinscription_unique_code`);

-- 5. Ajouter une contrainte de clé étrangère pour users.preinscription_id
ALTER TABLE `users` 
ADD CONSTRAINT `fk_users_preinscription_id` 
FOREIGN KEY (`preinscription_id`) REFERENCES `preinscriptions` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- 6. Créer une procédure stockée pour traiter automatiquement le statut student
DELIMITER $$
CREATE PROCEDURE `process_preinscription_student_status`(
    IN p_preinscription_id BIGINT,
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE v_applicant_email VARCHAR(255);
    DECLARE v_applicant_phone VARCHAR(20);
    DECLARE v_relationship VARCHAR(20);
    DECLARE v_user_id BIGINT;
    DECLARE v_processed TINYINT(1);
    
    -- Récupérer les informations de la préinscription
    SELECT applicant_email, applicant_phone, relationship, is_processed
    INTO v_applicant_email, v_applicant_phone, v_relationship, v_processed
    FROM preinscriptions 
    WHERE id = p_preinscription_id;
    
    -- Vérifier si déjà traité
    IF v_processed = 1 THEN
        SELECT 'Déjà traité' AS message;
    ELSE
        -- Si la préinscription est acceptée
        IF p_status = 'accepted' THEN
            -- Chercher un utilisateur existant par email
            IF v_applicant_email IS NOT NULL THEN
                SELECT id INTO v_user_id 
                FROM users 
                WHERE email = v_applicant_email AND deleted_at IS NULL;
                
                -- Si utilisateur trouvé, mettre à jour son statut
                IF v_user_id IS NOT NULL THEN
                    UPDATE users 
                    SET role = 'student', 
                        status = 'active',
                        preinscription_id = p_preinscription_id,
                        updated_at = NOW()
                    WHERE id = v_user_id;
                    
                    -- Marquer la préinscription comme traitée
                    UPDATE preinscriptions 
                    SET is_processed = 1, 
                        processed_at = NOW()
                    WHERE id = p_preinscription_id;
                    
                    SELECT CONCAT('Utilisateur ', v_user_id, ' mis à jour vers student') AS message;
                ELSE
                    -- Aucun utilisateur trouvé, préparer pour invitation
                    UPDATE preinscriptions 
                    SET is_processed = 0, 
                        processed_at = NOW()
                    WHERE id = p_preinscription_id;
                    
                    SELECT CONCAT('Aucun utilisateur trouvé pour ', v_applicant_email, '. Invitation nécessaire.') AS message;
                END IF;
            ELSE
                SELECT 'Aucun email fourni pour traiter automatiquement' AS message;
            END IF;
        END IF;
    END IF;
END$$
DELIMITER ;

-- 7. Créer un trigger pour appeler automatiquement la procédure quand le statut change
DELIMITER $$
CREATE TRIGGER `tr_preinscriptions_after_update`
AFTER UPDATE ON `preinscriptions`
FOR EACH ROW
BEGIN
    -- Si le statut change vers 'accepted' et n'est pas encore traité
    IF OLD.status != 'accepted' AND NEW.status = 'accepted' AND NEW.is_processed = 0 THEN
        CALL process_preinscription_student_status(NEW.id, 'accepted');
    END IF;
END$$
DELIMITER ;

-- 8. Afficher la structure mise à jour pour vérification
SHOW CREATE TABLE `preinscriptions`;
SHOW CREATE TABLE `users`;
