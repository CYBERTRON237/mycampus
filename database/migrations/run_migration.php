<?php
// Script pour exécuter la migration des stickers
try {
    $conn = new PDO("mysql:host=localhost;dbname=mycampus", "root", "");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Connexion réussie à la base de données\n";
    
    // Ajouter le type sticker à l'ENUM
    $sql1 = "ALTER TABLE messages MODIFY COLUMN type ENUM('text', 'image', 'file', 'audio', 'video', 'system', 'sticker') NOT NULL DEFAULT 'text'";
    $conn->exec($sql1);
    echo "Type 'sticker' ajouté à l'ENUM\n";
    
    // Rendre content nullable pour les stickers
    $sql2 = "ALTER TABLE messages MODIFY COLUMN content TEXT NULL";
    $conn->exec($sql2);
    echo "Content rendu nullable\n";
    
    echo "Migration terminée avec succès!\n";
    
} catch(PDOException $e) {
    echo "Erreur de migration: " . $e->getMessage() . "\n";
}
?>
