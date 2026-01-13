<?php
// Script simplifié pour créer les procédures stockées une par une
$host = '127.0.0.1';
$dbname = 'mycampus';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);

    echo "Connexion réussie à la base de données\n";

    // Créer la procédure sp_can_view_user
    $sql1 = "
    DROP PROCEDURE IF EXISTS sp_can_view_user;
    CREATE PROCEDURE sp_can_view_user(
        IN p_viewer_id BIGINT,
        IN p_target_id BIGINT,
        OUT p_can_view BOOLEAN
    )
    BEGIN
        DECLARE viewer_level INT DEFAULT 0;
        DECLARE target_level INT DEFAULT 0;
        DECLARE viewer_institution BIGINT;
        DECLARE target_institution BIGINT;
        
        -- Obtenir les niveaux et institutions
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO viewer_level, viewer_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_viewer_id AND u.deleted_at IS NULL;
        
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO target_level, target_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_target_id AND u.deleted_at IS NULL;
        
        -- Un utilisateur peut toujours voir son propre profil
        IF p_viewer_id = p_target_id THEN
            SET p_can_view = TRUE;
        -- Les admins de haut niveau peuvent voir tout le monde
        ELSEIF viewer_level >= 90 THEN
            SET p_can_view = TRUE;
        -- Les admins locaux peuvent voir les utilisateurs de leur institution
        ELSEIF viewer_level >= 80 AND viewer_institution = target_institution THEN
            SET p_can_view = TRUE;
        -- Les autres peuvent voir les utilisateurs de niveau inférieur ou égal
        ELSEIF viewer_level > target_level THEN
            SET p_can_view = TRUE;
        ELSE
            SET p_can_view = FALSE;
        END IF;
    END";
    
    $pdo->exec($sql1);
    echo "Procédure sp_can_view_user créée avec succès!\n";

    // Créer la procédure sp_get_visible_users
    $sql2 = "
    DROP PROCEDURE IF EXISTS sp_get_visible_users;
    CREATE PROCEDURE sp_get_visible_users(
        IN p_viewer_id BIGINT,
        IN p_page INT DEFAULT 1,
        IN p_limit INT DEFAULT 20,
        IN p_search VARCHAR(255) DEFAULT NULL,
        IN p_role_filter VARCHAR(50) DEFAULT NULL,
        IN p_status_filter VARCHAR(50) DEFAULT NULL
    )
    BEGIN
        DECLARE v_offset INT;
        DECLARE viewer_level INT DEFAULT 0;
        DECLARE viewer_institution BIGINT;
        
        SET v_offset = (p_page - 1) * p_limit;
        
        -- Obtenir les informations de l'utilisateur qui consulte
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO viewer_level, viewer_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_viewer_id AND u.deleted_at IS NULL;
        
        -- Requête principale avec filtres
        SELECT 
            u.id, u.uuid, u.email, u.first_name, u.last_name, u.matricule,
            u.primary_role, u.account_status, u.is_active, u.created_at, u.updated_at,
            i.name as institution_name,
            d.name as department_name,
            r.name as role_name,
            r.level as role_level
        FROM users u
        LEFT JOIN institutions i ON u.institution_id = i.id
        LEFT JOIN departments d ON u.department_id = d.id
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.deleted_at IS NULL
        -- Filtrer selon les permissions de l'utilisateur qui consulte
        AND (
            -- Un utilisateur peut toujours voir son propre profil
            u.id = p_viewer_id
            OR
            -- Les admins de haut niveau peuvent voir tout le monde
            viewer_level >= 90
            OR
            -- Les admins locaux peuvent voir les utilisateurs de leur institution
            (viewer_level >= 80 AND u.institution_id = viewer_institution)
            OR
            -- Les autres peuvent voir les utilisateurs de niveau inférieur
            (viewer_level > COALESCE(r.level, 0))
        )
        -- Filtre de recherche
        AND (
            p_search IS NULL 
            OR (
                u.first_name LIKE CONCAT('%', p_search, '%')
                OR u.last_name LIKE CONCAT('%', p_search, '%')
                OR u.email LIKE CONCAT('%', p_search, '%')
                OR u.matricule LIKE CONCAT('%', p_search, '%')
            )
        )
        -- Filtre de rôle
        AND (
            p_role_filter IS NULL
            OR r.name = p_role_filter
        )
        -- Filtre de statut
        AND (
            p_status_filter IS NULL
            OR u.account_status = p_status_filter
        )
        ORDER BY u.created_at DESC
        LIMIT v_offset, p_limit;
    END";
    
    $pdo->exec($sql2);
    echo "Procédure sp_get_visible_users créée avec succès!\n";

    // Créer la vue user_role_stats
    $sql3 = "
    DROP VIEW IF EXISTS user_role_stats;
    CREATE VIEW user_role_stats AS
    SELECT 
        r.name as role_name,
        r.level as role_level,
        COUNT(DISTINCT ur.user_id) as user_count,
        COUNT(DISTINCT CASE WHEN u.is_active = 1 THEN ur.user_id END) as active_users
    FROM roles r
    LEFT JOIN user_roles ur ON r.id = ur.role_id AND ur.is_active = 1
    LEFT JOIN users u ON ur.user_id = u.id AND u.deleted_at IS NULL
    GROUP BY r.id, r.name, r.level
    ORDER BY r.level DESC";
    
    $pdo->exec($sql3);
    echo "Vue user_role_stats créée avec succès!\n";

    echo "Toutes les procédures et vues ont été créées avec succès!\n";
    
} catch (PDOException $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
