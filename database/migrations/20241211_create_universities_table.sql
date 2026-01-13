-- Création de la table universities
CREATE TABLE IF NOT EXISTS `universities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `acronym` varchar(50) NOT NULL,
  `type` enum('public','private','confessional') NOT NULL DEFAULT 'public',
  `status` enum('active','inactive','suspended','pending') NOT NULL DEFAULT 'active',
  `region` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `acronym` (`acronym`),
  KEY `type` (`type`),
  KEY `status` (`status`),
  KEY `region` (`region`),
  KEY `is_verified` (`is_verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion de données de test
INSERT INTO `universities` (`name`, `acronym`, `type`, `status`, `region`, `description`, `website`, `email`, `phone`, `address`, `is_verified`) VALUES
('Université de Yaoundé I', 'UY1', 'public', 'active', 'Centre', 'Première université du Cameroun, fondée en 1962', 'https://www.uy1.cm', 'info@uy1.cm', '+237 222 22 34 56', 'Yaoundé, Cameroun', 1),
('Université de Yaoundé II', 'UY2', 'public', 'active', 'Centre', 'Université de Soa, spécialisée en sciences sociales et humaines', 'https://www.uy2.cm', 'info@uy2.cm', '+237 222 22 34 57', 'Soa, Cameroun', 1),
('Université de Douala', 'UD', 'public', 'active', 'Littoral', 'Université côtière, spécialisée en sciences et technologie', 'https://www.ud.cm', 'info@ud.cm', '+237 233 42 16 00', 'Douala, Cameroun', 1),
('Université de Dschang', 'UDS', 'public', 'active', 'Ouest', 'Université de l\'Ouest, spécialisée en agriculture et sciences naturelles', 'https://www.dschang.cm', 'info@dschang.cm', '+237 233 45 12 34', 'Dschang, Cameroun', 1),
('Université de Maroua', 'UM', 'public', 'active', 'Extrême-Nord', 'Université de l\'Extrême-Nord, spécialisée en sciences humaines', 'https://www.maroua.cm', 'info@maroua.cm', '+237 233 45 67 89', 'Maroua, Cameroun', 1),
('Université de Buéa', 'UB', 'public', 'active', 'Sud-Ouest', 'Université anglophone du Cameroun', 'https://www.buea.cm', 'info@buea.cm', '+237 233 33 22 11', 'Buéa, Cameroun', 1),
('Institut Universitaire de Technologie', 'IUT', 'public', 'active', 'Centre', 'Institut de formation professionnelle et technique', 'https://www.iut.cm', 'info@iut.cm', '+237 222 22 33 44', 'Yaoundé, Cameroun', 0);
