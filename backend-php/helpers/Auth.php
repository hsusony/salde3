<?php
/**
 * Authentication Helper
 * Handle user authentication and JWT tokens
 */

class Auth {
    
    private static $secretKey = 'sales_management_secret_key_2025';
    
    // Generate JWT token
    public static function generateToken($userId, $username, $role = 'admin') {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode([
            'user_id' => $userId,
            'username' => $username,
            'role' => $role,
            'iat' => time(),
            'exp' => time() + (24 * 60 * 60) // 24 hours
        ]);
        
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secretKey, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }
    
    // Verify JWT token
    public static function verifyToken($token) {
        if (!$token) {
            return false;
        }
        
        $tokenParts = explode('.', $token);
        if (count($tokenParts) !== 3) {
            return false;
        }
        
        $header = self::base64UrlDecode($tokenParts[0]);
        $payload = self::base64UrlDecode($tokenParts[1]);
        $signatureProvided = $tokenParts[2];
        
        $signature = hash_hmac('sha256', $tokenParts[0] . "." . $tokenParts[1], self::$secretKey, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        if ($base64UrlSignature !== $signatureProvided) {
            return false;
        }
        
        $payloadData = json_decode($payload, true);
        
        if ($payloadData['exp'] < time()) {
            return false; // Token expired
        }
        
        return $payloadData;
    }
    
    // Get token from request header
    public static function getTokenFromHeader() {
        $headers = getallheaders();
        
        if (isset($headers['Authorization'])) {
            $auth = $headers['Authorization'];
            if (strpos($auth, 'Bearer ') === 0) {
                return substr($auth, 7);
            }
        }
        
        return null;
    }
    
    // Middleware to check authentication
    public static function authenticate() {
        $token = self::getTokenFromHeader();
        $user = self::verifyToken($token);
        
        if (!$user) {
            Response::error('غير مصرح - يرجى تسجيل الدخول', 401);
        }
        
        return $user;
    }
    
    // Hash password
    public static function hashPassword($password) {
        return password_hash($password, PASSWORD_BCRYPT);
    }
    
    // Verify password
    public static function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    private static function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
    
    private static function base64UrlDecode($data) {
        return base64_decode(strtr($data, '-_', '+/'));
    }
}
