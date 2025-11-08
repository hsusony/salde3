<?php
/**
 * Product Model
 * Handle product operations
 */

require_once __DIR__ . '/../config/Database.php';

class Product {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getAll() {
        $sql = "SELECT p.*, c.CategoryName, u.UnitName
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Units u ON p.UnitID = u.UnitID
                WHERE p.IsActive = 1
                ORDER BY p.ProductID DESC";
        
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
    
    public function getById($id) {
        $sql = "SELECT p.*, c.CategoryName, u.UnitName
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Units u ON p.UnitID = u.UnitID
                WHERE p.ProductID = ? AND p.IsActive = 1";
        
        $stmt = $this->db->query($sql, [$id]);
        return $this->db->fetchOne($stmt);
    }
    
    public function create($data) {
        $sql = "INSERT INTO Products (ProductName, Barcode, CategoryID, UnitID, PurchasePrice, SalePrice, Stock, MinimumStock, ExpiryDate, Notes, IsActive) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        
        $params = [
            $data['ProductName'],
            $data['Barcode'] ?? null,
            $data['CategoryID'],
            $data['UnitID'],
            $data['PurchasePrice'],
            $data['SalePrice'],
            $data['Stock'] ?? 0,
            $data['MinimumStock'] ?? 0,
            $data['ExpiryDate'] ?? null,
            $data['Notes'] ?? null
        ];
        
        $this->db->execute($sql, $params);
        $id = $this->db->lastInsertId();
        
        return $this->getById($id);
    }
    
    public function update($id, $data) {
        $sql = "UPDATE Products 
                SET ProductName = ?, Barcode = ?, CategoryID = ?, UnitID = ?, 
                    PurchasePrice = ?, SalePrice = ?, Stock = ?, MinimumStock = ?, 
                    ExpiryDate = ?, Notes = ?
                WHERE ProductID = ?";
        
        $params = [
            $data['ProductName'],
            $data['Barcode'] ?? null,
            $data['CategoryID'],
            $data['UnitID'],
            $data['PurchasePrice'],
            $data['SalePrice'],
            $data['Stock'] ?? 0,
            $data['MinimumStock'] ?? 0,
            $data['ExpiryDate'] ?? null,
            $data['Notes'] ?? null,
            $id
        ];
        
        $this->db->execute($sql, $params);
        return $this->getById($id);
    }
    
    public function delete($id) {
        $sql = "UPDATE Products SET IsActive = 0 WHERE ProductID = ?";
        $this->db->execute($sql, [$id]);
        return true;
    }
     
    public function search($query) {
        $sql = "SELECT p.*, c.CategoryName, u.UnitName
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Units u ON p.UnitID = u.UnitID
                WHERE p.IsActive = 1 
                AND (p.ProductName LIKE ? OR p.Barcode LIKE ?)
                ORDER BY p.ProductID DESC";
        
        $searchTerm = "%$query%";
        $stmt = $this->db->query($sql, [$searchTerm, $searchTerm]);
        return $this->db->fetchAll($stmt);
    }
    
    public function getLowStock() {
        $sql = "SELECT p.*, c.CategoryName, u.UnitName
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Units u ON p.UnitID = u.UnitID
                WHERE p.IsActive = 1 AND p.Stock <= p.MinimumStock
                ORDER BY p.Stock ASC";
        
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
}
