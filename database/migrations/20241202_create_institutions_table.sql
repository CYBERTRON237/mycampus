-- Création de la table des institutions
CREATE TABLE IF NOT EXISTS `institutions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `logo_url` varchar(512) DEFAULT NULL,
  `address` varchar(512) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `type` enum('university','school','training_center','other') DEFAULT 'university',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `student_count` int(11) DEFAULT 0,
  `teacher_count` int(11) DEFAULT 0,
  `programs` text DEFAULT '[]',
  `facilities` text DEFAULT '[]',
  `metadata` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`),
  KEY `idx_type` (`type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_city` (`city`),
  KEY `idx_country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion de données de test (optionnel)
INSERT INTO `institutions` (`name`, `description`, `city`, `country`, `type`) VALUES
('Université de Yaoundé I', 'Première université du Cameroun', 'Yaoundé', 'Cameroun', 'university'),
('Lycée Général Leclerc', 'Lycée d''enseignement général de référence', 'Yaoundé', 'Cameroun', 'school'),
('Institut Universitaire de la Côte', 'Établissement d''enseignement supérieur privé', 'Douala', 'Cameroun', 'university');

-- Ajout d'index supplémentaires si nécessaire
-- ALTER TABLE `institutions` ADD FULLTEXT KEY `ft_search` (`name`,`description`,`city`,`country`);
