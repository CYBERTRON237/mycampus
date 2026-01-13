-- Migration pour la table de présence en ligne
-- Création: 2024-12-14
-- Purpose: Gérer les statuts en ligne des utilisateurs comme WhatsApp/Messenger

DROP TABLE IF EXISTS `user_presence`;
CREATE TABLE IF NOT EXISTS `user_presence` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `is_online` tinyint(1) NOT NULL DEFAULT '0',
  `last_seen` timestamp NULL DEFAULT NULL,
  `last_activity` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('online','away','busy','offline') NOT NULL DEFAULT 'offline',
  `device_type` enum('mobile','web','desktop') DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_presence` (`user_id`),
  KEY `idx_is_online` (`is_online`),
  KEY `idx_last_activity` (`last_activity`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_user_presence_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Créer un trigger pour mettre à jour last_active_at automatiquement
DROP TRIGGER IF EXISTS `update_user_last_active`;
DELIMITER $$
CREATE TRIGGER `update_user_last_active` 
AFTER UPDATE ON `user_presence` 
FOR EACH ROW 
BEGIN
  IF NEW.is_online = 1 THEN
    UPDATE users 
    SET last_active_at = NOW() 
    WHERE id = NEW.user_id;
  END IF;
END$$
DELIMITER ;

-- Index pour optimiser les requêtes de présence
CREATE INDEX `idx_online_users` ON `user_presence` (`is_online`, `last_activity`);
CREATE INDEX `idx_user_status_lookup` ON `user_presence` (`user_id`, `status`);
