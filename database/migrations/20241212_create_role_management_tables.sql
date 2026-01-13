-- Migration pour la gestion hiérarchique des rôles et permissions
-- Créée le 12/12/2025

-- Table des rôles hiérarchiques
DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `level` int UNSIGNED NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `permissions` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `level` (`level`),
  KEY `is_system` (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des permissions
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table pivot role_permission
DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` bigint UNSIGNED NOT NULL,
  `permission_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_role_permission` (`role_id`,`permission_id`),
  KEY `role_id` (`role_id`),
  KEY `permission_id` (`permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table user_roles pour gérer les rôles multiples par utilisateur
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE IF NOT EXISTS `user_roles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `role_id` bigint UNSIGNED NOT NULL,
  `assigned_by` bigint UNSIGNED DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_role_active` (`user_id`,`role_id`,`is_active`),
  KEY `user_id` (`user_id`),
  KEY `role_id` (`role_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `expires_at` (`expires_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des rôles de base avec hiérarchie
INSERT INTO `roles` (`name`, `display_name`, `description`, `level`, `is_system`, `permissions`) VALUES
('superadmin', 'Super Administrateur', 'Accès complet à tout le système', 100, 1, JSON_OBJECT('users', ['create', 'read', 'update', 'delete', 'manage_roles'], 'system', ['all'])),
('admin_national', 'Admin National', 'Administration au niveau national', 90, 1, JSON_OBJECT('users', ['create', 'read', 'update', 'delete'], 'institutions', ['manage'])),
('admin_local', 'Admin Local', 'Administration au niveau local/institution', 80, 1, JSON_OBJECT('users', ['create', 'read', 'update'], 'institutions', ['read'])),
('leader', 'Leader', 'Chef de département/faculté', 60, 1, JSON_OBJECT('users', ['read', 'update_limited'], 'reports', ['read'])),
('teacher', 'Enseignant', 'Personnel enseignant', 40, 1, JSON_OBJECT('users', ['read_students'], 'courses', ['manage'])),
('staff', 'Personnel', 'Personnel administratif', 30, 1, JSON_OBJECT('users', ['read_basic'], 'reports', ['limited'])),
('moderator', 'Modérateur', 'Modération du contenu', 25, 1, JSON_OBJECT('content', ['moderate'], 'users', ['read_basic'])),
('alumni', 'Ancien Étudiant', 'Anciens diplômés', 20, 1, JSON_OBJECT('users', ['read_basic'], 'content', ['create'])),
('student', 'Étudiant', 'Étudiants actifs', 10, 1, JSON_OBJECT('users', ['read_self'], 'content', ['read'])),
('guest', 'Invité', 'Utilisateurs invités', 5, 1, JSON_OBJECT('users', ['read_self']));

-- Insertion des permissions de base
INSERT INTO `permissions` (`name`, `display_name`, `description`, `category`) VALUES
('users.create', 'Créer des utilisateurs', 'Permet de créer de nouveaux utilisateurs', 'users'),
('users.read', 'Voir les utilisateurs', 'Permet de voir la liste des utilisateurs', 'users'),
('users.read_self', 'Voir son profil', 'Permet de voir son propre profil', 'users'),
('users.read_basic', 'Voir infos basiques', 'Permet de voir les informations basiques des autres utilisateurs', 'users'),
('users.read_students', 'Voir les étudiants', 'Permet de voir les informations des étudiants', 'users'),
('users.update', 'Modifier les utilisateurs', 'Permet de modifier les informations des utilisateurs', 'users'),
('users.update_limited', 'Modification limitée', 'Permet de modifier certaines informations des utilisateurs', 'users'),
('users.delete', 'Supprimer les utilisateurs', 'Permet de supprimer des utilisateurs', 'users'),
('users.manage_roles', 'Gérer les rôles', 'Permet de gérer les rôles des utilisateurs', 'users'),
('users.view_hierarchy', 'Voir la hiérarchie', 'Permet de voir les utilisateurs de niveau inférieur', 'users'),
('system.all', 'Accès système complet', 'Accès complet à toutes les fonctionnalités système', 'system'),
('institutions.manage', 'Gérer les institutions', 'Permet de gérer les institutions', 'institutions'),
('institutions.read', 'Voir les institutions', 'Permet de voir les informations des institutions', 'institutions'),
('content.moderate', 'Modérer le contenu', 'Permet de modérer le contenu utilisateur', 'content'),
('content.create', 'Créer du contenu', 'Permet de créer du contenu', 'content'),
('content.read', 'Lire le contenu', 'Permet de lire le contenu', 'content'),
('reports.read', 'Voir les rapports', 'Permet de voir les rapports', 'reports'),
('reports.limited', 'Rapports limités', 'Permet de voir des rapports limités', 'reports');

-- Association des permissions aux rôles
INSERT INTO `role_permissions` (`role_id`, `permission_id`) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE (
  (r.name = 'superadmin') OR
  (r.name = 'admin_national' AND p.category IN ('users', 'institutions')) OR
  (r.name = 'admin_local' AND p.category IN ('users', 'institutions') AND p.name NOT IN ('users.delete', 'users.manage_roles')) OR
  (r.name = 'leader' AND p.name IN ('users.read_students', 'users.update_limited', 'reports.read')) OR
  (r.name = 'teacher' AND p.name IN ('users.read_students', 'content.create', 'content.read')) OR
  (r.name = 'staff' AND p.name IN ('users.read_basic', 'reports.limited')) OR
  (r.name = 'moderator' AND p.name IN ('users.read_basic', 'content.moderate', 'content.read')) OR
  (r.name = 'alumni' AND p.name IN ('users.read_basic', 'content.create', 'content.read')) OR
  (r.name = 'student' AND p.name IN ('users.read_self', 'content.read')) OR
  (r.name = 'guest' AND p.name IN ('users.read_self'))
);

-- Procédure pour vérifier si un utilisateur peut voir un autre utilisateur
DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_can_view_user`$$
CREATE PROCEDURE `sp_can_view_user`(
  IN p_viewer_id BIGINT,
  IN p_target_id BIGINT,
  OUT p_can_view BOOLEAN
)
BEGIN
    DECLARE v_viewer_level INT;
    DECLARE v_target_level INT;
    DECLARE v_viewer_role VARCHAR(50);
    DECLARE v_target_role VARCHAR(50);
    DECLARE v_same_institution BOOLEAN;
    
    -- Obtenir les niveaux et rôles
    SELECT MAX(r.level), r.name INTO v_viewer_level, v_viewer_role
    FROM users u
    JOIN user_roles ur ON u.id = ur.user_id
    JOIN roles r ON ur.role_id = r.id
    WHERE u.id = p_viewer_id AND ur.is_active = 1;
    
    SELECT MAX(r.level), r.name INTO v_target_level, v_target_role
    FROM users u
    JOIN user_roles ur ON u.id = ur.user_id
    JOIN roles r ON ur.role_id = r.id
    WHERE u.id = p_target_id AND ur.is_active = 1;
    
    -- Vérifier si même institution
    SELECT (u1.institution_id = u2.institution_id) INTO v_same_institution
    FROM users u1, users u2
    WHERE u1.id = p_viewer_id AND u2.id = p_target_id;
    
    -- Logique de décision
    IF p_viewer_id = p_target_id THEN
        SET p_can_view = TRUE;
    ELSEIF v_viewer_level >= 90 THEN
        -- Admin national et superadmin peuvent voir tout le monde
        SET p_can_view = TRUE;
    ELSEIF v_viewer_level >= 80 AND v_same_institution THEN
        -- Admin local peut voir les utilisateurs de son institution
        SET p_can_view = TRUE;
    ELSEIF v_viewer_level > v_target_level THEN
        -- Peut voir les utilisateurs de niveau inférieur
        SET p_can_view = TRUE;
    ELSE
        SET p_can_view = FALSE;
    END IF;
END$$
DELIMITER ;

-- Procédure pour obtenir la liste des utilisateurs visibles
DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_get_visible_users`$$
CREATE PROCEDURE `sp_get_visible_users`(
    IN p_user_id BIGINT,
    IN p_page INT DEFAULT 1,
    IN p_limit INT DEFAULT 20,
    IN p_search VARCHAR(255) DEFAULT NULL,
    IN p_role_filter VARCHAR(50) DEFAULT NULL,
    IN p_status_filter VARCHAR(50) DEFAULT NULL
)
BEGIN
    DECLARE v_offset INT;
    DECLARE v_viewer_level INT;
    DECLARE v_viewer_institution_id BIGINT;
    
    SET v_offset = (p_page - 1) * p_limit;
    
    -- Obtenir le niveau et l'institution du viewer
    SELECT MAX(r.level), u.institution_id INTO v_viewer_level, v_viewer_institution_id
    FROM users u
    JOIN user_roles ur ON u.id = ur.user_id
    JOIN roles r ON ur.role_id = r.id
    WHERE u.id = p_user_id AND ur.is_active = 1;
    
    -- Requête principale avec filtrage basé sur le rôle
    SELECT 
        u.id,
        u.uuid,
        u.email,
        u.first_name,
        u.last_name,
        u.matricule,
        u.primary_role,
        u.account_status,
        u.is_active,
        u.created_at,
        u.last_login_at,
        i.name as institution_name,
        d.name as department_name,
        MAX(r.level) as user_level,
        MAX(r.display_name) as role_display_name,
        GROUP_CONCAT(DISTINCT r.display_name ORDER BY r.level DESC) as user_roles
    FROM users u
    LEFT JOIN institutions i ON u.institution_id = i.id
    LEFT JOIN departments d ON u.department_id = d.id
    LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
    LEFT JOIN roles r ON ur.role_id = r.id
    WHERE u.deleted_at IS NULL
      AND (
        -- Superadmin et admin national voient tout
        v_viewer_level >= 90
        OR
        -- Admin local voit son institution
        (v_viewer_level >= 80 AND u.institution_id = v_viewer_institution_id)
        OR
        -- Les autres voient uniquement les niveaux inférieurs
        (v_viewer_level < 80 AND (
            SELECT MAX(r2.level) 
            FROM user_roles ur2 
            JOIN roles r2 ON ur2.role_id = r2.id 
            WHERE ur2.user_id = u.id AND ur2.is_active = 1
        ) < v_viewer_level)
        OR
        -- Tout le monde peut voir son propre profil
        u.id = p_user_id
      )
      AND (p_search IS NULL OR 
           CONCAT(u.first_name, ' ', u.last_name) LIKE CONCAT('%', p_search, '%') OR
           u.email LIKE CONCAT('%', p_search, '%') OR
           u.matricule LIKE CONCAT('%', p_search, '%'))
      AND (p_role_filter IS NULL OR u.primary_role = p_role_filter)
      AND (p_status_filter IS NULL OR u.account_status = p_status_filter)
    GROUP BY u.id, u.uuid, u.email, u.first_name, u.last_name, u.matricule, 
             u.primary_role, u.account_status, u.is_active, u.created_at, 
             u.last_login_at, i.name, d.name
    ORDER BY u.created_at DESC
    LIMIT v_offset, p_limit;
END$$
DELIMITER ;

-- Vue matérialisée pour les statistiques des utilisateurs par rôle
CREATE OR REPLACE VIEW `user_role_stats` AS
SELECT 
    r.name as role_name,
    r.display_name as role_display_name,
    r.level as role_level,
    COUNT(ur.user_id) as user_count,
    COUNT(CASE WHEN u.is_active = 1 AND u.account_status = 'active' THEN 1 END) as active_count,
    COUNT(CASE WHEN u.last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as recent_login_count
FROM roles r
LEFT JOIN user_roles ur ON r.id = ur.role_id AND ur.is_active = 1
LEFT JOIN users u ON ur.user_id = u.id AND u.deleted_at IS NULL
GROUP BY r.id, r.name, r.display_name, r.level
ORDER BY r.level DESC;
