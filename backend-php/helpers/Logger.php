<?php
/**
 * ═══════════════════════════════════════════════════════════════════
 * 📝 Professional Logger - Advanced Logging System
 * ═══════════════════════════════════════════════════════════════════
 * 
 * @package     Sales Management System
 * @version     2.0.0
 * @author      9SOFT
 */

class Logger {
    
    private static $logDir = __DIR__ . '/../logs/';
    private static $logFile = 'app.log';
    private static $errorFile = 'error.log';
    private static $securityFile = 'security.log';
    private static $performanceFile = 'performance.log';
    private static $maxFileSize = 10485760; // 10MB
    
    // Log levels
    const DEBUG = 'DEBUG';
    const INFO = 'INFO';
    const WARNING = 'WARNING';
    const ERROR = 'ERROR';
    const CRITICAL = 'CRITICAL';
    const SECURITY = 'SECURITY';
    
    /**
     * Log info message
     */
    public static function info($message, $context = []) {
        self::write(self::INFO, $message, $context, self::$logFile);
    }
    
    /**
     * Log error message
     */
    public static function error($message, $context = []) {
        self::write(self::ERROR, $message, $context, self::$errorFile);
    }
    
    /**
     * Log warning message
     */
    public static function warning($message, $context = []) {
        self::write(self::WARNING, $message, $context, self::$logFile);
    }
    
    /**
     * Log debug message
     */
    public static function debug($message, $context = []) {
        if (defined('DEBUG_MODE') && DEBUG_MODE) {
            self::write(self::DEBUG, $message, $context, self::$logFile);
        }
    }
    
    /**
     * Log critical error
     */
    public static function critical($message, $context = []) {
        self::write(self::CRITICAL, $message, $context, self::$errorFile);
        // Could send email notification here
    }
    
    /**
     * Log security event
     */
    public static function security($message, $context = []) {
        self::write(self::SECURITY, $message, $context, self::$securityFile);
    }
    
    /**
     * Log API request
     */
    public static function logRequest($method, $uri, $params = []) {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        
        $context = [
            'method' => $method,
            'uri' => $uri,
            'ip' => $ip,
            'user_agent' => substr($userAgent, 0, 100),
            'params' => $params,
            'request_id' => defined('REQUEST_ID') ? REQUEST_ID : null
        ];
        
        self::info('API Request', $context);
    }
    
    /**
     * Log API response
     */
    public static function logResponse($statusCode, $data = null) {
        $executionTime = defined('REQUEST_START_TIME') 
            ? round((microtime(true) - REQUEST_START_TIME) * 1000, 2) 
            : 0;
        
        $context = [
            'status' => $statusCode,
            'execution_time' => $executionTime . ' ms',
            'memory_usage' => self::formatBytes(memory_get_usage(true)),
            'request_id' => defined('REQUEST_ID') ? REQUEST_ID : null
        ];
        
        self::info('API Response', $context);
        
        // Log slow requests
        if ($executionTime > 1000) {
            self::warning('Slow Request Detected', $context);
        }
    }
    
    /**
     * Log performance metrics
     */
    public static function performance($operation, $duration, $context = []) {
        $context['operation'] = $operation;
        $context['duration'] = round($duration * 1000, 2) . ' ms';
        $context['memory'] = self::formatBytes(memory_get_usage(true));
        
        self::write('PERFORMANCE', $operation, $context, self::$performanceFile);
    }
    
    /**
     * Write to log file
     */
    private static function write($level, $message, $context, $filename) {
        $logPath = self::$logDir . $filename;
        
        // Create log directory if not exists
        if (!file_exists(self::$logDir)) {
            mkdir(self::$logDir, 0755, true);
        }
        
        // Rotate log if too large
        if (file_exists($logPath) && filesize($logPath) > self::$maxFileSize) {
            self::rotateLogs($filename);
        }
        
        // Format log entry
        $timestamp = date('Y-m-d H:i:s');
        $levelFormatted = str_pad($level, 10);
        
        // Format context
        $contextStr = '';
        if (!empty($context)) {
            $contextStr = json_encode($context, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        
        // Color codes for console (if needed)
        $colors = [
            self::DEBUG => "\033[0;37m",     // White
            self::INFO => "\033[0;32m",      // Green
            self::WARNING => "\033[1;33m",   // Yellow
            self::ERROR => "\033[0;31m",     // Red
            self::CRITICAL => "\033[1;31m",  // Bold Red
            self::SECURITY => "\033[1;35m"   // Magenta
        ];
        $reset = "\033[0m";
        
        // Build log line
        $logLine = sprintf(
            "[%s] [%s] %s %s\n",
            $timestamp,
            $levelFormatted,
            $message,
            $contextStr
        );
        
        // Write to file
        file_put_contents($logPath, $logLine, FILE_APPEND | LOCK_EX);
    }
    
    /**
     * Rotate log files
     */
    private static function rotateLogs($filename) {
        $logPath = self::$logDir . $filename;
        $timestamp = date('Y-m-d_His');
        $newName = self::$logDir . pathinfo($filename, PATHINFO_FILENAME) . '_' . $timestamp . '.log';
        
        if (file_exists($logPath)) {
            rename($logPath, $newName);
            
            // Compress old log
            if (function_exists('gzopen')) {
                $source = file_get_contents($newName);
                $gzFile = $newName . '.gz';
                $gz = gzopen($gzFile, 'w9');
                gzwrite($gz, $source);
                gzclose($gz);
                unlink($newName);
            }
        }
    }
    
    /**
     * Format bytes to human readable
     */
    private static function formatBytes($bytes) {
        $units = ['B', 'KB', 'MB', 'GB'];
        $bytes = max($bytes, 0);
        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
        $pow = min($pow, count($units) - 1);
        $bytes /= (1 << (10 * $pow));
        
        return round($bytes, 2) . ' ' . $units[$pow];
    }
    
    /**
     * Clear logs
     */
    public static function clearLogs() {
        $files = glob(self::$logDir . '*.log');
        foreach ($files as $file) {
            if (is_file($file)) {
                unlink($file);
            }
        }
    }
    
    /**
     * Get recent logs
     */
    public static function getRecentLogs($filename = null, $lines = 100) {
        $filename = $filename ?? self::$logFile;
        $logPath = self::$logDir . $filename;
        
        if (!file_exists($logPath)) {
            return [];
        }
        
        $file = new SplFileObject($logPath);
        $file->seek(PHP_INT_MAX);
        $lastLine = $file->key();
        
        $logs = [];
        $start = max(0, $lastLine - $lines);
        
        $file->seek($start);
        while (!$file->eof()) {
            $line = trim($file->current());
            if (!empty($line)) {
                $logs[] = $line;
            }
            $file->next();
        }
        
        return $logs;
    }
}
