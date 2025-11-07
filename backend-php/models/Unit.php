<?php
/**
 * Unit Model
 * Handle unit operations
 */

require_once __DIR__ . '/../config/Database.php';

class Unit {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getAll() {
        $sql = "SELECT * FROM Units WHERE IsActive = 1 ORDER BY UnitName";
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
    
    public function getById($id) {
        $sql = "SELECT * FROM Units WHERE UnitID = ? AND IsActive = 1";
        $stmt = $this->db->query($sql, [$id]);
        return $this->db->fetchOne($stmt);
    }
    
    public function create($data) {
        $sql = "INSERT INTO Units (UnitName, Symbol, IsActive) 
                VALUES (?, ?, 1)";
        
        $params = [
            $data['UnitName'],
            $data['Symbol'] ?? null
        ];
        
        $this->db->execute($sql, $params);
        $id = $this->db->lastInsertId();
        
        return $this->getById($id);
    }
    
    public function update($id, $data) {
        $sql = "UPDATE Units 
                SET UnitName = ?, Symbol = ?
                WHERE UnitID = ?";
        
        $params = [
            $data['UnitName'],
            $data['Symbol'] ?? null,
            $id
        ];
        
        $this->db->execute($sql, $params);
        return $this->getById($id);
    }
    
    public function delete($id) {
        $sql = "UPDATE Units SET IsActive = 0 WHERE UnitID = ?";
        $this->db->execute($sql, [$id]);
        return true;
    }
}
