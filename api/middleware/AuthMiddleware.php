<?php
class AuthMiddleware {
    private $db;
    
    public function __construct($db) {
        $this->db = $db;
    }
    
    // Vérifie si le token JWT est valide
    public function validateToken() {
        $headers = $this->getAuthorizationHeader();
        
        // Vérifier si l'en-tête d'autorisation est présent
        if (empty($headers)) {
            throw new Exception('Token d\'authentification manquant', 401);
        }

        if (!preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
            throw new Exception('Format de token invalide', 401);
        }
        
        $token = $matches[1];
        
        // Valider le format et la signature du token JWT
        $payload = $this->validateJwtFormat($token);
        
        // Vérifier que le token n'est pas dans la liste noire (optionnel)
        // return $this->checkTokenRevocation($token);
        
        // Retourner les informations de l'utilisateur depuis le payload
        if (isset($payload['data']) && is_array($payload['data'])) {
            return [
                'success' => true,
                'user' => [
                    'id' => $payload['data']['id'] ?? null,
                    'email' => $payload['data']['email'] ?? null,
                    'role' => $payload['data']['role'] ?? 'user',
                    'ip' => $payload['data']['ip'] ?? null
                ]
            ];
        }
        
        throw new Exception('Données utilisateur manquantes dans le token', 401);
    }
    
    /**
     * Valide le format d'un token JWT
     * @param string $token Le token à valider
     * @throws Exception Si le token est invalide
     */
    private function validateJwtFormat($token) {
        error_log("Validation du format du token JWT...");
        
        // Un token JWT valide doit avoir 3 parties séparées par des points
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            error_log("Le token n'a pas 3 parties");
            throw new Exception('Format de token JWT invalide', 401);
        }
        
        // Vérifier que chaque partie est en base64url valide
        foreach ($parts as $index => $part) {
            if (!preg_match('/^[a-zA-Z0-9-_]+$/', $part)) {
                error_log("Partie $index du token contient des caractères invalides");
                throw new Exception('Token JWT contient des caractères invalides', 401);
            }
        }
        
        // Vérifier que le header est un JSON valide
        $header = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[0])), true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            error_log("Erreur de décodage du header: " . json_last_error_msg());
            error_log("Header: " . $parts[0]);
            throw new Exception('En-tête JWT invalide', 401);
        }
        
        // Vérifier que le payload est un JSON valide
        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1])), true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            error_log("Erreur de décodage du payload: " . json_last_error_msg());
            error_log("Payload: " . $parts[1]);
            throw new Exception('Contenu JWT invalide', 401);
        }
        
        // Vérifier les champs requis dans le payload
        if (!isset($payload['exp']) || !is_numeric($payload['exp'])) {
            error_log("Champ 'exp' manquant ou invalide dans le payload");
            error_log("Payload complet: " . print_r($payload, true));
            throw new Exception('Token JWT invalide: date d\'expiration manquante', 401);
        }
        
        // Vérifier si le token est expiré
        $currentTime = time();
        $expirationTime = $payload['exp'];
        
        error_log("Temps actuel: $currentTime");
        error_log("Expiration du token: $expirationTime");
        
        if ($currentTime >= $expirationTime) {
            error_log("Le token a expiré (délai dépassé de " . ($currentTime - $expirationTime) . " secondes)");
            throw new Exception('Token expiré', 401);
        }
        
        // Vérifier la signature du token
        $secret_key = "YOUR_SECRET_KEY"; // Doit correspondre à la clé utilisée dans login.php
        
        try {
            // Inclure la classe JWT si elle n'est pas déjà incluse
            if (!class_exists('Firebase\JWT\JWT')) {
                require_once __DIR__ . '/../../vendor/autoload.php';
            }
            
            // Décoder le token pour vérifier la signature
            $decoded = JWT::decode($token, new Firebase\JWT\Key($secret_key, 'HS256'));
            $decodedArray = (array)$decoded;
            
            // Vérifier l'émetteur (issuer) si nécessaire
            if (isset($payload['iss']) && $payload['iss'] !== 'mycampus') {
                throw new Exception('Émetteur du token invalide', 401);
            }
            
            error_log("Token JWT valide et signé");
            return $decodedArray;
        } catch (Exception $e) {
            error_log("Erreur de validation du token JWT: " . $e->getMessage());
            throw new Exception('Token JWT invalide: ' . $e->getMessage(), 401);
        }
    }
    
    // Récupère l'en-tête d'autorisation
    private function getAuthorizationHeader() {
        $headers = null;
        
        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER["Authorization"]);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
        } elseif (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            $requestHeaders = array_combine(
                array_map('ucwords', array_keys($requestHeaders)),
                array_values($requestHeaders)
            );
            
            if (isset($requestHeaders['Authorization'])) {
                $headers = trim($requestHeaders['Authorization']);
            }
        }
        
        return $headers;
    }
    
    // Vérifie si le token est révoqué (optionnel)
    private function checkTokenRevocation($token) {
        // Implémentez cette méthode si vous avez besoin de vérifier les tokens révoqués
        // Par exemple, en vérifiant dans une table de tokens révoqués
        return true;
    }
}
