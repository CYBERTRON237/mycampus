-- =====================================================
-- SYSTÈME ÉTENDU DE GESTION DES RÔLES POUR L'UNIVERSITÉ CAMEROUNAISE
-- =====================================================
-- Ce script étend le système existant pour gérer tous les acteurs
-- du système universitaire national camerounais

-- =====================================================
-- 1. MISE À JOUR DE LA TABLE USERS POUR AJOUTER DE NOUVEAUX RÔLES
-- =====================================================

-- Modifier l'énumération des rôles primaires pour inclure tous les acteurs
ALTER TABLE `users` 
MODIFY COLUMN `primary_role` enum(
    'student', 'teacher', 'admin_local', 'admin_national', 'superadmin', 
    'leader', 'staff', 'alumni', 'moderator', 'guest', 'invite',
    
    -- Acteurs Institutionnels Nationaux
    'ministry_official', 'regulatory_inspector', 'accreditation_officer',
    'interministerial_coordinator', 'financial_controller', 'public_service_director',
    
    -- Hiérarchie Universitaire
    'rector', 'vice_rector', 'secretary_general', 'dean', 'school_director',
    'institute_director', 'department_head', 'section_head', 'program_coordinator',
    
    -- Personnel Enseignant
    'professor_titular', 'professor_associate', 'master_conference', 'course_holder',
    'assistant', 'monitor', 'temporary_teacher', 'visiting_professor', 'postdoc_researcher',
    
    -- Personnel Administratif et Technique
    'administrative_agent', 'secretary', 'accountant', 'librarian', 'lab_technician',
    'maintenance_engineer', 'security_agent', 'cleaning_staff', 'driver', 'it_support',
    
    -- Représentations Étudiantes
    'student_executive', 'class_delegate', 'faculty_delegate', 'residence_delegate',
    'cultural_association_leader', 'club_president', 'promotion_coordinator',
    
    -- Partenaires et Sociaux
    'economic_partner', 'chamber_commerce', 'employer_organization', 'bank_representative',
    'insurance_representative', 'international_partner', 'foreign_embassy', 'international_organization',
    'ngo_representative',
    
    -- Organisations Sociales
    'syndicate_representative', 'parents_association', 'alumni_representative',
    'development_association', 'civil_society_organization',
    
    -- Services de Soutien
    'documentation_center', 'orientation_counselor', 'medical_service', 'psychological_service',
    'restaurant_service', 'housing_service', 'sports_service', 'cultural_service',
    
    -- Infrastructure et Logistique
    'building_service', 'transport_service', 'telecommunication_service', 'energy_service',
    'fire_safety_service',
    
    -- Cadre Juridique et Réglementaire
    'parliament_member', 'constitutional_council', 'supreme_court', 'administrative_tribunal',
    'account_commissary', 'legal_advisor',
    
    -- Organismes de Contrôle
    'state_control', 'finance_inspection', 'anti_corruption_commission', 'good_governance_observatory',
    
    -- Recherche et Innovation
    'research_center_director', 'research_laboratory_head', 'specialized_institute_director',
    'excellence_pole_director', 'business_incubator_manager', 'technology_park_manager',
    'scientific_community_member', 'academy_member', 'learned_society_member',
    'editorial_board_member', 'scientific_evaluator', 'expert_consultant'
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student';

-- =====================================================
-- 2. CRÉATION DE LA TABLE DES RÔLES DÉTAILLÉS
-- =====================================================

CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum(
    'national_institutional', 'university_hierarchy', 'teaching_staff', 'administrative_technical',
    'student_representation', 'partners_social', 'support_services', 'infrastructure_logistics',
    'legal_regulatory', 'control_organizations', 'research_innovation', 'academic', 'administrative'
  ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` tinyint UNSIGNED NOT NULL DEFAULT '50' COMMENT 'Niveau de permission (0-100)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `responsibilities` json DEFAULT NULL,
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_system_role` tinyint(1) NOT NULL DEFAULT '0',
  `parent_role_id` bigint UNSIGNED DEFAULT NULL,
  `institution_type` enum('all', 'public', 'private', 'professional', 'research') DEFAULT 'all',
  `ministry_affiliation` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_category` (`category`),
  KEY `idx_level` (`level`),
  KEY `idx_parent_role` (`parent_role_id`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. CRÉATION DE LA TABLE DES AFFECTATIONS DE RÔLES MULTIPLES
-- =====================================================

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
  CONSTRAINT `fk_ura_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ura_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ura_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ura_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ura_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ura_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. CRÉATION DE LA TABLE DES STRUCTURES ORGANISATIONNELLES
-- =====================================================

CREATE TABLE IF NOT EXISTS `organizational_structures` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum(
    'ministry', 'regulatory_body', 'coordination_committee', 'university', 'faculty', 
    'school', 'institute', 'department', 'research_center', 'administrative_unit',
    'student_organization', 'partner_organization', 'control_body', 'support_service'
  ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_structure_id` bigint UNSIGNED DEFAULT NULL,
  `institution_id` bigint UNSIGNED DEFAULT NULL,
  `level` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `hierarchy_path` varchar(500) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `address` text,
  `website` varchar(255) DEFAULT NULL,
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
  CONSTRAINT `fk_os_parent_structure` FOREIGN KEY (`parent_structure_id`) REFERENCES `organizational_structures` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_os_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 5. INSERTION DES RÔLES DÉTAILLÉS
-- =====================================================

-- Acteurs Institutionnels Nationaux
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'MINESUP_MINISTER', 'ministry_of_higher_education', 'Ministre de l\'Enseignement Supérieur', 'national_institutional', 100, 'Ministre en charge de l\'enseignement supérieur'),
(UUID(), 'MINESUP_SECRETARY', 'ministry_secretary_general', 'Secrétaire Général MINESUP', 'national_institutional', 95, 'Secrétaire général du ministère'),
(UUID(), 'MINRESIP_DIRECTOR', 'ministry_research_director', 'Directeur MINRESI', 'national_institutional', 90, 'Directeur du ministère de la recherche'),
(UUID(), 'CNES_PRESIDENT', 'cnes_president', 'Président CNES', 'national_institutional', 88, 'Président du conseil national'),
(UUID(), 'CAAQES_DIRECTOR', 'caaques_director', 'Directeur CAAQES', 'national_institutional', 85, 'Directeur de l\'agence d\'accréditation'),
(UUID(), 'INSPECTOR_GENERAL', 'general_inspector', 'Inspecteur Général', 'national_institutional', 87, 'Inspecteur général de l\'enseignement supérieur');

-- Hiérarchie Universitaire
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'UNIV_RECTOR', 'university_rector', 'Recteur d\'Université', 'university_hierarchy', 92, 'Recteur d\'université'),
(UUID(), 'UNIV_VICE_RECTOR', 'vice_rector', 'Vice-Recteur', 'university_hierarchy', 88, 'Vice-recteur'),
(UUID(), 'UNIV_SECRETARY', 'secretary_general', 'Secrétaire Général', 'university_hierarchy', 85, 'Secrétaire général d\'université'),
(UUID(), 'FACULTY_DEAN', 'faculty_dean', 'Doyen de Faculté', 'university_hierarchy', 80, 'Doyen de faculté'),
(UUID(), 'SCHOOL_DIRECTOR', 'school_director', 'Directeur d\'École', 'university_hierarchy', 78, 'Directeur d\'école'),
(UUID(), 'DEPARTMENT_HEAD', 'department_head', 'Chef de Département', 'university_hierarchy', 75, 'Chef de département'),
(UUID(), 'SECTION_HEAD', 'section_head', 'Chef de Section', 'university_hierarchy', 70, 'Chef de section'),
(UUID(), 'PROGRAM_COORD', 'program_coordinator', 'Coordonnateur de Programme', 'university_hierarchy', 68, 'Coordonnateur de programme');

-- Personnel Enseignant
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'PROF_TITULAR', 'professor_titular', 'Professeur Titulaire', 'teaching_staff', 72, 'Professeur titulaire'),
(UUID(), 'PROF_ASSOCIATE', 'professor_associate', 'Professeur Associé', 'teaching_staff', 70, 'Professeur associé'),
(UUID(), 'MASTER_CONF', 'master_conference', 'Maître de Conférences', 'teaching_staff', 68, 'Maître de conférences'),
(UUID(), 'COURSE_HOLDER', 'course_holder', 'Chargé de Cours', 'teaching_staff', 65, 'Chargé de cours'),
(UUID(), 'ASSISTANT', 'assistant_prof', 'Assistant', 'teaching_staff', 60, 'Assistant'),
(UUID(), 'MONITOR', 'monitor', 'Moniteur', 'teaching_staff', 55, 'Moniteur'),
(UUID(), 'TEMP_TEACHER', 'temporary_teacher', 'Enseignant Vacataire', 'teaching_staff', 50, 'Enseignant vacataire'),
(UUID(), 'VISITING_PROF', 'visiting_professor', 'Professeur Visiteur', 'teaching_staff', 65, 'Professeur visiteur'),
(UUID(), 'POSTDOC', 'postdoc_researcher', 'Chercheur Post-Doctorant', 'teaching_staff', 62, 'Chercheur post-doctorant');

-- Personnel Administratif et Technique
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'ADMIN_AGENT', 'administrative_agent', 'Agent Administratif', 'administrative_technical', 45, 'Agent administratif'),
(UUID(), 'SECRETARY', 'secretary', 'Secrétaire', 'administrative_technical', 40, 'Secrétaire'),
(UUID(), 'ACCOUNTANT', 'accountant', 'Comptable', 'administrative_technical', 48, 'Comptable'),
(UUID(), 'LIBRARIAN', 'librarian', 'Bibliothécaire', 'administrative_technical', 50, 'Bibliothécaire'),
(UUID(), 'LAB_TECH', 'lab_technician', 'Technicien de Labo', 'administrative_technical', 52, 'Technicien de laboratoire'),
(UUID(), 'MAINTENANCE_ENG', 'maintenance_engineer', 'Ingénieur Maintenance', 'administrative_technical', 55, 'Ingénieur de maintenance'),
(UUID(), 'SECURITY_AGENT', 'security_agent', 'Agent de Sécurité', 'administrative_technical', 35, 'Agent de sécurité'),
(UUID(), 'CLEANING_STAFF', 'cleaning_staff', 'Agent d\'Entretien', 'administrative_technical', 30, 'Agent d\'entretien'),
(UUID(), 'DRIVER', 'driver', 'Chauffeur', 'administrative_technical', 32, 'Chauffeur'),
(UUID(), 'IT_SUPPORT', 'it_support', 'Support Informatique', 'administrative_technical', 58, 'Support informatique');

-- Représentations Étudiantes
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'STUDENT_EXEC', 'student_executive', 'Membre Bureau Exécutif Étudiants', 'student_representation', 42, 'Membre du bureau exécutif étudiants'),
(UUID(), 'CLASS_DELEGATE', 'class_delegate', 'Délégué de Classe', 'student_representation', 35, 'Délégué de classe'),
(UUID(), 'FACULTY_DELEGATE', 'faculty_delegate', 'Délégué de Faculté', 'student_representation', 38, 'Délégué de faculté'),
(UUID(), 'RESIDENCE_DELEGATE', 'residence_delegate', 'Délégué de Résidence', 'student_representation', 36, 'Délégué de résidence'),
(UUID(), 'CULTURAL_ASSOC_LEADER', 'cultural_association_leader', 'Président Association Culturelle', 'student_representation', 40, 'Président association culturelle'),
(UUID(), 'CLUB_PRESIDENT', 'club_president', 'Président Club Étudiant', 'student_representation', 38, 'Président de club étudiant'),
(UUID(), 'PROMOTION_COORD', 'promotion_coordinator', 'Coordonnateur de Promotion', 'student_representation', 37, 'Coordonnateur de promotion');

-- Partenaires et Sociaux
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'ECONOMIC_PARTNER', 'economic_partner', 'Partenaire Économique', 'partners_social', 60, 'Partenaire économique'),
(UUID(), 'CHAMBER_COMMERCE', 'chamber_commerce', 'Chambre de Commerce', 'partners_social', 62, 'Représentant chambre de commerce'),
(UUID(), 'EMPLOYER_ORG', 'employer_organization', 'Organisation Patronale', 'partners_social', 64, 'Organisation patronale'),
(UUID(), 'BANK_REP', 'bank_representative', 'Représentant Bancaire', 'partners_social', 58, 'Représentant bancaire'),
(UUID(), 'INSURANCE_REP', 'insurance_representative', 'Représentant Assurance', 'partners_social', 56, 'Représentant assurance'),
(UUID(), 'INTL_PARTNER', 'international_partner', 'Partenaire International', 'partners_social', 70, 'Partenaire international'),
(UUID(), 'FOREIGN_EMBASSY', 'foreign_embassy', 'Ambassade Étrangère', 'partners_social', 75, 'Représentant ambassade'),
(UUID(), 'INTL_ORG', 'international_organization', 'Organisation Internationale', 'partners_social', 72, 'Organisation internationale'),
(UUID(), 'NGO_REP', 'ngo_representative', 'Représentant ONG', 'partners_social', 65, 'Représentant ONG');

-- Organisations Sociales
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'SYNDICATE_REP', 'syndicate_representative', 'Représentant Syndical', 'partners_social', 55, 'Représentant syndical'),
(UUID(), 'PARENTS_ASSOC', 'parents_association', 'Association Parents', 'partners_social', 45, 'Association de parents'),
(UUID(), 'ALUMNI_REP', 'alumni_representative', 'Représentant Anciens Étudiants', 'partners_social', 50, 'Représentant des anciens étudiants'),
(UUID(), 'DEV_ASSOC', 'development_association', 'Association Développement', 'partners_social', 48, 'Association de développement'),
(UUID(), 'CIVIL_SOCIETY', 'civil_society_organization', 'Organisation Société Civile', 'partners_social', 52, 'Organisation société civile');

-- Services de Soutien
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'DOC_CENTER', 'documentation_center', 'Centre Documentation', 'support_services', 50, 'Centre de documentation'),
(UUID(), 'ORIENTATION_COUNSELOR', 'orientation_counselor', 'Conseiller Orientation', 'support_services', 54, 'Conseiller en orientation'),
(UUID(), 'MEDICAL_SERVICE', 'medical_service', 'Service Médical', 'support_services', 56, 'Personnel médical'),
(UUID(), 'PSYCHO_SERVICE', 'psychological_service', 'Service Psychologique', 'support_services', 58, 'Service psychologique'),
(UUID(), 'RESTAURANT_SERVICE', 'restaurant_service', 'Service Restauration', 'support_services', 42, 'Service restauration'),
(UUID(), 'HOUSING_SERVICE', 'housing_service', 'Service Hébergement', 'support_services', 45, 'Service hébergement'),
(UUID(), 'SPORTS_SERVICE', 'sports_service', 'Service Sportif', 'support_services', 48, 'Service sportif'),
(UUID(), 'CULTURAL_SERVICE', 'cultural_service', 'Service Culturel', 'support_services', 46, 'Service culturel');

-- Infrastructure et Logistique
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'BUILDING_SERVICE', 'building_service', 'Service Bâtiments', 'infrastructure_logistics', 52, 'Service des bâtiments'),
(UUID(), 'TRANSPORT_SERVICE', 'transport_service', 'Service Transport', 'infrastructure_logistics', 48, 'Service transport'),
(UUID(), 'TELECOM_SERVICE', 'telecommunication_service', 'Service Télécommunication', 'infrastructure_logistics', 55, 'Service télécommunication'),
(UUID(), 'ENERGY_SERVICE', 'energy_service', 'Service Énergie', 'infrastructure_logistics', 50, 'Service énergie'),
(UUID(), 'FIRE_SAFETY', 'fire_safety_service', 'Service Sécurité Incendie', 'infrastructure_logistics', 53, 'Service sécurité incendie');

-- Cadre Juridique et Réglementaire
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'PARLIAMENT_MEMBER', 'parliament_member', 'Membre Parlement', 'legal_regulatory', 85, 'Membre du parlement'),
(UUID(), 'CONSTITUTIONAL_COUNCIL', 'constitutional_council', 'Conseil Constitutionnel', 'legal_regulatory', 90, 'Membre conseil constitutionnel'),
(UUID(), 'SUPREME_COURT', 'supreme_court', 'Cour Suprême', 'legal_regulatory', 88, 'Membre cour suprême'),
(UUID(), 'ADMIN_TRIBUNAL', 'administrative_tribunal', 'Tribunal Administratif', 'legal_regulatory', 80, 'Membre tribunal administratif'),
(UUID(), 'ACCOUNT_COMMISSARY', 'account_commissary', 'Commissaire aux Comptes', 'legal_regulatory', 75, 'Commissaire aux comptes'),
(UUID(), 'LEGAL_ADVISOR', 'legal_advisor', 'Conseiller Juridique', 'legal_regulatory', 70, 'Conseiller juridique');

-- Organismes de Contrôle
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'STATE_CONTROL', 'state_control', 'Contrôle Supérieur État', 'control_organizations', 87, 'Contrôle supérieur de l\'État'),
(UUID(), 'FINANCE_INSPECTION', 'finance_inspection', 'Inspection Finances', 'control_organizations', 85, 'Inspection générale des finances'),
(UUID(), 'ANTI_CORRUPTION', 'anti_corruption_commission', 'Commission Anti-Corruption', 'control_organizations', 82, 'Commission anti-corruption'),
(UUID(), 'GOOD_GOVERNANCE', 'good_governance_observatory', 'Observatoire Bonne Gouvernance', 'control_organizations', 78, 'Observatoire bonne gouvernance');

-- Recherche et Innovation
INSERT INTO `roles` (`uuid`, `code`, `name`, `display_name`, `category`, `level`, `description`) VALUES
(UUID(), 'RESEARCH_CENTER_DIR', 'research_center_director', 'Directeur Centre Recherche', 'research_innovation', 80, 'Directeur centre de recherche'),
(UUID(), 'RESEARCH_LAB_HEAD', 'research_laboratory_head', 'Chef Laboratoire', 'research_innovation', 75, 'Chef laboratoire recherche'),
(UUID(), 'SPECIALIZED_INSTITUTE_DIR', 'specialized_institute_director', 'Directeur Institut Spécialisé', 'research_innovation', 78, 'Directeur institut spécialisé'),
(UUID(), 'EXCELLENCE_POLE_DIR', 'excellence_pole_director', 'Directeur Pôle Excellence', 'research_innovation', 82, 'Directeur pôle excellence'),
(UUID(), 'BUSINESS_INCUBATOR', 'business_incubator_manager', 'Manager Incubateur', 'research_innovation', 72, 'Manager incubateur'),
(UUID(), 'TECH_PARK_MANAGER', 'technology_park_manager', 'Manager Parc Technologique', 'research_innovation', 74, 'Manager parc technologique'),
(UUID(), 'SCIENTIFIC_COMMUNITY', 'scientific_community_member', 'Membre Communauté Scientifique', 'research_innovation', 68, 'Membre communauté scientifique'),
(UUID(), 'ACADEMY_MEMBER', 'academy_member', 'Membre Académie', 'research_innovation', 85, 'Membre académie des sciences'),
(UUID(), 'LEARNED_SOCIETY', 'learned_society_member', 'Membre Société Savante', 'research_innovation', 70, 'Membre société savante'),
(UUID(), 'EDITORIAL_BOARD', 'editorial_board_member', 'Membre Comité Éditorial', 'research_innovation', 65, 'Membre comité éditorial'),
(UUID(), 'SCIENTIFIC_EVALUATOR', 'scientific_evaluator', 'Évaluateur Scientifique', 'research_innovation', 67, 'Évaluateur scientifique'),
(UUID(), 'EXPERT_CONSULTANT', 'expert_consultant', 'Expert Consultant', 'research_innovation', 72, 'Expert consultant');

-- =====================================================
-- 6. INSERTION DES STRUCTURES ORGANISATIONNELLES
-- =====================================================

-- Structures Nationales
INSERT INTO `organizational_structures` (`uuid`, `code`, `name`, `type`, `level`) VALUES
(UUID(), 'MINESUP', 'Ministère de l\'Enseignement Supérieur', 'ministry', 1),
(UUID(), 'MINRESI', 'Ministère Recherche Scientifique Innovation', 'ministry', 1),
(UUID(), 'CNES', 'Conseil National Enseignement Supérieur', 'regulatory_body', 2),
(UUID(), 'CAAQES', 'Agence Accréditation Assurance Qualité', 'regulatory_body', 2),
(UUID(), 'IGES', 'Inspection Générale Enseignement Supérieur', 'control_body', 2),
(UUID(), 'DBS', 'Direction Bourses Stages', 'administrative_unit', 2),
(UUID(), 'DPUP', 'Direction Promotion Universités Privées', 'administrative_unit', 2);

-- Universités Publiques
INSERT INTO `organizational_structures` (`uuid`, `code`, `name`, `type`, `level`) VALUES
(UUID(), 'UY1', 'Université de Yaoundé I', 'university', 2),
(UUID(), 'UY2', 'Université de Yaoundé II', 'university', 2),
(UUID(), 'UD', 'Université de Douala', 'university', 2),
(UUID(), 'UDS', 'Université de Dschang', 'university', 2),
(UUID(), 'UM', 'Université de Maroua', 'university', 2),
(UUID(), 'UB', 'Université de Bamenda', 'university', 2),
(UUID(), 'UBa', 'Université de Buéa', 'university', 2),
(UUID(), 'UN', 'Université de Ngaoundéré', 'university', 2),
(UUID(), 'UG', 'Université de Garoua', 'university', 2);

-- Grandes Écoles
INSERT INTO `organizational_structures` (`uuid`, `code`, `name`, `type`, `level`) VALUES
(UUID(), 'ENS', 'École Normale Supérieure', 'school', 3),
(UUID(), 'ENSP', 'École Nationale Supérieure Polytechnique', 'school', 3),
(UUID(), 'ENAM', 'École Nationale Administration Magistrature', 'school', 3),
(UUID(), 'IRIC', 'Institut Relations Internationales', 'institute', 3),
(UUID(), 'ENSTP', 'École Nationale Supérieure Travaux Publics', 'school', 3),
(UUID(), 'EGEC', 'École Gestion Expertise Comptable', 'school', 3),
(UUID(), 'IUT', 'Institut Universitaire Technologie', 'institute', 3);

-- =====================================================
-- 7. CRÉATION DES VUES POUR LA GESTION DES RÔLES
-- =====================================================

CREATE OR REPLACE VIEW `v_user_roles_complete` AS
SELECT 
    u.id as user_id,
    u.uuid as user_uuid,
    u.first_name,
    u.last_name,
    u.email,
    u.primary_role,
    u.institution_id,
    i.name as institution_name,
    r.id as role_id,
    r.code as role_code,
    r.name as role_name,
    r.display_name as role_display_name,
    r.category as role_category,
    r.level as role_level,
    ura.is_primary,
    ura.is_active as assignment_active,
    ura.assigned_at,
    ura.expires_at,
    os.name as structure_name,
    os.type as structure_type
FROM users u
LEFT JOIN user_role_assignments ura ON u.id = ura.user_id AND ura.is_active = 1
LEFT JOIN roles r ON ura.role_id = r.id
LEFT JOIN institutions i ON u.institution_id = i.id
LEFT JOIN organizational_structures os ON ura.institution_id = os.id
WHERE u.deleted_at IS NULL;

-- Vue pour les statistiques des rôles par institution
CREATE OR REPLACE VIEW `v_role_stats_by_institution` AS
SELECT 
    i.id as institution_id,
    i.name as institution_name,
    r.category as role_category,
    COUNT(DISTINCT u.id) as user_count,
    AVG(r.level) as avg_role_level,
    MAX(r.level) as max_role_level
FROM institutions i
LEFT JOIN users u ON i.id = u.institution_id AND u.deleted_at IS NULL
LEFT JOIN user_role_assignments ura ON u.id = ura.user_id AND ura.is_active = 1
LEFT JOIN roles r ON ura.role_id = r.id
GROUP BY i.id, r.category
ORDER BY i.name, r.category;

-- =====================================================
-- 8. PROCÉDURES STOCKÉES POUR LA GESTION DES RÔLES
-- =====================================================

DELIMITER //

-- Procédure pour assigner un rôle à un utilisateur
CREATE PROCEDURE `AssignRoleToUser`(
    IN p_user_id BIGINT,
    IN p_role_code VARCHAR(50),
    IN p_institution_id BIGINT,
    IN p_assigned_by BIGINT,
    IN p_is_primary BOOLEAN,
    IN p_context JSON
)
BEGIN
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
    
END //

-- Procédure pour retirer un rôle à un utilisateur
CREATE PROCEDURE `RemoveRoleFromUser`(
    IN p_user_id BIGINT,
    IN p_role_id BIGINT,
    IN p_removed_by BIGINT
)
BEGIN
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
    
END //

DELIMITER ;

-- =====================================================
-- 9. TRIGGERS POUR LA MAINTENANCE DE LA COHÉRENCE
-- =====================================================

DELIMITER //

-- Trigger pour maintenir la cohérence des rôles primaires
CREATE TRIGGER `tr_maintain_primary_role`
AFTER INSERT ON `user_role_assignments`
FOR EACH ROW
BEGIN
    IF NEW.is_primary = 1 THEN
        -- Désactiver les autres rôles primaires pour cet utilisateur
        UPDATE user_role_assignments 
        SET is_primary = 0 
        WHERE user_id = NEW.user_id 
        AND id != NEW.id 
        AND is_primary = 1;
        
        -- Mettre à jour le rôle primaire dans users
        UPDATE users 
        SET primary_role = (SELECT name FROM roles WHERE id = NEW.role_id)
        WHERE id = NEW.user_id;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- 10. INDEX DE PERFORMANCE
-- =====================================================

-- Index composites pour les requêtes fréquentes
CREATE INDEX idx_ura_user_role_active ON user_role_assignments(user_id, role_id, is_active);
CREATE INDEX idx_ura_institution_role ON user_role_assignments(institution_id, role_id);
CREATE INDEX idx_users_institution_role ON users(institution_id, primary_role);
CREATE INDEX idx_roles_category_level ON roles(category, level);
CREATE INDEX idx_os_type_level ON organizational_structures(type, level);

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
