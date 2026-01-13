<?php
// Simple test for upload avatar API
?>
<!DOCTYPE html>
<html>
<head>
    <title>Simple Upload Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .result { margin: 20px 0; padding: 15px; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>Simple Upload Test</h1>
    
    <?php
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        echo '<h3>POST Request Received</h3>';
        echo '<pre>POST Data: ' . print_r($_POST, true) . '</pre>';
        echo '<pre>FILES Data: ' . print_r($_FILES, true) . '</pre>';
        
        // Test the debug endpoint first
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1/mycampus/debug_upload.php');
        curl_setopt($ch, CURLOPT_POST, true);
        
        if (!empty($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
            $postFields = [
                'user_id' => $_POST['user_id'] ?? '1',
                'action' => 'upload_avatar',
                'avatar' => new CURLFile($_FILES['avatar']['tmp_name'], $_FILES['avatar']['type'], $_FILES['avatar']['name'])
            ];
            curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);
        }
        
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "<h3>Debug API Response (HTTP $httpCode)</h3>";
        echo '<pre>' . htmlspecialchars($response) . '</pre>';
        
        // If debug passes, test the actual upload
        $debugResult = json_decode($response, true);
        if ($debugResult && $debugResult['success']) {
            echo '<h3>Testing Actual Upload API...</h3>';
            
            $ch2 = curl_init();
            curl_setopt($ch2, CURLOPT_URL, 'http://127.0.0.1/mycampus/api/upload_avatar.php');
            curl_setopt($ch2, CURLOPT_POST, true);
            curl_setopt($ch2, CURLOPT_POSTFIELDS, $postFields);
            curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
            
            $uploadResponse = curl_exec($ch2);
            $uploadHttpCode = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
            curl_close($ch2);
            
            echo "<h3>Upload API Response (HTTP $uploadHttpCode)</h3>";
            echo '<pre>' . htmlspecialchars($uploadResponse) . '</pre>';
            
            $uploadResult = json_decode($uploadResponse, true);
            if ($uploadResult && $uploadResult['success']) {
                echo '<div class="success">Upload successful! Avatar URL: ' . htmlspecialchars($uploadResult['avatar_url'] ?? '') . '</div>';
            } else {
                echo '<div class="error">Upload failed: ' . htmlspecialchars($uploadResult['message'] ?? 'Unknown error') . '</div>';
            }
        }
    }
    ?>
    
    <form method="post" enctype="multipart/form-data">
        <p>
            <label>User ID: <input type="text" name="user_id" value="1" required></label>
        </p>
        <p>
            <label>Avatar: <input type="file" name="avatar" accept="image/*" required></label>
        </p>
        <p>
            <button type="submit">Test Upload</button>
        </p>
    </form>
</body>
</html>
