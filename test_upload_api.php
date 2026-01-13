<?php
// Test de l'API upload_avatar.php
?>
<!DOCTYPE html>
<html>
<head>
    <title>Test API Upload Avatar</title>
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
        .debug { background: #f8f9fa; color: #495057; border: 1px solid #dee2e6; margin-top: 10px; padding: 10px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Test API Upload Avatar</h1>
        
        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            echo '<div class="debug">';
            echo '<h3>Debug Information:</h3>';
            echo '<pre>';
            echo 'POST data: ' . print_r($_POST, true) . "\n";
            echo 'FILES data: ' . print_r($_FILES, true) . "\n";
            echo '</pre>';
            echo '</div>';
            
            // Appeler l'API upload_avatar.php
            $url = 'http://127.0.0.1/mycampus/api/upload_avatar.php';
            
            // Préparer les données pour cURL
            $postData = $_POST;
            $files = $_FILES;
            
            if (function_exists('curl_init')) {
                $ch = curl_init();
                
                // Préparer le multipart form data
                $postData['action'] = 'upload_avatar';
                
                if (!empty($files['avatar']) && $files['avatar']['error'] === UPLOAD_ERR_OK) {
                    $tmpFile = $files['avatar']['tmp_name'];
                    $fileName = $files['avatar']['name'];
                    
                    // Créer un fichier temporaire pour cURL
                    $postFields = [
                        'user_id' => $postData['user_id'],
                        'action' => $postData['action'],
                        'avatar' => new CURLFile($tmpFile, $files['avatar']['type'], $fileName)
                    ];
                    
                    curl_setopt($ch, CURLOPT_URL, $url);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_VERBOSE, true);
                    
                    $response = curl_exec($ch);
                    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                    $error = curl_error($ch);
                    curl_close($ch);
                    
                    echo '<div class="debug">';
                    echo '<h3>cURL Debug:</h3>';
                    echo '<pre>';
                    echo 'HTTP Code: ' . $httpCode . "\n";
                    echo 'cURL Error: ' . $error . "\n";
                    echo 'Response: ' . $response . "\n";
                    echo '</pre>';
                    echo '</div>';
                    
                    // Afficher le résultat
                    $result = json_decode($response, true);
                    if ($result && $result['success']) {
                        echo '<div class="result success">';
                        echo '<h3>Succès!</h3>';
                        echo '<p>Message: ' . htmlspecialchars($result['message']) . '</p>';
                        echo '<p>Avatar URL: ' . htmlspecialchars($result['avatar_url'] ?? '') . '</p>';
                        echo '<p>Filename: ' . htmlspecialchars($result['filename'] ?? '') . '</p>';
                        
                        // Afficher l'image si l'URL est disponible
                        if (!empty($result['avatar_url'])) {
                            echo '<img src="http://127.0.0.1/mycampus' . htmlspecialchars($result['avatar_url']) . '" style="max-width: 200px; border-radius: 50%; margin-top: 10px;">';
                        }
                        echo '</div>';
                    } else {
                        echo '<div class="result error">';
                        echo '<h3>Erreur!</h3>';
                        echo '<p>Message: ' . htmlspecialchars($result['message'] ?? 'Unknown error') . '</p>';
                        echo '</div>';
                    }
                } else {
                    echo '<div class="result error">';
                    echo '<h3>Erreur!</h3>';
                    echo '<p>Aucun fichier uploadé ou erreur lors de l\'upload</p>';
                    echo '</div>';
                }
            } else {
                echo '<div class="result error">';
                echo '<h3>Erreur!</h3>';
                echo '<p>cURL n\'est pas disponible</p>';
                echo '</div>';
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
            
            <input type="submit" value="Tester Upload Avatar">
        </form>
        
        <div style="margin-top: 30px; padding: 15px; background: #e9ecef; border-radius: 4px;">
            <h3>Instructions:</h3>
            <ol>
                <li>Entrez un ID utilisateur (ex: 1)</li>
                <li>Sélectionnez une image (JPEG, PNG, GIF)</li>
                <li>Cliquez sur "Tester Upload Avatar"</li>
                <li>Vérifiez la réponse de l'API et l'affichage de l'image</li>
            </ol>
        </div>
    </div>
</body>
</html>
