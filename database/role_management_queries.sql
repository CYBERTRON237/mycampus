-- =====================================================
-- REQUÊTES SQL POUR LA GESTION DES RÔLES ET UTILISATEURS
-- =====================================================
-- Ce script contient les requêtes essentielles pour gérer tous les acteurs
-- du système universitaire camerounais

-- =====================================================
-- 1. REQUÊTES D'INSERTION POUR CHAQUE CATÉGORIE D'ACTEURS
-- =====================================================

-- Insertion générique pour Acteurs Institutionnels Nationaux
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 
    1, -- Institution nationale
    'MATRICULE_SPECIFIQUE', 
    'email@domaine.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password par défaut
    'Prénom', 
    'Nom', 
    '+2376XXXXXXXX', 
    'CODE_ROLE', 
    'active', 
    1, 
    1
);

-- Insertion pour Hiérarchie Universitaire
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 
    (SELECT id FROM institutions WHERE code = 'CODE_UNIVERSITE'), 
    'MATRICULE_UNIVERSITE', 
    'email@universite.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Prénom', 
    'Nom', 
    '+2376XXXXXXXX', 
    'ROLE_HIERARCHIE', 
    'active', 
    1, 
    1
);

-- Insertion pour Personnel Enseignant
INSERT INTO `users` (
    uuid, institution_id, matricule, email, password_hash, first_name, last_name, 
    phone, primary_role, account_status, is_verified, is_active
) VALUES (
    UUID(), 
    (SELECT id FROM institutions WHERE code = 'CODE_UNIVERSITE'), 
    'MATRICULE_ENSEIGNANT', 
    'email@universite.cm', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'Prénom', 
    'Nom', 
    '+2376XXXXXXXX', 
    'ROLE_ENSEIGNANT', 
    'active', 
    1, 
    1
);

-- =====================================================
-- 2. PROCÉDURES D'ASSIGNATION DE RÔLES MULTIPLES
-- =====================================================

-- Assigner un rôle primaire à un utilisateur
INSERT INTO `user_role_assignments` (
    uuid, user_id, role_id, institution_id, assigned_by, is_primary, is_active, context
) VALUES (
    UUID(),
    (SELECT id FROM users WHERE email = 'email_utilisateur'),
    (SELECT id FROM roles WHERE code = 'CODE_ROLE'),
    (SELECT id FROM institutions WHERE code = 'CODE_INSTITUTION'),
    (SELECT id FROM users WHERE primary_role = 'superadmin' LIMIT 1),
    1, -- Rôle primaire
    1, -- Actif
    JSON_OBJECT('department', 'NOM_DEPARTEMENT', 'faculty', 'NOM_FACULTE')
);

-- Assigner un rôle secondaire à un utilisateur
INSERT INTO `user_role_assignments` (
    uuid, user_id, role_id, institution_id, assigned_by, is_primary, is_active, context
) VALUES (
    UUID(),
    (SELECT id FROM users WHERE email = 'email_utilisateur'),
    (SELECT id FROM roles WHERE code = 'CODE_ROLE_SECONDAIRE'),
    (SELECT id FROM institutions WHERE code = 'CODE_INSTITUTION'),
    (SELECT id FROM users WHERE primary_role = 'superadmin' LIMIT 1),
    0, -- Rôle secondaire
    1, -- Actif
    JSON_OBJECT('responsibility', 'RESPONSABILITE_SPECIFIQUE')
);

-- =====================================================
-- 3. REQUÊTES DE RECHERCHE ET FILTRAGE
-- =====================================================

-- Rechercher tous les utilisateurs par catégorie de rôle
SELECT 
    u.id, u.first_name, u.last_name, u.email, u.primary_role,
    r.display_name as role_display, r.category as role_category,
    i.name as institution_name,
    GROUP_CONCAT(r2.display_name SEPARATOR ', ') as secondary_roles
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
LEFT JOIN institutions i ON u.institution_id = i.id
LEFT JOIN user_role_assignments ura ON u.id = ura.user_id AND ura.is_active = 1
LEFT JOIN roles r2 ON ura.role_id = r2.id AND ura.is_primary = 0
WHERE u.deleted_at IS NULL
AND r.category = 'NOM_CATEGORIE' -- Remplacer par la catégorie souhaitée
GROUP BY u.id
ORDER BY u.last_name, u.first_name;

-- Rechercher tous les acteurs d'une institution spécifique
SELECT 
    u.id, u.first_name, u.last_name, u.email, u.primary_role,
    r.display_name as role_display, r.category as role_category,
    r.level as permission_level
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
WHERE u.institution_id = (SELECT id FROM institutions WHERE code = 'CODE_UNIVERSITE')
AND u.deleted_at IS NULL
ORDER BY r.level DESC, u.last_name, u.first_name;

-- Rechercher les utilisateurs avec des permissions élevées (niveau >= 80)
SELECT 
    u.id, u.first_name, u.last_name, u.email,
    r.display_name as role_display, r.level as permission_level,
    i.name as institution_name
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
LEFT JOIN institutions i ON u.institution_id = i.id
WHERE r.level >= 80
AND u.deleted_at IS NULL
ORDER BY r.level DESC, i.name, u.last_name;

