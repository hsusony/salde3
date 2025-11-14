<?php
/**
 * ═══════════════════════════════════════════════════════════════════
 * 🛡️ Security Middleware - Advanced Protection Layer
 * ═══════════════════════════════════════════════════════════════════
 * 
 * @package     Sales Management System
 * @version     2.0.0
 * @author      9SOFT
 */

class SecurityMiddleware {
    
    private static $rateLimitWindow = 60; // seconds
    private static $maxRequestsPerWindow = 100;
    private static $blockedIPs = [];
    
    /**
     * Initialize security middleware
     */
    public static function init() {
        self::validateRequest();
        self::checkRateLimit();
        self::sanitizeInputs();
        self::preventSQLInjection();
    }
    
    /**
     * Validate incoming request
     */
    private static function validateRequest() {
        // Check request method
        $allowedMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'];
        if (!in_array($_SERVER['REQUEST_METHOD'], $allowedMethods)) {
            Response::error('Invalid request method', 405);
        }
        
        // Validate content type for POST/PUT requests
        if (in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT', 'PATCH'])) {
            $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
            if (strpos($contentType, 'application/json') === false && !empty($_POST) === false) {
                // Allow form data or JSON
            }
        }
        
        // Check for suspicious patterns
        $uri = $_SERVER['REQUEST_URI'] ?? '';
        $suspiciousPatterns = [
            '/\.\./i',           // Directory traversal
            '/union.*select/i',  // SQL injection
            '/<script/i',        // XSS
            '/javascript:/i',    // XSS
            '/eval\(/i',         // Code injection
            '/base64_decode/i'   // Code injection
        ];
        
        foreach ($suspiciousPatterns as $pattern) {
            if (preg_match($pattern, $uri)) {
                Logger::security('Suspicious request detected', [
                    'ip' => self::getClientIP(),
                    'uri' => $uri,
                    'pattern' => $pattern
                ]);
                Response::error('Security violation detected', 403);
            }
        }
    }
    
    /**
     * Check rate limiting
     */
    private static function checkRateLimit() {
        $ip = self::getClientIP();
        
        // Check if IP is blocked
        if (in_array($ip, self::$blockedIPs)) {
            Response::error('IP address blocked', 429);
        }
        
        // Simple file-based rate limiting
        $rateLimitFile = __DIR__ . '/../logs/rate-limit.json';
        
        if (!file_exists($rateLimitFile)) {
            file_put_contents($rateLimitFile, json_encode([]));
        }
        
        $rateData = json_decode(file_get_contents($rateLimitFile), true) ?? [];
        $now = time();
        
        // Clean old entries
        foreach ($rateData as $key => $data) {
            if ($now - $data['timestamp'] > self::$rateLimitWindow) {
                unset($rateData[$key]);
            }
        }
        
        // Check current IP
        if (!isset($rateData[$ip])) {
            $rateData[$ip] = [
                'count' => 1,
                'timestamp' => $now
            ];
        } else {
            $rateData[$ip]['count']++;
            
            if ($rateData[$ip]['count'] > self::$maxRequestsPerWindow) {
                Logger::security('Rate limit exceeded', ['ip' => $ip]);
                Response::error('Rate limit exceeded. Please try again later.', 429);
            }
        }
        
        file_put_contents($rateLimitFile, json_encode($rateData));
    }
    
    /**
     * Sanitize all inputs
     */
    private static function sanitizeInputs() {
        // Sanitize GET parameters
        if (!empty($_GET)) {
            foreach ($_GET as $key => $value) {
                $_GET[$key] = self::sanitizeValue($value);
            }
        }
        
        // Sanitize POST parameters
        if (!empty($_POST)) {
            foreach ($_POST as $key => $value) {
                $_POST[$key] = self::sanitizeValue($value);
            }
        }
    }
    
    /**
     * Sanitize a single value
     */
    private static function sanitizeValue($value) {
        if (is_array($value)) {
            return array_map([self::class, 'sanitizeValue'], $value);
        }
        
        // Remove null bytes
        $value = str_replace(chr(0), '', $value);
        
        // Trim whitespace
        $value = trim($value);
        
        return $value;
    }
    
    /**
     * Prevent SQL injection
     */
    private static function preventSQLInjection() {
        $input = file_get_contents('php://input');
        
        $sqlPatterns = [
            '/(\bunion\b.*\bselect\b)/i',
            '/(\bselect\b.*\bfrom\b.*\bwhere\b)/i',
            '/(\binsert\b.*\binto\b)/i',
            '/(\bupdate\b.*\bset\b)/i',
            '/(\bdelete\b.*\bfrom\b)/i',
            '/(\bdrop\b.*\btable\b)/i',
            '/(\bexec\b.*\()/i',
            '/(\bexecute\b.*\()/i'
        ];
        
        foreach ($sqlPatterns as $pattern) {
            if (preg_match($pattern, $input)) {
                Logger::security('SQL injection attempt detected', [
                    'ip' => self::getClientIP(),
                    'input' => substr($input, 0, 200)
                ]);
                Response::error('Invalid request', 400);
            }
        }
    }
    
    /**
     * Get client IP address
     */
    public static function getClientIP() {
        $ipKeys = [
            'HTTP_CLIENT_IP',
            'HTTP_X_FORWARDED_FOR',
            'HTTP_X_FORWARDED',
            'HTTP_X_CLUSTER_CLIENT_IP',
            'HTTP_FORWARDED_FOR',
            'HTTP_FORWARDED',
            'REMOTE_ADDR'
        ];
        
        foreach ($ipKeys as $key) {
            if (!empty($_SERVER[$key])) {
                $ip = $_SERVER[$key];
                
                // Handle multiple IPs (take first one)
                if (strpos($ip, ',') !== false) {
                    $ips = explode(',', $ip);
                    $ip = trim($ips[0]);
                }
                
                // Validate IP
                if (filter_var($ip, FILTER_VALIDATE_IP)) {
                    return $ip;
                }
            }
        }
        
        return 'unknown';
    }
    
    /**
     * Generate secure token
     */
    public static function generateSecureToken($length = 32) {
        return bin2hex(random_bytes($length));
    }
    
    /**
     * Hash password securely
     */
    public static function hashPassword($password) {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }
    
    /**
     * Verify password
     */
    public static function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    /**
     * Encrypt sensitive data
     */
    public static function encrypt($data, $key = null) {
        $key = $key ?? self::getEncryptionKey();
        $iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length('aes-256-cbc'));
        $encrypted = openssl_encrypt($data, 'aes-256-cbc', $key, 0, $iv);
        return base64_encode($encrypted . '::' . $iv);
    }
    
    /**
     * Decrypt sensitive data
     */
    public static function decrypt($data, $key = null) {
        $key = $key ?? self::getEncryptionKey();
        list($encrypted, $iv) = explode('::', base64_decode($data), 2);
        return openssl_decrypt($encrypted, 'aes-256-cbc', $key, 0, $iv);
    }
    
    /**
     * Get encryption key
     */
    private static function getEncryptionKey() {
        // In production, this should be in environment variable
        return hash('sha256', 'sales_management_system_9soft_2025');
    }
}
