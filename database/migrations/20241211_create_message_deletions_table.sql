-- Migration: Create message_deletions table for WhatsApp-like "delete for me" functionality
-- Created: 2024-12-11
-- Purpose: Track which users have deleted which messages (for "delete for me" feature)

CREATE TABLE IF NOT EXISTS `message_deletions` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_message_user_deletion` (`message_id`, `user_id`),
  KEY `idx_message_deletions_message_id` (`message_id`),
  KEY `idx_message_deletions_user_id` (`user_id`),
  KEY `idx_message_deletions_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key constraints if messages table exists
ALTER TABLE `message_deletions` 
  ADD CONSTRAINT `fk_message_deletions_message_id` 
  FOREIGN KEY (`message_id`) 
  REFERENCES `messages` (`id`) 
  ON DELETE CASCADE 
  ON UPDATE CASCADE;

ALTER TABLE `message_deletions` 
  ADD CONSTRAINT `fk_message_deletions_user_id` 
  FOREIGN KEY (`user_id`) 
  REFERENCES `users` (`id`) 
  ON DELETE CASCADE 
  ON UPDATE CASCADE;

-- Add indexes for better performance on message queries
CREATE INDEX `idx_message_deletions_composite` ON `message_deletions` (`message_id`, `user_id`, `deleted_at`);