-- Rechercher tous les rôles actifs par catégorie
SELECT 
    r.id, r.code, r.name, r.display_name, r.category, r.level,
    COUNT(ura.user_id) as user_count
FROM roles r
LEFT JOIN user_role_assignments ura ON r.id = ura.role_id AND ura.is_active = 1
WHERE r.is_active = 1
GROUP BY r.id
ORDER BY r.category, r.level DESC;

-- =====================================================
-- 4. REQUÊTES DE STATISTIQUES
-- =====================================================

-- Statistiques des utilisateurs par catégorie de rôle
SELECT 
    r.category as role_category,
    COUNT(DISTINCT u.id) as total_users,
    AVG(r.level) as avg_permission_level,
    MAX(r.level) as max_permission_level,
    COUNT(DISTINCT u.institution_id) as institutions_count
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
WHERE u.deleted_at IS NULL
GROUP BY r.category
ORDER BY total_users DESC;

-- Statistiques des rôles par institution
SELECT 
    i.name as institution_name,
    r.category as role_category,
    COUNT(DISTINCT u.id) as user_count,
    GROUP_CONCAT(DISTINCT r.display_name ORDER BY r.level DESC SEPARATOR ', ') as roles_in_category
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
LEFT JOIN institutions i ON u.institution_id = i.id
WHERE u.deleted_at IS NULL
GROUP BY i.id, r.category
ORDER BY i.name, r.category;

-- Répartition des niveaux de permission
SELECT 
    CASE 
        WHEN r.level >= 90 THEN 'Niveau Élevé (90-100)'
        WHEN r.level >= 70 THEN 'Niveau Moyen-Élevé (70-89)'
        WHEN r.level >= 50 THEN 'Niveau Moyen (50-69)'
        WHEN r.level >= 30 THEN 'Niveau Bas-Moyen (30-49)'
        ELSE 'Niveau Bas (0-29)'
    END as permission_range,
    COUNT(DISTINCT u.id) as user_count,
    ROUND(COUNT(DISTINCT u.id) * 100.0 / (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL), 2) as percentage
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
WHERE u.deleted_at IS NULL
GROUP BY permission_range
ORDER BY MIN(r.level) DESC;

-- =====================================================
-- 5. REQUÊTES DE GESTION DES PERMISSIONS
-- =====================================================

-- Vérifier si un utilisateur a une permission spécifique
SELECT 
    u.id, u.first_name, u.last_name, u.email,
    r.display_name as role_display, r.level as permission_level,
    CASE 
        WHEN r.level >= 80 THEN 'Accès complet administration'
        WHEN r.level >= 70 THEN 'Accès gestion académique'
        WHEN r.level >= 60 THEN 'Accès enseignement avancé'
        WHEN r.level >= 50 THEN 'Accès enseignement de base'
        WHEN r.level >= 40 THEN 'Accès représentation étudiante'
        ELSE 'Accès utilisateur standard'
    END as access_level
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
WHERE u.id = USER_ID; -- Remplacer USER_ID par l'ID de l'utilisateur

-- Lister les utilisateurs pouvant gérer d'autres utilisateurs
SELECT 
    u.id, u.first_name, u.last_name, u.email,
    r.display_name as role_display, r.level as permission_level,
    i.name as institution_name,
    CASE 
        WHEN r.level >= 90 THEN 'Peut gérer tous les utilisateurs nationaux'
        WHEN r.level >= 80 THEN 'Peut gérer tous les utilisateurs institutionnels'
        WHEN r.level >= 70 THEN 'Peut gérer les utilisateurs académiques'
        ELSE 'Permissions limitées'
    END as management_scope
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
LEFT JOIN institutions i ON u.institution_id = i.id
WHERE r.level >= 70 -- Niveau minimum pour gestion
AND u.deleted_at IS NULL
ORDER BY r.level DESC, i.name;

-- =====================================================
-- 6. REQUÊTES D'AUDIT ET DE CONFORMITÉ
-- =====================================================

-- Historique des assignations de rôles pour un utilisateur
SELECT 
    ura.id, ura.assigned_at, ura.expires_at,
    ura.is_primary, ura.is_active,
    r.display_name as role_display,
    i.name as institution_name,
    CONCAT(assigner.first_name, ' ', assigner.last_name) as assigned_by_name
FROM user_role_assignments ura
LEFT JOIN roles r ON ura.role_id = r.id
LEFT JOIN institutions i ON ura.institution_id = i.id
LEFT JOIN users assigner ON ura.assigned_by = assigner.id
WHERE ura.user_id = USER_ID -- Remplacer USER_ID
ORDER BY ura.assigned_at DESC;

