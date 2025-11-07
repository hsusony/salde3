<?php
/**
 * Customer Model
 * Handle customer operations
 */

require_once __DIR__ . '/../config/Database.php';

class Customer {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getAll() {
        $sql = "SELECT * FROM Customers WHERE IsActive = 1 ORDER BY CustomerID DESC";
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
    
    public function getById($id) {
        $sql = "SELECT * FROM Customers WHERE CustomerID = ? AND IsActive = 1";
        $stmt = $this->db->query($sql, [$id]);
        return $this->db->fetchOne($stmt);
    }
    
    public function create($data) {
        $sql = "INSERT INTO Customers (CustomerName, Phone, Address, Email, TaxNumber, Notes, Balance, IsActive) 
                VALUES (?, ?, ?, ?, ?, ?, 0, 1)";
        
        $params = [
            $data['CustomerName'],
            $data['Phone'] ?? null,
            $data['Address'] ?? null,
            $data['Email'] ?? null,
            $data['TaxNumber'] ?? null,
            $data['Notes'] ?? null
        ];
        
        $this->db->execute($sql, $params);
        $id = $this->db->lastInsertId();
        
        return $this->getById($id);
    }
    
    public function update($id, $data) {
        $sql = "UPDATE Customers 
                SET CustomerName = ?, Phone = ?, Address = ?, Email = ?, TaxNumber = ?, Notes = ?
                WHERE CustomerID = ?";
        
        $params = [
            $data['CustomerName'],
            $data['Phone'] ?? null,
            $data['Address'] ?? null,
            $data['Email'] ?? null,
            $data['TaxNumber'] ?? null,
            $data['Notes'] ?? null,
            $id
        ];
        
        $this->db->execute($sql, $params);
        return $this->getById($id);
    }
    
    public function delete($id) {
        $sql = "UPDATE Customers SET IsActive = 0 WHERE CustomerID = ?";
        $this->db->execute($sql, [$id]);
        return true;
    }
    
    public function search($query) {
        $sql = "SELECT * FROM Customers 
                WHERE IsActive = 1 
                AND (CustomerName LIKE ? OR Phone LIKE ? OR Email LIKE ?)
                ORDER BY CustomerID DESC";
        
        $searchTerm = "%$query%";
        $stmt = $this->db->query($sql, [$searchTerm, $searchTerm, $searchTerm]);
        return $this->db->fetchAll($stmt);
    }
}
