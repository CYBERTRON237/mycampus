<?php
// Script final pour créer les procédures stockées correctement
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
    echo "Création de sp_can_view_user...\n";
    $pdo->exec("DROP PROCEDURE IF EXISTS sp_can_view_user");
    $sql1 = "CREATE PROCEDURE sp_can_view_user(
        IN p_viewer_id BIGINT,
        IN p_target_id BIGINT,
        OUT p_can_view BOOLEAN
    )
    BEGIN
        DECLARE viewer_level INT DEFAULT 0;
        DECLARE target_level INT DEFAULT 0;
        DECLARE viewer_institution BIGINT;
        DECLARE target_institution BIGINT;
        
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
        
        IF p_viewer_id = p_target_id THEN
            SET p_can_view = TRUE;
        ELSEIF viewer_level >= 90 THEN
            SET p_can_view = TRUE;
        ELSEIF viewer_level >= 80 AND viewer_institution = target_institution THEN
            SET p_can_view = TRUE;
        ELSEIF viewer_level > target_level THEN
            SET p_can_view = TRUE;
        ELSE
            SET p_can_view = FALSE;
        END IF;
    END";
    $pdo->exec($sql1);
    echo "sp_can_view_user créée!\n";

    // Créer la procédure sp_get_visible_users
    echo "Création de sp_get_visible_users...\n";
    $pdo->exec("DROP PROCEDURE IF EXISTS sp_get_visible_users");
    $sql2 = "CREATE PROCEDURE sp_get_visible_users(
        IN p_viewer_id BIGINT,
        IN p_page INT,
        IN p_limit INT,
        IN p_search VARCHAR(255),
        IN p_role_filter VARCHAR(50),
        IN p_status_filter VARCHAR(50)
    )
    BEGIN
        DECLARE v_offset INT;
        DECLARE viewer_level INT DEFAULT 0;
        DECLARE viewer_institution BIGINT;
        
        SET v_offset = (p_page - 1) * p_limit;
        
        SELECT COALESCE(r.level, 0), u.institution_id 
        INTO viewer_level, viewer_institution
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = p_viewer_id AND u.deleted_at IS NULL;
        
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
        AND (
            u.id = p_viewer_id
            OR viewer_level >= 90
            OR (viewer_level >= 80 AND u.institution_id = viewer_institution)
            OR (viewer_level > COALESCE(r.level, 0))
        )
        AND (
            p_search IS NULL 
            OR (
                u.first_name LIKE CONCAT('%', p_search, '%')
                OR u.last_name LIKE CONCAT('%', p_search, '%')
                OR u.email LIKE CONCAT('%', p_search, '%')
                OR u.matricule LIKE CONCAT('%', p_search, '%')
            )
        )
        AND (
            p_role_filter IS NULL
            OR r.name = p_role_filter
        )
        AND (
            p_status_filter IS NULL
            OR u.account_status = p_status_filter
        )
        ORDER BY u.created_at DESC
        LIMIT v_offset, p_limit;
    END";
    $pdo->exec($sql2);
    echo "sp_get_visible_users créée!\n";

    // Créer la vue user_role_stats
    echo "Création de user_role_stats...\n";
    $pdo->exec("DROP VIEW IF EXISTS user_role_stats");
    $sql3 = "CREATE VIEW user_role_stats AS
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
    echo "user_role_stats créée!\n";

    echo "Toutes les procédures et vues ont été créées avec succès!\n";
    
} catch (PDOException $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