-- Utilisateurs avec des rôles incohérents (niveau de permission trop bas pour le rôle)
SELECT 
    u.id, u.first_name, u.last_name, u.email,
    u.primary_role, r.display_name as role_display, r.level as current_level,
    CASE 
        WHEN u.primary_role = 'rector' AND r.level < 92 THEN 'Niveau trop bas pour recteur'
        WHEN u.primary_role = 'dean' AND r.level < 80 THEN 'Niveau trop bas pour doyen'
        WHEN u.primary_role = 'professor_titular' AND r.level < 72 THEN 'Niveau trop bas pour prof titulaire'
        ELSE 'Niveau approprié'
    END as level_check
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
WHERE u.deleted_at IS NULL
AND (
    (u.primary_role = 'rector' AND r.level < 92) OR
    (u.primary_role = 'dean' AND r.level < 80) OR
    (u.primary_role = 'professor_titular' AND r.level < 72)
);

-- =====================================================
-- 7. REQUÊTES DE MISE À JOUR EN MASSE
-- =====================================================

-- Mettre à jour tous les rôles primaires selon une nouvelle matrice de permissions
UPDATE users u
SET primary_role = CASE 
    WHEN u.primary_role = 'rector' THEN 'rector'
    WHEN u.primary_role = 'dean' THEN 'faculty_dean'
    WHEN u.primary_role = 'teacher' THEN 'professor_associate'
    ELSE u.primary_role
END
WHERE u.deleted_at IS NULL;

-- Désactiver toutes les assignations de rôles expirées
UPDATE user_role_assignments 
SET is_active = 0, updated_at = NOW()
WHERE expires_at IS NOT NULL 
AND expires_at < NOW()
AND is_active = 1;

-- =====================================================
-- 8. REQUÊTES DE RECHERCHE AVANCÉE
-- =====================================================

-- Rechercher des utilisateurs par combinaison de critères
SELECT 
    u.id, u.first_name, u.last_name, u.email, u.phone,
    r.display_name as primary_role_display,
    i.name as institution_name,
    GROUP_CONCAT(r2.display_name SEPARATOR ', ') as all_roles
FROM users u
LEFT JOIN roles r ON u.primary_role = r.name
LEFT JOIN institutions i ON u.institution_id = i.id
LEFT JOIN user_role_assignments ura ON u.id = ura.user_id AND ura.is_active = 1
LEFT JOIN roles r2 ON ura.role_id = r2.id
WHERE u.deleted_at IS NULL
AND (
    -- Filtres personnalisables
    (r.category = 'university_hierarchy' OR r.category = 'teaching_staff')
    AND (i.region = 'Centre' OR i.region = 'Littoral')
    AND u.is_active = 1
)
GROUP BY u.id
ORDER BY i.name, r.level DESC, u.last_name;

-- Rechercher les doublons potentiels (même email ou matricule)
SELECT 
    email, COUNT(*) as email_count,
    GROUP_CONCAT(CONCAT(first_name, ' ', last_name) SEPARATOR ' | ') as users
FROM users
WHERE deleted_at IS NULL
GROUP BY email
HAVING COUNT(*) > 1;

-- =====================================================
-- 9. REQUÊTES D'EXPORTATION
-- =====================================================

-- Export complet des utilisateurs avec tous leurs rôles
SELECT 
    u.uuid, u.matricule, u.email, u.first_name, u.last_name, u.phone,
    u.primary_role, u.account_status, u.is_active, u.created_at,
    i.name as institution_name, i.type as institution_type,
    r.display_name as role_display, r.category as role_category, r.level as permission_level,
    GROUP_CONCAT(
        CONCAT(r2.display_name, ' (', CASE WHEN ura2.is_primary = 1 THEN 'Primaire' ELSE 'Secondaire' END, ')')
        ORDER BY r2.level DESC
        SEPARATOR '; '
    ) as all_roles
FROM users u
LEFT JOIN institutions i ON u.institution_id = i.id
LEFT JOIN roles r ON u.primary_role = r.name
LEFT JOIN user_role_assignments ura2 ON u.id = ura2.user_id AND ura2.is_active = 1
LEFT JOIN roles r2 ON ura2.role_id = r2.id
WHERE u.deleted_at IS NULL
GROUP BY u.id
ORDER BY i.name, r.category, u.last_name;

-- =====================================================
-- 10. REQUÊTES DE NETTOYAGE ET MAINTENANCE
-- =====================================================

-- Nettoyer les assignations de rôles orphelines
DELETE FROM user_role_assignments 
WHERE user_id NOT IN (SELECT id FROM users WHERE deleted_at IS NULL)
OR role_id NOT IN (SELECT id FROM roles WHERE is_active = 1);

-- Mettre à jour les statistiques des institutions
UPDATE institutions i
SET total_students = (
    SELECT COUNT(*) 
    FROM users u 
    WHERE u.institution_id = i.id 
    AND u.primary_role = 'student' 
    AND u.deleted_at IS NULL
),
total_staff = (
    SELECT COUNT(*) 
    FROM users u 
    WHERE u.institution_id = i.id 
    AND u.primary_role != 'student' 
    AND u.deleted_at IS NULL
);

-- =====================================================
-- FIN DES REQUÊTES DE GESTION
-- =====================================================
