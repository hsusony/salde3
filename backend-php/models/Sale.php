<?php
/**
 * Sale Model
 * Handle sales operations
 */

require_once __DIR__ . '/../config/Database.php';

class Sale {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getAll() {
        $sql = "SELECT s.*, c.CustomerName
                FROM Sales s
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                ORDER BY s.SaleID DESC";
        
        $stmt = $this->db->query($sql);
        $sales = $this->db->fetchAll($stmt);
        
        // Get items for each sale
        foreach ($sales as &$sale) {
            $sale['items'] = $this->getSaleDetails($sale['SaleID']);
        }
        
        return $sales;
    }
    
    public function getById($id) {
        $sql = "SELECT s.*, c.CustomerName
                FROM Sales s
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE s.SaleID = ?";
        
        $stmt = $this->db->query($sql, [$id]);
        $sale = $this->db->fetchOne($stmt);
        
        if ($sale) {
            $sale['items'] = $this->getSaleDetails($id);
        }
        
        return $sale;
    }
    
    private function getSaleDetails($saleId) {
        $sql = "SELECT sd.*, p.ProductName, p.Barcode
                FROM SaleDetails sd
                JOIN Products p ON sd.ProductID = p.ProductID
                WHERE sd.SaleID = ?";
        
        $stmt = $this->db->query($sql, [$saleId]);
        return $this->db->fetchAll($stmt);
    }
    
    public function create($data) {
        try {
            $this->db->beginTransaction();
            
            // Calculate totals
            $totalAmount = 0;
            foreach ($data['items'] as $item) {
                $totalAmount += $item['Quantity'] * $item['UnitPrice'];
            }
            
            $discount = $data['Discount'] ?? 0;
            $tax = $data['Tax'] ?? 0;
            $finalAmount = $totalAmount - $discount + $tax;
            
            // Generate invoice number
            $countSql = "SELECT COUNT(*) as count FROM Sales";
            $countStmt = $this->db->query($countSql);
            $countRow = $this->db->fetchOne($countStmt);
            $count = $countRow['count'] + 1;
            $invoiceNumber = 'INV-' . date('Ymd') . '-' . str_pad($count, 4, '0', STR_PAD_LEFT);
            
            // Create sale
            $sql = "INSERT INTO Sales (InvoiceNumber, CustomerID, SaleDate, TotalAmount, Discount, Tax, FinalAmount, PaymentMethod, Status, Notes) 
                    VALUES (?, ?, GETDATE(), ?, ?, ?, ?, ?, ?, ?)";
            
            $params = [
                $invoiceNumber,
                $data['CustomerID'] ?? null,
                $totalAmount,
                $discount,
                $tax,
                $finalAmount,
                $data['PaymentMethod'],
                'مكتملة',
                $data['Notes'] ?? null
            ];
            
            $this->db->execute($sql, $params);
            $saleId = $this->db->lastInsertId();
            
            // Add sale details
            foreach ($data['items'] as $item) {
                $totalPrice = $item['Quantity'] * $item['UnitPrice'];
                
                $detailSql = "INSERT INTO SaleDetails (SaleID, ProductID, Quantity, UnitPrice, TotalPrice) 
                              VALUES (?, ?, ?, ?, ?)";
                
                $this->db->execute($detailSql, [
                    $saleId,
                    $item['ProductID'],
                    $item['Quantity'],
                    $item['UnitPrice'],
                    $totalPrice
                ]);
                
                // Update stock
                $stockSql = "UPDATE Products SET Stock = Stock - ? WHERE ProductID = ?";
                $this->db->execute($stockSql, [$item['Quantity'], $item['ProductID']]);
            }
            
            // Update customer balance
            if (!empty($data['CustomerID'])) {
                $balanceSql = "UPDATE Customers SET Balance = Balance + ? WHERE CustomerID = ?";
                $this->db->execute($balanceSql, [$finalAmount, $data['CustomerID']]);
            }
            
            $this->db->commit();
            
            return $this->getById($saleId);
            
        } catch (Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }
    
    public function getDailyReport($date = null) {
        $date = $date ?? date('Y-m-d');
        
        $sql = "SELECT s.*, c.CustomerName
                FROM Sales s
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE CAST(s.SaleDate AS DATE) = ?
                ORDER BY s.SaleID DESC";
        
        $stmt = $this->db->query($sql, [$date]);
        $sales = $this->db->fetchAll($stmt);
        
        $totalSales = 0;
        $totalDiscount = 0;
        $totalTax = 0;
        
        foreach ($sales as &$sale) {
            $sale['items'] = $this->getSaleDetails($sale['SaleID']);
            $totalSales += $sale['FinalAmount'];
            $totalDiscount += $sale['Discount'];
            $totalTax += $sale['Tax'];
        }
        
        return [
            'sales' => $sales,
            'summary' => [
                'totalSales' => $totalSales,
                'totalDiscount' => $totalDiscount,
                'totalTax' => $totalTax,
                'count' => count($sales),
                'date' => $date
            ]
        ];
    }
}
