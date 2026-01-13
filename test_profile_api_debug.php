<?php
// Script de test simple pour l'API de profil
header('Content-Type: text/html; charset=utf-8');

?>
<!DOCTYPE html>
<html>
<head>
    <title>Test API Profile</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background: #d4edda; }
        .error { background: #f8d7da; }
        pre { background: #f8f9fa; padding: 10px; overflow-x: auto; }
        button { background: #007cba; color: white; padding: 8px 15px; border: none; cursor: pointer; margin: 5px; }
    </style>
</head>
<body>
    <h1>Test API Profile - Débogage</h1>
    
    <div class="test-section">
        <h2>1. Test de connexion à la base de données</h2>
        <button onclick="testDBConnection()">Tester DB</button>
        <div id="db-result"></div>
    </div>
    
    <div class="test-section">
        <h2>2. Test de l'API Profile (sans auth)</h2>
        <button onclick="testProfileAPI()">Tester /api/profile/</button>
        <div id="profile-result"></div>
    </div>
    
    <div class="test-section">
        <h2>3. Test de l'endpoint photo</h2>
        <button onclick="testPhotoEndpoint()">Tester /api/profile/photo</button>
        <div id="photo-result"></div>
    </div>
    
    <div class="test-section">
        <h2>4. Test avec fichier (simulé)</h2>
        <input type="file" id="testFile" accept="image/*">
        <button onclick="testFileUpload()">Tester upload</button>
        <div id="upload-result"></div>
    </div>

    <script>
        async function testDBConnection() {
            const resultDiv = document.getElementById('db-result');
            try {
                const response = await fetch('test_profile_api_debug.php');
                const text = await response.text();
                resultDiv.innerHTML = `<pre>${text}</pre>`;
            } catch (error) {
                resultDiv.innerHTML = `<div class="error">Erreur: ${error.message}</div>`;
            }
        }
        
        async function testProfileAPI() {
            const resultDiv = document.getElementById('profile-result');
            try {
                const response = await fetch('/api/profile/');
                const text = await response.text();
                resultDiv.innerHTML = `
                    <div class="${response.ok ? 'success' : 'error'}">
                        Status: ${response.status}<br>
                        <pre>${text}</pre>
                    </div>
                `;
            } catch (error) {
                resultDiv.innerHTML = `<div class="error">Erreur: ${error.message}</div>`;
            }
        }
        
        async function testPhotoEndpoint() {
            const resultDiv = document.getElementById('photo-result');
            try {
                const response = await fetch('/api/profile/photo', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
                const text = await response.text();
                resultDiv.innerHTML = `
                    <div class="${response.ok ? 'success' : 'error'}">
                        Status: ${response.status}<br>
                        <pre>${text}</pre>
                    </div>
                `;
            } catch (error) {
                resultDiv.innerHTML = `<div class="error">Erreur: ${error.message}</div>`;
            }
        }
        
        async function testFileUpload() {
            const resultDiv = document.getElementById('upload-result');
            const fileInput = document.getElementById('testFile');
            
            if (!fileInput.files[0]) {
                resultDiv.innerHTML = '<div class="error">Veuillez sélectionner un fichier</div>';
                return;
            }
            
            const formData = new FormData();
            formData.append('profile_photo', fileInput.files[0]);
            
            try {
                const response = await fetch('/api/profile/photo', {
                    method: 'POST',
                    body: formData
                });
                const text = await response.text();
                resultDiv.innerHTML = `
                    <div class="${response.ok ? 'success' : 'error'}">
                        Status: ${response.status}<br>
                        <pre>${text}</pre>
                    </div>
                `;
            } catch (error) {
                resultDiv.innerHTML = `<div class="error">Erreur: ${error.message}</div>`;
            }
        }
    </script>
</body>
</html>
