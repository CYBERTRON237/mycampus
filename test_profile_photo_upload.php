<?php
// Test script for profile photo upload
header('Content-Type: text/html; charset=utf-8');

?>
<!DOCTYPE html>
<html>
<head>
    <title>Test Upload Photo de Profil</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .form-group { margin: 15px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="file"], input[type="text"] { width: 100%; padding: 8px; }
        button { background: #007cba; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        button:hover { background: #005a87; }
        .result { margin: 20px 0; padding: 15px; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .debug { background: #f8f9fa; border: 1px solid #dee2e6; padding: 10px; margin: 10px 0; }
        pre { background: #f8f9fa; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Test Upload Photo de Profil</h1>
        
        <form id="uploadForm" enctype="multipart/form-data">
            <div class="form-group">
                <label for="token">JWT Token:</label>
                <input type="text" id="token" name="token" placeholder="Collez votre token JWT ici" required>
            </div>
            
            <div class="form-group">
                <label for="profile_photo">Photo de profil:</label>
                <input type="file" id="profile_photo" name="profile_photo" accept="image/*" required>
            </div>
            
            <button type="submit">Uploader la photo</button>
        </form>
        
        <div id="result"></div>
        
        <div class="debug">
            <h3>Informations de débogage:</h3>
            <p><strong>URL de l'API:</strong> /api/profile/photo</p>
            <p><strong>Méthode:</strong> POST</p>
            <p><strong>Format:</strong> FormData avec fichier et token</p>
        </div>
        
        <div class="debug">
            <h3>Étapes du test:</h3>
            <ol>
                <li>Connectez-vous à l'application et obtenez un token JWT</li>
                <li>Collez le token dans le champ ci-dessus</li>
                <li>Sélectionnez une image (JPEG, PNG, GIF, WebP - max 5MB)</li>
                <li>Cliquez sur "Uploader la photo"</li>
                <li>Vérifiez le résultat et les messages d'erreur</li>
            </ol>
        </div>
    </div>

    <script>
        document.getElementById('uploadForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const token = document.getElementById('token').value;
            const fileInput = document.getElementById('profile_photo');
            const resultDiv = document.getElementById('result');
            
            if (!fileInput.files[0]) {
                showResult('Veuillez sélectionner un fichier', 'error');
                return;
            }
            
            const formData = new FormData();
            formData.append('profile_photo', fileInput.files[0]);
            
            try {
                resultDiv.innerHTML = '<div class="debug">Upload en cours...</div>';
                
                const response = await fetch('/api/profile/photo', {
                    method: 'POST',
                    headers: {
                        'Authorization': 'Bearer ' + token
                    },
                    body: formData
                });
                
                const responseText = await response.text();
                
                let data;
                try {
                    data = JSON.parse(responseText);
                } catch (e) {
                    data = { raw_response: responseText };
                }
                
                if (response.ok && data.success) {
                    showResult(`
                        <h3>Succès!</h3>
                        <p><strong>Message:</strong> ${data.message}</p>
                        <p><strong>URL de la photo:</strong> ${data.data?.profile_photo_url}</p>
                        <p><strong>URL complète:</strong> ${data.data?.full_url}</p>
                        <img src="${data.data?.full_url}" style="max-width: 200px; border-radius: 50%; margin-top: 10px;" onerror="this.style.display='none'">
                    `, 'success');
                } else {
                    showResult(`
                        <h3>Erreur ${response.status}</h3>
                        <p><strong>Message:</strong> ${data.message || 'Erreur inconnue'}</p>
                        <h4>Détails de la réponse:</h4>
                        <pre>${JSON.stringify(data, null, 2)}</pre>
                        <h4>Response brute:</h4>
                        <pre>${responseText}</pre>
                    `, 'error');
                }
                
            } catch (error) {
                showResult(`
                    <h3>Erreur réseau</h3>
                    <p><strong>Message:</strong> ${error.message}</p>
                    <p>Vérifiez que le serveur est accessible et que CORS est configuré.</p>
                `, 'error');
            }
        });
        
        function showResult(message, type) {
            const resultDiv = document.getElementById('result');
            resultDiv.innerHTML = `<div class="result ${type}">${message}</div>`;
        }
        
        // Fonction pour obtenir le token depuis localStorage (si disponible)
        function loadTokenFromStorage() {
            try {
                const token = localStorage.getItem('jwt_token') || localStorage.getItem('auth_token');
                if (token) {
                    document.getElementById('token').value = token;
                }
            } catch (e) {
                console.log('Impossible de charger le token depuis localStorage');
            }
        }
        
        // Charger le token au chargement de la page
        loadTokenFromStorage();
    </script>
</body>
</html>
