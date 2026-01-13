<?php
// Script de réparation rapide pour la messagerie
header('Content-Type: text/plain; charset=utf-8');

try {
    $conn = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Vérification et réparation de la messagerie...\n";
    
    // Vérifier si les colonnes existent
    $stmt = $conn->query("SHOW COLUMNS FROM messages LIKE 'uuid'");
    $uuidExists = $stmt->rowCount() > 0;
    
    $stmt = $conn->query("SHOW COLUMNS FROM messages LIKE 'message_type'");
    $messageTypeExists = $stmt->rowCount() > 0;
    
    $stmt = $conn->query("SHOW COLUMNS FROM messages LIKE 'delivery_status'");
    $deliveryStatusExists = $stmt->rowCount() > 0;
    
    echo "UUID exists: " . ($uuidExists ? 'yes' : 'no') . "\n";
    echo "message_type exists: " . ($messageTypeExists ? 'yes' : 'no') . "\n";
    echo "delivery_status exists: " . ($deliveryStatusExists ? 'yes' : 'no') . "\n";
    
    // Si les colonnes n'existent pas, on les ajoute rapidement
    if (!$uuidExists) {
        $conn->exec("ALTER TABLE messages ADD COLUMN uuid VARCHAR(36) UNIQUE NOT NULL AFTER id");
        echo "Colonne uuid ajoutée\n";
    }
    
    if (!$messageTypeExists) {
        $conn->exec("ALTER TABLE messages ADD COLUMN message_type ENUM('private', 'group', 'broadcast') NOT NULL DEFAULT 'private' AFTER type");
        echo "Colonne message_type ajoutée\n";
    }
    
    if (!$deliveryStatusExists) {
        $conn->exec("ALTER TABLE messages ADD COLUMN delivery_status ENUM('sending', 'sent', 'delivered', 'read', 'failed') NOT NULL DEFAULT 'sent' AFTER message_type");
        echo "Colonne delivery_status ajoutée\n";
    }
    
    // Vérifier si le type sticker existe
    $stmt = $conn->query("SHOW COLUMNS FROM messages LIKE 'type'");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $typeDefinition = $row['Type'];
    
    if (strpos($typeDefinition, 'sticker') === false) {
        echo "Ajout du type sticker...\n";
        $conn->exec("ALTER TABLE messages MODIFY COLUMN type ENUM('text', 'image', 'file', 'audio', 'video', 'system', 'sticker') NOT NULL DEFAULT 'text'");
        echo "Type sticker ajouté\n";
    }
    
    // Mettre à jour les UUID manquants
    $conn->exec("UPDATE messages SET uuid = CONCAT('msg_', id, '_', UNIX_TIMESTAMP(created_at)) WHERE uuid IS NULL OR uuid = ''");
    echo "UUIDs mis à jour\n";
    
    echo "Réparation terminée avec succès!\n";
    
} catch(PDOException $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}
?>
