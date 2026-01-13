<?php
class Database {
    private $host = 'sql100.infinityfree.com';
    private $db_name = 'if0_40888420_mycampus';
    private $username = 'if0_40888420';
    private $password = '8462579130Abc';
    public $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host={$this->host};dbname={$this->db_name};charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
            return $this->conn;

        } catch (PDOException $e) {
            error_log("DB ERROR: " . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Database connection failed"
            ]);
            exit;
        }
    }
}

function getPDO() {
    $db = new Database();
    return $db->getConnection();
}
