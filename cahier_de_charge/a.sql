salut bolt je voudrais heberger ma BD sur infinity free mais ils nacceptent pas les proceduure de mon application tu va toutes les enlever tu va corriger tous le  code de la BD faire beacoup de verifications et tassurer que lhebergeur en ligne va executer la requete sql que tu va me donner et ne va rencontrer exactement aucune erreur enleve toutes les procedure nenleve rien qui peut nuire a lapplication elle meme corrige les erreur et donne moi un code parfait tu generera le code de la Base de donees en code brute broullon a copier code brut broullon a copier je veux juste copier donc genere du code brute voici la BD en question redonne la moi complete verifie les regle debergement et de mysql et tous assure toi quil y aura auncune erreur et redonne moi la requete de creation de la BD et de toutes ces tables complete :-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : lun. 12 jan. 2026 à 16:02
-- Version du serveur : 8.4.7
-- Version de PHP : 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mycampus`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `AssignRoleToUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AssignRoleToUser` (IN `p_user_id` BIGINT, IN `p_role_code` VARCHAR(50), IN `p_institution_id` BIGINT, IN `p_assigned_by` BIGINT, IN `p_is_primary` BOOLEAN, IN `p_context` JSON)   BEGIN
    DECLARE v_role_id BIGINT;
    DECLARE v_assignment_count INT;
    
    -- Récupérer l'ID du rôle
    SELECT id INTO v_role_id FROM roles WHERE code = p_role_code AND is_active = 1;
    
    IF v_role_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rôle non trouvé ou inactif';
    END IF;
    
    -- Si c'est un rôle primaire, désactiver les autres rôles primaires
    IF p_is_primary = TRUE THEN
        UPDATE user_role_assignments 
        SET is_primary = 0 
        WHERE user_id = p_user_id AND is_primary = 1;
    END IF;
    
    -- Insérer la nouvelle affectation
    INSERT INTO user_role_assignments (
        uuid, user_id, role_id, institution_id, assigned_by, 
        is_primary, context
    ) VALUES (
        UUID(), p_user_id, v_role_id, p_institution_id, p_assigned_by,
        p_is_primary, p_context
    );
    
    -- Mettre à jour le rôle primaire dans la table users si nécessaire
    IF p_is_primary = TRUE THEN
        UPDATE users 
        SET primary_role = (SELECT name FROM roles WHERE id = v_role_id)
        WHERE id = p_user_id;
    END IF;
    
END$$

DROP PROCEDURE IF EXISTS `process_preinscription_student_status`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `process_preinscription_student_status` (IN `p_preinscription_id` BIGINT, IN `p_status` VARCHAR(20))   BEGIN
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

DROP PROCEDURE IF EXISTS `RemoveRoleFromUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RemoveRoleFromUser` (IN `p_user_id` BIGINT, IN `p_role_id` BIGINT, IN `p_removed_by` BIGINT)   BEGIN
    DECLARE v_was_primary BOOLEAN;
    
    -- Vérifier si c'était un rôle primaire
    SELECT is_primary INTO v_was_primary 
    FROM user_role_assignments 
    WHERE user_id = p_user_id AND role_id = p_role_id AND is_active = 1;
    
    -- Désactiver l'affectation
    UPDATE user_role_assignments 
    SET is_active = 0, updated_at = NOW()
    WHERE user_id = p_user_id AND role_id = p_role_id AND is_active = 1;
    
    -- Si c'était un rôle primaire, assigner le rôle le plus élevé restant comme primaire
    IF v_was_primary = TRUE THEN
        UPDATE user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        SET ura.is_primary = 1
        WHERE ura.user_id = p_user_id 
        AND ura.is_active = 1
        ORDER BY r.level DESC
        LIMIT 1;
        
        -- Mettre à jour le rôle primaire dans users
        UPDATE users u
        SET primary_role = (
            SELECT r.name 
            FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = u.id AND ura.is_active = 1 AND ura.is_primary = 1
            LIMIT 1
        )
        WHERE u.id = p_user_id;
    END IF;
    
END$$

DROP PROCEDURE IF EXISTS `sp_can_view_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_can_view_user` (IN `p_viewer_id` BIGINT, IN `p_target_id` BIGINT, OUT `p_can_view` BOOLEAN)   BEGIN
        DECLARE viewer_level INT DEFAULT 0;
        DECLARE target_level INT DEFAULT 0;
        DECLARE viewer_institution BIGINT;
        DECLARE target_institution BIGINT;
        
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO viewer_level, viewer_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_viewer_id AND u.deleted_at IS NULL;
        
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO target_level, target_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_target_id AND u.deleted_at IS NULL;
        
        IF p_viewer_id = p_target_id THEN
            SET p_can_view = TRUE;
        ELSEIF viewer_level >= 90 THEN
            SET p_can_view = TRUE;
        ELSEIF viewer_level >= 80 AND viewer_institution = target_institution THEN
            SET p_can_view = TRUE;
        ELSEIF viewer_level > target_level THEN
            SET p_can_view = TRUE;
        ELSE
            SET p_can_view = FALSE;
        END IF;
    END$$

DROP PROCEDURE IF EXISTS `sp_create_notification`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_notification` (IN `p_user_id` BIGINT, IN `p_title` VARCHAR(255), IN `p_content` TEXT, IN `p_type` VARCHAR(50), IN `p_related_id` BIGINT, IN `p_related_type` VARCHAR(50))   BEGIN
  INSERT INTO notifications (
    uuid, user_id, title, content, body,
    notification_type, category, related_id, related_type
  )
  VALUES (
    UUID(), p_user_id, p_title, p_content, p_content,
    p_type, p_type, p_related_id, p_related_type
  );
END$$

DROP PROCEDURE IF EXISTS `sp_create_student`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_student` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_first_name` VARCHAR(100), IN `p_last_name` VARCHAR(100), IN `p_institution_id` BIGINT, IN `p_program_id` BIGINT, IN `p_academic_year_id` BIGINT, IN `p_current_level` VARCHAR(20), OUT `p_user_id` BIGINT, OUT `p_success` BOOLEAN, OUT `p_message` VARCHAR(500))   BEGIN
  DECLARE v_uuid CHAR(36);
  DECLARE v_matricule VARCHAR(50);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = FALSE;
    SET p_message = 'Erreur lors de la création de l''étudiant';
  END;

  START TRANSACTION;

  SET v_uuid = UUID();
  SET v_matricule = CONCAT('STU', YEAR(NOW()), LPAD(FLOOR(RAND() * 100000), 5, '0'));

  INSERT INTO users (
    uuid, institution_id, matricule, email, password_hash,
    first_name, last_name, primary_role, account_status
  ) VALUES (
    v_uuid, p_institution_id, v_matricule, p_email, p_password,
    p_first_name, p_last_name, 'student', 'pending_verification'
  );

  SET p_user_id = LAST_INSERT_ID();

  INSERT INTO student_profiles (
    user_id, program_id, academic_year_id, current_level,
    enrollment_date, student_status
  ) VALUES (
    p_user_id, p_program_id, p_academic_year_id, p_current_level,
    NOW(), 'enrolled'
  );

  INSERT INTO user_settings (user_id) VALUES (p_user_id);

  COMMIT;

  SET p_success = TRUE;
  SET p_message = 'Étudiant créé avec succès';
END$$

DROP PROCEDURE IF EXISTS `sp_get_recommended_offers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_recommended_offers` (IN `p_user_id` BIGINT)   BEGIN
  DECLARE v_level VARCHAR(20);
  DECLARE v_department_id BIGINT;

  SELECT level, department_id INTO v_level, v_department_id
  FROM users WHERE id = p_user_id;

  SELECT
    o.id,
    o.uuid,
    o.title,
    o.description,
    o.type,
    o.company_name,
    o.location,
    o.deadline,
    o.is_featured,
    i.name as institution_name
  FROM opportunities o
  LEFT JOIN institutions i ON o.institution_id = i.id
  WHERE o.status = 'published'
    AND (o.deadline >= CURDATE() OR o.application_deadline >= CURDATE())
    AND (
      o.target_level LIKE CONCAT('%', v_level, '%')
      OR o.target_level IS NULL
    )
  ORDER BY o.is_featured DESC, o.created_at DESC
  LIMIT 20;
END$$

DROP PROCEDURE IF EXISTS `sp_get_user_stats`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_stats` (IN `p_user_id` BIGINT)   BEGIN
  SELECT
    u.id,
    u.uuid,
    CONCAT(u.first_name, ' ', u.last_name) as full_name,
    u.email,
    u.matricule,
    i.name as institution,
    d.name as department,
    COUNT(DISTINCT gm.group_id) as groups_count,
    COUNT(DISTINCT p.id) as posts_count,
    COUNT(DISTINCT c.id) as comments_count,
    COUNT(DISTINCT r.id) as reactions_given,
    COUNT(DISTINCT m.id) as messages_sent,
    COUNT(DISTINCT oa.id) as applications_submitted,
    COUNT(DISTINCT n.id) as total_notifications,
    COUNT(DISTINCT CASE WHEN n.is_read = FALSE THEN n.id END) as unread_notifications,
    u.created_at,
    u.last_login_at
  FROM users u
  INNER JOIN institutions i ON u.institution_id = i.id
  LEFT JOIN departments d ON u.department_id = d.id
  LEFT JOIN group_members gm ON u.id = gm.user_id AND gm.status = 'active'
  LEFT JOIN posts p ON u.id = p.author_id AND p.status = 'published'
  LEFT JOIN comments c ON u.id = c.author_id AND c.status = 'published'
  LEFT JOIN reactions r ON u.id = r.user_id
  LEFT JOIN messages m ON u.id = m.sender_id
  LEFT JOIN opportunity_applications oa ON u.id = oa.user_id
  LEFT JOIN notifications n ON u.id = n.user_id
  WHERE u.id = p_user_id
  GROUP BY u.id, u.uuid, u.first_name, u.last_name, u.email, u.matricule,
           i.name, d.name, u.created_at, u.last_login_at;
END$$

DROP PROCEDURE IF EXISTS `sp_get_visible_users`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_visible_users` (IN `p_viewer_id` BIGINT, IN `p_page` INT, IN `p_limit` INT, IN `p_search` VARCHAR(255), IN `p_role_filter` VARCHAR(50), IN `p_status_filter` VARCHAR(50))   BEGIN
        DECLARE v_offset INT;
        DECLARE viewer_level INT DEFAULT 0;
        DECLARE viewer_institution BIGINT;
        
        SET v_offset = (p_page - 1) * p_limit;
        
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO viewer_level, viewer_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_viewer_id AND u.deleted_at IS NULL;
        
        SELECT 
            u.id, u.uuid, u.email, u.first_name, u.last_name, u.matricule,
            u.primary_role, u.account_status, u.is_active, u.created_at, u.updated_at,
            i.name as institution_name,
            d.name as department_name,
            r.name as role_name,
            r.level as role_level
        FROM users u
        LEFT JOIN institutions i ON u.institution_id = i.id
        LEFT JOIN departments d ON u.department_id = d.id
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.deleted_at IS NULL
        AND (
            u.id = p_viewer_id
            OR viewer_level >= 90
            OR (viewer_level >= 80 AND u.institution_id = viewer_institution)
            OR (viewer_level > COALESCE(r.level, 0))
        )
        AND (
            p_search IS NULL 
            OR (
                u.first_name LIKE CONCAT('%', p_search, '%')
                OR u.last_name LIKE CONCAT('%', p_search, '%')
                OR u.email LIKE CONCAT('%', p_search, '%')
                OR u.matricule LIKE CONCAT('%', p_search, '%')
            )
        )
        AND (
            p_role_filter IS NULL
            OR r.name = p_role_filter
        )
        AND (
            p_status_filter IS NULL
            OR u.account_status = p_status_filter
        )
        ORDER BY u.created_at DESC
        LIMIT v_offset, p_limit;
    END$$

