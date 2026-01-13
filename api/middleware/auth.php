<?php
class Auth {
    private $db;
    
    public function __construct() {
        require_once '../../config/database.php';
        $database = new Database();
        $this->db = $database->getConnection();
    }
    
    public function getCurrentUser() {
        // Vérifier le token dans l'en-tête Authorization
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        
        if (empty($authHeader)) {
            return null;
        }
        
        // Extraire le token (format: "Bearer token")
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = $matches[1];
            return $this->validateToken($token);
        }
        
        return null;
    }
    
    private function validateToken($token) {
        try {
            // Pour l'instant, vérification simple - dans un vrai projet, utiliser JWT
            $stmt = $this->db->prepare("SELECT * FROM users WHERE auth_token = ? AND token_expires_at > NOW()");
            $stmt->execute([$token]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($user && $user['is_active'] && $user['account_status'] === 'active') {
                // Vérifier si c'est un admin pour les endpoints admin
                $adminRoles = ['admin_local', 'admin_national', 'superadmin', 'super_admin'];
                $isAdmin = in_array($user['primary_role'], $adminRoles);
                
                return $user;
            }
            
            return null;
        } catch (Exception $e) {
            error_log("Token validation error: " . $e->getMessage());
            return null;
        }
    }
    
    public function generateToken($userId) {
        try {
            $token = bin2hex(random_bytes(32));
            $expiresAt = date('Y-m-d H:i:s', strtotime('+24 hours'));
            
            $stmt = $this->db->prepare("UPDATE users SET auth_token = ?, token_expires_at = ? WHERE id = ?");
            $stmt->execute([$token, $expiresAt, $userId]);
            
            return $token;
        } catch (Exception $e) {
            error_log("Token generation error: " . $e->getMessage());
            return null;
        }
    }
    
    public function login($email, $password) {
        try {
            $stmt = $this->db->prepare("SELECT * FROM users WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($user && password_verify($password, $user['password_hash'])) {
                // Mettre à jour la dernière connexion
                $updateStmt = $this->db->prepare("UPDATE users SET last_login_at = NOW(), last_login_ip = ?, login_count = login_count + 1 WHERE id = ?");
                $updateStmt->execute([$_SERVER['REMOTE_ADDR'] ?? '', $user['id']]);
                
                // Générer un token
                $token = $this->generateToken($user['id']);
                
                return [
                    'success' => true,
                    'token' => $token,
                    'user' => [
                        'id' => $user['id'],
                        'email' => $user['email'],
                        'first_name' => $user['first_name'],
                        'last_name' => $user['last_name'],
                        'primary_role' => $user['primary_role'],
                        'institution_id' => $user['institution_id']
                    ]
                ];
            }
            
            return ['success' => false, 'message' => 'Email ou mot de passe incorrect'];
        } catch (Exception $e) {
            error_log("Login error: " . $e->getMessage());
            return ['success' => false, 'message' => 'Erreur de connexion'];
        }
    }
}
?>
