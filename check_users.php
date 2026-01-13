<?php
// Check existing users in database
header('Content-Type: text/html');

try {
    $host = 'localhost';
    $dbname = 'mycampus';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo '<h2>Database Connection: SUCCESS</h2>';
    
    // Check if users table exists and get sample users
    $stmt = $pdo->query("SELECT id, email, first_name, last_name, profile_photo_url FROM users LIMIT 5");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo '<h3>Sample Users:</h3>';
    if (count($users) > 0) {
        echo '<table border="1" cellpadding="5">';
        echo '<tr><th>ID</th><th>Name</th><th>Email</th><th>Current Avatar</th></tr>';
        foreach ($users as $user) {
            echo '<tr>';
            echo '<td>' . htmlspecialchars($user['id']) . '</td>';
            echo '<td>' . htmlspecialchars($user['first_name'] . ' ' . $user['last_name']) . '</td>';
            echo '<td>' . htmlspecialchars($user['email']) . '</td>';
            echo '<td>' . htmlspecialchars($user['profile_photo_url'] ?? 'NULL') . '</td>';
            echo '</tr>';
        }
        echo '</table>';
        
        echo '<h3>Test User IDs you can use:</h3>';
        foreach ($users as $user) {
            echo '<button onclick="copyUserId(' . $user['id'] . ')">Copy User ID ' . $user['id'] . ' (' . htmlspecialchars($user['first_name'] . ' ' . $user['last_name']) . ')</button><br>';
        }
    } else {
        echo '<p>No users found in the database. You need to create a user first.</p>';
    }
    
    // Check table structure
    echo '<h3>Users Table Structure (avatar related columns):</h3>';
    $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE '%photo%' OR LIKE '%avatar%' OR LIKE '%picture%'");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo '<table border="1" cellpadding="5">';
    echo '<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th></tr>';
    foreach ($columns as $column) {
        echo '<tr>';
        echo '<td>' . htmlspecialchars($column['Field']) . '</td>';
        echo '<td>' . htmlspecialchars($column['Type']) . '</td>';
        echo '<td>' . htmlspecialchars($column['Null']) . '</td>';
        echo '<td>' . htmlspecialchars($column['Key']) . '</td>';
        echo '<td>' . htmlspecialchars($column['Default']) . '</td>';
        echo '</tr>';
    }
    echo '</table>';
    
} catch (Exception $e) {
    echo '<h2>Database Connection: FAILED</h2>';
    echo '<p>Error: ' . htmlspecialchars($e->getMessage()) . '</p>';
}
?>

<script>
function copyUserId(userId) {
    navigator.clipboard.writeText(userId).then(function() {
        alert('User ID ' + userId + ' copied to clipboard!');
    });
}
</script>

<h2>Test Upload API</h2>
<p>Use the test page: <a href="test_simple_upload.php">test_simple_upload.php</a></p>
<p>Or the original test: <a href="test_upload_api.php">test_upload_api.php</a></p>
