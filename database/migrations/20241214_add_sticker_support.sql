-- Add sticker support to messages table
ALTER TABLE messages 
MODIFY COLUMN type ENUM('text', 'image', 'file', 'audio', 'video', 'system', 'sticker') NOT NULL DEFAULT 'text';

-- Add missing columns if they don't exist
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS uuid VARCHAR(36) UNIQUE NOT NULL AFTER id,
ADD COLUMN IF NOT EXISTS message_type ENUM('private', 'group', 'broadcast') NOT NULL DEFAULT 'private' AFTER type,
ADD COLUMN IF NOT EXISTS delivery_status ENUM('sending', 'sent', 'delivered', 'read', 'failed') NOT NULL DEFAULT 'sent' AFTER message_type,
ADD COLUMN IF NOT EXISTS sent_at TIMESTAMP NULL AFTER delivery_status,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Update existing messages to have UUIDs (for those that don't have one)
UPDATE messages 
SET uuid = CONCAT('msg_', id, '_', UNIX_TIMESTAMP(created_at))
WHERE uuid IS NULL OR uuid = '';

-- Make sure content can be nullable for stickers
ALTER TABLE messages 
MODIFY COLUMN content TEXT NULL;

-- Add index for UUID if it doesn't exist
ALTER TABLE messages 
ADD INDEX IF NOT EXISTS idx_uuid (uuid);
