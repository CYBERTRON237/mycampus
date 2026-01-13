-- =====================================================
-- INSERTION D'UTILISATEURS EXEMPLES POUR TOUS LES ACTEURS
-- =====================================================
-- Ce script contient des exemples d'insertion pour chaque type d'acteur
-- du système universitaire camerounais

-- =====================================================
-- 1. ACTEURS INSTITUTIONNELS NATIONAUX
-- =====================================================

-- Ministre de l'Enseignement Supérieur
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'MIN001', 'minister@minesup.gov.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Jean', 'Pierre', '+237699000001', 'ministry_official', 'active', 1, 1
);

-- Secrétaire Général MINESUP
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'MIN002', 'sg@minesup.gov.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Marie', 'Mbarga', '+237699000002', 'ministry_secretary_general', 'active', 1, 1
);

-- Président CNES
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'CNES001', 'president@cnes.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Joseph', 'Etoa', '+237699000003', 'cnes_president', 'active', 1, 1
);

-- Directeur CAAQES
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'CAAQES001', 'directeur@caaques.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Sophie', 'Ngo', '+237699000004', 'caaques_director', 'active', 1, 1
);

-- =====================================================
-- 2. HIÉRARCHIE UNIVERSITAIRE
-- =====================================================

-- Recteur Université de Yaoundé I
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'RECTUY1001', 'recteur@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Aristide', 'Fotso', '+237699000010', 'rector', 'active', 1, 1
);

-- Vice-Recteur Université de Douala
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'VRECTUD2001', 'vice.recteur@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Claudine', 'Tchamda', '+237699000011', 'vice_rector', 'active', 1, 1
);

-- Doyen Faculté des Sciences UY1
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'DEANUY1001', 'dean.sciences@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Pierre', 'Mvondo', '+237699000012', 'faculty_dean', 'active', 1, 1
);

-- Directeur ENS Yaoundé
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'DIRNSY1001', 'directeur@ens.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Emmanuel', 'Njoh', '+237699000013', 'school_director', 'active', 1, 1
);

-- Chef de Département Mathématiques UY1
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'CHEFDPT001', 'head.math@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Michel', 'Owona', '+237699000014', 'department_head', 'active', 1, 1
);

-- =====================================================
-- 3. PERSONNEL ENSEIGNANT
-- =====================================================

-- Professeur Titulaire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'PROFTIT001', 'prof.titulaire@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Jean', 'Ngueguim', '+237699000020', 'professor_titular', 'active', 1, 1
);

-- Maître de Conférences
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'MASTERCONF001', 'm.conf@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Catherine', 'Mballa', '+237699000021', 'master_conference', 'active', 1, 1
);

-- Chargé de Cours
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'CHARGEC001', 'c.holder@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Paul', 'Tchoundjeu', '+237699000022', 'course_holder', 'active', 1, 1
);

-- Assistant
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'ASSIST001', 'assistant@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Brigitte', 'Moukouri', '+237699000023', 'assistant', 'active', 1, 1
);

-- Moniteur
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'MONITOR001', 'monitor@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Eric', 'Fotie', '+237699000024', 'monitor', 'active', 1, 1
);

-- =====================================================
-- 4. PERSONNEL ADMINISTRATIF ET TECHNIQUE
-- =====================================================

-- Agent Administratif
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'ADMINAG001', 'admin.agent@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Jacques', 'Mballa', '+237699000030', 'administrative_agent', 'active', 1, 1
);

-- Secrétaire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'SECRETARY001', 'secretary@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Esther', 'Ngo Nga', '+237699000031', 'secretary', 'active', 1, 1
);

-- Comptable
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'COMPTABLE001', 'comptable@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Alain', 'Mvondo', '+237699000032', 'accountant', 'active', 1, 1
);

-- Bibliothécaire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'LIBRARIAN001', 'bibliothecaire@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Monique', 'Etoa', '+237699000033', 'librarian', 'active', 1, 1
);

-- Technicien de Laboratoire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'LABTECH001', 'lab.tech@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Philippe', 'Njike', '+237699000034', 'lab_technician', 'active', 1, 1
);

-- Support Informatique
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'ITSUPPORT001', 'it.support@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Christian', 'Tchuenkam', '+237699000035', 'it_support', 'active', 1, 1
);

-- =====================================================
-- 5. REPRÉSENTATIONS ÉTUDIANTES
-- =====================================================

-- Membre Bureau Exécutif Étudiants
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'STUDEXEC001', 'student.exec@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Patrice', 'Kamga', '+237699000040', 'student_executive', 'active', 1, 1
);

-- Délégué de Classe
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'CLASSDEL001', 'delegate.class@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Sandrine', 'Mouangue', '+237699000041', 'class_delegate', 'active', 1, 1
);

-- Président Association Culturelle
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'CULTASSOC001', 'president.cultural@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Bertrand', 'Nkoum', '+237699000042', 'cultural_association_leader', 'active', 1, 1
);

