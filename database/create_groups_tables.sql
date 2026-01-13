-- Création des tables pour le système de groupes
-- MyCampus Group Management System

-- Table principale des groupes
CREATE TABLE IF NOT EXISTS `user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT (UUID()),
  `institution_id` int(11) DEFAULT NULL,
  `program_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `parent_group_id` int(11) DEFAULT NULL,
  `group_type` enum('program','filiere','level','year','club','association','project','sport','cultural','academic','department','faculty','national','inter_university','custom','chat') NOT NULL DEFAULT 'custom',
  `visibility` enum('public','private','secret','restricted','official') NOT NULL DEFAULT 'public',
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `cover_image_url` varchar(500) DEFAULT NULL,
  `cover_url` varchar(500) DEFAULT NULL,
  `icon_url` varchar(500) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `academic_level` varchar(50) DEFAULT NULL,
  `academic_year_id` int(11) DEFAULT NULL,
  `is_official` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_national` tinyint(1) NOT NULL DEFAULT 0,
  `max_members` int(11) NOT NULL DEFAULT 1000,
  `current_members_count` int(11) NOT NULL DEFAULT 0,
  `join_approval_required` tinyint(1) NOT NULL DEFAULT 0,
  `allow_member_posts` tinyint(1) NOT NULL DEFAULT 1,
  `allow_member_invites` tinyint(1) NOT NULL DEFAULT 1,
  `rules` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `status` enum('active','inactive','suspended','archived') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_institution_id` (`institution_id`),
  KEY `idx_program_id` (`program_id`),
  KEY `idx_department_id` (`department_id`),
  KEY `idx_parent_group_id` (`parent_group_id`),
  KEY `idx_group_type` (`group_type`),
  KEY `idx_visibility` (`visibility`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des membres des groupes
CREATE TABLE IF NOT EXISTS `group_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('owner','admin','moderator','member','pending','invited') NOT NULL DEFAULT 'member',
  `status` enum('active','inactive','banned','left') NOT NULL DEFAULT 'active',
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at` timestamp NULL DEFAULT NULL,
  `invited_by` int(11) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `last_activity_at` timestamp NULL DEFAULT NULL,
  `contribution_count` int(11) NOT NULL DEFAULT 0,
  `is_muted` tinyint(1) NOT NULL DEFAULT 0,
  `muted_until` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_group_user` (`group_id`, `user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_joined_at` (`joined_at`),
  KEY `idx_last_activity_at` (`last_activity_at`),
  CONSTRAINT `fk_group_members_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des activités de groupe
CREATE TABLE IF NOT EXISTS `group_activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `activity_type` enum('created','updated','deleted','member_joined','member_left','member_added','member_removed','role_changed','post_created','post_updated','post_deleted','event_created','event_updated','event_deleted') NOT NULL,
  `activity_data` json DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_group_id` (`group_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_group_activities_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_activities_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des invitations aux groupes
CREATE TABLE IF NOT EXISTS `group_invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `invited_by` int(11) NOT NULL,
  `invited_user_id` int(11) DEFAULT NULL,
  `invited_email` varchar(255) DEFAULT NULL,
  `invitation_token` varchar(255) NOT NULL,
  `role` enum('member','moderator','admin') NOT NULL DEFAULT 'member',
  `message` text DEFAULT NULL,
  `status` enum('pending','accepted','declined','expired','cancelled') NOT NULL DEFAULT 'pending',
  `expires_at` timestamp NOT NULL DEFAULT (DATE_ADD(NOW(), INTERVAL 7 DAY)),
  `accepted_at` timestamp NULL DEFAULT NULL,
  `declined_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invitation_token` (`invitation_token`),
  KEY `idx_group_id` (`group_id`),
  KEY `idx_invited_by` (`invited_by`),
  KEY `idx_invited_user_id` (`invited_user_id`),
  KEY `idx_invited_email` (`invited_email`),
  KEY `idx_status` (`status`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `fk_group_invitations_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_invitations_invited_by` FOREIGN KEY (`invited_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_invitations_invited_user` FOREIGN KEY (`invited_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des paramètres et préférences des groupes
CREATE TABLE IF NOT EXISTS `group_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('string','integer','boolean','json') NOT NULL DEFAULT 'string',
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_group_setting` (`group_id`, `setting_key`),
  KEY `idx_setting_key` (`setting_key`),
  CONSTRAINT `fk_group_settings_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insérer quelques paramètres par défaut pour les nouveaux groupes
INSERT IGNORE INTO `group_settings` (`group_id`, `setting_key`, `setting_value`, `setting_type`, `is_public`) VALUES
(0, 'allow_file_sharing', '1', 'boolean', 1),
(0, 'max_file_size', '10485760', 'integer', 1),
(0, 'allowed_file_types', '["jpg","jpeg","png","gif","pdf","doc","docx","txt"]', 'json', 1),
(0, 'enable_chat', '1', 'boolean', 1),
(0, 'enable_events', '1', 'boolean', 1),
(0, 'enable_announcements', '1', 'boolean', 1);

-- Mettre à jour la table users si elle n'a pas les colonnes nécessaires
ALTER TABLE `users` 
ADD COLUMN IF NOT EXISTS `is_group_admin` tinyint(1) NOT NULL DEFAULT 0 AFTER `role`,
ADD COLUMN IF NOT EXISTS `group_preferences` json DEFAULT NULL AFTER `is_group_admin`;

-- Créer des index pour optimiser les performances
CREATE INDEX IF NOT EXISTS `idx_groups_search` ON `user_groups` (`name`, `description`, `group_type`);
CREATE INDEX IF NOT EXISTS `idx_groups_members_count` ON `user_groups` (`current_members_count`);
CREATE INDEX IF NOT EXISTS `idx_groups_created_by_type` ON `user_groups` (`created_by`, `group_type`);
CREATE INDEX IF NOT EXISTS `idx_members_user_status` ON `group_members` (`user_id`, `status`);
CREATE INDEX IF NOT EXISTS `idx_members_group_role` ON `group_members` (`group_id`, `role`);
