<?php
/**
 * Category Model
 * Handle category operations
 */

require_once __DIR__ . '/../config/Database.php';

class Category {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getAll() {
        $sql = "SELECT * FROM Categories WHERE IsActive = 1 ORDER BY CategoryName";
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
    
    public function getById($id) {
        $sql = "SELECT * FROM Categories WHERE CategoryID = ? AND IsActive = 1";
        $stmt = $this->db->query($sql, [$id]);
        return $this->db->fetchOne($stmt);
    }
    
    public function create($data) {
        $sql = "INSERT INTO Categories (CategoryName, Description, IsActive) 
                VALUES (?, ?, 1)";
        
        $params = [
            $data['CategoryName'],
            $data['Description'] ?? null
        ];
        
        $this->db->execute($sql, $params);
        $id = $this->db->lastInsertId();
        
        return $this->getById($id);
    }
    
    public function update($id, $data) {
        $sql = "UPDATE Categories 
                SET CategoryName = ?, Description = ?
                WHERE CategoryID = ?";
        
        $params = [
            $data['CategoryName'],
            $data['Description'] ?? null,
            $id
        ];
        
        $this->db->execute($sql, $params);
        return $this->getById($id);
    }
    
    public function delete($id) {
        $sql = "UPDATE Categories SET IsActive = 0 WHERE CategoryID = ?";
        $this->db->execute($sql, [$id]);
        return true;
    }
    
    public function getWithProductCount() {
        $sql = "SELECT c.*, 
                       COUNT(p.ProductID) as ProductCount
                FROM Categories c
                LEFT JOIN Products p ON c.CategoryID = p.CategoryID AND p.IsActive = 1
                WHERE c.IsActive = 1
                GROUP BY c.CategoryID, c.CategoryName, c.Description, c.IsActive
                ORDER BY c.CategoryName";
        
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
}