DROP PROCEDURE IF EXISTS `sp_join_group`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_join_group` (IN `p_user_id` BIGINT, IN `p_group_id` BIGINT, OUT `p_success` BOOLEAN, OUT `p_message` VARCHAR(255))   BEGIN
  DECLARE v_max_members INT;
  DECLARE v_current_count INT;
  DECLARE v_visibility VARCHAR(20);
  DECLARE v_already_member INT;
  DECLARE v_status VARCHAR(20);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_success = FALSE;
    SET p_message = 'Erreur lors de l''ajout au groupe';
  END;

  START TRANSACTION;

  SELECT COUNT(*) INTO v_already_member
  FROM group_members
  WHERE user_id = p_user_id AND group_id = p_group_id;

  IF v_already_member > 0 THEN
    SET p_success = FALSE;
    SET p_message = 'Vous êtes déjà membre de ce groupe';
    ROLLBACK;
  ELSE
    SELECT max_members, current_members_count, visibility
    INTO v_max_members, v_current_count, v_visibility
    FROM user_groups
    WHERE id = p_group_id;

    IF v_max_members > 0 AND v_current_count >= v_max_members THEN
      SET p_success = FALSE;
      SET p_message = 'Le groupe a atteint sa capacité maximale';
      ROLLBACK;
    ELSE
      IF v_visibility IN ('private', 'restricted') THEN
        SET v_status = 'pending';
        SET p_message = 'Demande d''adhésion envoyée';
      ELSE
        SET v_status = 'active';
        SET p_message = 'Vous avez rejoint le groupe avec succès';
      END IF;

      INSERT INTO group_members (group_id, user_id, role, status)
      VALUES (p_group_id, p_user_id, 'member', v_status);

      COMMIT;
      SET p_success = TRUE;
    END IF;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_mark_notifications_read`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_mark_notifications_read` (IN `p_user_id` BIGINT)   BEGIN
  UPDATE notifications
  SET is_read = TRUE, read_at = NOW()
  WHERE user_id = p_user_id AND is_read = FALSE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `academic_records`
--

DROP TABLE IF EXISTS `academic_records`;
CREATE TABLE IF NOT EXISTS `academic_records` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_profile_id` bigint UNSIGNED NOT NULL,
  `enrollment_id` bigint UNSIGNED NOT NULL,
  `record_type` enum('semester','annual','final') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `academic_year_id` bigint UNSIGNED NOT NULL,
  `semester` enum('semester1','semester2','annual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` enum('licence1','licence2','licence3','master1','master2','doctorat1','doctorat2','doctorat3') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gpa` decimal(3,2) DEFAULT NULL,
  `total_credits` int UNSIGNED DEFAULT '0',
  `earned_credits` int UNSIGNED DEFAULT '0',
  `class_rank` int UNSIGNED DEFAULT NULL,
  `total_students` int UNSIGNED DEFAULT NULL,
  `honors_status` enum('none','honors','high_honors','highest_honors') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'none',
  `academic_standing` enum('excellent','good','satisfactory','probation','warning') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'good',
  `decision` enum('promoted','repeat','conditional_promotion','suspended','expelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'promoted',
  `transcript_generated` tinyint(1) NOT NULL DEFAULT '0',
  `transcript_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_student_record` (`student_profile_id`,`academic_year_id`,`semester`,`record_type`),
  KEY `idx_student_profile` (`student_profile_id`),
  KEY `idx_academic_year` (`academic_year_id`),
  KEY `idx_level` (`level`),
  KEY `idx_gpa` (`gpa`),
  KEY `enrollment_id` (`enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `academic_years`
--

DROP TABLE IF EXISTS `academic_years`;
CREATE TABLE IF NOT EXISTS `academic_years` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` bigint UNSIGNED NOT NULL,
  `year_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `semester1_start` date DEFAULT NULL,
  `semester1_end` date DEFAULT NULL,
  `semester2_start` date DEFAULT NULL,
  `semester2_end` date DEFAULT NULL,
  `registration_start` date DEFAULT NULL,
  `registration_end` date DEFAULT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('upcoming','active','completed','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_year_per_institution` (`institution_id`,`year_code`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_is_current` (`is_current`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `academic_years`
--

INSERT INTO `academic_years` (`id`, `institution_id`, `year_code`, `start_date`, `end_date`, `semester1_start`, `semester1_end`, `semester2_start`, `semester2_end`, `registration_start`, `registration_end`, `is_current`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, '2024-2025', '2024-09-01', '2025-08-31', NULL, NULL, NULL, NULL, NULL, NULL, 1, 'active', '2025-12-15 01:47:16', '2025-12-15 01:47:16');

-- --------------------------------------------------------

--
-- Structure de la table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` bigint UNSIGNED DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `changes` json DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `platform` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `severity` enum('info','warning','error','critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'info',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_severity` (`severity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `analytics_events`
--

DROP TABLE IF EXISTS `analytics_events`;
CREATE TABLE IF NOT EXISTS `analytics_events` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `event_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_value` int DEFAULT NULL,
  `platform` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referrer_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_event_name` (`event_name`),
  KEY `idx_event_category` (`event_category`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
CREATE TABLE IF NOT EXISTS `announcements` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `author_id` bigint UNSIGNED NOT NULL,
  `published_by` bigint UNSIGNED DEFAULT NULL,
  `scope` enum('institution','local','faculty','department','program','national','inter_university','multi_institutions') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'institution',
  `scope_ids` json DEFAULT NULL,
  `target_audience` json DEFAULT NULL,
  `target_levels` json DEFAULT NULL,
  `priority` enum('low','normal','high','urgent','critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `category` enum('academic','administrative','event','exam','registration','scholarship','alert','general','emergency','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `announcement_type` enum('academic','administrative','event','urgent','general') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'general',
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `excerpt` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attachments` json DEFAULT NULL,
  `attachments_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `external_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_pinned` tinyint(1) NOT NULL DEFAULT '0',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `show_on_homepage` tinyint(1) NOT NULL DEFAULT '0',
  `requires_acknowledgment` tinyint(1) NOT NULL DEFAULT '0',
  `acknowledgment_count` int UNSIGNED NOT NULL DEFAULT '0',
  `publish_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `expire_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `status` enum('draft','scheduled','published','archived','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `views_count` int UNSIGNED NOT NULL DEFAULT '0',
  `shares_count` int UNSIGNED NOT NULL DEFAULT '0',
  `comments_count` int UNSIGNED NOT NULL DEFAULT '0',
  `allow_comments` tinyint(1) NOT NULL DEFAULT '1',
  `tags` json DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `archived_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_scope` (`scope`),
  KEY `idx_priority` (`priority`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_publish_at` (`publish_at`),
  KEY `idx_is_pinned` (`is_pinned`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_announcements_published_by` (`published_by`),
  KEY `idx_announcements_institution_status_published` (`institution_id`,`status`,`published_at` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `announcements`
--

INSERT INTO `announcements` (`id`, `uuid`, `institution_id`, `author_id`, `published_by`, `scope`, `scope_ids`, `target_audience`, `target_levels`, `priority`, `category`, `announcement_type`, `title`, `content`, `excerpt`, `cover_image_url`, `attachments`, `attachments_url`, `external_link`, `is_pinned`, `is_featured`, `show_on_homepage`, `requires_acknowledgment`, `acknowledgment_count`, `publish_at`, `published_at`, `expire_at`, `expires_at`, `status`, `views_count`, `shares_count`, `comments_count`, `allow_comments`, `tags`, `metadata`, `archived_at`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, '2d3142ab-d932-454e-9fe6-714f0eb1f91f', 1, 1, NULL, 'institution', '[]', '[]', '[]', 'normal', 'general', 'general', 'Test Announcement 2025-12-19 20:45:17', 'This is a test announcement created via direct API test', NULL, NULL, '[]', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, 'draft', 0, 0, 0, 1, '[]', '[]', NULL, NULL, '2025-12-19 20:45:17', '2025-12-19 20:45:17'),
(2, 'eb72b5af-5b65-4738-8f70-82cdfdc9f1fb', 1, 1, NULL, 'institution', '[]', '[]', '[]', 'normal', 'general', 'general', 'Test No Auth', 'Test content without auth', NULL, NULL, '[]', NULL, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, 'draft', 0, 0, 0, 1, '[]', '[]', NULL, NULL, '2025-12-19 20:46:23', '2025-12-19 20:46:23');

-- --------------------------------------------------------

--
-- Structure de la table `announcement_acknowledgments`
--

DROP TABLE IF EXISTS `announcement_acknowledgments`;
CREATE TABLE IF NOT EXISTS `announcement_acknowledgments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `announcement_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `acknowledged_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_announcement_user` (`announcement_id`,`user_id`),
  KEY `idx_announcement` (`announcement_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `permissions` json NOT NULL,
  `rate_limit` int UNSIGNED DEFAULT NULL,
  `allowed_ips` json DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`),
  UNIQUE KEY `unique_key` (`key`),
  KEY `idx_user` (`user_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` bigint UNSIGNED DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blocked_users`
--

DROP TABLE IF EXISTS `blocked_users`;
CREATE TABLE IF NOT EXISTS `blocked_users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `blocker_id` bigint UNSIGNED NOT NULL,
  `blocked_id` bigint UNSIGNED NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_blocker_blocked` (`blocker_id`,`blocked_id`),
  KEY `idx_blocker` (`blocker_id`),
  KEY `idx_blocked` (`blocked_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `certification_requests`
--

DROP TABLE IF EXISTS `certification_requests`;
CREATE TABLE IF NOT EXISTS `certification_requests` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `type` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci,
  `status` enum('submitted','processing','ready','delivered','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `pickup_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fee` decimal(10,2) DEFAULT '0.00',
  `payment_status` enum('pending','paid','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cert_req_uuid` (`uuid`),
  KEY `idx_cert_req_user` (`user_id`),
  KEY `fk_cert_req_institution` (`institution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `comments`
--

DROP TABLE IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_id` bigint UNSIGNED NOT NULL,
  `author_id` bigint UNSIGNED NOT NULL,
  `parent_comment_id` bigint UNSIGNED DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attachments` json DEFAULT NULL,
  `likes_count` int UNSIGNED NOT NULL DEFAULT '0',
  `replies_count` int UNSIGNED NOT NULL DEFAULT '0',
  `is_edited` tinyint(1) NOT NULL DEFAULT '0',
  `edited_at` timestamp NULL DEFAULT NULL,
  `status` enum('published','deleted','reported','moderated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'published',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `moderated_by` bigint UNSIGNED DEFAULT NULL,
  `moderation_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_post` (`post_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_parent_comment` (`parent_comment_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_status` (`status`),
  KEY `fk_comments_moderated_by` (`moderated_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contact_requests`
--

DROP TABLE IF EXISTS `contact_requests`;
CREATE TABLE IF NOT EXISTS `contact_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `requester_id` int NOT NULL,
  `recipient_id` int NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','accepted','rejected','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_request` (`requester_id`,`recipient_id`),
  KEY `idx_requester_id` (`requester_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_status` (`status`)
) ;

-- --------------------------------------------------------

--
-- Structure de la table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
CREATE TABLE IF NOT EXISTS `conversations` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('private','group','announcement') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'private',
  `message_type` enum('private','group') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'private',
  `group_id` bigint UNSIGNED DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_muted` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `last_message_at` timestamp NULL DEFAULT NULL,
  `last_message_preview` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_messages` int UNSIGNED NOT NULL DEFAULT '0',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_type` (`type`),
  KEY `idx_group` (`group_id`),
  KEY `idx_last_message_at` (`last_message_at`),
  KEY `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `conversation_participants`
--

DROP TABLE IF EXISTS `conversation_participants`;
CREATE TABLE IF NOT EXISTS `conversation_participants` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `role` enum('admin','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at` timestamp NULL DEFAULT NULL,
  `last_read_at` timestamp NULL DEFAULT NULL,
  `unread_count` int UNSIGNED NOT NULL DEFAULT '0',
  `is_muted` tinyint(1) NOT NULL DEFAULT '0',
  `muted_until` timestamp NULL DEFAULT NULL,
  `notification_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_pinned` tinyint(1) NOT NULL DEFAULT '0',
  `metadata` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_conversation_user` (`conversation_id`,`user_id`),
  KEY `idx_conversation` (`conversation_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_unread_count` (`unread_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `courses`
--

DROP TABLE IF EXISTS `courses`;
CREATE TABLE IF NOT EXISTS `courses` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `program_id` bigint UNSIGNED NOT NULL,
  `code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `credits` tinyint UNSIGNED NOT NULL DEFAULT '3',
  `semester` enum('S1','S2','S3','S4','S5','S6') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'S1',
  `level` enum('undergraduate','graduate','postgraduate') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'undergraduate',
  `instructor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instructor_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instructor_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_course_per_program` (`program_id`,`code`),
  KEY `idx_program` (`program_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `departments`
--

DROP TABLE IF EXISTS `departments`;
CREATE TABLE IF NOT EXISTS `departments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `faculty_id` bigint UNSIGNED NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `head_of_department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hod_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hod_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` enum('undergraduate','graduate','postgraduate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'undergraduate',
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_department_per_faculty` (`faculty_id`,`code`),
  KEY `idx_uuid` (`uuid`),
  KEY `idx_faculty` (`faculty_id`),
  KEY `idx_status` (`status`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `device_tokens`
--

DROP TABLE IF EXISTS `device_tokens`;
CREATE TABLE IF NOT EXISTS `device_tokens` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `platform` enum('android','ios','web','desktop') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `app_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_used_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  UNIQUE KEY `unique_token` (`token`),
  KEY `idx_user` (`user_id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `email_queue`
--

DROP TABLE IF EXISTS `email_queue`;
CREATE TABLE IF NOT EXISTS `email_queue` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `to_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `to_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `from_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reply_to` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `body_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `attachments` json DEFAULT NULL,
  `priority` enum('low','normal','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `template` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `template_data` json DEFAULT NULL,
  `status` enum('pending','processing','sent','failed','bounced') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `attempts` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `max_attempts` tinyint UNSIGNED NOT NULL DEFAULT '3',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sent_at` timestamp NULL DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_scheduled_at` (`scheduled_at`),
  KEY `idx_to_email` (`to_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `email_verifications`
--

DROP TABLE IF EXISTS `email_verifications`;
CREATE TABLE IF NOT EXISTS `email_verifications` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('registration','email_change','login','password_reset') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verified_at` timestamp NULL DEFAULT NULL,
  `attempts` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_code` (`code`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `faculties`
--

DROP TABLE IF EXISTS `faculties`;
CREATE TABLE IF NOT EXISTS `faculties` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` bigint UNSIGNED NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `dean_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dean_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dean_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `building_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `office_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `total_students` int UNSIGNED DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_faculty_per_institution` (`institution_id`,`code`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `connection` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `favorite_contacts`
--

DROP TABLE IF EXISTS `favorite_contacts`;
CREATE TABLE IF NOT EXISTS `favorite_contacts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `contact_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_favorite` (`user_id`,`contact_user_id`),
  KEY `contact_user_id` (`contact_user_id`),
  KEY `idx_user_id` (`user_id`)
) ;

--
-- Déchargement des données de la table `favorite_contacts`
--

INSERT INTO `favorite_contacts` (`id`, `user_id`, `contact_user_id`, `created_at`) VALUES
(1, 1, 2, '2025-12-11 11:22:09');

-- --------------------------------------------------------

--
-- Structure de la table `files`
--

DROP TABLE IF EXISTS `files`;
CREATE TABLE IF NOT EXISTS `files` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint UNSIGNED NOT NULL,
  `file_type` enum('image','video','audio','document','archive','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `width` int UNSIGNED DEFAULT NULL,
  `height` int UNSIGNED DEFAULT NULL,
  `duration` int UNSIGNED DEFAULT NULL,
  `thumbnail_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `storage_provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'local',
  `is_public` tinyint(1) NOT NULL DEFAULT '0',
  `downloads_count` int UNSIGNED NOT NULL DEFAULT '0',
  `related_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_id` bigint UNSIGNED DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_user` (`user_id`),
  KEY `idx_file_type` (`file_type`),
  KEY `idx_related` (`related_type`,`related_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `group_members`
--

DROP TABLE IF EXISTS `group_members`;
CREATE TABLE IF NOT EXISTS `group_members` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `role` enum('admin','moderator','leader','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'member',
  `status` enum('active','pending','banned','left') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `invited_by` bigint UNSIGNED DEFAULT NULL,
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_at` timestamp NULL DEFAULT NULL,
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `left_at` timestamp NULL DEFAULT NULL,
  `banned_at` timestamp NULL DEFAULT NULL,
  `banned_by` bigint UNSIGNED DEFAULT NULL,
  `ban_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `can_post` tinyint(1) NOT NULL DEFAULT '1',
  `can_comment` tinyint(1) NOT NULL DEFAULT '1',
  `can_invite` tinyint(1) NOT NULL DEFAULT '0',
  `notification_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `muted_until` timestamp NULL DEFAULT NULL,
  `last_read_at` timestamp NULL DEFAULT NULL,
  `unread_count` int UNSIGNED NOT NULL DEFAULT '0',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_group_user` (`group_id`,`user_id`),
  KEY `idx_group` (`group_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_joined_at` (`joined_at`),
  KEY `fk_group_members_invited_by` (`invited_by`),
  KEY `fk_group_members_approved_by` (`approved_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `housing_requests`
--

DROP TABLE IF EXISTS `housing_requests`;
CREATE TABLE IF NOT EXISTS `housing_requests` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `faculty_id` bigint UNSIGNED DEFAULT NULL,
  `dormitory` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `room_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('submitted','processing','allocated','rejected','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_housing_uuid` (`uuid`),
  KEY `idx_housing_user` (`user_id`),
  KEY `idx_housing_institution` (`institution_id`),
  KEY `fk_housing_faculty` (`faculty_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `institutions`
--

DROP TABLE IF EXISTS `institutions`;
CREATE TABLE IF NOT EXISTS `institutions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('public','private','professional','research') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public',
  `status` enum('active','inactive','suspended') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
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
  `founded_year` year DEFAULT NULL,
  `rector_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_students` int UNSIGNED DEFAULT '0',
  `total_staff` int UNSIGNED DEFAULT '0',
  `is_national_hub` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sync_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `last_sync_at` timestamp NULL DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_uuid` (`uuid`),
  KEY `idx_code` (`code`),
  KEY `idx_type_status` (`type`,`status`),
  KEY `idx_region` (`region`),
  KEY `idx_is_national_hub` (`is_national_hub`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `merchant_space_requests`
--

DROP TABLE IF EXISTS `merchant_space_requests`;
CREATE TABLE IF NOT EXISTS `merchant_space_requests` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `company_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Cameroun',
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('submitted','approved','rejected','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_merchant_uuid` (`uuid`),
  KEY `idx_merchant_user` (`user_id`),
  KEY `fk_merchant_institution` (`institution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `conversation_id` bigint UNSIGNED NOT NULL,
  `sender_id` bigint UNSIGNED NOT NULL,
  `receiver_id` bigint UNSIGNED DEFAULT NULL,
  `group_id` bigint UNSIGNED DEFAULT NULL,
  `parent_message_id` bigint UNSIGNED DEFAULT NULL,
  `type` enum('text','image','video','audio','document','link','location','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `message_type` enum('private','group') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'private',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `attachments` json DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `is_edited` tinyint(1) NOT NULL DEFAULT '0',
  `edited_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_for_everyone` tinyint(1) NOT NULL DEFAULT '0',
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `read_count` int UNSIGNED NOT NULL DEFAULT '0',
  `delivery_status` enum('sent','delivered','read','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sent',
  `status` enum('sent','delivered','read','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'sent',
  `sent_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_conversation` (`conversation_id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  KEY `idx_group` (`group_id`),
  KEY `idx_parent_message` (`parent_message_id`),
  KEY `idx_sent_at` (`sent_at`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_messages_conversation_sent` (`conversation_id`,`sent_at` DESC),
  KEY `idx_messages_receiver_read` (`receiver_id`,`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `message_attachments`
--

DROP TABLE IF EXISTS `message_attachments`;
CREATE TABLE IF NOT EXISTS `message_attachments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_id` bigint UNSIGNED NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_message` (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `message_reads`
--

DROP TABLE IF EXISTS `message_reads`;
CREATE TABLE IF NOT EXISTS `message_reads` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_message_user` (`message_id`,`user_id`),
  KEY `idx_message` (`message_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_type` enum('announcement','message','offer','group','system','mention','post','comment','reaction','opportunity','academic','security') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('message','group','post','comment','reaction','announcement','opportunity','system','academic','security') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_id` bigint UNSIGNED DEFAULT NULL,
  `related_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `actor_id` bigint UNSIGNED DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `is_sent_push` tinyint(1) NOT NULL DEFAULT '0',
  `sent_push_at` timestamp NULL DEFAULT NULL,
  `is_sent_email` tinyint(1) NOT NULL DEFAULT '0',
  `sent_email_at` timestamp NULL DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_user` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_category` (`category`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_actor` (`actor_id`),
  KEY `idx_notifications_user_read_created` (`user_id`,`is_read`,`created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `opportunities`
--

DROP TABLE IF EXISTS `opportunities`;
CREATE TABLE IF NOT EXISTS `opportunities` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `posted_by` bigint UNSIGNED NOT NULL,
  `published_by` bigint UNSIGNED DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_logo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_website` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `contact_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('internship','job','scholarship','volunteer','competition','training','exchange','exchange_program') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `offer_type` enum('internship','job','scholarship','exchange','competition') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'internship',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `responsibilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `benefits` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Cameroun',
  `scope` enum('local','national','international') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'local',
  `is_remote` tinyint(1) NOT NULL DEFAULT '0',
  `work_type` enum('full_time','part_time','contract','temporary','flexible') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salary_range` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salary_currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'XAF',
  `is_paid` tinyint(1) DEFAULT NULL,
  `target_programs` json DEFAULT NULL,
  `target_levels` json DEFAULT NULL,
  `target_level` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_institutions` json DEFAULT NULL,
  `target_departments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `required_gpa` decimal(3,2) DEFAULT NULL,
  `required_skills` json DEFAULT NULL,
  `application_deadline` date DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `positions_available` int UNSIGNED DEFAULT NULL,
  `applications_count` int UNSIGNED NOT NULL DEFAULT '0',
  `views_count` int UNSIGNED NOT NULL DEFAULT '0',
  `application_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `application_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `application_instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `required_documents` json DEFAULT NULL,
  `attachments` json DEFAULT NULL,
  `priority` enum('normal','featured','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verified_by` bigint UNSIGNED DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `status` enum('draft','published','closed','expired','archived','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `publish_at` timestamp NULL DEFAULT NULL,
  `expire_at` timestamp NULL DEFAULT NULL,
  `tags` json DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_posted_by` (`posted_by`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_application_deadline` (`application_deadline`),
  KEY `idx_deadline` (`deadline`),
  KEY `idx_is_verified` (`is_verified`),
  KEY `idx_is_featured` (`is_featured`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_opportunities_verified_by` (`verified_by`),
  KEY `idx_opportunities_type_status_deadline` (`type`,`status`,`application_deadline`),
  KEY `idx_offers_status_deadline` (`status`,`deadline`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `opportunity_applications`
--

DROP TABLE IF EXISTS `opportunity_applications`;
CREATE TABLE IF NOT EXISTS `opportunity_applications` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `opportunity_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `cover_letter` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cv_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `additional_documents` json DEFAULT NULL,
  `answers` json DEFAULT NULL,
  `status` enum('submitted','under_review','shortlisted','accepted','rejected','withdrawn') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `reviewed_by` bigint UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `applied_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_opportunity_user` (`opportunity_id`,`user_id`),
  KEY `idx_opportunity` (`opportunity_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `fk_applications_reviewed_by` (`reviewed_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `organizational_structures`
--

DROP TABLE IF EXISTS `organizational_structures`;
CREATE TABLE IF NOT EXISTS `organizational_structures` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('ministry','regulatory_body','coordination_committee','university','faculty','school','institute','department','research_center','administrative_unit','student_organization','partner_organization','control_body','support_service') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_structure_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `level` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `hierarchy_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_type` (`type`),
  KEY `idx_parent` (`parent_structure_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_level` (`level`),
  KEY `idx_active` (`is_active`),
  KEY `idx_os_type_level` (`type`,`level`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `organizational_structures`
--

INSERT INTO `organizational_structures` (`id`, `uuid`, `code`, `name`, `type`, `parent_structure_id`, `institution_id`, `level`, `hierarchy_path`, `contact_email`, `contact_phone`, `address`, `website`, `description`, `is_active`, `metadata`, `created_at`, `updated_at`) VALUES
(1, '242c18dc-dda8-11f0-b63a-68f728e7cdfb', 'MINESUP', 'Ministère de l\'Enseignement Supérieur', 'ministry', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(2, '242c7e70-dda8-11f0-b63a-68f728e7cdfb', 'MINRESI', 'Ministère Recherche Scientifique Innovation', 'ministry', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(3, '242c8048-dda8-11f0-b63a-68f728e7cdfb', 'CNES', 'Conseil National Enseignement Supérieur', 'regulatory_body', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(4, '242c8190-dda8-11f0-b63a-68f728e7cdfb', 'CAAQES', 'Agence Accréditation Assurance Qualité', 'regulatory_body', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(5, '242c82c1-dda8-11f0-b63a-68f728e7cdfb', 'IGES', 'Inspection Générale Enseignement Supérieur', 'control_body', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(6, '242c8403-dda8-11f0-b63a-68f728e7cdfb', 'DBS', 'Direction Bourses Stages', 'administrative_unit', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(7, '242c8539-dda8-11f0-b63a-68f728e7cdfb', 'DPUP', 'Direction Promotion Universités Privées', 'administrative_unit', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(8, '2434073f-dda8-11f0-b63a-68f728e7cdfb', 'UY1', 'Université de Yaoundé I', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(9, '24341946-dda8-11f0-b63a-68f728e7cdfb', 'UY2', 'Université de Yaoundé II', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(10, '24341aca-dda8-11f0-b63a-68f728e7cdfb', 'UD', 'Université de Douala', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(11, '24341cf1-dda8-11f0-b63a-68f728e7cdfb', 'UDS', 'Université de Dschang', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(12, '24341e30-dda8-11f0-b63a-68f728e7cdfb', 'UM', 'Université de Maroua', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(13, '24341fa9-dda8-11f0-b63a-68f728e7cdfb', 'UB', 'Université de Bamenda', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(14, '243420cb-dda8-11f0-b63a-68f728e7cdfb', 'UBa', 'Université de Buéa', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(15, '243421e6-dda8-11f0-b63a-68f728e7cdfb', 'UN', 'Université de Ngaoundéré', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(16, '24342309-dda8-11f0-b63a-68f728e7cdfb', 'UG', 'Université de Garoua', 'university', NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(17, '243ae2eb-dda8-11f0-b63a-68f728e7cdfb', 'ENS', 'École Normale Supérieure', 'school', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(18, '243aefee-dda8-11f0-b63a-68f728e7cdfb', 'ENSP', 'École Nationale Supérieure Polytechnique', 'school', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(19, '243af19c-dda8-11f0-b63a-68f728e7cdfb', 'ENAM', 'École Nationale Administration Magistrature', 'school', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(20, '243af2da-dda8-11f0-b63a-68f728e7cdfb', 'IRIC', 'Institut Relations Internationales', 'institute', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(21, '243af423-dda8-11f0-b63a-68f728e7cdfb', 'ENSTP', 'École Nationale Supérieure Travaux Publics', 'school', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(22, '243af55d-dda8-11f0-b63a-68f728e7cdfb', 'EGEC', 'École Gestion Expertise Comptable', 'school', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08'),
(23, '243af67c-dda8-11f0-b63a-68f728e7cdfb', 'IUT', 'Institut Universitaire Technologie', 'institute', NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2025-12-20 13:31:08', '2025-12-20 13:31:08');

-- --------------------------------------------------------

--
-- Structure de la table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT '0',
  `used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_user` (`user_id`),
  KEY `idx_token` (`token`),
  KEY `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_name` (`name`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `display_name`, `category`, `description`, `created_at`) VALUES
(1, 'manage_users', 'Gérer utilisateurs', 'users', 'Créer, modifier, supprimer utilisateurs', '2025-11-24 06:15:14'),
(2, 'manage_institutions', 'Gérer institutions', 'institutions', 'Gérer les universités', '2025-11-24 06:15:14'),
(3, 'manage_groups', 'Gérer groupes', 'groups', 'Créer et gérer les groupes', '2025-11-24 06:15:14'),
(4, 'publish_announcements', 'Publier annonces', 'content', 'Publier annonces officielles', '2025-11-24 06:15:14'),
(5, 'publish_offers', 'Publier offres', 'content', 'Publier stages/emplois/bourses', '2025-11-24 06:15:14'),
(6, 'moderate_content', 'Modérer contenu', 'moderation', 'Modérer publications', '2025-11-24 06:15:14'),
(7, 'view_analytics', 'Voir statistiques', 'analytics', 'Accéder aux statistiques', '2025-11-24 06:15:14'),
(8, 'manage_settings', 'Gérer paramètres', 'settings', 'Modifier paramètres système', '2025-11-24 06:15:14'),
(9, 'send_messages', 'Envoyer messages', 'messaging', 'Utiliser messagerie', '2025-11-24 06:15:14'),
(10, 'create_posts', 'Créer publications', 'content', 'Publier dans groupes', '2025-11-24 06:15:14');

-- --------------------------------------------------------

--
-- Structure de la table `phone_verifications`
--

DROP TABLE IF EXISTS `phone_verifications`;
CREATE TABLE IF NOT EXISTS `phone_verifications` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('registration','phone_change','login','2fa') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verified_at` timestamp NULL DEFAULT NULL,
  `attempts` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_phone` (`phone`),
  KEY `idx_code` (`code`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `posts`
--

DROP TABLE IF EXISTS `posts`;
CREATE TABLE IF NOT EXISTS `posts` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_id` bigint UNSIGNED DEFAULT NULL,
  `author_id` bigint UNSIGNED NOT NULL,
  `type` enum('text','image','video','link','poll','event','document','shared','announcement') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `post_type` enum('text','announcement','poll','event','document') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'text',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `media_urls` json DEFAULT NULL,
  `attachments` json DEFAULT NULL,
  `attachments_count` int DEFAULT '0',
  `link_preview` json DEFAULT NULL,
  `poll_options` json DEFAULT NULL,
  `poll_end_date` timestamp NULL DEFAULT NULL,
  `shared_post_id` bigint UNSIGNED DEFAULT NULL,
  `visibility` enum('public','group_only','private') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'group_only',
  `is_pinned` tinyint(1) NOT NULL DEFAULT '0',
  `is_announcement` tinyint(1) NOT NULL DEFAULT '0',
  `allow_comments` tinyint(1) NOT NULL DEFAULT '1',
  `likes_count` int UNSIGNED NOT NULL DEFAULT '0',
  `comments_count` int UNSIGNED NOT NULL DEFAULT '0',
  `shares_count` int UNSIGNED NOT NULL DEFAULT '0',
  `views_count` int UNSIGNED NOT NULL DEFAULT '0',
  `is_edited` tinyint(1) NOT NULL DEFAULT '0',
  `edited_at` timestamp NULL DEFAULT NULL,
  `status` enum('draft','published','archived','deleted','reported','moderated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'published',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `moderated_at` timestamp NULL DEFAULT NULL,
  `moderated_by` bigint UNSIGNED DEFAULT NULL,
  `moderation_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  KEY `idx_group` (`group_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_pinned` (`is_pinned`),
  KEY `fk_posts_shared_post` (`shared_post_id`),
  KEY `fk_posts_moderated_by` (`moderated_by`),
  KEY `idx_posts_group_status_created` (`group_id`,`status`,`created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `preinscriptions`
--

DROP TABLE IF EXISTS `preinscriptions`;
CREATE TABLE IF NOT EXISTS `preinscriptions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID unique de la préinscription',
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID universel unique',
  `unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Code unique de référence',
  `faculty` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Faculté visée (UY1, FALSH, FS, FSE, IUT, ENSPY)',
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nom de famille',
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Prénom',
  `middle_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Autre prénom',
  `date_of_birth` date NOT NULL COMMENT 'Date de naissance',
  `is_birth_date_on_certificate` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'La date de naissance correspond-elle au certificat ?',
  `place_of_birth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Lieu de naissance',
  `gender` enum('MASCULIN','FEMININ') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Genre',
  `cni_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Numéro CNI/PI',
  `residence_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Adresse de résidence',
  `marital_status` enum('CELIBATAIRE','MARIE(E)','DIVORCE(E)','VEUF(VE)') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Situation maritale',
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Numéro de téléphone',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Adresse email',
  `first_language` enum('FRANÇAIS','ANGLAIS','BILINGUE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Première langue',
  `professional_situation` enum('SANS EMPLOI','SALARIE(E)','EN AUTO-EMPLOI','STAGIAIRE','RETRAITE(E)') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Situation professionnelle',
  `previous_diploma` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Diplôme précédent (BAC, GCE, BREVET, etc.)',
  `previous_institution` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Établissement précédent',
  `graduation_year` int DEFAULT NULL COMMENT 'Année d''obtention du diplôme',
  `graduation_month` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Mois d''obtention',
  `desired_program` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Programme souhaité',
  `study_level` enum('LICENCE','MASTER','DOCTORAT','DUT','BTS','MASTER_PRO','DEUST','AUTRE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Niveau d''études visé',
  `specialization` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Spécialisation souhaitée',
  `series_bac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Série du BAC (A, B, C, D, E, F, G, H, TI)',
  `bac_year` int DEFAULT NULL COMMENT 'Année du BAC',
  `bac_center` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Centre d''examen BAC',
  `bac_mention` enum('PASSABLE','ASSEZ_BIEN','BIEN','TRES_BIEN','EXCELLENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Mention au BAC',
  `gpa_score` decimal(4,2) DEFAULT NULL COMMENT 'Score GPA si applicable',
  `rank_in_class` int DEFAULT NULL COMMENT 'Rang dans la classe',
  `birth_certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin certificat naissance',
  `cni_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin CNI/PI',
  `diploma_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin diplôme',
  `transcript_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin relevé de notes',
  `photo_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin photo d''identité',
  `recommendation_letter_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin lettre de recommandation',
  `motivation_letter_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin lettre de motivation',
  `medical_certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin certificat médical',
  `other_documents_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Chemins autres documents (JSON)',
  `parent_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Nom complet du parent/tuteur',
  `parent_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Téléphone du parent',
  `parent_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email du parent',
  `parent_occupation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Profession du parent',
  `parent_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Adresse du parent',
  `parent_relationship` enum('PERE','MERE','TUTEUR','AUTRE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Lien avec le parent',
  `parent_income_level` enum('FAIBLE','MOYEN','ELEVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Niveau de revenu du parent',
  `payment_method` enum('ORANGE_MONEY','MTN_MONEY','BANK_TRANSFER','CASH','MOBILE_MONEY','CHEQUE','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Méthode de paiement',
  `payment_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Référence de paiement',
  `payment_amount` decimal(10,2) DEFAULT NULL COMMENT 'Montant payé',
  `payment_currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'XAF' COMMENT 'Devise du paiement',
  `payment_date` timestamp NULL DEFAULT NULL COMMENT 'Date de paiement',
  `payment_status` enum('pending','paid','confirmed','refunded','partial') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Statut du paiement',
  `payment_proof_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chemin preuve de paiement',
  `scholarship_requested` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Bourse demandée ?',
  `scholarship_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type de bourse',
  `financial_aid_amount` decimal(10,2) DEFAULT NULL COMMENT 'Montant aide financière',
  `status` enum('pending','under_review','accepted','rejected','cancelled','deferred','waitlisted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Statut global',
  `documents_status` enum('pending','submitted','verified','incomplete','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Statut des documents',
  `review_priority` enum('LOW','NORMAL','HIGH','URGENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NORMAL' COMMENT 'Priorité de révision',
  `reviewed_by` bigint UNSIGNED DEFAULT NULL COMMENT 'ID de l''administrateur qui a validé',
  `review_date` timestamp NULL DEFAULT NULL COMMENT 'Date de validation/rejet',
  `review_comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Commentaires de révision',
  `rejection_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Motif de rejet',
  `interview_required` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Entretien requis ?',
  `interview_date` timestamp NULL DEFAULT NULL COMMENT 'Date d''entretien',
  `interview_location` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Lieu d''entretien',
  `interview_type` enum('PHYSICAL','ONLINE','PHONE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type d''entretien',
  `interview_result` enum('PENDING','PASSED','FAILED','NO_SHOW') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Résultat entretien',
  `interview_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Notes entretien',
  `admission_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Numéro d''admission si accepté',
  `admission_date` timestamp NULL DEFAULT NULL COMMENT 'Date d''admission',
  `registration_deadline` date DEFAULT NULL COMMENT 'Date limite pour inscription définitive',
  `registration_completed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Inscription complétée ?',
  `student_id` bigint UNSIGNED DEFAULT NULL COMMENT 'ID étudiant final - lié à la table users',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Numéro de promotion',
  `contact_preference` enum('EMAIL','PHONE','SMS','WHATSAPP') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Préférence de contact',
  `marketing_consent` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Consentement marketing ?',
  `data_processing_consent` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Consentement traitement données ?',
  `newsletter_subscription` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Abonnement newsletter ?',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Adresse IP de soumission',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Navigateur utilisé',
  `device_type` enum('DESKTOP','MOBILE','TABLET','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type d''appareil',
  `browser_info` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Informations navigateur',
  `os_info` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Système d''exploitation',
  `location_country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Pays de soumission',
  `location_city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Ville de soumission',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Notes générales',
  `admin_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Notes administrateur',
  `internal_comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Commentaires internes',
  `special_needs` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Besoins spéciaux',
  `medical_conditions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Conditions médicales',
  `submission_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de soumission',
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière mise à jour',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date de modification',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Date de suppression (soft delete)',
  `applicant_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email de la personne concernée (si différent du créateur)',
  `applicant_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Téléphone de la personne concernée (si différent du créateur)',
  `relationship` enum('self','parent','tutor','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'self' COMMENT 'Relation entre créateur et personne concernée',
  `is_processed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Indique si la préinscription a été traitée pour mise à jour du statut utilisateur',
  `processed_at` timestamp NULL DEFAULT NULL COMMENT 'Date de traitement automatique du statut utilisateur',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_code` (`unique_code`),
  UNIQUE KEY `idx_uuid` (`uuid`),
  UNIQUE KEY `idx_admission_number` (`admission_number`),
  UNIQUE KEY `idx_student_id` (`student_id`),
  KEY `idx_faculty` (`faculty`(191)),
  KEY `idx_status` (`status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_documents_status` (`documents_status`),
  KEY `idx_submission_date` (`submission_date`),
  KEY `idx_email` (`email`(191)),
  KEY `idx_phone` (`phone_number`),
  KEY `idx_desired_program` (`desired_program`(191)),
  KEY `idx_study_level` (`study_level`),
  KEY `idx_graduation_year` (`graduation_year`),
  KEY `idx_payment_method` (`payment_method`),
  KEY `idx_review_date` (`review_date`),
  KEY `idx_reviewed_by` (`reviewed_by`),
  KEY `idx_payment_date` (`payment_date`),
  KEY `idx_interview_date` (`interview_date`),
  KEY `idx_admission_date` (`admission_date`),
  KEY `idx_registration_deadline` (`registration_deadline`),
  KEY `idx_parent_phone` (`parent_phone`),
  KEY `idx_parent_email` (`parent_email`(191)),
  KEY `idx_batch_number` (`batch_number`),
  KEY `idx_deleted_at` (`deleted_at`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_updated_at` (`updated_at`),
  KEY `idx_faculty_status` (`faculty`(191),`status`),
  KEY `idx_program_level` (`desired_program`(191),`study_level`),
  KEY `idx_payment_status_date` (`payment_status`,`payment_date`),
  KEY `idx_review_status_date` (`status`,`review_date`),
  KEY `idx_student_id_fk` (`student_id`),
  KEY `idx_applicant_email` (`applicant_email`(191)),
  KEY `idx_applicant_phone` (`applicant_phone`),
  KEY `idx_relationship` (`relationship`),
  KEY `idx_is_processed` (`is_processed`),
  KEY `idx_processed_at` (`processed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_audit_logs`
--

DROP TABLE IF EXISTS `pre_audit_logs`;
CREATE TABLE IF NOT EXISTS `pre_audit_logs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `entity` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` bigint UNSIGNED NOT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `performed_by` bigint UNSIGNED DEFAULT NULL,
  `payload` json DEFAULT NULL,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pre_audit_entity` (`entity`,`entity_id`),
  KEY `fk_pre_audit_performed_by` (`performed_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_event_settings`
--

DROP TABLE IF EXISTS `pre_event_settings`;
CREATE TABLE IF NOT EXISTS `pre_event_settings` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` bigint UNSIGNED NOT NULL,
  `key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pre_event_inst_key` (`institution_id`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_faculties`
--

DROP TABLE IF EXISTS `pre_faculties`;
CREATE TABLE IF NOT EXISTS `pre_faculties` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` bigint UNSIGNED NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pre_faculties_code` (`code`),
  KEY `idx_pre_faculties_inst` (`institution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_payments`
--

DROP TABLE IF EXISTS `pre_payments`;
CREATE TABLE IF NOT EXISTS `pre_payments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `pre_registration_id` bigint UNSIGNED DEFAULT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `provider` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider_ref` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'XAF',
  `status` enum('pending','completed','failed','cancelled','refunded') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `paid_at` timestamp NULL DEFAULT NULL,
  `meta` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pre_payments_pre` (`pre_registration_id`),
  KEY `idx_pre_payments_user` (`user_id`),
  KEY `fk_pre_payments_institution` (`institution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_programs`
--

DROP TABLE IF EXISTS `pre_programs`;
CREATE TABLE IF NOT EXISTS `pre_programs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `faculty_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` int UNSIGNED DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pre_programs_faculty` (`faculty_id`),
  KEY `idx_pre_programs_institution` (`institution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_registration_documents`
--

DROP TABLE IF EXISTS `pre_registration_documents`;
CREATE TABLE IF NOT EXISTS `pre_registration_documents` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `pre_registration_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `filename` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stored_path` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mimetype` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size` int UNSIGNED DEFAULT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT '0',
  `verified_by` bigint UNSIGNED DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pre_reg_docs_pre` (`pre_registration_id`),
  KEY `fk_pre_reg_docs_user` (`user_id`),
  KEY `fk_pre_reg_docs_verified_by` (`verified_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pre_resources`
--

DROP TABLE IF EXISTS `pre_resources`;
CREATE TABLE IF NOT EXISTS `pre_resources` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `filepath` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mimetype` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pre_resources_inst` (`institution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `programs`
--

DROP TABLE IF EXISTS `programs`;
CREATE TABLE IF NOT EXISTS `programs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `department_id` bigint UNSIGNED NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `degree_level` enum('licence1','licence2','licence3','master1','master2','doctorat','ingenieur','bts','professional') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_years` tinyint UNSIGNED NOT NULL DEFAULT '3',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `admission_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `career_prospects` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('active','inactive','suspended') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_program_per_department` (`department_id`,`code`),
  KEY `idx_department` (`department_id`),
  KEY `idx_degree_level` (`degree_level`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reactions`
--

DROP TABLE IF EXISTS `reactions`;
CREATE TABLE IF NOT EXISTS `reactions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `reactable_type` enum('post','comment','message') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reactable_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `reaction_type` enum('like','love','haha','wow','sad','angry','support') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'like',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_reaction` (`reactable_type`,`reactable_id`,`user_id`),
  KEY `idx_reactable` (`reactable_type`,`reactable_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `regions`
--

DROP TABLE IF EXISTS `regions`;
CREATE TABLE IF NOT EXISTS `regions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `name` (`name`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `regions`
--

INSERT INTO `regions` (`id`, `name`, `code`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Adamaoua', 'AD', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(2, 'Centre', 'CE', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(3, 'Est', 'ES', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(4, 'Extrême-Nord', 'EN', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(5, 'Littoral', 'LT', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(6, 'Nord', 'NO', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(7, 'Nord-Ouest', 'NW', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(8, 'Ouest', 'OU', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(9, 'Sud', 'SU', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57'),
(10, 'Sud-Ouest', 'SO', 1, '2025-12-11 14:39:57', '2025-12-11 14:39:57');

-- --------------------------------------------------------

--
-- Structure de la table `reports`
--

DROP TABLE IF EXISTS `reports`;
CREATE TABLE IF NOT EXISTS `reports` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `reporter_id` bigint UNSIGNED NOT NULL,
  `reportable_type` enum('post','comment','message','user','group','announcement','opportunity') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reportable_id` bigint UNSIGNED NOT NULL,
  `reason` enum('spam','harassment','hate_speech','violence','nudity','misinformation','copyright','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `evidence` json DEFAULT NULL,
  `status` enum('pending','under_review','resolved','rejected','escalated') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reviewed_by` bigint UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `action_taken` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reporter` (`reporter_id`),
  KEY `idx_reportable` (`reportable_type`,`reportable_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_reports_reviewed_by` (`reviewed_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('national_institutional','university_hierarchy','teaching_staff','administrative_technical','student_representation','partners_social','support_services','infrastructure_logistics','legal_regulatory','control_organizations','research_innovation','academic','administrative') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` tinyint UNSIGNED NOT NULL DEFAULT '50' COMMENT 'Niveau de permission (0-100)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `responsibilities` json DEFAULT NULL,
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_system_role` tinyint(1) NOT NULL DEFAULT '0',
  `parent_role_id` bigint UNSIGNED DEFAULT NULL,
  `institution_type` enum('all','public','private','professional','research') COLLATE utf8mb4_unicode_ci DEFAULT 'all',
  `ministry_affiliation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_category` (`category`),
  KEY `idx_level` (`level`),
  KEY `idx_parent_role` (`parent_role_id`),
  KEY `idx_active` (`is_active`),
  KEY `idx_roles_category_level` (`category`,`level`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `roles`
--

INSERT INTO `roles` (`id`, `uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`, `responsibilities`, `permissions`, `is_active`, `is_system_role`, `parent_role_id`, `institution_type`, `ministry_affiliation`, `created_at`, `updated_at`) VALUES
(1, '23aba124-dda8-11f0-b63a-68f728e7cdfb', 'MINESUP_MINISTER', 'ministry_of_higher_education', 'Ministre de l\'Enseignement Supérieur', 'national_institutional', 100, 'Ministre en charge de l\'enseignement supérieur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(2, '23ac4820-dda8-11f0-b63a-68f728e7cdfb', 'MINESUP_SECRETARY', 'ministry_secretary_general', 'Secrétaire Général MINESUP', 'national_institutional', 95, 'Secrétaire général du ministère', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(3, '23ac554f-dda8-11f0-b63a-68f728e7cdfb', 'MINRESIP_DIRECTOR', 'ministry_research_director', 'Directeur MINRESI', 'national_institutional', 90, 'Directeur du ministère de la recherche', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(4, '23ac5925-dda8-11f0-b63a-68f728e7cdfb', 'CNES_PRESIDENT', 'cnes_president', 'Président CNES', 'national_institutional', 88, 'Président du conseil national', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(5, '23ac5c7a-dda8-11f0-b63a-68f728e7cdfb', 'CAAQES_DIRECTOR', 'caaques_director', 'Directeur CAAQES', 'national_institutional', 85, 'Directeur de l\'agence d\'accréditation', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(6, '23ac5f13-dda8-11f0-b63a-68f728e7cdfb', 'INSPECTOR_GENERAL', 'general_inspector', 'Inspecteur Général', 'national_institutional', 87, 'Inspecteur général de l\'enseignement supérieur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(7, '23bc3932-dda8-11f0-b63a-68f728e7cdfb', 'UNIV_RECTOR', 'university_rector', 'Recteur d\'Université', 'university_hierarchy', 92, 'Recteur d\'université', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(8, '23bd7de0-dda8-11f0-b63a-68f728e7cdfb', 'UNIV_VICE_RECTOR', 'vice_rector', 'Vice-Recteur', 'university_hierarchy', 88, 'Vice-recteur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(9, '23bd805e-dda8-11f0-b63a-68f728e7cdfb', 'UNIV_SECRETARY', 'secretary_general', 'Secrétaire Général', 'university_hierarchy', 85, 'Secrétaire général d\'université', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(10, '23bd828a-dda8-11f0-b63a-68f728e7cdfb', 'FACULTY_DEAN', 'faculty_dean', 'Doyen de Faculté', 'university_hierarchy', 80, 'Doyen de faculté', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(11, '23bd83cb-dda8-11f0-b63a-68f728e7cdfb', 'SCHOOL_DIRECTOR', 'school_director', 'Directeur d\'École', 'university_hierarchy', 78, 'Directeur d\'école', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(12, '23bd84fd-dda8-11f0-b63a-68f728e7cdfb', 'DEPARTMENT_HEAD', 'department_head', 'Chef de Département', 'university_hierarchy', 75, 'Chef de département', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(13, '23bd8619-dda8-11f0-b63a-68f728e7cdfb', 'SECTION_HEAD', 'section_head', 'Chef de Section', 'university_hierarchy', 70, 'Chef de section', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(14, '23bd872a-dda8-11f0-b63a-68f728e7cdfb', 'PROGRAM_COORD', 'program_coordinator', 'Coordonnateur de Programme', 'university_hierarchy', 68, 'Coordonnateur de programme', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(15, '23cad314-dda8-11f0-b63a-68f728e7cdfb', 'PROF_TITULAR', 'professor_titular', 'Professeur Titulaire', 'teaching_staff', 72, 'Professeur titulaire', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(16, '23cd362d-dda8-11f0-b63a-68f728e7cdfb', 'PROF_ASSOCIATE', 'professor_associate', 'Professeur Associé', 'teaching_staff', 70, 'Professeur associé', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(17, '23cd380b-dda8-11f0-b63a-68f728e7cdfb', 'MASTER_CONF', 'master_conference', 'Maître de Conférences', 'teaching_staff', 68, 'Maître de conférences', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(18, '23cd3943-dda8-11f0-b63a-68f728e7cdfb', 'COURSE_HOLDER', 'course_holder', 'Chargé de Cours', 'teaching_staff', 65, 'Chargé de cours', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(19, '23cd3a5d-dda8-11f0-b63a-68f728e7cdfb', 'ASSISTANT', 'assistant_prof', 'Assistant', 'teaching_staff', 60, 'Assistant', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(20, '23cd3b77-dda8-11f0-b63a-68f728e7cdfb', 'MONITOR', 'monitor', 'Moniteur', 'teaching_staff', 55, 'Moniteur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(21, '23cd3c9b-dda8-11f0-b63a-68f728e7cdfb', 'TEMP_TEACHER', 'temporary_teacher', 'Enseignant Vacataire', 'teaching_staff', 50, 'Enseignant vacataire', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(22, '23cd3da1-dda8-11f0-b63a-68f728e7cdfb', 'VISITING_PROF', 'visiting_professor', 'Professeur Visiteur', 'teaching_staff', 65, 'Professeur visiteur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(23, '23cd3eae-dda8-11f0-b63a-68f728e7cdfb', 'POSTDOC', 'postdoc_researcher', 'Chercheur Post-Doctorant', 'teaching_staff', 62, 'Chercheur post-doctorant', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(24, '23d5ba9b-dda8-11f0-b63a-68f728e7cdfb', 'ADMIN_AGENT', 'administrative_agent', 'Agent Administratif', 'administrative_technical', 45, 'Agent administratif', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(25, '23d5c780-dda8-11f0-b63a-68f728e7cdfb', 'SECRETARY', 'secretary', 'Secrétaire', 'administrative_technical', 40, 'Secrétaire', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(26, '23d5c90a-dda8-11f0-b63a-68f728e7cdfb', 'ACCOUNTANT', 'accountant', 'Comptable', 'administrative_technical', 48, 'Comptable', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(27, '23d5ca35-dda8-11f0-b63a-68f728e7cdfb', 'LIBRARIAN', 'librarian', 'Bibliothécaire', 'administrative_technical', 50, 'Bibliothécaire', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(28, '23d5cb53-dda8-11f0-b63a-68f728e7cdfb', 'LAB_TECH', 'lab_technician', 'Technicien de Labo', 'administrative_technical', 52, 'Technicien de laboratoire', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(29, '23d5cc81-dda8-11f0-b63a-68f728e7cdfb', 'MAINTENANCE_ENG', 'maintenance_engineer', 'Ingénieur Maintenance', 'administrative_technical', 55, 'Ingénieur de maintenance', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(30, '23d5cd9e-dda8-11f0-b63a-68f728e7cdfb', 'SECURITY_AGENT', 'security_agent', 'Agent de Sécurité', 'administrative_technical', 35, 'Agent de sécurité', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(31, '23d5ceaf-dda8-11f0-b63a-68f728e7cdfb', 'CLEANING_STAFF', 'cleaning_staff', 'Agent d\'Entretien', 'administrative_technical', 30, 'Agent d\'entretien', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(32, '23d5cfba-dda8-11f0-b63a-68f728e7cdfb', 'DRIVER', 'driver', 'Chauffeur', 'administrative_technical', 32, 'Chauffeur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(33, '23d5d0c8-dda8-11f0-b63a-68f728e7cdfb', 'IT_SUPPORT', 'it_support', 'Support Informatique', 'administrative_technical', 58, 'Support informatique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(34, '23ddcc23-dda8-11f0-b63a-68f728e7cdfb', 'STUDENT_EXEC', 'student_executive', 'Membre Bureau Exécutif Étudiants', 'student_representation', 42, 'Membre du bureau exécutif étudiants', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(35, '23de050a-dda8-11f0-b63a-68f728e7cdfb', 'CLASS_DELEGATE', 'class_delegate', 'Délégué de Classe', 'student_representation', 35, 'Délégué de classe', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(36, '23de0f79-dda8-11f0-b63a-68f728e7cdfb', 'FACULTY_DELEGATE', 'faculty_delegate', 'Délégué de Faculté', 'student_representation', 38, 'Délégué de faculté', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(37, '23de12cc-dda8-11f0-b63a-68f728e7cdfb', 'RESIDENCE_DELEGATE', 'residence_delegate', 'Délégué de Résidence', 'student_representation', 36, 'Délégué de résidence', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(38, '23de1516-dda8-11f0-b63a-68f728e7cdfb', 'CULTURAL_ASSOC_LEADER', 'cultural_association_leader', 'Président Association Culturelle', 'student_representation', 40, 'Président association culturelle', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(39, '23de17b7-dda8-11f0-b63a-68f728e7cdfb', 'CLUB_PRESIDENT', 'club_president', 'Président Club Étudiant', 'student_representation', 38, 'Président de club étudiant', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(40, '23de1a74-dda8-11f0-b63a-68f728e7cdfb', 'PROMOTION_COORD', 'promotion_coordinator', 'Coordonnateur de Promotion', 'student_representation', 37, 'Coordonnateur de promotion', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(41, '23e7cee9-dda8-11f0-b63a-68f728e7cdfb', 'ECONOMIC_PARTNER', 'economic_partner', 'Partenaire Économique', 'partners_social', 60, 'Partenaire économique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(42, '23e7e6be-dda8-11f0-b63a-68f728e7cdfb', 'CHAMBER_COMMERCE', 'chamber_commerce', 'Chambre de Commerce', 'partners_social', 62, 'Représentant chambre de commerce', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(43, '23e7e85a-dda8-11f0-b63a-68f728e7cdfb', 'EMPLOYER_ORG', 'employer_organization', 'Organisation Patronale', 'partners_social', 64, 'Organisation patronale', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(44, '23e7e986-dda8-11f0-b63a-68f728e7cdfb', 'BANK_REP', 'bank_representative', 'Représentant Bancaire', 'partners_social', 58, 'Représentant bancaire', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(45, '23e7eab8-dda8-11f0-b63a-68f728e7cdfb', 'INSURANCE_REP', 'insurance_representative', 'Représentant Assurance', 'partners_social', 56, 'Représentant assurance', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(46, '23e7ebd3-dda8-11f0-b63a-68f728e7cdfb', 'INTL_PARTNER', 'international_partner', 'Partenaire International', 'partners_social', 70, 'Partenaire international', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(47, '23e7ece5-dda8-11f0-b63a-68f728e7cdfb', 'FOREIGN_EMBASSY', 'foreign_embassy', 'Ambassade Étrangère', 'partners_social', 75, 'Représentant ambassade', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(48, '23e7ee40-dda8-11f0-b63a-68f728e7cdfb', 'INTL_ORG', 'international_organization', 'Organisation Internationale', 'partners_social', 72, 'Organisation internationale', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(49, '23e7ef5f-dda8-11f0-b63a-68f728e7cdfb', 'NGO_REP', 'ngo_representative', 'Représentant ONG', 'partners_social', 65, 'Représentant ONG', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(50, '23eeb651-dda8-11f0-b63a-68f728e7cdfb', 'SYNDICATE_REP', 'syndicate_representative', 'Représentant Syndical', 'partners_social', 55, 'Représentant syndical', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(51, '23eec5d7-dda8-11f0-b63a-68f728e7cdfb', 'PARENTS_ASSOC', 'parents_association', 'Association Parents', 'partners_social', 45, 'Association de parents', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(52, '23eec775-dda8-11f0-b63a-68f728e7cdfb', 'ALUMNI_REP', 'alumni_representative', 'Représentant Anciens Étudiants', 'partners_social', 50, 'Représentant des anciens étudiants', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(53, '23eec8b8-dda8-11f0-b63a-68f728e7cdfb', 'DEV_ASSOC', 'development_association', 'Association Développement', 'partners_social', 48, 'Association de développement', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(54, '23eec9d6-dda8-11f0-b63a-68f728e7cdfb', 'CIVIL_SOCIETY', 'civil_society_organization', 'Organisation Société Civile', 'partners_social', 52, 'Organisation société civile', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(55, '23f6cea6-dda8-11f0-b63a-68f728e7cdfb', 'DOC_CENTER', 'documentation_center', 'Centre Documentation', 'support_services', 50, 'Centre de documentation', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(56, '23f6da60-dda8-11f0-b63a-68f728e7cdfb', 'ORIENTATION_COUNSELOR', 'orientation_counselor', 'Conseiller Orientation', 'support_services', 54, 'Conseiller en orientation', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(57, '23f6dbd8-dda8-11f0-b63a-68f728e7cdfb', 'MEDICAL_SERVICE', 'medical_service', 'Service Médical', 'support_services', 56, 'Personnel médical', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(58, '23f6dd00-dda8-11f0-b63a-68f728e7cdfb', 'PSYCHO_SERVICE', 'psychological_service', 'Service Psychologique', 'support_services', 58, 'Service psychologique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(59, '23f6de1d-dda8-11f0-b63a-68f728e7cdfb', 'RESTAURANT_SERVICE', 'restaurant_service', 'Service Restauration', 'support_services', 42, 'Service restauration', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(60, '23f6df3d-dda8-11f0-b63a-68f728e7cdfb', 'HOUSING_SERVICE', 'housing_service', 'Service Hébergement', 'support_services', 45, 'Service hébergement', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(61, '23f6e05c-dda8-11f0-b63a-68f728e7cdfb', 'SPORTS_SERVICE', 'sports_service', 'Service Sportif', 'support_services', 48, 'Service sportif', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(62, '23f6e171-dda8-11f0-b63a-68f728e7cdfb', 'CULTURAL_SERVICE', 'cultural_service', 'Service Culturel', 'support_services', 46, 'Service culturel', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(63, '23fe3492-dda8-11f0-b63a-68f728e7cdfb', 'BUILDING_SERVICE', 'building_service', 'Service Bâtiments', 'infrastructure_logistics', 52, 'Service des bâtiments', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(64, '23fe442e-dda8-11f0-b63a-68f728e7cdfb', 'TRANSPORT_SERVICE', 'transport_service', 'Service Transport', 'infrastructure_logistics', 48, 'Service transport', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(65, '23fe46b6-dda8-11f0-b63a-68f728e7cdfb', 'TELECOM_SERVICE', 'telecommunication_service', 'Service Télécommunication', 'infrastructure_logistics', 55, 'Service télécommunication', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(66, '23fe48de-dda8-11f0-b63a-68f728e7cdfb', 'ENERGY_SERVICE', 'energy_service', 'Service Énergie', 'infrastructure_logistics', 50, 'Service énergie', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(67, '23fe4b00-dda8-11f0-b63a-68f728e7cdfb', 'FIRE_SAFETY', 'fire_safety_service', 'Service Sécurité Incendie', 'infrastructure_logistics', 53, 'Service sécurité incendie', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(68, '240ae79c-dda8-11f0-b63a-68f728e7cdfb', 'PARLIAMENT_MEMBER', 'parliament_member', 'Membre Parlement', 'legal_regulatory', 85, 'Membre du parlement', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(69, '240afdae-dda8-11f0-b63a-68f728e7cdfb', 'CONSTITUTIONAL_COUNCIL', 'constitutional_council', 'Conseil Constitutionnel', 'legal_regulatory', 90, 'Membre conseil constitutionnel', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(70, '240affdf-dda8-11f0-b63a-68f728e7cdfb', 'SUPREME_COURT', 'supreme_court', 'Cour Suprême', 'legal_regulatory', 88, 'Membre cour suprême', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(71, '240b019a-dda8-11f0-b63a-68f728e7cdfb', 'ADMIN_TRIBUNAL', 'administrative_tribunal', 'Tribunal Administratif', 'legal_regulatory', 80, 'Membre tribunal administratif', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(72, '240b0344-dda8-11f0-b63a-68f728e7cdfb', 'ACCOUNT_COMMISSARY', 'account_commissary', 'Commissaire aux Comptes', 'legal_regulatory', 75, 'Commissaire aux comptes', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(73, '240b0503-dda8-11f0-b63a-68f728e7cdfb', 'LEGAL_ADVISOR', 'legal_advisor', 'Conseiller Juridique', 'legal_regulatory', 70, 'Conseiller juridique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(74, '24151d07-dda8-11f0-b63a-68f728e7cdfb', 'STATE_CONTROL', 'state_control', 'Contrôle Supérieur État', 'control_organizations', 87, 'Contrôle supérieur de l\'État', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(75, '24156e84-dda8-11f0-b63a-68f728e7cdfb', 'FINANCE_INSPECTION', 'finance_inspection', 'Inspection Finances', 'control_organizations', 85, 'Inspection générale des finances', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(76, '241570e9-dda8-11f0-b63a-68f728e7cdfb', 'ANTI_CORRUPTION', 'anti_corruption_commission', 'Commission Anti-Corruption', 'control_organizations', 82, 'Commission anti-corruption', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(77, '241572b3-dda8-11f0-b63a-68f728e7cdfb', 'GOOD_GOVERNANCE', 'good_governance_observatory', 'Observatoire Bonne Gouvernance', 'control_organizations', 78, 'Observatoire bonne gouvernance', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(78, '2423d535-dda8-11f0-b63a-68f728e7cdfb', 'RESEARCH_CENTER_DIR', 'research_center_director', 'Directeur Centre Recherche', 'research_innovation', 80, 'Directeur centre de recherche', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(79, '2423e11c-dda8-11f0-b63a-68f728e7cdfb', 'RESEARCH_LAB_HEAD', 'research_laboratory_head', 'Chef Laboratoire', 'research_innovation', 75, 'Chef laboratoire recherche', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(80, '2423e285-dda8-11f0-b63a-68f728e7cdfb', 'SPECIALIZED_INSTITUTE_DIR', 'specialized_institute_director', 'Directeur Institut Spécialisé', 'research_innovation', 78, 'Directeur institut spécialisé', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(81, '2423e3d8-dda8-11f0-b63a-68f728e7cdfb', 'EXCELLENCE_POLE_DIR', 'excellence_pole_director', 'Directeur Pôle Excellence', 'research_innovation', 82, 'Directeur pôle excellence', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(82, '2423e4f4-dda8-11f0-b63a-68f728e7cdfb', 'BUSINESS_INCUBATOR', 'business_incubator_manager', 'Manager Incubateur', 'research_innovation', 72, 'Manager incubateur', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(83, '2423e618-dda8-11f0-b63a-68f728e7cdfb', 'TECH_PARK_MANAGER', 'technology_park_manager', 'Manager Parc Technologique', 'research_innovation', 74, 'Manager parc technologique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(84, '2423e733-dda8-11f0-b63a-68f728e7cdfb', 'SCIENTIFIC_COMMUNITY', 'scientific_community_member', 'Membre Communauté Scientifique', 'research_innovation', 68, 'Membre communauté scientifique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(85, '2423e84f-dda8-11f0-b63a-68f728e7cdfb', 'ACADEMY_MEMBER', 'academy_member', 'Membre Académie', 'research_innovation', 85, 'Membre académie des sciences', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(86, '2423e965-dda8-11f0-b63a-68f728e7cdfb', 'LEARNED_SOCIETY', 'learned_society_member', 'Membre Société Savante', 'research_innovation', 70, 'Membre société savante', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(87, '2423ea88-dda8-11f0-b63a-68f728e7cdfb', 'EDITORIAL_BOARD', 'editorial_board_member', 'Membre Comité Éditorial', 'research_innovation', 65, 'Membre comité éditorial', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(88, '2423eb99-dda8-11f0-b63a-68f728e7cdfb', 'SCIENTIFIC_EVALUATOR', 'scientific_evaluator', 'Évaluateur Scientifique', 'research_innovation', 67, 'Évaluateur scientifique', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07'),
(89, '2423ecb5-dda8-11f0-b63a-68f728e7cdfb', 'EXPERT_CONSULTANT', 'expert_consultant', 'Expert Consultant', 'research_innovation', 72, 'Expert consultant', NULL, NULL, 1, 0, NULL, 'all', NULL, '2025-12-20 13:31:07', '2025-12-20 13:31:07');

-- --------------------------------------------------------

--
-- Structure de la table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` bigint UNSIGNED NOT NULL,
  `permission_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_role_permission` (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `created_at`) VALUES
(1, 1, 1, '2025-11-24 06:15:14'),
(2, 1, 2, '2025-11-24 06:15:14'),
(3, 1, 3, '2025-11-24 06:15:14'),
(4, 1, 4, '2025-11-24 06:15:14'),
(5, 1, 5, '2025-11-24 06:15:14'),
(6, 1, 6, '2025-11-24 06:15:14'),
(7, 1, 7, '2025-11-24 06:15:14'),
(8, 1, 8, '2025-11-24 06:15:14'),
(9, 1, 9, '2025-11-24 06:15:14'),
(10, 1, 10, '2025-11-24 06:15:14'),
(11, 2, 1, '2025-11-24 06:15:14'),
(12, 2, 2, '2025-11-24 06:15:14'),
(13, 2, 4, '2025-11-24 06:15:14'),
(14, 2, 5, '2025-11-24 06:15:14'),
(15, 2, 6, '2025-11-24 06:15:14'),
(16, 2, 7, '2025-11-24 06:15:14'),
(17, 2, 8, '2025-11-24 06:15:14'),
(18, 3, 1, '2025-11-24 06:15:14'),
(19, 3, 3, '2025-11-24 06:15:14'),
(20, 3, 4, '2025-11-24 06:15:14'),
(21, 3, 5, '2025-11-24 06:15:14'),
(22, 3, 6, '2025-11-24 06:15:14'),
(23, 3, 7, '2025-11-24 06:15:14'),
(24, 4, 3, '2025-11-24 06:15:14'),
(25, 4, 4, '2025-11-24 06:15:14'),
(26, 4, 5, '2025-11-24 06:15:14'),
(27, 4, 9, '2025-11-24 06:15:14'),
(28, 4, 10, '2025-11-24 06:15:14'),
(29, 5, 3, '2025-11-24 06:15:14'),
(30, 5, 9, '2025-11-24 06:15:14'),
(31, 5, 10, '2025-11-24 06:15:14'),
(32, 6, 9, '2025-11-24 06:15:14'),
(33, 6, 10, '2025-11-24 06:15:14'),
(34, 7, 6, '2025-11-24 06:15:14'),
(35, 7, 9, '2025-11-24 06:15:14');

-- --------------------------------------------------------

--
-- Structure de la table `security_logs`
--

DROP TABLE IF EXISTS `security_logs`;
CREATE TABLE IF NOT EXISTS `security_logs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `event_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('low','medium','high','critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_data` json DEFAULT NULL,
  `response_status` int DEFAULT NULL,
  `is_suspicious` tinyint(1) NOT NULL DEFAULT '0',
  `is_blocked` tinyint(1) NOT NULL DEFAULT '0',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_is_suspicious` (`is_suspicious`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sms_queue`
--

DROP TABLE IF EXISTS `sms_queue`;
CREATE TABLE IF NOT EXISTS `sms_queue` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `to_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('transactional','marketing','otp','notification') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'transactional',
  `priority` enum('low','normal','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `status` enum('pending','processing','sent','failed','delivered') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider_message_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attempts` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `max_attempts` tinyint UNSIGNED NOT NULL DEFAULT '3',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cost` decimal(10,2) DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_to_phone` (`to_phone`),
  KEY `idx_scheduled_at` (`scheduled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `student_courses`
--

DROP TABLE IF EXISTS `student_courses`;
CREATE TABLE IF NOT EXISTS `student_courses` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_profile_id` bigint UNSIGNED NOT NULL,
  `course_id` bigint UNSIGNED NOT NULL,
  `enrollment_id` bigint UNSIGNED NOT NULL,
  `registration_status` enum('registered','dropped','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'registered',
  `registration_date` date NOT NULL,
  `final_grade` decimal(5,2) DEFAULT NULL,
  `grade_points` decimal(3,2) DEFAULT NULL,
  `credits_earned` decimal(3,1) DEFAULT '0.0',
  `attendance_count` int UNSIGNED DEFAULT '0',
  `total_sessions` int UNSIGNED DEFAULT '0',
  `assignment_grade` decimal(5,2) DEFAULT NULL,
  `midterm_grade` decimal(5,2) DEFAULT NULL,
  `final_exam_grade` decimal(5,2) DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_student_course_enrollment` (`student_profile_id`,`course_id`,`enrollment_id`),
  KEY `idx_student_profile` (`student_profile_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_enrollment` (`enrollment_id`),
  KEY `idx_status` (`registration_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `student_discipline`
--

DROP TABLE IF EXISTS `student_discipline`;
CREATE TABLE IF NOT EXISTS `student_discipline` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_profile_id` bigint UNSIGNED NOT NULL,
  `incident_type` enum('attendance','behavior','academic_honesty','misconduct','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity_level` enum('warning','minor','major','severe','critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `incident_date` date NOT NULL,
  `incident_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `witnesses` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `evidence` json DEFAULT NULL,
  `sanction_type` enum('none','warning','probation','suspension','expulsion','community_service','counseling') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'none',
  `sanction_duration` int UNSIGNED DEFAULT NULL,
  `sanction_start_date` date DEFAULT NULL,
  `sanction_end_date` date DEFAULT NULL,
  `status` enum('pending','investigation','resolved','appealed','closed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `reported_by` bigint UNSIGNED NOT NULL,
  `investigated_by` bigint UNSIGNED DEFAULT NULL,
  `resolved_by` bigint UNSIGNED DEFAULT NULL,
  `resolution_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `appeal_deadline` date DEFAULT NULL,
  `appeal_status` enum('none','filed','under_review','upheld','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'none',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `idx_student_profile` (`student_profile_id`),
  KEY `idx_incident_type` (`incident_type`),
  KEY `idx_severity` (`severity_level`),
  KEY `idx_status` (`status`),
  KEY `idx_incident_date` (`incident_date`),
  KEY `reported_by` (`reported_by`),
  KEY `investigated_by` (`investigated_by`),
  KEY `resolved_by` (`resolved_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `student_documents`
--

DROP TABLE IF EXISTS `student_documents`;
CREATE TABLE IF NOT EXISTS `student_documents` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_profile_id` bigint UNSIGNED NOT NULL,
  `document_type` enum('birth_certificate','national_id','transcript','diploma','certificate','medical_form','insurance','photo','signature','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint UNSIGNED DEFAULT NULL,
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `upload_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiry_date` date DEFAULT NULL,
  `status` enum('pending','verified','rejected','expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `verified_by` bigint UNSIGNED DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `idx_student_profile` (`student_profile_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_status` (`status`),
  KEY `idx_upload_date` (`upload_date`),
  KEY `verified_by` (`verified_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `student_enrollments`
--

DROP TABLE IF EXISTS `student_enrollments`;
CREATE TABLE IF NOT EXISTS `student_enrollments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_profile_id` bigint UNSIGNED NOT NULL,
  `academic_year_id` bigint UNSIGNED NOT NULL,
  `semester` enum('semester1','semester2') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `program_id` bigint UNSIGNED NOT NULL,
  `level` enum('licence1','licence2','licence3','master1','master2','doctorat1','doctorat2','doctorat3') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `enrollment_status` enum('enrolled','deferred','suspended','withdrawn','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'enrolled',
  `enrollment_date` date NOT NULL,
  `completion_date` date DEFAULT NULL,
  `gpa_semester` decimal(3,2) DEFAULT NULL,
  `credits_attempted` int UNSIGNED DEFAULT '0',
  `credits_earned` int UNSIGNED DEFAULT '0',
  `attendance_rate` decimal(5,2) DEFAULT NULL,
  `tuition_fee_status` enum('unpaid','partial','paid','scholarship','exempt') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'unpaid',
  `tuition_amount` decimal(10,2) DEFAULT '0.00',
  `amount_paid` decimal(10,2) DEFAULT '0.00',
  `scholarship_amount` decimal(10,2) DEFAULT '0.00',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_student_semester` (`student_profile_id`,`academic_year_id`,`semester`),
  KEY `idx_student_profile` (`student_profile_id`),
  KEY `idx_academic_year` (`academic_year_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_level` (`level`),
  KEY `idx_status` (`enrollment_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `student_profiles`
--

DROP TABLE IF EXISTS `student_profiles`;
CREATE TABLE IF NOT EXISTS `student_profiles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `program_id` bigint UNSIGNED NOT NULL,
  `academic_year_id` bigint UNSIGNED NOT NULL,
  `current_level` enum('licence1','licence2','licence3','master1','master2','doctorat1','doctorat2','doctorat3') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `enrollment_date` date NOT NULL,
  `expected_graduation_date` date DEFAULT NULL,
  `actual_graduation_date` date DEFAULT NULL,
  `student_status` enum('enrolled','deferred','suspended','graduated','withdrawn','expelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'enrolled',
  `admission_type` enum('regular','transfer','exchange','special') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'regular',
  `scholarship_status` enum('none','partial','full','government','merit') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scholarship_details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `gpa` decimal(3,2) DEFAULT NULL,
  `total_credits_earned` int UNSIGNED DEFAULT '0',
  `total_credits_required` int UNSIGNED DEFAULT NULL,
  `class_rank` int UNSIGNED DEFAULT NULL,
  `honors` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `disciplinary_records` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `graduation_thesis_title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thesis_supervisor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thesis_defense_date` date DEFAULT NULL,
  `alumni_status` tinyint(1) NOT NULL DEFAULT '0',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `unique_user` (`user_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_academic_year` (`academic_year_id`),
  KEY `idx_current_level` (`current_level`),
  KEY `idx_student_status` (`student_status`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `student_profiles`
--

INSERT INTO `student_profiles` (`id`, `user_id`, `program_id`, `academic_year_id`, `current_level`, `enrollment_date`, `expected_graduation_date`, `actual_graduation_date`, `student_status`, `admission_type`, `scholarship_status`, `scholarship_details`, `gpa`, `total_credits_earned`, `total_credits_required`, `class_rank`, `honors`, `disciplinary_records`, `graduation_thesis_title`, `thesis_supervisor`, `thesis_defense_date`, `alumni_status`, `metadata`, `created_at`, `updated_at`) VALUES
(6, 30, 19, 1, 'licence1', '2025-12-15', NULL, NULL, '', 'regular', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2025-12-15 01:48:15', '2025-12-15 19:36:39'),
(7, 31, 19, 1, '', '2025-12-15', NULL, NULL, '', 'regular', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2025-12-15 01:48:21', '2025-12-15 19:36:50'),
(8, 32, 19, 1, 'licence1', '2025-12-15', NULL, NULL, 'enrolled', 'regular', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2025-12-15 01:48:41', '2025-12-15 01:48:41'),
(9, 33, 19, 1, '', '2025-12-15', NULL, NULL, '', 'regular', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2025-12-15 01:49:32', '2025-12-18 08:00:41'),
(10, 34, 19, 1, 'licence2', '2025-12-15', NULL, NULL, '', 'regular', NULL, NULL, 3.50, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2025-12-15 01:51:44', '2025-12-15 01:52:05');

-- --------------------------------------------------------

--
-- Structure de la table `student_scholarships`
--

DROP TABLE IF EXISTS `student_scholarships`;
CREATE TABLE IF NOT EXISTS `student_scholarships` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_profile_id` bigint UNSIGNED NOT NULL,
  `scholarship_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `scholarship_type` enum('merit','need','athletic','government','private','institutional') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount_per_year` decimal(10,2) DEFAULT '0.00',
  `amount_per_semester` decimal(10,2) DEFAULT '0.00',
  `coverage_percentage` decimal(5,2) DEFAULT '0.00',
  `duration_years` int UNSIGNED DEFAULT NULL,
  `renewal_conditions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `academic_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `application_date` date DEFAULT NULL,
  `award_date` date DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('applied','awarded','active','suspended','terminated','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'applied',
  `renewal_status` enum('not_applicable','pending_renewal','renewed','not_renewed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'not_applicable',
  `gpa_requirement` decimal(3,2) DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `idx_student_profile` (`student_profile_id`),
  KEY `idx_scholarship_type` (`scholarship_type`),
  KEY `idx_status` (`status`),
  KEY `idx_award_date` (`award_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `student_statistics`
--

DROP TABLE IF EXISTS `student_statistics`;
CREATE TABLE IF NOT EXISTS `student_statistics` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `faculty_id` bigint UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `program_id` bigint UNSIGNED DEFAULT NULL,
  `academic_year_id` bigint UNSIGNED NOT NULL,
  `level` enum('licence1','licence2','licence3','master1','master2','doctorat1','doctorat2','doctorat3','all') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` enum('male','female','all') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'all',
  `total_students` int UNSIGNED NOT NULL DEFAULT '0',
  `active_students` int UNSIGNED NOT NULL DEFAULT '0',
  `graduated_students` int UNSIGNED NOT NULL DEFAULT '0',
  `withdrawn_students` int UNSIGNED NOT NULL DEFAULT '0',
  `suspended_students` int UNSIGNED NOT NULL DEFAULT '0',
  `average_gpa` decimal(3,2) DEFAULT NULL,
  `average_age` decimal(4,1) DEFAULT NULL,
  `international_students` int UNSIGNED NOT NULL DEFAULT '0',
  `scholarship_students` int UNSIGNED NOT NULL DEFAULT '0',
  `statistics_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_statistic_record` (`institution_id`,`faculty_id`,`department_id`,`program_id`,`academic_year_id`,`level`,`gender`,`statistics_date`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_faculty` (`faculty_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_academic_year` (`academic_year_id`),
  KEY `idx_level` (`level`),
  KEY `idx_statistics_date` (`statistics_date`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sync_logs`
--

DROP TABLE IF EXISTS `sync_logs`;
CREATE TABLE IF NOT EXISTS `sync_logs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` bigint UNSIGNED NOT NULL,
  `sync_type` enum('full','incremental','manual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `direction` enum('push','pull','bidirectional') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `records_processed` int UNSIGNED NOT NULL DEFAULT '0',
  `records_created` int UNSIGNED NOT NULL DEFAULT '0',
  `records_updated` int UNSIGNED NOT NULL DEFAULT '0',
  `records_failed` int UNSIGNED NOT NULL DEFAULT '0',
  `status` enum('pending','in_progress','completed','failed','partial') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `duration_seconds` int UNSIGNED DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_status` (`status`),
  KEY `idx_started_at` (`started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `system_health`
--

DROP TABLE IF EXISTS `system_health`;
CREATE TABLE IF NOT EXISTS `system_health` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `check_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('healthy','degraded','down','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `response_time_ms` int UNSIGNED DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `details` json DEFAULT NULL,
  `checked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_check_type` (`check_type`),
  KEY `idx_status` (`status`),
  KEY `idx_checked_at` (`checked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `setting_type` enum('string','number','boolean','json','text') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'string',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_public` tinyint(1) DEFAULT '0',
  `is_editable` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_setting_key` (`setting_key`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `system_settings`
--

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `setting_type`, `category`, `description`, `is_public`, `is_editable`, `created_at`, `updated_at`) VALUES
(1, 'app_name', 'MyCampus', 'string', 'general', 'Nom de l\'application', 1, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(2, 'app_version', '3.0.0', 'string', 'general', 'Version de l\'application', 1, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(3, 'maintenance_mode', 'false', 'boolean', 'system', 'Mode maintenance', 0, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(4, 'registration_enabled', 'true', 'boolean', 'auth', 'Inscription activée', 1, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(5, 'max_file_size_mb', '50', 'number', 'uploads', 'Taille max fichier (MB)', 1, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(6, 'session_lifetime_minutes', '1440', 'number', 'auth', 'Durée session (minutes)', 0, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(7, 'password_min_length', '8', 'number', 'auth', 'Longueur min mot de passe', 1, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(8, 'otp_expiry_minutes', '10', 'number', 'auth', 'Expiration OTP (minutes)', 0, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(9, 'max_login_attempts', '5', 'number', 'security', 'Tentatives connexion max', 0, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(10, 'notification_retention_days', '90', 'number', 'notifications', 'Rétention notifications (jours)', 0, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14'),
(11, 'supported_languages', '[\"fr\", \"en\"]', 'json', 'general', 'Langues supportées', 1, 1, '2025-11-24 06:15:14', '2025-11-24 06:15:14');

-- --------------------------------------------------------

--
-- Structure de la table `teacher_profiles`
--

DROP TABLE IF EXISTS `teacher_profiles`;
CREATE TABLE IF NOT EXISTS `teacher_profiles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `employee_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` enum('professor','associate_professor','assistant_professor','lecturer','teaching_assistant','researcher','visiting_professor','emeritus') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employment_type` enum('full_time','part_time','contract','visiting','retired') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'full_time',
  `hire_date` date NOT NULL,
  `tenure_date` date DEFAULT NULL,
  `specialization` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `research_interests` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `qualifications` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `publications_count` int UNSIGNED NOT NULL DEFAULT '0',
  `publications` json DEFAULT NULL,
  `awards` json DEFAULT NULL,
  `office_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `office_hours` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consultation_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `research_group` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `courses_taught` json DEFAULT NULL,
  `supervision_capacity` tinyint UNSIGNED DEFAULT '5',
  `current_students_supervised` tinyint UNSIGNED DEFAULT '0',
  `status` enum('active','on_leave','sabbatical','retired','resigned') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `unique_user` (`user_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  UNIQUE KEY `unique_employee_id` (`employee_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_position` (`position`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
CREATE TABLE IF NOT EXISTS `tokens` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token_type` enum('access','refresh','password_reset','email_verification') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token_type` (`token_type`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_revoked` (`revoked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `matricule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `auth_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token_expires_at` datetime DEFAULT NULL,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `place_of_birth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Camerounaise',
  `profile_photo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_picture` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_photo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Cameroun',
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_relationship` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_role` enum('student','teacher','admin_local','admin_national','superadmin','leader','staff','alumni','moderator','guest','invite','ministry_official','regulatory_inspector','accreditation_officer','interministerial_coordinator','financial_controller','public_service_director','rector','vice_rector','secretary_general','dean','school_director','institute_director','department_head','section_head','program_coordinator','professor_titular','professor_associate','master_conference','course_holder','assistant','monitor','temporary_teacher','visiting_professor','postdoc_researcher','administrative_agent','secretary','accountant','librarian','lab_technician','maintenance_engineer','security_agent','cleaning_staff','driver','it_support','student_executive','class_delegate','faculty_delegate','residence_delegate','cultural_association_leader','club_president','promotion_coordinator','economic_partner','chamber_commerce','employer_organization','bank_representative','insurance_representative','international_partner','foreign_embassy','international_organization','ngo_representative','syndicate_representative','parents_association','alumni_representative','development_association','civil_society_organization','documentation_center','orientation_counselor','medical_service','psychological_service','restaurant_service','housing_service','sports_service','cultural_service','building_service','transport_service','telecommunication_service','energy_service','fire_safety_service','parliament_member','constitutional_council','supreme_court','administrative_tribunal','account_commissary','legal_advisor','state_control','finance_inspection','anti_corruption_commission','good_governance_observatory','research_center_director','research_laboratory_head','specialized_institute_director','excellence_pole_director','business_incubator_manager','technology_park_manager','scientific_community_member','academy_member','learned_society_member','editorial_board_member','scientific_evaluator','expert_consultant') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student',
  `academic_year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` enum('L1','L2','L3','M1','M2','D1','D2','D3','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'L1',
  `account_status` enum('active','inactive','suspended','banned','pending_verification','graduated','withdrawn') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending_verification',
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `language_preference` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fr',
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Africa/Douala',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_device` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_active_at` timestamp NULL DEFAULT NULL,
  `login_count` int UNSIGNED NOT NULL DEFAULT '0',
  `failed_login_attempts` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `locked_until` timestamp NULL DEFAULT NULL,
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT '0',
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `two_factor_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notification_preferences` json DEFAULT NULL,
  `privacy_settings` json DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `terms_accepted_at` timestamp NULL DEFAULT NULL,
  `terms_version` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gdpr_consent_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `preinscription_id` bigint UNSIGNED DEFAULT NULL COMMENT 'ID de la préinscription validée associée à cet utilisateur',
  `preinscription_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Code unique de la préinscription validée',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  UNIQUE KEY `unique_email` (`email`),
  UNIQUE KEY `unique_matricule_institution` (`matricule`,`institution_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_primary_role` (`primary_role`),
  KEY `idx_account_status` (`account_status`),
  KEY `idx_phone` (`phone`),
  KEY `idx_last_login` (`last_login_at`),
  KEY `idx_deleted_at` (`deleted_at`),
  KEY `idx_active` (`is_active`),
  KEY `idx_users_institution_role_status` (`institution_id`,`primary_role`,`account_status`),
  KEY `idx_users_institution_active` (`institution_id`,`is_active`),
  KEY `idx_auth_token` (`auth_token`),
  KEY `idx_token_expires_at` (`token_expires_at`),
  KEY `idx_preinscription_id` (`preinscription_id`),
  KEY `idx_preinscription_unique_code` (`preinscription_unique_code`),
  KEY `idx_users_institution_role` (`institution_id`,`primary_role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_contacts`
--

DROP TABLE IF EXISTS `user_contacts`;
CREATE TABLE IF NOT EXISTS `user_contacts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `contact_user_id` int NOT NULL,
  `status` enum('pending','accepted','blocked') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_contact` (`user_id`,`contact_user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_contact_user_id` (`contact_user_id`),
  KEY `idx_status` (`status`)
) ;

--
-- Déchargement des données de la table `user_contacts`
--

INSERT INTO `user_contacts` (`id`, `user_id`, `contact_user_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 'accepted', '2025-12-11 11:21:11', '2025-12-11 11:21:11'),
(2, 1, 2, 'accepted', '2025-12-11 11:21:11', '2025-12-11 11:21:11'),
(3, 1, 7, 'accepted', '2025-12-13 09:21:57', '2025-12-13 09:21:57'),
(4, 7, 1, 'accepted', '2025-12-13 09:21:57', '2025-12-13 09:21:57'),
(5, 1, 3, 'accepted', '2025-12-14 07:29:23', '2025-12-14 07:29:23'),
(6, 3, 1, 'accepted', '2025-12-14 07:29:23', '2025-12-14 07:29:23'),
(7, 1, 39, 'accepted', '2025-12-15 02:49:33', '2025-12-15 02:49:33'),
(8, 39, 1, 'accepted', '2025-12-15 02:49:33', '2025-12-15 02:49:33');

-- --------------------------------------------------------

--
-- Structure de la table `user_groups`
--

DROP TABLE IF EXISTS `user_groups`;
CREATE TABLE IF NOT EXISTS `user_groups` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `program_id` bigint UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `parent_group_id` bigint UNSIGNED DEFAULT NULL,
  `group_type` enum('program','filiere','level','year','club','association','project','sport','cultural','academic','department','faculty','national','inter_university','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `visibility` enum('public','private','secret','restricted','official') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cover_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `academic_level` enum('licence1','licence2','licence3','master1','master2','doctorat','all','L1','L2','L3','M1','M2','D1','D2','D3') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `academic_year_id` bigint UNSIGNED DEFAULT NULL,
  `is_official` tinyint(1) NOT NULL DEFAULT '0',
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_national` tinyint(1) NOT NULL DEFAULT '0',
  `max_members` int UNSIGNED DEFAULT '0',
  `current_members_count` int UNSIGNED NOT NULL DEFAULT '0',
  `join_approval_required` tinyint(1) NOT NULL DEFAULT '0',
  `allow_member_posts` tinyint(1) NOT NULL DEFAULT '1',
  `allow_member_invites` tinyint(1) NOT NULL DEFAULT '0',
  `rules` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tags` json DEFAULT NULL,
  `settings` json DEFAULT NULL,
  `status` enum('active','archived','suspended','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_by` bigint UNSIGNED NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  UNIQUE KEY `unique_slug_institution` (`slug`,`institution_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_parent_group` (`parent_group_id`),
  KEY `idx_group_type` (`group_type`),
  KEY `idx_visibility` (`visibility`),
  KEY `idx_is_official` (`is_official`),
  KEY `idx_is_national` (`is_national`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  KEY `fk_user_groups_academic_year` (`academic_year_id`),
  KEY `idx_user_groups_institution_type_status` (`institution_id`,`group_type`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `user_groups`
--

INSERT INTO `user_groups` (`id`, `uuid`, `institution_id`, `program_id`, `department_id`, `parent_group_id`, `group_type`, `visibility`, `name`, `slug`, `description`, `cover_image_url`, `cover_url`, `icon_url`, `avatar_url`, `academic_level`, `academic_year_id`, `is_official`, `is_verified`, `is_national`, `max_members`, `current_members_count`, `join_approval_required`, `allow_member_posts`, `allow_member_invites`, `rules`, `tags`, `settings`, `status`, `created_by`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 'f7977c4d-eec0-11f0-9ea5-68f728e7cdfb', 1, 24, 47, 1, 'custom', 'public', 'Mon premier groupe', 'mon-premier-groupe-1', 'Groupe créé pour les tests de l’utilisateur 1', NULL, NULL, NULL, NULL, 'all', 1, 0, 0, 0, 200, 1, 0, 1, 1, 'Respectez les règles du groupe', '[\"test\", \"campus\"]', '{\"allow_calls\": true, \"allow_files\": true}', 'active', 1, NULL, '2026-01-11 07:41:40', '2026-01-11 07:43:05');

-- --------------------------------------------------------

--
-- Structure de la table `user_presence`
--

DROP TABLE IF EXISTS `user_presence`;
CREATE TABLE IF NOT EXISTS `user_presence` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `is_online` tinyint(1) NOT NULL DEFAULT '0',
  `last_seen` timestamp NULL DEFAULT NULL,
  `last_activity` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('online','away','busy','offline') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'offline',
  `device_type` enum('mobile','web','desktop') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_presence` (`user_id`),
  KEY `idx_is_online` (`is_online`),
  KEY `idx_last_activity` (`last_activity`),
  KEY `idx_status` (`status`),
  KEY `idx_online_users` (`is_online`,`last_activity`),
  KEY `idx_user_status_lookup` (`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE IF NOT EXISTS `user_roles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `role_id` bigint UNSIGNED NOT NULL,
  `scope` enum('institution','faculty','department','program','group','national','global') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'institution',
  `scope_id` bigint UNSIGNED DEFAULT NULL,
  `granted_by` bigint UNSIGNED DEFAULT NULL,
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `permissions` json DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_role_scope` (`user_id`,`role_id`,`scope`,`scope_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `granted_by` (`granted_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_role_assignments`
--

DROP TABLE IF EXISTS `user_role_assignments`;
CREATE TABLE IF NOT EXISTS `user_role_assignments` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `role_id` bigint UNSIGNED NOT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `faculty_id` bigint UNSIGNED DEFAULT NULL,
  `assigned_by` bigint UNSIGNED NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `context` json DEFAULT NULL COMMENT 'Contexte spécifique du rôle',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_faculty` (`faculty_id`),
  KEY `idx_assigned_by` (`assigned_by`),
  KEY `idx_active` (`is_active`),
  KEY `idx_primary` (`is_primary`),
  KEY `idx_ura_user_role_active` (`user_id`,`role_id`,`is_active`),
  KEY `idx_ura_institution_role` (`institution_id`,`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `user_role_assignments`
--

INSERT INTO `user_role_assignments` (`id`, `uuid`, `user_id`, `role_id`, `institution_id`, `department_id`, `faculty_id`, `assigned_by`, `assigned_at`, `expires_at`, `is_primary`, `is_active`, `context`, `created_at`, `updated_at`) VALUES
(1, '461c21f8-dda8-11f0-b63a-68f728e7cdfb', 47, 15, 1, NULL, NULL, 1, '2025-12-20 13:32:04', NULL, 0, 1, NULL, '2025-12-20 13:32:04', '2025-12-20 13:32:04'),
(2, '462651fd-dda8-11f0-b63a-68f728e7cdfb', 49, 17, 1, NULL, NULL, 1, '2025-12-20 13:32:04', NULL, 0, 1, NULL, '2025-12-20 13:32:04', '2025-12-20 13:32:04'),
(3, '4630c702-dda8-11f0-b63a-68f728e7cdfb', 64, 34, 1, NULL, NULL, 1, '2025-12-20 13:32:05', NULL, 0, 1, NULL, '2025-12-20 13:32:05', '2025-12-20 13:32:05');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `user_role_stats`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `user_role_stats`;
CREATE TABLE IF NOT EXISTS `user_role_stats` (
`role_name` varchar(255)
,`role_level` tinyint unsigned
,`user_count` bigint
,`active_users` bigint
);

-- --------------------------------------------------------

--
-- Structure de la table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
CREATE TABLE IF NOT EXISTS `user_sessions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `session_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `platform` enum('android','ios','web','desktop','api') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_activity_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_token` (`session_token`),
  UNIQUE KEY `unique_session_token` (`session_token`),
  KEY `idx_user` (`user_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_settings`
--

DROP TABLE IF EXISTS `user_settings`;
CREATE TABLE IF NOT EXISTS `user_settings` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `notification_email` tinyint(1) DEFAULT '1',
  `notification_push` tinyint(1) DEFAULT '1',
  `notification_sms` tinyint(1) DEFAULT '0',
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'fr',
  `theme` enum('light','dark','auto') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'light',
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Africa/Douala',
  `privacy_profile` enum('public','friends','private') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'public',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_settings` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `vw_pre_registration_summary`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `vw_pre_registration_summary`;
CREATE TABLE IF NOT EXISTS `vw_pre_registration_summary` (
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_active_users`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_active_users`;
CREATE TABLE IF NOT EXISTS `v_active_users` (
`id` bigint unsigned
,`uuid` char(36)
,`email` varchar(255)
,`first_name` varchar(100)
,`last_name` varchar(100)
,`matricule` varchar(50)
,`level` enum('L1','L2','L3','M1','M2','D1','D2','D3','other')
,`primary_role` enum('student','teacher','admin_local','admin_national','superadmin','leader','staff','alumni','moderator','guest','invite','ministry_official','regulatory_inspector','accreditation_officer','interministerial_coordinator','financial_controller','public_service_director','rector','vice_rector','secretary_general','dean','school_director','institute_director','department_head','section_head','program_coordinator','professor_titular','professor_associate','master_conference','course_holder','assistant','monitor','temporary_teacher','visiting_professor','postdoc_researcher','administrative_agent','secretary','accountant','librarian','lab_technician','maintenance_engineer','security_agent','cleaning_staff','driver','it_support','student_executive','class_delegate','faculty_delegate','residence_delegate','cultural_association_leader','club_president','promotion_coordinator','economic_partner','chamber_commerce','employer_organization','bank_representative','insurance_representative','international_partner','foreign_embassy','international_organization','ngo_representative','syndicate_representative','parents_association','alumni_representative','development_association','civil_society_organization','documentation_center','orientation_counselor','medical_service','psychological_service','restaurant_service','housing_service','sports_service','cultural_service','building_service','transport_service','telecommunication_service','energy_service','fire_safety_service','parliament_member','constitutional_council','supreme_court','administrative_tribunal','account_commissary','legal_advisor','state_control','finance_inspection','anti_corruption_commission','good_governance_observatory','research_center_director','research_laboratory_head','specialized_institute_director','excellence_pole_director','business_incubator_manager','technology_park_manager','scientific_community_member','academy_member','learned_society_member','editorial_board_member','scientific_evaluator','expert_consultant')
,`account_status` enum('active','inactive','suspended','banned','pending_verification','graduated','withdrawn')
,`institution_id` bigint unsigned
,`institution_name` varchar(255)
,`department_name` varchar(255)
,`last_login_at` timestamp
,`last_active_at` timestamp
,`login_count` int unsigned
,`activity_status` varchar(8)
,`groups_count` bigint
,`posts_count` bigint
,`comments_count` bigint
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_group_stats`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_group_stats`;
CREATE TABLE IF NOT EXISTS `v_group_stats` (
`id` bigint unsigned
,`uuid` char(36)
,`name` varchar(255)
,`group_type` enum('program','filiere','level','year','club','association','project','sport','cultural','academic','department','faculty','national','inter_university','custom')
,`visibility` enum('public','private','secret','restricted','official')
,`is_official` tinyint(1)
,`current_members_count` int unsigned
,`institution_id` bigint unsigned
,`institution_name` varchar(255)
,`actual_members` bigint
,`active_members` bigint
,`leaders_count` bigint
,`posts_count` bigint
,`posts_last_7d` bigint
,`posts_last_30d` bigint
,`last_post_at` timestamp
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_institution_stats`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_institution_stats`;
CREATE TABLE IF NOT EXISTS `v_institution_stats` (
`id` bigint unsigned
,`code` varchar(20)
,`name` varchar(255)
,`type` enum('public','private','professional','research')
,`status` enum('active','inactive','suspended')
,`total_users` bigint
,`total_students` bigint
,`total_teachers` bigint
,`total_faculties` bigint
,`total_departments` bigint
,`total_programs` bigint
,`total_groups` bigint
,`active_users_7d` bigint
,`active_users_30d` bigint
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_institution_summary`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_institution_summary`;
CREATE TABLE IF NOT EXISTS `v_institution_summary` (
`id` bigint unsigned
,`uuid` char(36)
,`name` varchar(255)
,`code` varchar(20)
,`city` varchar(100)
,`region` varchar(100)
,`total_users` bigint
,`total_departments` bigint
,`total_groups` bigint
,`total_announcements` bigint
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_preinscriptions_stats`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_preinscriptions_stats`;
CREATE TABLE IF NOT EXISTS `v_preinscriptions_stats` (
`faculty` varchar(255)
,`total_count` bigint
,`pending_count` bigint
,`accepted_count` bigint
,`rejected_count` bigint
,`paid_count` bigint
,`total_revenue` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_preinscriptions_summary`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_preinscriptions_summary`;
CREATE TABLE IF NOT EXISTS `v_preinscriptions_summary` (
`id` bigint unsigned
,`unique_code` varchar(50)
,`faculty` varchar(255)
,`last_name` varchar(100)
,`first_name` varchar(100)
,`email` varchar(255)
,`phone_number` varchar(20)
,`desired_program` varchar(255)
,`study_level` enum('LICENCE','MASTER','DOCTORAT','DUT','BTS','MASTER_PRO','DEUST','AUTRE')
,`status` enum('pending','under_review','accepted','rejected','cancelled','deferred','waitlisted')
,`payment_status` enum('pending','paid','confirmed','refunded','partial')
,`submission_date` timestamp
,`status_fr` varchar(12)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_role_stats_by_institution`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_role_stats_by_institution`;
CREATE TABLE IF NOT EXISTS `v_role_stats_by_institution` (
`institution_id` bigint unsigned
,`institution_name` varchar(255)
,`role_category` enum('national_institutional','university_hierarchy','teaching_staff','administrative_technical','student_representation','partners_social','support_services','infrastructure_logistics','legal_regulatory','control_organizations','research_innovation','academic','administrative')
,`user_count` bigint
,`avg_role_level` decimal(7,4)
,`max_role_level` tinyint unsigned
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_user_roles_complete`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_user_roles_complete`;
CREATE TABLE IF NOT EXISTS `v_user_roles_complete` (
`user_id` bigint unsigned
,`user_uuid` char(36)
,`first_name` varchar(100)
,`last_name` varchar(100)
,`email` varchar(255)
,`primary_role` enum('student','teacher','admin_local','admin_national','superadmin','leader','staff','alumni','moderator','guest','invite','ministry_official','regulatory_inspector','accreditation_officer','interministerial_coordinator','financial_controller','public_service_director','rector','vice_rector','secretary_general','dean','school_director','institute_director','department_head','section_head','program_coordinator','professor_titular','professor_associate','master_conference','course_holder','assistant','monitor','temporary_teacher','visiting_professor','postdoc_researcher','administrative_agent','secretary','accountant','librarian','lab_technician','maintenance_engineer','security_agent','cleaning_staff','driver','it_support','student_executive','class_delegate','faculty_delegate','residence_delegate','cultural_association_leader','club_president','promotion_coordinator','economic_partner','chamber_commerce','employer_organization','bank_representative','insurance_representative','international_partner','foreign_embassy','international_organization','ngo_representative','syndicate_representative','parents_association','alumni_representative','development_association','civil_society_organization','documentation_center','orientation_counselor','medical_service','psychological_service','restaurant_service','housing_service','sports_service','cultural_service','building_service','transport_service','telecommunication_service','energy_service','fire_safety_service','parliament_member','constitutional_council','supreme_court','administrative_tribunal','account_commissary','legal_advisor','state_control','finance_inspection','anti_corruption_commission','good_governance_observatory','research_center_director','research_laboratory_head','specialized_institute_director','excellence_pole_director','business_incubator_manager','technology_park_manager','scientific_community_member','academy_member','learned_society_member','editorial_board_member','scientific_evaluator','expert_consultant')
,`institution_id` bigint unsigned
,`institution_name` varchar(255)
,`role_id` bigint unsigned
,`role_code` varchar(50)
,`role_name` varchar(255)
,`role_display_name` varchar(255)
,`role_category` enum('national_institutional','university_hierarchy','teaching_staff','administrative_technical','student_representation','partners_social','support_services','infrastructure_logistics','legal_regulatory','control_organizations','research_innovation','academic','administrative')
,`role_level` tinyint unsigned
,`is_primary` tinyint(1)
,`assignment_active` tinyint(1)
,`assigned_at` timestamp
,`expires_at` timestamp
,`structure_name` varchar(255)
,`structure_type` enum('ministry','regulatory_body','coordination_committee','university','faculty','school','institute','department','research_center','administrative_unit','student_organization','partner_organization','control_body','support_service')
);

-- --------------------------------------------------------

--
-- Structure de la table `webhooks`
--

DROP TABLE IF EXISTS `webhooks`;
CREATE TABLE IF NOT EXISTS `webhooks` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `events` json NOT NULL,
  `secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_triggered_at` timestamp NULL DEFAULT NULL,
  `success_count` int UNSIGNED NOT NULL DEFAULT '0',
  `failure_count` int UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `announcements`
--
ALTER TABLE `announcements` ADD FULLTEXT KEY `ft_title_content` (`title`,`content`);

--
-- Index pour la table `comments`
--
ALTER TABLE `comments` ADD FULLTEXT KEY `ft_content` (`content`);

--
-- Index pour la table `messages`
--
ALTER TABLE `messages` ADD FULLTEXT KEY `ft_content` (`content`);

--
-- Index pour la table `opportunities`
--
ALTER TABLE `opportunities` ADD FULLTEXT KEY `ft_title_description` (`title`,`description`);

--
-- Index pour la table `posts`
--
ALTER TABLE `posts` ADD FULLTEXT KEY `ft_content` (`content`);

--
-- Index pour la table `user_groups`
--
ALTER TABLE `user_groups` ADD FULLTEXT KEY `ft_name_description` (`name`,`description`);

-- --------------------------------------------------------

--
-- Structure de la vue `user_role_stats`
--
DROP TABLE IF EXISTS `user_role_stats`;

DROP VIEW IF EXISTS `user_role_stats`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_role_stats`  AS SELECT `r`.`name` AS `role_name`, `r`.`level` AS `role_level`, count(distinct `ur`.`user_id`) AS `user_count`, count(distinct (case when (`u`.`is_active` = 1) then `ur`.`user_id` end)) AS `active_users` FROM ((`roles` `r` left join `user_roles` `ur` on(((`r`.`id` = `ur`.`role_id`) and (`ur`.`is_active` = 1)))) left join `users` `u` on(((`ur`.`user_id` = `u`.`id`) and (`u`.`deleted_at` is null)))) GROUP BY `r`.`id`, `r`.`name`, `r`.`level` ORDER BY `r`.`level` DESC ;

-- --------------------------------------------------------

--
-- Structure de la vue `vw_pre_registration_summary`
--
DROP TABLE IF EXISTS `vw_pre_registration_summary`;

DROP VIEW IF EXISTS `vw_pre_registration_summary`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_pre_registration_summary`  AS SELECT `pr`.`id` AS `id`, `pr`.`uuid` AS `uuid`, `pr`.`institution_id` AS `institution_id`, `inst`.`name` AS `institution_name`, `pr`.`faculty_id` AS `faculty_id`, `f`.`name` AS `faculty_name`, `pr`.`program_id` AS `program_id`, `p`.`name` AS `program_name`, `pr`.`email` AS `email`, `pr`.`phone` AS `phone`, `pr`.`status` AS `status`, `pr`.`payment_status` AS `payment_status`, `pr`.`created_at` AS `created_at` FROM (((`pre_registrations` `pr` left join `institutions` `inst` on((`inst`.`id` = `pr`.`institution_id`))) left join `pre_faculties` `f` on((`f`.`id` = `pr`.`faculty_id`))) left join `pre_programs` `p` on((`p`.`id` = `pr`.`program_id`))) ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_active_users`
--
DROP TABLE IF EXISTS `v_active_users`;

DROP VIEW IF EXISTS `v_active_users`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_active_users`  AS SELECT `u`.`id` AS `id`, `u`.`uuid` AS `uuid`, `u`.`email` AS `email`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`matricule` AS `matricule`, `u`.`level` AS `level`, `u`.`primary_role` AS `primary_role`, `u`.`account_status` AS `account_status`, `u`.`institution_id` AS `institution_id`, `i`.`name` AS `institution_name`, `d`.`name` AS `department_name`, `u`.`last_login_at` AS `last_login_at`, `u`.`last_active_at` AS `last_active_at`, `u`.`login_count` AS `login_count`, (case when (`u`.`last_active_at` >= (now() - interval 1 day)) then 'today' when (`u`.`last_active_at` >= (now() - interval 7 day)) then 'week' when (`u`.`last_active_at` >= (now() - interval 30 day)) then 'month' else 'inactive' end) AS `activity_status`, count(distinct `gm`.`group_id`) AS `groups_count`, count(distinct `p`.`id`) AS `posts_count`, count(distinct `c`.`id`) AS `comments_count`, `u`.`created_at` AS `created_at` FROM (((((`users` `u` join `institutions` `i` on((`u`.`institution_id` = `i`.`id`))) left join `departments` `d` on((`u`.`department_id` = `d`.`id`))) left join `group_members` `gm` on(((`u`.`id` = `gm`.`user_id`) and (`gm`.`status` = 'active')))) left join `posts` `p` on(((`u`.`id` = `p`.`author_id`) and (`p`.`status` = 'published')))) left join `comments` `c` on(((`u`.`id` = `c`.`author_id`) and (`c`.`status` = 'published')))) WHERE ((`u`.`deleted_at` is null) AND (`u`.`account_status` = 'active') AND (`u`.`is_active` = true)) GROUP BY `u`.`id`, `u`.`uuid`, `u`.`email`, `u`.`first_name`, `u`.`last_name`, `u`.`matricule`, `u`.`level`, `u`.`primary_role`, `u`.`account_status`, `u`.`institution_id`, `i`.`name`, `d`.`name`, `u`.`last_login_at`, `u`.`last_active_at`, `u`.`login_count`, `u`.`created_at` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_group_stats`
--
DROP TABLE IF EXISTS `v_group_stats`;

DROP VIEW IF EXISTS `v_group_stats`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_group_stats`  AS SELECT `g`.`id` AS `id`, `g`.`uuid` AS `uuid`, `g`.`name` AS `name`, `g`.`group_type` AS `group_type`, `g`.`visibility` AS `visibility`, `g`.`is_official` AS `is_official`, `g`.`current_members_count` AS `current_members_count`, `g`.`institution_id` AS `institution_id`, `i`.`name` AS `institution_name`, count(distinct `gm`.`id`) AS `actual_members`, count(distinct (case when (`gm`.`status` = 'active') then `gm`.`id` end)) AS `active_members`, count(distinct (case when (`gm`.`role` in ('admin','moderator','leader')) then `gm`.`id` end)) AS `leaders_count`, count(distinct `p`.`id`) AS `posts_count`, count(distinct (case when (`p`.`created_at` >= (now() - interval 7 day)) then `p`.`id` end)) AS `posts_last_7d`, count(distinct (case when (`p`.`created_at` >= (now() - interval 30 day)) then `p`.`id` end)) AS `posts_last_30d`, max(`p`.`created_at`) AS `last_post_at`, `g`.`created_at` AS `created_at`, `g`.`updated_at` AS `updated_at` FROM (((`user_groups` `g` join `institutions` `i` on((`g`.`institution_id` = `i`.`id`))) left join `group_members` `gm` on((`g`.`id` = `gm`.`group_id`))) left join `posts` `p` on(((`g`.`id` = `p`.`group_id`) and (`p`.`status` = 'published')))) WHERE (`g`.`status` = 'active') GROUP BY `g`.`id`, `g`.`uuid`, `g`.`name`, `g`.`group_type`, `g`.`visibility`, `g`.`is_official`, `g`.`current_members_count`, `g`.`institution_id`, `i`.`name`, `g`.`created_at`, `g`.`updated_at` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_institution_stats`
--
DROP TABLE IF EXISTS `v_institution_stats`;

DROP VIEW IF EXISTS `v_institution_stats`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_institution_stats`  AS SELECT `i`.`id` AS `id`, `i`.`code` AS `code`, `i`.`name` AS `name`, `i`.`type` AS `type`, `i`.`status` AS `status`, count(distinct `u`.`id`) AS `total_users`, count(distinct (case when (`u`.`primary_role` = 'student') then `u`.`id` end)) AS `total_students`, count(distinct (case when (`u`.`primary_role` = 'teacher') then `u`.`id` end)) AS `total_teachers`, count(distinct `f`.`id`) AS `total_faculties`, count(distinct `d`.`id`) AS `total_departments`, count(distinct `p`.`id`) AS `total_programs`, count(distinct `g`.`id`) AS `total_groups`, count(distinct (case when (`u`.`last_active_at` >= (now() - interval 7 day)) then `u`.`id` end)) AS `active_users_7d`, count(distinct (case when (`u`.`last_active_at` >= (now() - interval 30 day)) then `u`.`id` end)) AS `active_users_30d`, `i`.`created_at` AS `created_at`, `i`.`updated_at` AS `updated_at` FROM (((((`institutions` `i` left join `users` `u` on(((`i`.`id` = `u`.`institution_id`) and (`u`.`deleted_at` is null)))) left join `faculties` `f` on((`i`.`id` = `f`.`institution_id`))) left join `departments` `d` on((`f`.`id` = `d`.`faculty_id`))) left join `programs` `p` on((`d`.`id` = `p`.`department_id`))) left join `user_groups` `g` on(((`i`.`id` = `g`.`institution_id`) and (`g`.`status` = 'active')))) WHERE (`i`.`status` = 'active') GROUP BY `i`.`id`, `i`.`code`, `i`.`name`, `i`.`type`, `i`.`status`, `i`.`created_at`, `i`.`updated_at` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_institution_summary`
--
DROP TABLE IF EXISTS `v_institution_summary`;

DROP VIEW IF EXISTS `v_institution_summary`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_institution_summary`  AS SELECT `i`.`id` AS `id`, `i`.`uuid` AS `uuid`, `i`.`name` AS `name`, `i`.`code` AS `code`, `i`.`city` AS `city`, `i`.`region` AS `region`, count(distinct `u`.`id`) AS `total_users`, count(distinct `d`.`id`) AS `total_departments`, count(distinct `g`.`id`) AS `total_groups`, count(distinct `a`.`id`) AS `total_announcements`, `i`.`created_at` AS `created_at` FROM (((((`institutions` `i` left join `users` `u` on(((`i`.`id` = `u`.`institution_id`) and (`u`.`is_active` = true)))) left join `faculties` `f` on(((`i`.`id` = `f`.`institution_id`) and (`f`.`status` = 'active')))) left join `departments` `d` on(((`f`.`id` = `d`.`faculty_id`) and (`d`.`status` = 'active')))) left join `user_groups` `g` on((`i`.`id` = `g`.`institution_id`))) left join `announcements` `a` on(((`i`.`id` = `a`.`institution_id`) and (`a`.`status` = 'published')))) WHERE (`i`.`is_active` = true) GROUP BY `i`.`id`, `i`.`uuid`, `i`.`name`, `i`.`code`, `i`.`city`, `i`.`region`, `i`.`created_at` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_preinscriptions_stats`
--
DROP TABLE IF EXISTS `v_preinscriptions_stats`;

DROP VIEW IF EXISTS `v_preinscriptions_stats`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_preinscriptions_stats`  AS SELECT `preinscriptions`.`faculty` AS `faculty`, count(0) AS `total_count`, count((case when (`preinscriptions`.`status` = 'pending') then 1 end)) AS `pending_count`, count((case when (`preinscriptions`.`status` = 'accepted') then 1 end)) AS `accepted_count`, count((case when (`preinscriptions`.`status` = 'rejected') then 1 end)) AS `rejected_count`, count((case when (`preinscriptions`.`payment_status` = 'paid') then 1 end)) AS `paid_count`, sum((case when (`preinscriptions`.`payment_amount` > 0) then `preinscriptions`.`payment_amount` else 0 end)) AS `total_revenue` FROM `preinscriptions` WHERE (`preinscriptions`.`deleted_at` is null) GROUP BY `preinscriptions`.`faculty` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_preinscriptions_summary`
--
DROP TABLE IF EXISTS `v_preinscriptions_summary`;

DROP VIEW IF EXISTS `v_preinscriptions_summary`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_preinscriptions_summary`  AS SELECT `preinscriptions`.`id` AS `id`, `preinscriptions`.`unique_code` AS `unique_code`, `preinscriptions`.`faculty` AS `faculty`, `preinscriptions`.`last_name` AS `last_name`, `preinscriptions`.`first_name` AS `first_name`, `preinscriptions`.`email` AS `email`, `preinscriptions`.`phone_number` AS `phone_number`, `preinscriptions`.`desired_program` AS `desired_program`, `preinscriptions`.`study_level` AS `study_level`, `preinscriptions`.`status` AS `status`, `preinscriptions`.`payment_status` AS `payment_status`, `preinscriptions`.`submission_date` AS `submission_date`, (case when (`preinscriptions`.`status` = 'accepted') then 'Admis' when (`preinscriptions`.`status` = 'rejected') then 'Rejeté' when (`preinscriptions`.`status` = 'pending') then 'En attente' when (`preinscriptions`.`status` = 'under_review') then 'En cours' else `preinscriptions`.`status` end) AS `status_fr` FROM `preinscriptions` WHERE (`preinscriptions`.`deleted_at` is null) ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_role_stats_by_institution`
--
DROP TABLE IF EXISTS `v_role_stats_by_institution`;

DROP VIEW IF EXISTS `v_role_stats_by_institution`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_role_stats_by_institution`  AS SELECT `i`.`id` AS `institution_id`, `i`.`name` AS `institution_name`, `r`.`category` AS `role_category`, count(distinct `u`.`id`) AS `user_count`, avg(`r`.`level`) AS `avg_role_level`, max(`r`.`level`) AS `max_role_level` FROM (((`institutions` `i` left join `users` `u` on(((`i`.`id` = `u`.`institution_id`) and (`u`.`deleted_at` is null)))) left join `user_role_assignments` `ura` on(((`u`.`id` = `ura`.`user_id`) and (`ura`.`is_active` = 1)))) left join `roles` `r` on((`ura`.`role_id` = `r`.`id`))) GROUP BY `i`.`id`, `r`.`category` ORDER BY `i`.`name` ASC, `r`.`category` ASC ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_user_roles_complete`
--
DROP TABLE IF EXISTS `v_user_roles_complete`;

DROP VIEW IF EXISTS `v_user_roles_complete`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_user_roles_complete`  AS SELECT `u`.`id` AS `user_id`, `u`.`uuid` AS `user_uuid`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, `u`.`primary_role` AS `primary_role`, `u`.`institution_id` AS `institution_id`, `i`.`name` AS `institution_name`, `r`.`id` AS `role_id`, `r`.`code` AS `role_code`, `r`.`name` AS `role_name`, `r`.`display_name` AS `role_display_name`, `r`.`category` AS `role_category`, `r`.`level` AS `role_level`, `ura`.`is_primary` AS `is_primary`, `ura`.`is_active` AS `assignment_active`, `ura`.`assigned_at` AS `assigned_at`, `ura`.`expires_at` AS `expires_at`, `os`.`name` AS `structure_name`, `os`.`type` AS `structure_type` FROM ((((`users` `u` left join `user_role_assignments` `ura` on(((`u`.`id` = `ura`.`user_id`) and (`ura`.`is_active` = 1)))) left join `roles` `r` on((`ura`.`role_id` = `r`.`id`))) left join `institutions` `i` on((`u`.`institution_id` = `i`.`id`))) left join `organizational_structures` `os` on((`ura`.`institution_id` = `os`.`id`))) WHERE (`u`.`deleted_at` is null) ;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `academic_records`
--
ALTER TABLE `academic_records`
  ADD CONSTRAINT `academic_records_ibfk_1` FOREIGN KEY (`student_profile_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `academic_records_ibfk_2` FOREIGN KEY (`enrollment_id`) REFERENCES `student_enrollments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `academic_records_ibfk_3` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `academic_years`
--
ALTER TABLE `academic_years`
  ADD CONSTRAINT `fk_academic_years_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_activity_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `analytics_events`
--
ALTER TABLE `analytics_events`
  ADD CONSTRAINT `fk_analytics_events_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_analytics_events_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_announcements_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_announcements_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_announcements_published_by` FOREIGN KEY (`published_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `announcement_acknowledgments`
--
ALTER TABLE `announcement_acknowledgments`
  ADD CONSTRAINT `fk_acknowledgments_announcement` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_acknowledgments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `api_keys`
--
ALTER TABLE `api_keys`
  ADD CONSTRAINT `fk_api_keys_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_api_keys_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `blocked_users`
--
ALTER TABLE `blocked_users`
  ADD CONSTRAINT `fk_blocked_users_blocked` FOREIGN KEY (`blocked_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_blocked_users_blocker` FOREIGN KEY (`blocker_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `certification_requests`
--
ALTER TABLE `certification_requests`
  ADD CONSTRAINT `fk_cert_req_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cert_req_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `fk_comments_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_comments_moderated_by` FOREIGN KEY (`moderated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_comments_parent` FOREIGN KEY (`parent_comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_comments_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `conversations`
--
ALTER TABLE `conversations`
  ADD CONSTRAINT `fk_conversations_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_conversations_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `conversation_participants`
--
ALTER TABLE `conversation_participants`
  ADD CONSTRAINT `fk_participants_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_participants_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `fk_courses_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `departments`
--
ALTER TABLE `departments`
  ADD CONSTRAINT `fk_departments_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD CONSTRAINT `fk_device_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `email_verifications`
--
ALTER TABLE `email_verifications`
  ADD CONSTRAINT `fk_email_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `faculties`
--
ALTER TABLE `faculties`
  ADD CONSTRAINT `fk_faculties_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `files`
--
ALTER TABLE `files`
  ADD CONSTRAINT `fk_files_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `group_members`
--
ALTER TABLE `group_members`
  ADD CONSTRAINT `fk_group_members_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_group_members_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_group_members_invited_by` FOREIGN KEY (`invited_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_group_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `housing_requests`
--
ALTER TABLE `housing_requests`
  ADD CONSTRAINT `fk_housing_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `pre_faculties` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_housing_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_housing_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `merchant_space_requests`
--
ALTER TABLE `merchant_space_requests`
  ADD CONSTRAINT `fk_merchant_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_merchant_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_messages_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_messages_parent` FOREIGN KEY (`parent_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_messages_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Contraintes pour la table `message_attachments`
--
ALTER TABLE `message_attachments`
  ADD CONSTRAINT `fk_message_attachments_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `message_reads`
--
ALTER TABLE `message_reads`
  ADD CONSTRAINT `fk_message_reads_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_message_reads_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `opportunities`
--
ALTER TABLE `opportunities`
  ADD CONSTRAINT `fk_opportunities_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_opportunities_posted_by` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_opportunities_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `opportunity_applications`
--
ALTER TABLE `opportunity_applications`
  ADD CONSTRAINT `fk_applications_opportunity` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_applications_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_applications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `organizational_structures`
--
ALTER TABLE `organizational_structures`
  ADD CONSTRAINT `fk_os_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_os_parent_structure` FOREIGN KEY (`parent_structure_id`) REFERENCES `organizational_structures` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `phone_verifications`
--
ALTER TABLE `phone_verifications`
  ADD CONSTRAINT `fk_phone_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `fk_posts_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_posts_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_posts_moderated_by` FOREIGN KEY (`moderated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_posts_shared_post` FOREIGN KEY (`shared_post_id`) REFERENCES `posts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `preinscriptions`
--
ALTER TABLE `preinscriptions`
  ADD CONSTRAINT `fk_preinscriptions_student_id` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_audit_logs`
--
ALTER TABLE `pre_audit_logs`
  ADD CONSTRAINT `fk_pre_audit_performed_by` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_event_settings`
--
ALTER TABLE `pre_event_settings`
  ADD CONSTRAINT `fk_pre_event_settings_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_faculties`
--
ALTER TABLE `pre_faculties`
  ADD CONSTRAINT `fk_pre_faculties_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_payments`
--
ALTER TABLE `pre_payments`
  ADD CONSTRAINT `fk_pre_payments_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pre_payments_pre_registration` FOREIGN KEY (`pre_registration_id`) REFERENCES `pre_registrations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pre_payments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_programs`
--
ALTER TABLE `pre_programs`
  ADD CONSTRAINT `fk_pre_programs_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `pre_faculties` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pre_programs_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_registration_documents`
--
ALTER TABLE `pre_registration_documents`
  ADD CONSTRAINT `fk_pre_reg_docs_pre_registration` FOREIGN KEY (`pre_registration_id`) REFERENCES `pre_registrations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pre_reg_docs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pre_reg_docs_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `pre_resources`
--
ALTER TABLE `pre_resources`
  ADD CONSTRAINT `fk_pre_resources_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `programs`
--
ALTER TABLE `programs`
  ADD CONSTRAINT `fk_programs_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `reactions`
--
ALTER TABLE `reactions`
  ADD CONSTRAINT `fk_reactions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `fk_reports_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `security_logs`
--
ALTER TABLE `security_logs`
  ADD CONSTRAINT `fk_security_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `student_courses`
--
ALTER TABLE `student_courses`
  ADD CONSTRAINT `student_courses_ibfk_1` FOREIGN KEY (`student_profile_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_courses_ibfk_2` FOREIGN KEY (`enrollment_id`) REFERENCES `student_enrollments` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `student_discipline`
--
ALTER TABLE `student_discipline`
  ADD CONSTRAINT `student_discipline_ibfk_1` FOREIGN KEY (`student_profile_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_discipline_ibfk_2` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `student_discipline_ibfk_3` FOREIGN KEY (`investigated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `student_discipline_ibfk_4` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `student_documents`
--
ALTER TABLE `student_documents`
  ADD CONSTRAINT `student_documents_ibfk_1` FOREIGN KEY (`student_profile_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_documents_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `student_enrollments`
--
ALTER TABLE `student_enrollments`
  ADD CONSTRAINT `student_enrollments_ibfk_1` FOREIGN KEY (`student_profile_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_enrollments_ibfk_2` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `student_enrollments_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `student_profiles`
--
ALTER TABLE `student_profiles`
  ADD CONSTRAINT `fk_student_profiles_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_student_profiles_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_student_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `student_scholarships`
--
ALTER TABLE `student_scholarships`
  ADD CONSTRAINT `student_scholarships_ibfk_1` FOREIGN KEY (`student_profile_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `student_statistics`
--
ALTER TABLE `student_statistics`
  ADD CONSTRAINT `student_statistics_ibfk_1` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_statistics_ibfk_2` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_statistics_ibfk_3` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_statistics_ibfk_4` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_statistics_ibfk_5` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sync_logs`
--
ALTER TABLE `sync_logs`
  ADD CONSTRAINT `fk_sync_logs_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `teacher_profiles`
--
ALTER TABLE `teacher_profiles`
  ADD CONSTRAINT `fk_teacher_profiles_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_teacher_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `tokens`
--
ALTER TABLE `tokens`
  ADD CONSTRAINT `fk_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_users_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_users_preinscription_id` FOREIGN KEY (`preinscription_id`) REFERENCES `preinscriptions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `user_groups`
--
ALTER TABLE `user_groups`
  ADD CONSTRAINT `fk_user_groups_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_parent` FOREIGN KEY (`parent_group_id`) REFERENCES `user_groups` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `user_presence`
--
ALTER TABLE `user_presence`
  ADD CONSTRAINT `fk_user_presence_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_roles_ibfk_3` FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `user_role_assignments`
--
ALTER TABLE `user_role_assignments`
  ADD CONSTRAINT `fk_ura_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_ura_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ura_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ura_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ura_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ura_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `fk_user_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `user_settings`
--
ALTER TABLE `user_settings`
  ADD CONSTRAINT `user_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `webhooks`
--
ALTER TABLE `webhooks`
  ADD CONSTRAINT `fk_webhooks_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_webhooks_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
