<?php
// Script de test pour l'upload d'avatar
?>
<!DOCTYPE html>
<html>
<head>
    <title>Test Upload Avatar</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="file"] { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        input[type="submit"] { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        .result { margin-top: 20px; padding: 10px; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Test Upload Avatar</h1>
        
        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            // Simuler l'upload
            $userId = $_POST['user_id'] ?? '1';
            
            if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
                $file = $_FILES['avatar'];
                $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
                
                if (in_array($file['type'], $allowedTypes)) {
                    // Créer le dossier uploads s'il n'existe pas
                    $uploadsDir = '../uploads/avatars';
                    if (!is_dir($uploadsDir)) {
                        mkdir($uploadsDir, 0755, true);
                    }
                    
                    // Générer un nom de fichier unique
                    $filename = $userId . '_avatar_' . time() . '.' . pathinfo($file['name'], PATHINFO_EXTENSION);
                    $filepath = $uploadsDir . '/' . $filename;
                    
                    if (move_uploaded_file($file['tmp_name'], $filepath)) {
                        echo '<div class="result success">';
                        echo '<h3>Succès!</h3>';
                        echo '<p>Fichier uploadé avec succès</p>';
                        echo '<p>Nom du fichier: ' . htmlspecialchars($filename) . '</p>';
                        echo '<p>Chemin: ' . htmlspecialchars($filepath) . '</p>';
                        echo '<p>URL: /uploads/avatars/' . htmlspecialchars($filename) . '</p>';
                        echo '</div>';
                    } else {
                        echo '<div class="result error">Erreur lors du déplacement du fichier</div>';
                    }
                } else {
                    echo '<div class="result error">Type de fichier non autorisé</div>';
                }
            } else {
                echo '<div class="result error">Erreur lors de l\'upload du fichier</div>';
            }
        }
        ?>
        
        <form method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="user_id">User ID:</label>
                <input type="text" id="user_id" name="user_id" value="1" required>
            </div>
            
            <div class="form-group">
                <label for="avatar">Avatar:</label>
                <input type="file" id="avatar" name="avatar" accept="image/*" required>
            </div>
            
            <input type="hidden" name="action" value="upload_avatar">
            
            <input type="submit" value="Upload Avatar">
        </form>
    </div>
</body>
</html>
