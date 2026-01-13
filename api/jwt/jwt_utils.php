<?php

class JWTUtils {
    private static $secret_key = 'mycampus_secret_key_2024';
    private static $algorithm = 'HS256';
    private static $token_expiry = 3600; // 1 hour

    public static function generateToken($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => self::$algorithm]);
        $payload = json_encode($payload);
        
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret_key, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function validateToken($token) {
        try {
            $parts = explode('.', $token);
            if (count($parts) != 3) {
                return false;
            }

            $header = base64_decode($parts[0]);
            $payload = base64_decode($parts[1]);
            $signature = $parts[2];

            // Verify signature
            $base64UrlHeader = self::base64UrlEncode($header);
            $base64UrlPayload = self::base64UrlEncode($payload);
            
            $expectedSignature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret_key, true);
            $base64UrlExpectedSignature = self::base64UrlEncode($expectedSignature);

            if (!hash_equals($base64UrlSignature, $base64UrlExpectedSignature)) {
                return false;
            }

            // Check expiry
            $payloadData = json_decode($payload, true);
            if (isset($payloadData['exp']) && $payloadData['exp'] < time()) {
                return false;
            }

            return $payloadData;
        } catch (Exception $e) {
            return false;
        }
    }

    public static function decodeToken($token) {
        return self::validateToken($token);
    }

    private static function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64UrlDecode($data) {
        return base64_decode(str_pad(strtr($data, '-_', '+/'), strlen($data) % 4, '=', STR_PAD_RIGHT));
    }
}
?>
