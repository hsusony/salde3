<?php
/**
 * Request Helper Class
 * Handle HTTP requests
 */

class Request {
    
    private $method;
    private $uri;
    private $params;
    private $body;
    
    public function __construct() {
        $this->method = $_SERVER['REQUEST_METHOD'];
        $this->uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        $this->params = $_GET;
        
        // Get JSON body
        $input = file_get_contents('php://input');
        $this->body = json_decode($input, true) ?? [];
    }
    
    public function getMethod() {
        return $this->method;
    }
    
    public function getUri() {
        return $this->uri;
    }
    
    public function getParams() {
        return $this->params;
    }
    
    public function getParam($key, $default = null) {
        return $this->params[$key] ?? $default;
    }
    
    public function getBody() {
        return $this->body;
    }
    
    public function input($key, $default = null) {
        return $this->body[$key] ?? $default;
    }
    
    public function validate($rules) {
        $errors = [];
        
        foreach ($rules as $field => $rule) {
            $value = $this->input($field);
            $ruleList = explode('|', $rule);
            
            foreach ($ruleList as $r) {
                if ($r === 'required' && empty($value)) {
                    $errors[$field] = "حقل $field مطلوب";
                }
                
                if (strpos($r, 'max:') === 0) {
                    $max = (int)substr($r, 4);
                    if (strlen($value) > $max) {
                        $errors[$field] = "حقل $field يجب ألا يتجاوز $max حرف";
                    }
                }
                
                if ($r === 'email' && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $errors[$field] = "حقل $field يجب أن يكون بريد إلكتروني صحيح";
                }
                
                if ($r === 'numeric' && !is_numeric($value)) {
                    $errors[$field] = "حقل $field يجب أن يكون رقم";
                }
            }
        }
        
        if (!empty($errors)) {
            Response::error('بيانات غير صحيحة', 422);
        }
        
        return true;
    }
}
