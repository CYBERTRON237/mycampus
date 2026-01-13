-- Migration de base pour le module de gestion des étudiants
-- Date: 2025-12-15
-- Description: Tables essentielles pour le fonctionnement minimal du module

-- Table des profils d'étudiants (table principale)
DROP TABLE IF EXISTS `student_profiles`;
CREATE TABLE IF NOT EXISTS `student_profiles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `matricule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `place_of_birth` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Cameroon',
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `emergency_contact_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `blood_group` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medical_conditions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `admission_date` date DEFAULT NULL,
  `admission_type` enum('regular','transfer','international') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'regular',
  `student_status` enum('active','inactive','graduated','suspended','withdrawn','deferred') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `current_level` enum('licence1','licence2','licence3','master1','master2','doctorat1','doctorat2','doctorat3') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_gpa` decimal(3,2) DEFAULT NULL,
  `total_credits` int UNSIGNED DEFAULT '0',
  `institution_id` bigint UNSIGNED NOT NULL,
  `faculty_id` bigint UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `program_id` bigint UNSIGNED DEFAULT NULL,
  `academic_year_id` bigint UNSIGNED DEFAULT NULL,
  `profile_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enrollment_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_matricule` (`matricule`),
  UNIQUE KEY `unique_email` (`email`),
  UNIQUE KEY `unique_enrollment_number` (`enrollment_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_institution_id` (`institution_id`),
  KEY `idx_faculty_id` (`faculty_id`),
  KEY `idx_department_id` (`department_id`),
  KEY `idx_program_id` (`program_id`),
  KEY `idx_academic_year_id` (`academic_year_id`),
  KEY `idx_student_status` (`student_status`),
  KEY `idx_current_level` (`current_level`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`faculty_id`) REFERENCES `faculties`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`program_id`) REFERENCES `programs`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion de données de test si la table est vide
INSERT IGNORE INTO `student_profiles` (
  `uuid`, `matricule`, `first_name`, `last_name`, `email`, `phone`, 
  `date_of_birth`, `gender`, `student_status`, `current_level`, 
  `current_gpa`, `institution_id`, `faculty_id`, `department_id`, 
  `program_id`, `academic_year_id`
) VALUES 
(
  UUID(), '2025001', 'Jean', 'Dupont', 'jean.dupont@example.com', '237123456789',
  '2000-01-15', 'male', 'active', 'licence1', 3.50,
  1, 1, 1, 1, 1
),
(
  UUID(), '2025002', 'Marie', 'Curie', 'marie.curie@example.com', '237987654321',
  '2001-05-20', 'female', 'active', 'licence2', 3.75,
  1, 1, 1, 1, 1
),
(
  UUID(), '2025003', 'Pierre', 'Nguyen', 'pierre.nguyen@example.com', '237555666777',
  '2002-03-10', 'male', 'active', 'licence3', 3.25,
  1, 1, 1, 1, 1
);

-- Table des années académiques (si elle n'existe pas)
CREATE TABLE IF NOT EXISTS `academic_years` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `year_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('upcoming','active','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_year_name` (`year_name`),
  KEY `idx_is_current` (`is_current`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion d'années académiques de test
INSERT IGNORE INTO `academic_years` (`uuid`, `year_name`, `start_date`, `end_date`, `is_current`, `status`) VALUES
(UUID(), '2024-2025', '2024-09-01', '2025-08-31', 1, 'active'),
(UUID(), '2023-2024', '2023-09-01', '2024-08-31', 0, 'completed'),
(UUID(), '2025-2026', '2025-09-01', '2026-08-31', 0, 'upcoming');

-- Message de confirmation
SELECT 'Tables student_profiles créées avec succès!' as message;
