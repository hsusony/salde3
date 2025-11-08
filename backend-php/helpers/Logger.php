<?php
/**
 * Logger Helper
 * Handle logging and debugging
 */

class Logger {
    
    private static $logFile = __DIR__ . '/../logs/app.log';
    private static $errorFile = __DIR__ . '/../logs/error.log';
    
    // Log info message
    public static function info($message, $context = []) {
        self::write('INFO', $message, $context, self::$logFile);
    }
    
    // Log error message
    public static function error($message, $context = []) {
        self::write('ERROR', $message, $context, self::$errorFile);
    }
    
    // Log warning message
    public static function warning($message, $context = []) {
        self::write('WARNING', $message, $context, self::$logFile);
    }
    
    // Log debug message
    public static function debug($message, $context = []) {
        if (defined('DEBUG_MODE') && DEBUG_MODE) {
            self::write('DEBUG', $message, $context, self::$logFile);
        }
    }
    
    // Log API request
    public static function logRequest($method, $uri, $params = []) {
        $message = sprintf('%s %s', $method, $uri);
        self::info($message, $params);
    }
    
    // Log API response
    public static function logResponse($statusCode, $data = null) {
        $message = sprintf('Response: %d', $statusCode);
        self::info($message, ['data' => $data]);
    }
    
    // Write to log file
    private static function write($level, $message, $context, $file) {
        $logDir = dirname($file);
        if (!file_exists($logDir)) {
            mkdir($logDir, 0777, true);
        }
        
        $timestamp = date('Y-m-d H:i:s');
        $contextStr = !empty($context) ? json_encode($context, JSON_UNESCAPED_UNICODE) : '';
        $logLine = sprintf("[%s] [%s] %s %s\n", $timestamp, $level, $message, $contextStr);
        
        file_put_contents($file, $logLine, FILE_APPEND);
    }
    
    // Clear logs
    public static function clearLogs() {
        if (file_exists(self::$logFile)) {
            unlink(self::$logFile);
        }
        if (file_exists(self::$errorFile)) {
            unlink(self::$errorFile);
        }
    }
}
