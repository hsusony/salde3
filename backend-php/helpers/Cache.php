<?php
/**
 * Cache Helper
 * Simple file-based caching system
 */

class Cache {
    
    private static $cacheDir = __DIR__ . '/../cache/';
    private static $defaultTTL = 3600; // 1 hour
    
    // Get value from cache
    public static function get($key) {
        $file = self::getFilePath($key);
        
        if (!file_exists($file)) {
            return null;
        }
        
        $data = json_decode(file_get_contents($file), true);
        
        if ($data['expires'] < time()) {
            self::delete($key);
            return null;
        }
        
        return $data['value'];
    }
    
    // Set value in cache
    public static function set($key, $value, $ttl = null) {
        if (!file_exists(self::$cacheDir)) {
            mkdir(self::$cacheDir, 0777, true);
        }
        
        $ttl = $ttl ?? self::$defaultTTL;
        $file = self::getFilePath($key);
        
        $data = [
            'value' => $value,
            'expires' => time() + $ttl
        ];
        
        file_put_contents($file, json_encode($data));
    }
    
    // Check if key exists in cache
    public static function has($key) {
        return self::get($key) !== null;
    }
    
    // Delete value from cache
    public static function delete($key) {
        $file = self::getFilePath($key);
        if (file_exists($file)) {
            unlink($file);
        }
    }
    
    // Clear all cache
    public static function clear() {
        if (!file_exists(self::$cacheDir)) {
            return;
        }
        
        $files = glob(self::$cacheDir . '*.cache');
        foreach ($files as $file) {
            if (is_file($file)) {
                unlink($file);
            }
        }
    }
    
    // Remember value (get or set)
    public static function remember($key, $callback, $ttl = null) {
        $value = self::get($key);
        
        if ($value !== null) {
            return $value;
        }
        
        $value = $callback();
        self::set($key, $value, $ttl);
        
        return $value;
    }
    
    private static function getFilePath($key) {
        return self::$cacheDir . md5($key) . '.cache';
    }
}
