<?php
/**
 * Response Helper Class
 * Handle JSON responses
 */

class Response {
    
    public static function json($data, $statusCode = 200) {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
    
    public static function success($data, $message = null, $statusCode = 200) {
        self::json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $statusCode);
    }
    
    public static function error($message, $statusCode = 400) {
        self::json([
            'success' => false,
            'message' => $message
        ], $statusCode);
    }
    
    public static function created($data, $message = 'تم الإنشاء بنجاح') {
        self::success($data, $message, 201);
    }
    
    public static function notFound($message = 'غير موجود') {
        self::error($message, 404);
    }
    
    public static function serverError($message = 'خطأ في السيرفر') {
        self::error($message, 500);
    }
}
