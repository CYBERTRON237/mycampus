-- Vérification des tables de messagerie
SHOW TABLES LIKE 'user_groups';
SHOW TABLES LIKE 'group_members';
SHOW TABLES LIKE 'users';

-- Si les tables n'existent pas, les créer
CREATE TABLE IF NOT EXISTS user_groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(36) UNIQUE,
    institution_id INT,
    program_id INT,
    department_id INT,
    parent_group_id INT,
    group_type ENUM('chat', 'study', 'project', 'class', 'club') DEFAULT 'chat',
    visibility ENUM('public', 'private', 'secret') DEFAULT 'private',
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,
    cover_image_url VARCHAR(500),
    icon_url VARCHAR(500),
    avatar_url VARCHAR(500),
    academic_level VARCHAR(50),
    academic_year_id INT,
    is_official BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_national BOOLEAN DEFAULT FALSE,
    max_members INT DEFAULT 100,
    current_members_count INT DEFAULT 0,
    join_approval_required BOOLEAN DEFAULT FALSE,
    allow_member_posts BOOLEAN DEFAULT TRUE,
    allow_member_invites BOOLEAN DEFAULT TRUE,
    rules TEXT,
    tags JSON,
    settings JSON,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_slug (slug),
    INDEX idx_created_by (created_by),
    INDEX idx_institution (institution_id),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS group_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(36) UNIQUE,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('admin', 'moderator', 'member') DEFAULT 'member',
    status ENUM('pending', 'active', 'banned', 'left') DEFAULT 'pending',
    unread_count INT DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP NULL,
    invited_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_group_user (group_id, user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_group_id (group_id),
    INDEX idx_status (status),
    FOREIGN KEY (group_id) REFERENCES user_groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE SET NULL
);
