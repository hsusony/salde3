<?php
/**
 * Validator Helper Class
 * Professional validation for API requests
 */

class Validator {
    private $errors = [];
    private $data = [];
    
    public function __construct($data = []) {
        $this->data = $data;
    }
    
    /**
     * Validate data against rules
     */
    public function validate($rules) {
        foreach ($rules as $field => $ruleString) {
            $rules = explode('|', $ruleString);
            $value = $this->data[$field] ?? null;
            
            foreach ($rules as $rule) {
                $this->applyRule($field, $value, $rule);
            }
        }
        
        return empty($this->errors);
    }
    
    /**
     * Apply single rule
     */
    private function applyRule($field, $value, $rule) {
        // Extract rule name and parameter
        $parts = explode(':', $rule);
        $ruleName = $parts[0];
        $parameter = $parts[1] ?? null;
        
        switch ($ruleName) {
            case 'required':
                if (empty($value) && $value !== '0' && $value !== 0) {
                    $this->addError($field, "$field مطلوب");
                }
                break;
                
            case 'email':
                if ($value && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $this->addError($field, "$field يجب أن يكون بريد إلكتروني صحيح");
                }
                break;
                
            case 'numeric':
                if ($value && !is_numeric($value)) {
                    $this->addError($field, "$field يجب أن يكون رقماً");
                }
                break;
                
            case 'min':
                if ($value && (is_numeric($value) && $value < $parameter)) {
                    $this->addError($field, "$field يجب أن يكون أكبر من أو يساوي $parameter");
                } elseif ($value && (is_string($value) && strlen($value) < $parameter)) {
                    $this->addError($field, "$field يجب أن يكون على الأقل $parameter حرف");
                }
                break;
                
            case 'max':
                if ($value && (is_numeric($value) && $value > $parameter)) {
                    $this->addError($field, "$field يجب أن يكون أصغر من أو يساوي $parameter");
                } elseif ($value && (is_string($value) && strlen($value) > $parameter)) {
                    $this->addError($field, "$field يجب ألا يتجاوز $parameter حرف");
                }
                break;
                
            case 'between':
                list($min, $max) = explode(',', $parameter);
                if ($value && (is_numeric($value) && ($value < $min || $value > $max))) {
                    $this->addError($field, "$field يجب أن يكون بين $min و $max");
                }
                break;
                
            case 'in':
                $allowed = explode(',', $parameter);
                if ($value && !in_array($value, $allowed)) {
                    $this->addError($field, "$field يجب أن يكون أحد القيم التالية: " . implode(', ', $allowed));
                }
                break;
                
            case 'url':
                if ($value && !filter_var($value, FILTER_VALIDATE_URL)) {
                    $this->addError($field, "$field يجب أن يكون رابط صحيح");
                }
                break;
                
            case 'phone':
                if ($value && !preg_match('/^[0-9]{10,15}$/', $value)) {
                    $this->addError($field, "$field يجب أن يكون رقم هاتف صحيح");
                }
                break;
                
            case 'date':
                if ($value && !strtotime($value)) {
                    $this->addError($field, "$field يجب أن يكون تاريخ صحيح");
                }
                break;
                
            case 'alpha':
                if ($value && !preg_match('/^[a-zA-Z]+$/', $value)) {
                    $this->addError($field, "$field يجب أن يحتوي على حروف فقط");
                }
                break;
                
            case 'alphanumeric':
                if ($value && !preg_match('/^[a-zA-Z0-9]+$/', $value)) {
                    $this->addError($field, "$field يجب أن يحتوي على حروف وأرقام فقط");
                }
                break;
                
            case 'unique':
                // For database unique validation
                // Parameter format: table,column
                if ($value && $parameter) {
                    list($table, $column) = explode(',', $parameter);
                    if ($this->existsInDatabase($table, $column, $value)) {
                        $this->addError($field, "$field موجود مسبقاً");
                    }
                }
                break;
        }
    }
    
    /**
     * Check if value exists in database
     */
    private function existsInDatabase($table, $column, $value) {
        try {
            $db = Database::getInstance();
            $sql = "SELECT COUNT(*) as count FROM $table WHERE $column = ?";
            $stmt = $db->prepare($sql);
            $db->execute($stmt, [$value]);
            $result = $db->fetchOne($stmt);
            return $result['count'] > 0;
        } catch (Exception $e) {
            return false;
        }
    }
    
    /**
     * Add validation error
     */
    private function addError($field, $message) {
        if (!isset($this->errors[$field])) {
            $this->errors[$field] = [];
        }
        $this->errors[$field][] = $message;
    }
    
    /**
     * Get all errors
     */
    public function getErrors() {
        return $this->errors;
    }
    
    /**
     * Get first error
     */
    public function getFirstError() {
        if (empty($this->errors)) {
            return null;
        }
        $firstField = array_key_first($this->errors);
        return $this->errors[$firstField][0];
    }
    
    /**
     * Check if validation passed
     */
    public function passes() {
        return empty($this->errors);
    }
    
    /**
     * Check if validation failed
     */
    public function fails() {
        return !empty($this->errors);
    }
    
    /**
     * Sanitize input data
     */
    public static function sanitize($data) {
        if (is_array($data)) {
            return array_map([self::class, 'sanitize'], $data);
        }
        
        if (is_string($data)) {
            $data = trim($data);
            $data = stripslashes($data);
            $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
        }
        
        return $data;
    }
    
    /**
     * Quick validation static method
     */
    public static function make($data, $rules) {
        $validator = new self($data);
        $validator->validate($rules);
        return $validator;
    }
}
