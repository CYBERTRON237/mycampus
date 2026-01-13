-- Create messages table
CREATE TABLE messages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    conversation_id BIGINT NULL,
    content TEXT NOT NULL,
    type ENUM('text', 'image', 'file', 'audio', 'video', 'system') NOT NULL DEFAULT 'text',
    status ENUM('sending', 'sent', 'delivered', 'read', 'failed') NOT NULL DEFAULT 'sent',
    attachment_url VARCHAR(500) NULL,
    attachment_name VARCHAR(255) NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    metadata JSON NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE SET NULL,
    
    INDEX idx_sender_receiver (sender_id, receiver_id),
    INDEX idx_conversation (conversation_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_read_at (read_at)
);

-- Create conversations table
CREATE TABLE conversations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    participant_id BIGINT NOT NULL,
    last_message_id BIGINT NULL,
    last_activity TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unread_count INT NOT NULL DEFAULT 0,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
    is_muted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_user_participant (user_id, participant_id),
    INDEX idx_user_id (user_id),
    INDEX idx_participant_id (participant_id),
    INDEX idx_last_activity (last_activity),
    INDEX idx_unread_count (unread_count)
);

-- Create blocked_users table for managing blocked relationships
CREATE TABLE blocked_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    blocker_id BIGINT NOT NULL,
    blocked_id BIGINT NOT NULL,
    reason VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_block (blocker_id, blocked_id),
    INDEX idx_blocker_id (blocker_id),
    INDEX idx_blocked_id (blocked_id)
);

-- Create message_attachments table for file management
CREATE TABLE message_attachments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    message_id BIGINT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    
    INDEX idx_message_id (message_id),
    INDEX idx_mime_type (mime_type)
);

-- Create message_read_receipts table for read status tracking
CREATE TABLE message_read_receipts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    message_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_message_user_read (message_id, user_id),
    INDEX idx_message_id (message_id),
    INDEX idx_user_id (user_id),
    INDEX idx_read_at (read_at)
);

-- Add triggers for automatic conversation updates
DELIMITER //

CREATE TRIGGER after_message_insert 
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
    -- Update sender's conversation
    INSERT INTO conversations (user_id, participant_id, last_message_id, last_activity)
    VALUES (NEW.sender_id, NEW.receiver_id, NEW.id, NEW.created_at)
    ON DUPLICATE KEY UPDATE 
        last_message_id = NEW.id,
        last_activity = NEW.created_at;
    
    -- Update receiver's conversation
    INSERT INTO conversations (user_id, participant_id, last_message_id, last_activity, unread_count)
    VALUES (NEW.receiver_id, NEW.sender_id, NEW.id, NEW.created_at, 1)
    ON DUPLICATE KEY UPDATE 
        last_message_id = NEW.id,
        last_activity = NEW.created_at,
        unread_count = unread_count + 1;
    
    -- Set conversation_id in message
    UPDATE messages SET conversation_id = (
        SELECT id FROM conversations 
        WHERE user_id = NEW.sender_id AND participant_id = NEW.receiver_id
        LIMIT 1
    ) WHERE id = NEW.id;
END//

CREATE TRIGGER after_message_read 
AFTER UPDATE ON messages
FOR EACH ROW
BEGIN
    IF NEW.status = 'read' AND OLD.status != 'read' THEN
        -- Update receiver's unread count
        UPDATE conversations 
        SET unread_count = GREATEST(unread_count - 1, 0)
        WHERE user_id = NEW.receiver_id AND participant_id = NEW.sender_id;
    END IF;
END//

DELIMITER ;

-- Insert some sample data for testing
INSERT INTO messages (sender_id, receiver_id, content, type, status) VALUES
(1, 2, 'Bonjour ! Comment allez-vous ?', 'text', 'read'),
(2, 1, 'Bonjour ! Je vais bien, merci. Et vous ?', 'text', 'read'),
(1, 2, 'Très bien aussi ! J''avais une question concernant le cours.', 'text', 'sent'),
(3, 1, 'Les documents sont prêts pour la réunion', 'text', 'delivered'),
(1, 3, 'Merci ! Je vais les consulter', 'text', 'sent');

-- Update conversations based on sample messages
INSERT INTO conversations (user_id, participant_id, last_message_id, last_activity, unread_count)
SELECT 
    m.sender_id as user_id,
    m.receiver_id as participant_id,
    m.id as last_message_id,
    m.created_at as last_activity,
    0 as unread_count
FROM messages m
GROUP BY m.sender_id, m.receiver_id
ORDER BY m.created_at DESC;

INSERT INTO conversations (user_id, participant_id, last_message_id, last_activity, unread_count)
SELECT 
    m.receiver_id as user_id,
    m.sender_id as participant_id,
    m.id as last_message_id,
    m.created_at as last_activity,
    CASE WHEN m.status != 'read' THEN 1 ELSE 0 END as unread_count
FROM messages m
GROUP BY m.receiver_id, m.sender_id
ORDER BY m.created_at DESC;
