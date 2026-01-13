<?php
$pdo = new PDO('mysql:host=127.0.0.1;dbname=mycampus;charset=utf8mb4', 'root', '');
$stmt = $pdo->query('SELECT email, status, first_name, last_name FROM preinscriptions WHERE deleted_at IS NULL LIMIT 5');
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($results as $row) {
    echo 'Email: ' . $row['email'] . ', Status: ' . $row['status'] . ', Name: ' . $row['first_name'] . ' ' . $row['last_name'] . PHP_EOL;
}
?>