-- =====================================================
-- 6. PARTENAIRES ET SOCIAUX
-- =====================================================

-- Représentant Chambre de Commerce
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'CHAMBER001', 'rep@gicam.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'André', 'Bikoko', '+237699000050', 'chamber_commerce', 'active', 1, 1
);

-- Représentant Bancaire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'BANKREP001', 'rep@bank.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'François', 'Mbida', '+237699000051', 'bank_representative', 'active', 1, 1
);

-- Représentant ONG
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'NGOREP001', 'rep@ngo.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Céline', 'Noumi', '+237699000052', 'ngo_representative', 'active', 1, 1
);

-- =====================================================
-- 7. SERVICES DE SOUTIEN
-- =====================================================

-- Conseiller Orientation
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'ORIENT001', 'counselor@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Laurent', 'Tchuente', '+237699000060', 'orientation_counselor', 'active', 1, 1
);

-- Service Médical
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'MEDICAL001', 'medical@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Dr. Jeanne', 'Mballa', '+237699000061', 'medical_service', 'active', 1, 1
);

-- Service Psychologique
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'PSYCHO001', 'psychology@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Dr. Marie', 'Fotsing', '+237699000062', 'psychological_service', 'active', 1, 1
);

-- =====================================================
-- 8. RECHERCHE ET INNOVATION
-- =====================================================

-- Directeur Centre Recherche
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'RESEARCHDIR001', 'director.research@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Prof. Samuel', 'Njine', '+237699000070', 'research_center_director', 'active', 1, 1
);

-- Chef Laboratoire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 4, 'LABHEAD001', 'lab.head@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Prof. Thérèse', 'Ongla', '+237699000071', 'research_laboratory_head', 'active', 1, 1
);

-- Membre Académie des Sciences
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'ACADEMY001', 'member@academy.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Prof. Jacques', 'Fame Ndongo', '+237699000072', 'academy_member', 'active', 1, 1
);

-- =====================================================
-- 9. ÉTUDIANTS (POUR TESTS)
-- =====================================================

-- Étudiant L1
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active, level
) VALUES (
    UUID(), 2, 'STU2024001', 'student.l1@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Jean', 'Tchamda', '+237699000100', 'student', 'active', 1, 1, 'L1'
);

-- Étudiant M1
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active, level
) VALUES (
    UUID(), 4, 'STU2024002', 'student.m1@ud.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Marie', 'Etoa', '+237699000101', 'student', 'active', 1, 1, 'M1'
);

-- =====================================================
-- 10. ASSIGNATIONS DE RÔLES MULTIPLES (EXEMPLES)
-- =====================================================

-- Assigner des rôles supplémentaires à certains utilisateurs
-- Le Recteur a aussi un rôle de professeur
INSERT INTO `user_role_assignments` (
    uuid, user_id, role_id, institution_id, assigned_by, is_primary, is_active
) VALUES (
    UUID(), 
    (SELECT id FROM users WHERE email = 'recteur@uy1.cm'),
    (SELECT id FROM roles WHERE code = 'PROF_TITULAR'),
    (SELECT id FROM institutions WHERE code = 'UY1'),
    1, 0, 1
);

-- Le Doyen a aussi un rôle de maître de conférences
INSERT INTO `user_role_assignments` (
    uuid, user_id, role_id, institution_id, assigned_by, is_primary, is_active
) VALUES (
    UUID(), 
    (SELECT id FROM users WHERE email = 'dean.sciences@uy1.cm'),
    (SELECT id FROM roles WHERE code = 'MASTER_CONF'),
    (SELECT id FROM institutions WHERE code = 'UY1'),
    1, 0, 1
);

-- L'étudiant délégué a aussi un rôle de membre bureau exécutif
INSERT INTO `user_role_assignments` (
    uuid, user_id, role_id, institution_id, assigned_by, is_primary, is_active
) VALUES (
    UUID(), 
    (SELECT id FROM users WHERE email = 'delegate.class@uy1.cm'),
    (SELECT id FROM roles WHERE code = 'STUDENT_EXEC'),
    (SELECT id FROM institutions WHERE code = 'UY1'),
    1, 0, 1
);

-- =====================================================
-- 11. UTILISATEURS AVEC PERMISSIONS ÉLEVÉES
-- =====================================================

-- Superadmin du système
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'SUPER001', 'superadmin@mycampus.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'System', 'Administrator', '+237699000999', 'superadmin', 'active', 1, 1
);

-- Admin National
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 1, 'ADMINNAT001', 'admin.national@mycampus.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'National', 'Administrator', '+237699000998', 'admin_national', 'active', 1, 1
);

-- Admin Local (pour chaque université)
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 2, 'ADMINLOC001', 'admin.local@uy1.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'UY1', 'Administrator', '+237699000997', 'admin_local', 'active', 1, 1
);

-- =====================================================
-- FIN DU SCRIPT D'INSERTION
-- =====================================================
