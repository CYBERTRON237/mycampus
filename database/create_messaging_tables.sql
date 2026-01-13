-- Créer la table conversations
CREATE TABLE IF NOT EXISTS conversations (
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    user1_id bigint UNSIGNED NOT NULL,
    user2_id bigint UNSIGNED NOT NULL,
    last_message_id bigint UNSIGNED DEFAULT NULL,
    last_message_at timestamp NULL DEFAULT NULL,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_conversation_users (user1_id, user2_id),
    KEY idx_last_message_at (last_message_at),
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Créer la table messages
CREATE TABLE IF NOT EXISTS messages (
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    conversation_id bigint UNSIGNED NOT NULL,
    sender_id bigint UNSIGNED NOT NULL,
    receiver_id bigint UNSIGNED NOT NULL,
    content text NOT NULL,
    type enum('text','image','file','audio','video') NOT NULL DEFAULT 'text',
    status enum('sending','sent','delivered','read','failed') NOT NULL DEFAULT 'sent',
    attachment_url varchar(500) DEFAULT NULL,
    attachment_name varchar(255) DEFAULT NULL,
    attachment_size int DEFAULT NULL,
    is_edited tinyint(1) NOT NULL DEFAULT 0,
    edited_at timestamp NULL DEFAULT NULL,
    is_deleted tinyint(1) NOT NULL DEFAULT 0,
    deleted_at timestamp NULL DEFAULT NULL,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_conversation_id (conversation_id),
    KEY idx_sender_id (sender_id),
    KEY idx_receiver_id (receiver_id),
    KEY idx_created_at (created_at),
    KEY idx_status (status),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
