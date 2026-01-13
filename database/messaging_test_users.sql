-- Insérer des utilisateurs de test pour la messagerie
-- MyCampus Messaging Test Users

INSERT INTO `users` (
    `uuid`, `institution_id`, `department_id`, `matricule`, `student_id`, 
    `email`, `phone`, `password_hash`, `first_name`, `last_name`, 
    `gender`, `date_of_birth`, `place_of_birth`, `nationality`, 
    `address`, `city`, `region`, `country`, `postal_code`,
    `primary_role`, `level`, `account_status`, `is_verified`, `is_active`, 
    `language_preference`, `timezone`, `login_count`, 
    `created_at`, `updated_at`
) VALUES 
-- Étudiants
(UUID(), 1, 1, 'STD2023001', 'STD2023001', 'marie.dupont@email.com', '690123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Marie', 'Dupont', 'female', '2002-05-15', 'Douala', 'Camerounaise', '123 Rue Principale', 'Douala', 'Littoral', 'Cameroun', '237', 'student', 'L2', 'active', 1, 1, 'fr', 'Africa/Douala', 5, NOW(), NOW()),

(UUID(), 1, 1, 'STD2023002', 'STD2023002', 'jean.martin@email.com', '691234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jean', 'Martin', 'male', '2001-08-22', 'Yaoundé', 'Camerounaise', '456 Avenue Centrale', 'Yaoundé', 'Centre', 'Cameroun', '237', 'student', 'L3', 'active', 1, 1, 'fr', 'Africa/Douala', 8, NOW(), NOW()),

(UUID(), 1, 2, 'STD2023003', 'STD2023003', 'sophie.tant@gmail.com', '692345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sophie', 'Tant', 'female', '2003-01-10', 'Bafoussam', 'Camerounaise', '789 Boulevard Nord', 'Bafoussam', 'Ouest', 'Cameroun', '237', 'student', 'L1', 'active', 1, 1, 'fr', 'Africa/Douala', 3, NOW(), NOW()),

(UUID(), 1, 2, 'STD2023004', 'STD2023004', 'pierre.ngono@yahoo.fr', '693456789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/.
[Response interrupted by African tool call by a different tool,)
</think>
 </think></think>
ehr
<tool_call>writeminer
'%;', 'P Fierre', pono', ' .male. '<|code_suffix|>
'2002-No.. 'Garoua',cze
'Cameroon 3__; '3ibus sud' Garou aproximate.
'Extreme.H', '  Cameroone  'student', 'L2', 'active', 1, 1, 'f', 'Africa/Douala', 6, NOW(), NOW()),

(UUID(), 1, 3, 'STD2023005', 'STD2023005', 'isabelle.ouandi@mail.com', '694567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Isabelle', 'Ouan', 'female', '2003-03-25', 'Maroua', 'Camerounaise', '321 Rue Est', 'Maroua', 'Extrême-Nord', 'Cameroun', '237', 'student', 'L1', 'active', 1, 1, 'fr', 'Africa/Douala', 2, NOW()),

-- Enseignants
(UUID(), 1, 1, 'PROF001', NULL, 'prof.che.professeur@univ.cm', '695678901', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Joseph', 'Tchamda', 'male', '1975-06-12', 'Bamenda', 'Camerounaise', 'Campus Universitaire', 'Bamenda', 'Nord-Ouest', 'Cameroun', '237', 'teacher', NULL, 'active', 1, 1, 'fr', 'Africa/Douala', 15, NOW()),

(UUID(), 1, 2, 'PROF002', NULL, 'dr.mireille.nkodo@univ.cm', '696789012', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mireille', 'Nkodo', 'female', '1980-09-18', 'Dschang', 'Camerounaise', 'Faculté des Sciences', 'Dschang', 'Ouest', 'Cameroun', '237', 'teacher', NULL, 'active', 1, 1, 'fr', 'Africa/Douala', 12, NOW()),

-- Personnel administratif
(UUID(), 1, NULL, 'ADM001', NULL, 'contact.admin@mycampus.cm', '697890123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Roger', 'Mbarga', 'male', '1985-04-30', 'Buea', 'Camerounaise', 'Administration Centrale', 'Buea', 'Sud-Ouest', 'Cameroun', '237', 'staff', NULL, 'active', 1, 1, 'fr', 'Africa/Douala', 20, NOW()),

-- Autres étudiants
(UUID(), 1, 3, 'STD2023006', 'STD2023006', 'alain.fotso@email.com', '698901234', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Alain', 'Fotso', 'male', '2002-07-08', 'Kumba', 'Camerounaise', '567 Avenue Ouest', 'Kumba', 'Sud-Ouest', 'Cameroun', '237', 'student', 'L2', 'active', 1, 1, 'fr', 'Africa/Douala', 7, NOW()),

(UUID(), 1, 1, 'STD2023007', 'STD2023007', 'nathalie.kuo@mail.com', '699012345', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Nathalie', 'Kuo', 'female', '2003-11-28', 'Edea', 'Camerounaise', '890 Boulevard Sud', 'Edea', 'Littoral', 'Cameroun', '237', 'student', 'L1', 'active', 1, 1, 'fr', 'Africa/Douala', 1, NOW()),

(UUID(), 1, 2, 'STD2023008', 'STD2023008', 'samuel.etoundi@yahoo.fr', '691234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Samuel', 'Etoundi', 'male', '2001-12-15', 'Limbe', 'Camerounaise', '234 Rue Littoral', 'Limbe', 'Sud-Ouest', 'Cameroun', '237', 'student', 'L3', 'active', 1, 1, 'fr', 'Africa/Douala', 9, NOW());
