-- Suppression et recréation complète de la table preinscriptions
-- Version la plus complète et optimisée possible

-- Supprimer la table existante
DROP TABLE IF EXISTS `preinscriptions`;

-- Recréer la table complète avec tous les champs nécessaires
CREATE TABLE `preinscriptions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID unique de la préinscription',
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID universel unique',
  `unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Code unique de référence',

  -- Informations personnelles de base
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

  -- Informations académiques
  `previous_diploma` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Diplôme précédent (BAC, GCE, BREVET, etc.)',
  `previous_institution` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Établissement précédent',
  `graduation_year` int(4) NULL COMMENT 'Année d\'obtention du diplôme',
  `graduation_month` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Mois d\'obtention',
  `desired_program` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Programme souhaité',
  `study_level` enum('LICENCE','MASTER','DOCTORAT','DUT','BTS','MASTER_PRO','DEUST','AUTRE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Niveau d\'études visé',
  `specialization` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Spécialisation souhaitée',
  `series_bac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Série du BAC (A, B, C, D, E, F, G, H, TI)',
  `bac_year` int(4) NULL COMMENT 'Année du BAC',
  `bac_center` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Centre d\'examen BAC',
  `bac_mention` enum('PASSABLE','ASSEZ_BIEN','BIEN','TRES_BIEN','EXCELLENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Mention au BAC',
  `gpa_score` decimal(4,2) NULL COMMENT 'Score GPA si applicable',
  `rank_in_class` int(6) NULL COMMENT 'Rang dans la classe',

  -- Documents et fichiers
  `birth_certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin certificat naissance',
  `cni_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin CNI/PI',
  `diploma_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin diplôme',
  `transcript_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin relevé de notes',
  `photo_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin photo d\'identité',
  `recommendation_letter_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin lettre de recommandation',
  `motivation_letter_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin lettre de motivation',
  `medical_certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin certificat médical',
  `other_documents_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemins autres documents (JSON)',

  -- Informations parents/tuteurs
  `parent_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Nom complet du parent/tuteur',
  `parent_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Téléphone du parent',
  `parent_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Email du parent',
  `parent_occupation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Profession du parent',
  `parent_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Adresse du parent',
  `parent_relationship` enum('PERE','MERE','TUTEUR','AUTRE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Lien avec le parent',
  `parent_income_level` enum('FAIBLE','MOYEN','ELEVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Niveau de revenu du parent',

  -- Informations financières et paiement
  `payment_method` enum('ORANGE_MONEY','MTN_MONEY','BANK_TRANSFER','CASH','MOBILE_MONEY','CHEQUE','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Méthode de paiement',
  `payment_reference` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Référence de paiement',
  `payment_amount` decimal(10,2) NULL COMMENT 'Montant payé',
  `payment_currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'XAF' COMMENT 'Devise du paiement',
  `payment_date` timestamp NULL COMMENT 'Date de paiement',
  `payment_status` enum('pending','paid','confirmed','refunded','partial') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Statut du paiement',
  `payment_proof_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Chemin preuve de paiement',
  `scholarship_requested` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Bourse demandée ?',
  `scholarship_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Type de bourse',
  `financial_aid_amount` decimal(10,2) NULL COMMENT 'Montant aide financière',

  -- Statuts et suivi
  `status` enum('pending','under_review','accepted','rejected','cancelled','deferred','waitlisted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Statut global',
  `documents_status` enum('pending','submitted','verified','incomplete','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Statut des documents',
  `review_priority` enum('LOW','NORMAL','HIGH','URGENT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NORMAL' COMMENT 'Priorité de révision',
  `reviewed_by` bigint UNSIGNED NULL COMMENT 'ID de l\'administrateur qui a validé',
  `review_date` timestamp NULL COMMENT 'Date de validation/rejet',
  `review_comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Commentaires de révision',
  `rejection_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Motif de rejet',

  -- Entretien et admission
  `interview_required` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Entretien requis ?',
  `interview_date` timestamp NULL COMMENT 'Date d\'entretien',
  `interview_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Lieu d\'entretien',
  `interview_type` enum('PHYSICAL','ONLINE','PHONE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Type d\'entretien',
  `interview_result` enum('PENDING','PASSED','FAILED','NO_SHOW') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Résultat entretien',
  `interview_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Notes entretien',

  -- Admission finale
  `admission_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Numéro d\'admission si accepté',
  `admission_date` timestamp NULL COMMENT 'Date d\'admission',
  `registration_deadline` date NULL COMMENT 'Date limite pour inscription définitive',
  `registration_completed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Inscription complétée ?',
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'ID étudiant final',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Numéro de promotion',

  -- Suivi et communication
  `contact_preference` enum('EMAIL','PHONE','SMS','WHATSAPP') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Préférence de contact',
  `marketing_consent` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Consentement marketing ?',
  `data_processing_consent` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Consentement traitement données ?',
  `newsletter_subscription` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Abonnement newsletter ?',

  -- Informations système et suivi
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Adresse IP de soumission',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Navigateur utilisé',
  `device_type` enum('DESKTOP','MOBILE','TABLET','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Type d\'appareil',
  `browser_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Informations navigateur',
  `os_info` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Système d\'exploitation',
  `location_country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Pays de soumission',
  `location_city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Ville de soumission',

  -- Notes et commentaires
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Notes générales',
  `admin_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Notes administrateur',
  `internal_comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Commentaires internes',
  `special_needs` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Besoins spéciaux',
  `medical_conditions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Conditions médicales',

  -- Timestamps et tracking
  `submission_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de soumission',
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière mise à jour',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date de modification',
  `deleted_at` timestamp NULL COMMENT 'Date de suppression (soft delete)',

  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_code` (`unique_code`),
  UNIQUE KEY `idx_uuid` (`uuid`),
  UNIQUE KEY `idx_admission_number` (`admission_number`),
  UNIQUE KEY `idx_student_id` (`student_id`),
  
  -- Index pour optimisation
  KEY `idx_faculty` (`faculty`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_documents_status` (`documents_status`),
  KEY `idx_submission_date` (`submission_date`),
  KEY `idx_email` (`email`),
  KEY `idx_phone` (`phone_number`),
  KEY `idx_desired_program` (`desired_program`),
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
  KEY `idx_parent_email` (`parent_email`),
  KEY `idx_batch_number` (`batch_number`),
  KEY `idx_deleted_at` (`deleted_at`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_updated_at` (`updated_at`),

  -- Index composites
  KEY `idx_faculty_status` (`faculty`, `status`),
  KEY `idx_program_level` (`desired_program`, `study_level`),
  KEY `idx_payment_status_date` (`payment_status`, `payment_date`),
  KEY `idx_review_status_date` (`status`, `review_date`),

  -- Contraintes de vérification
  CONSTRAINT `chk_graduation_year` CHECK (`graduation_year` >= 1900 AND `graduation_year` <= 2100),
  CONSTRAINT `chk_bac_year` CHECK (`bac_year` >= 1900 AND `bac_year` <= 2100),
  CONSTRAINT `chk_payment_amount` CHECK (`payment_amount` >= 0),
  CONSTRAINT `chk_gpa_score` CHECK (`gpa_score` >= 0.00 AND `gpa_score` <= 5.00),
  CONSTRAINT `chk_rank_in_class` CHECK (`rank_in_class` >= 1),
  CONSTRAINT `chk_financial_aid_amount` CHECK (`financial_aid_amount` >= 0)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table complète des préinscriptions universitaires avec tous les champs nécessaires';

-- Créer des vues utiles pour les rapports
CREATE VIEW `v_preinscriptions_summary` AS
SELECT 
    id,
    unique_code,
    faculty,
    last_name,
    first_name,
    email,
    phone_number,
    desired_program,
    study_level,
    status,
    payment_status,
    submission_date,
    CASE 
        WHEN status = 'accepted' THEN 'Admis'
        WHEN status = 'rejected' THEN 'Rejeté'
        WHEN status = 'pending' THEN 'En attente'
        WHEN status = 'under_review' THEN 'En cours'
        ELSE status
    END as status_fr
FROM preinscriptions 
WHERE deleted_at IS NULL;

CREATE VIEW `v_preinscriptions_stats` AS
SELECT 
    faculty,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'accepted' THEN 1 END) as accepted_count,
    COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_count,
    COUNT(CASE WHEN payment_status = 'paid' THEN 1 END) as paid_count,
    SUM(CASE WHEN payment_amount > 0 THEN payment_amount ELSE 0 END) as total_revenue
FROM preinscriptions 
WHERE deleted_at IS NULL
GROUP BY faculty;

-- Créer des triggers pour le suivi automatique
DELIMITER //
CREATE TRIGGER `tr_preinscriptions_before_insert` 
BEFORE INSERT ON `preinscriptions` 
FOR EACH ROW
BEGIN
    -- Générer un code unique si non fourni
    IF NEW.unique_code IS NULL OR NEW.unique_code = '' THEN
        SET NEW.unique_code = CONCAT('PRE', YEAR(NOW()), LPAD(CONNECTION_ID(), 6, '0'));
    END IF;
    
    -- Générer un UUID si non fourni
    IF NEW.uuid IS NULL OR NEW.uuid = '' THEN
        SET NEW.uuid = UUID();
    END IF;
END//

CREATE TRIGGER `tr_preinscriptions_before_update` 
BEFORE UPDATE ON `preinscriptions` 
FOR EACH ROW
BEGIN
    -- Mettre à jour la date de révision si le statut change
    IF OLD.status != NEW.status AND NEW.status IN ('accepted', 'rejected') THEN
        SET NEW.review_date = NOW();
    END IF;
    
    -- Mettre à jour la date de paiement si le statut de paiement change
    IF OLD.payment_status != NEW.payment_status AND NEW.payment_status = 'paid' THEN
        SET NEW.payment_date = NOW();
    END IF;
END//
DELIMITER ;

-- Afficher un message de succès
SELECT 'Table preinscriptions recréée avec succès!' as message;
