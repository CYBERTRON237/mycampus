-- Tables pour le système de contacts et d'amis comme WhatsApp

-- Table des contacts (relations d'amitié)
CREATE TABLE IF NOT EXISTS user_contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    contact_user_id INT NOT NULL,
    status ENUM('pending', 'accepted', 'blocked') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Empêcher les doublons et l'auto-ajout
    UNIQUE KEY unique_contact (user_id, contact_user_id),
    CHECK (user_id != contact_user_id),
    
    INDEX idx_user_id (user_id),
    INDEX idx_contact_user_id (contact_user_id),
    INDEX idx_status (status)
);

-- Table des demandes de contact
CREATE TABLE IF NOT EXISTS contact_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    requester_id INT NOT NULL,
    recipient_id INT NOT NULL,
    message TEXT,
    status ENUM('pending', 'accepted', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Empêcher les doublons
    UNIQUE KEY unique_request (requester_id, recipient_id),
    CHECK (requester_id != recipient_id),
    
    INDEX idx_requester_id (requester_id),
    INDEX idx_recipient_id (recipient_id),
    INDEX idx_status (status)
);

-- Table des favoris (contacts étoilés comme WhatsApp)
CREATE TABLE IF NOT EXISTS favorite_contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    contact_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_favorite (user_id, contact_user_id),
    CHECK (user_id != contact_user_id),
    
    INDEX idx_user_id (user_id)
);
