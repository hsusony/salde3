<?php
/**
 * Installment Model
 * Handle installment operations
 */

require_once __DIR__ . '/../config/Database.php';

class Installment {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getAllBySale($saleId) {
        $sql = "SELECT i.*, c.CustomerName
                FROM Installments i
                JOIN Sales s ON i.SaleID = s.SaleID
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE i.SaleID = ?
                ORDER BY i.DueDate";
        
        $stmt = $this->db->query($sql, [$saleId]);
        return $this->db->fetchAll($stmt);
    }
    
    public function getById($id) {
        $sql = "SELECT i.*, c.CustomerName
                FROM Installments i
                JOIN Sales s ON i.SaleID = s.SaleID
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE i.InstallmentID = ?";
        
        $stmt = $this->db->query($sql, [$id]);
        return $this->db->fetchOne($stmt);
    }
    
    public function create($data) {
        $sql = "INSERT INTO Installments (SaleID, InstallmentNumber, Amount, DueDate, Status, Notes) 
                VALUES (?, ?, ?, ?, 'معلق', ?)";
        
        $params = [
            $data['SaleID'],
            $data['InstallmentNumber'],
            $data['Amount'],
            $data['DueDate'],
            $data['Notes'] ?? null
        ];
        
        $this->db->execute($sql, $params);
        $id = $this->db->lastInsertId();
        
        return $this->getById($id);
    }
    
    public function payInstallment($id, $paidAmount, $paidDate = null) {
        $paidDate = $paidDate ?? date('Y-m-d');
        
        $sql = "UPDATE Installments 
                SET Status = 'مدفوع', PaidAmount = ?, PaidDate = ?
                WHERE InstallmentID = ?";
        
        $this->db->execute($sql, [$paidAmount, $paidDate, $id]);
        return $this->getById($id);
    }
    
    public function getDueInstallments($daysAhead = 7) {
        $sql = "SELECT i.*, s.InvoiceNumber, c.CustomerName, c.Phone
                FROM Installments i
                JOIN Sales s ON i.SaleID = s.SaleID
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE i.Status = 'معلق'
                AND i.DueDate <= DATEADD(day, ?, GETDATE())
                ORDER BY i.DueDate";
        
        $stmt = $this->db->query($sql, [$daysAhead]);
        return $this->db->fetchAll($stmt);
    }
    
    public function getOverdueInstallments() {
        $sql = "SELECT i.*, s.InvoiceNumber, c.CustomerName, c.Phone
                FROM Installments i
                JOIN Sales s ON i.SaleID = s.SaleID
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE i.Status = 'معلق'
                AND i.DueDate < CAST(GETDATE() AS DATE)
                ORDER BY i.DueDate";
        
        $stmt = $this->db->query($sql);
        return $this->db->fetchAll($stmt);
    }
    
    public function getCustomerInstallments($customerId) {
        $sql = "SELECT i.*, s.InvoiceNumber
                FROM Installments i
                JOIN Sales s ON i.SaleID = s.SaleID
                WHERE s.CustomerID = ?
                ORDER BY i.DueDate DESC";
        
        $stmt = $this->db->query($sql, [$customerId]);
        return $this->db->fetchAll($stmt);
    }
}
