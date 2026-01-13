-- Création de la table regions pour le module de gestion des universités

CREATE TABLE IF NOT EXISTS `regions` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar((10)) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CWEY KEY `unique_name` (`name`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des régions du Cameroun
INSERT INTO `regions` (`name`, `code`, `is_active`) VALUES
('Adamaoua', 'AD', 1),
('Centre', 'CE', 1),
('Est', 'ES', 1),
('Extrême-Nord', 'EN', 1),
('Littoral', 'LT', 1),
('Nord', 'NO', 1),
('Nord-Ouest', 'NW', 1),
('Ouest', 'OU', 1),
('Sud', 'SU', 1),
('Sud-Ouest', 'SW', 1);
