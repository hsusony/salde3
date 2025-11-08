<?php
/**
 * User Model
 * Handle user authentication and management
 */

require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../helpers/Auth.php';

class User {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    // Login user
    public function login($username, $password) {
        $sql = "SELECT * FROM Users WHERE Username = ? AND IsActive = 1";
        $stmt = $this->db->query($sql, [$username]);
        $user = $this->db->fetchOne($stmt);
        
        if (!$user) {
            return ['success' => false, 'message' => 'اسم المستخدم أو كلمة المرور غير صحيحة'];
        }
        
        if (!Auth::verifyPassword($password, $user['Password'])) {
            return ['success' => false, 'message' => 'اسم المستخدم أو كلمة المرور غير صحيحة'];
        }
        
        // Update last login
        $updateSql = "UPDATE Users SET LastLogin = GETDATE() WHERE UserID = ?";
        $this->db->execute($updateSql, [$user['UserID']]);
        
        // Generate token
        $token = Auth::generateToken($user['UserID'], $user['Username'], $user['Role']);
        
        return [
            'success' => true,
            'token' => $token,
            'user' => [
                'id' => $user['UserID'],
                'username' => $user['Username'],
                'fullName' => $user['FullName'],
                'role' => $user['Role'],
                'email' => $user['Email']
            ]
        ];
    }
    
    // Create user
    public function create($data) {
        $hashedPassword = Auth::hashPassword($data['Password']);
        
        $sql = "INSERT INTO Users (Username, Password, FullName, Email, Phone, Role, IsActive) 
                VALUES (?, ?, ?, ?, ?, ?, 1)";
        
        $params = [
            $data['Username'],
            $hashedPassword,
            $data['FullName'],
            $data['Email'] ?? null,
            $data['Phone'] ?? null,
            $data['Role'] ?? 'user'
        ];
        
        $this->db->execute($sql, $params);
        $id = $this->db->lastInsertId();
        
        return $this->getById($id);
    }
    
    // Get user by ID
    public function getById($id) {
        $sql = "SELECT UserID, Username, FullName, Email, Phone, Role, IsActive, CreatedAt, LastLogin 
                FROM Users WHERE UserID = ?";
        $stmt = $this->db->query($sql, [$id]);
        return $this->db->fetchOne($stmt);
    }
    
    // Get all users
    public function getAll() {
        $sql = "SELECT UserID, Username, FullName, Email, Phone, Role, IsActive, CreatedAt, LastLogin 
                FROM Users WHERE IsActive = 1 
                ORDER BY UserID DESC";
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
    
    // Update user
    public function update($id, $data) {
        $sql = "UPDATE Users 
                SET FullName = ?, Email = ?, Phone = ?, Role = ?
                WHERE UserID = ?";
        
        $params = [
            $data['FullName'],
            $data['Email'] ?? null,
            $data['Phone'] ?? null,
            $data['Role'],
            $id
        ];
        
        $this->db->execute($sql, $params);
        return $this->getById($id);
    }
    
    // Change password
    public function changePassword($id, $newPassword) {
        $hashedPassword = Auth::hashPassword($newPassword);
        
        $sql = "UPDATE Users SET Password = ? WHERE UserID = ?";
        $this->db->execute($sql, [$hashedPassword, $id]);
        
        return true;
    }
    
    // Delete user
    public function delete($id) {
        $sql = "UPDATE Users SET IsActive = 0 WHERE UserID = ?";
        $this->db->execute($sql, [$id]);
        return true;
    }
}
