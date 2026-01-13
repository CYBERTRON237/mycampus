<?php
class Database {
    private $host = 'localhost';
    private $db_name = 'mycampus';
    private $username = 'root';
    private $password = '';
    public $conn;

    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
            
            return $this->conn;
            
        } catch(PDOException $e) {
            // Journaliser l'erreur dans le fichier de log PHP
            error_log("Erreur de connexion à la base de données: " . $e->getMessage());
            
            // Lancer une exception avec un message clair
            throw new Exception("Impossible de se connecter à la base de données. Veuillez réessayer plus tard.");
        }
    }
}

// Fonction utilitaire pour obtenir une connexion PDO
function getPDO() {
    try {
        $db = new Database();
        return $db->getConnection();
    } catch (Exception $e) {
        // Journaliser l'erreur et la propager
        error_log("Erreur dans getPDO(): " . $e->getMessage());
        throw $e;
    }
}
