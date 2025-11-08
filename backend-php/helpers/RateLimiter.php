<?php
/**
 * Rate Limiter Helper
 * Protect API from abuse
 */

class RateLimiter {
    private static $store = [];
    private static $cacheFile = __DIR__ . '/../cache/rate_limits.json';
    
    /**
     * Check if request is allowed
     */
    public static function allow($identifier, $maxRequests = RATE_LIMIT_REQUESTS, $period = RATE_LIMIT_PERIOD) {
        if (!RATE_LIMIT_ENABLED) {
            return true;
        }
        
        self::loadStore();
        
        $key = self::getKey($identifier);
        $now = time();
        
        // Clean old entries
        self::cleanup($now);
        
        if (!isset(self::$store[$key])) {
            self::$store[$key] = [
                'count' => 1,
                'reset_at' => $now + $period
            ];
            self::saveStore();
            return true;
        }
        
        $data = self::$store[$key];
        
        // Reset if period expired
        if ($now >= $data['reset_at']) {
            self::$store[$key] = [
                'count' => 1,
                'reset_at' => $now + $period
            ];
            self::saveStore();
            return true;
        }
        
        // Check limit
        if ($data['count'] >= $maxRequests) {
            return false;
        }
        
        // Increment counter
        self::$store[$key]['count']++;
        self::saveStore();
        
        return true;
    }
    
    /**
     * Get remaining requests
     */
    public static function remaining($identifier, $maxRequests = RATE_LIMIT_REQUESTS) {
        if (!RATE_LIMIT_ENABLED) {
            return $maxRequests;
        }
        
        self::loadStore();
        
        $key = self::getKey($identifier);
        
        if (!isset(self::$store[$key])) {
            return $maxRequests;
        }
        
        $data = self::$store[$key];
        $now = time();
        
        if ($now >= $data['reset_at']) {
            return $maxRequests;
        }
        
        return max(0, $maxRequests - $data['count']);
    }
    
    /**
     * Get retry after time
     */
    public static function retryAfter($identifier) {
        self::loadStore();
        
        $key = self::getKey($identifier);
        
        if (!isset(self::$store[$key])) {
            return 0;
        }
        
        $data = self::$store[$key];
        $now = time();
        
        return max(0, $data['reset_at'] - $now);
    }
    
    /**
     * Clear limit for identifier
     */
    public static function clear($identifier) {
        self::loadStore();
        
        $key = self::getKey($identifier);
        unset(self::$store[$key]);
        
        self::saveStore();
    }
    
    /**
     * Get cache key
     */
    private static function getKey($identifier) {
        return 'rate_limit:' . md5($identifier);
    }
    
    /**
     * Load store from cache
     */
    private static function loadStore() {
        if (empty(self::$store) && file_exists(self::$cacheFile)) {
            $content = file_get_contents(self::$cacheFile);
            self::$store = json_decode($content, true) ?: [];
        }
    }
    
    /**
     * Save store to cache
     */
    private static function saveStore() {
        $dir = dirname(self::$cacheFile);
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        file_put_contents(self::$cacheFile, json_encode(self::$store));
    }
    
    /**
     * Cleanup expired entries
     */
    private static function cleanup($now) {
        foreach (self::$store as $key => $data) {
            if ($now >= $data['reset_at']) {
                unset(self::$store[$key]);
            }
        }
    }
    
    /**
     * Get identifier from request
     */
    public static function getIdentifier() {
        // Use IP address as identifier
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
        } elseif (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } else {
            $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        }
        
        return trim($ip);
    }
    
    /**
     * Middleware to check rate limit
     */
    public static function middleware() {
        $identifier = self::getIdentifier();
        
        if (!self::allow($identifier)) {
            $retryAfter = self::retryAfter($identifier);
            
            header('X-RateLimit-Limit: ' . RATE_LIMIT_REQUESTS);
            header('X-RateLimit-Remaining: 0');
            header('X-RateLimit-Reset: ' . (time() + $retryAfter));
            header('Retry-After: ' . $retryAfter);
            
            Response::error('تم تجاوز حد الطلبات. حاول مرة أخرى بعد قليل.', 429);
        }
        
        // Add rate limit headers
        $remaining = self::remaining($identifier);
        header('X-RateLimit-Limit: ' . RATE_LIMIT_REQUESTS);
        header('X-RateLimit-Remaining: ' . $remaining);
    }
}
