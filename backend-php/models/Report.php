<?php
/**
 * Report Model
 * Handle report operations
 */

require_once __DIR__ . '/../config/Database.php';

class Report {
    
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    // تقرير المبيعات اليومية
    public function getDailySales($date = null) {
        $date = $date ?? date('Y-m-d');
        
        $sql = "SELECT s.*, c.CustomerName
                FROM Sales s
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE CAST(s.SaleDate AS DATE) = ?
                ORDER BY s.SaleID DESC";
        
        $stmt = $this->db->query($sql, [$date]);
        $sales = $this->db->fetchAll($stmt);
        
        $total = array_sum(array_column($sales, 'FinalAmount'));
        
        return [
            'date' => $date,
            'sales' => $sales,
            'count' => count($sales),
            'total' => $total
        ];
    }
    
    // تقرير المبيعات الشهرية
    public function getMonthlySales($year = null, $month = null) {
        $year = $year ?? date('Y');
        $month = $month ?? date('m');
        
        $sql = "SELECT s.*, c.CustomerName
                FROM Sales s
                LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
                WHERE YEAR(s.SaleDate) = ? AND MONTH(s.SaleDate) = ?
                ORDER BY s.SaleDate DESC";
        
        $stmt = $this->db->query($sql, [$year, $month]);
        $sales = $this->db->fetchAll($stmt);
        
        $total = array_sum(array_column($sales, 'FinalAmount'));
        
        return [
            'year' => $year,
            'month' => $month,
            'sales' => $sales,
            'count' => count($sales),
            'total' => $total
        ];
    }
    
    // تقرير المنتجات الأكثر مبيعاً
    public function getTopSellingProducts($limit = 10) {
        $sql = "SELECT TOP (?) 
                    p.ProductID, p.ProductName, p.Barcode,
                    SUM(sd.Quantity) as TotalQuantity,
                    SUM(sd.TotalPrice) as TotalRevenue,
                    COUNT(DISTINCT sd.SaleID) as SalesCount
                FROM SaleDetails sd
                JOIN Products p ON sd.ProductID = p.ProductID
                GROUP BY p.ProductID, p.ProductName, p.Barcode
                ORDER BY TotalRevenue DESC";
        
        $stmt = $this->db->query($sql, [$limit]);
        return $this->db->fetchAll($stmt);
    }
    
    // تقرير العملاء الأكثر شراءً
    public function getTopCustomers($limit = 10) {
        $sql = "SELECT TOP (?) 
                    c.CustomerID, c.CustomerName, c.Phone,
                    COUNT(s.SaleID) as PurchaseCount,
                    SUM(s.FinalAmount) as TotalSpent,
                    c.Balance
                FROM Customers c
                LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
                WHERE c.IsActive = 1
                GROUP BY c.CustomerID, c.CustomerName, c.Phone, c.Balance
                ORDER BY TotalSpent DESC";
        
        $stmt = $this->db->query($sql, [$limit]);
        return $this->db->fetchAll($stmt);
    }
    
    // تقرير الأرباح
    public function getProfitReport($startDate = null, $endDate = null) {
        $startDate = $startDate ?? date('Y-m-01');
        $endDate = $endDate ?? date('Y-m-d');
        
        $sql = "SELECT 
                    sd.ProductID,
                    p.ProductName,
                    SUM(sd.Quantity) as TotalQuantity,
                    SUM(sd.TotalPrice) as TotalRevenue,
                    SUM(sd.Quantity * p.PurchasePrice) as TotalCost,
                    SUM(sd.TotalPrice - (sd.Quantity * p.PurchasePrice)) as TotalProfit
                FROM SaleDetails sd
                JOIN Products p ON sd.ProductID = p.ProductID
                JOIN Sales s ON sd.SaleID = s.SaleID
                WHERE s.SaleDate BETWEEN ? AND ?
                GROUP BY sd.ProductID, p.ProductName
                ORDER BY TotalProfit DESC";
        
        $stmt = $this->db->query($sql, [$startDate, $endDate]);
        $products = $this->db->fetchAll($stmt);
        
        $totalRevenue = array_sum(array_column($products, 'TotalRevenue'));
        $totalCost = array_sum(array_column($products, 'TotalCost'));
        $totalProfit = array_sum(array_column($products, 'TotalProfit'));
        
        return [
            'startDate' => $startDate,
            'endDate' => $endDate,
            'products' => $products,
            'summary' => [
                'totalRevenue' => $totalRevenue,
                'totalCost' => $totalCost,
                'totalProfit' => $totalProfit,
                'profitMargin' => $totalRevenue > 0 ? ($totalProfit / $totalRevenue * 100) : 0
            ]
        ];
    }
    
    // تقرير المخزون
    public function getInventoryReport() {
        $sql = "SELECT 
                    p.ProductID,
                    p.ProductName,
                    p.Barcode,
                    c.CategoryName,
                    u.UnitName,
                    p.Stock,
                    p.MinimumStock,
                    p.PurchasePrice,
                    p.SalePrice,
                    (p.Stock * p.PurchasePrice) as TotalValue,
                    CASE 
                        WHEN p.Stock <= 0 THEN 'نفذ'
                        WHEN p.Stock <= p.MinimumStock THEN 'منخفض'
                        ELSE 'متوفر'
                    END as Status
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Units u ON p.UnitID = u.UnitID
                WHERE p.IsActive = 1
                ORDER BY p.Stock ASC";
        
        $stmt = $this->db->query($sql);
        $products = $this->db->fetchAll($stmt);
        
        $totalValue = array_sum(array_column($products, 'TotalValue'));
        $outOfStock = count(array_filter($products, fn($p) => $p['Stock'] <= 0));
        $lowStock = count(array_filter($products, fn($p) => $p['Stock'] > 0 && $p['Stock'] <= $p['MinimumStock']));
        
        return [
            'products' => $products,
            'summary' => [
                'totalProducts' => count($products),
                'totalValue' => $totalValue,
                'outOfStock' => $outOfStock,
                'lowStock' => $lowStock
            ]
        ];
    }
    
    // تقرير الديون
    public function getDebtsReport() {
        $sql = "SELECT 
                    c.CustomerID,
                    c.CustomerName,
                    c.Phone,
                    c.Balance as TotalDebt,
                    COUNT(i.InstallmentID) as PendingInstallments,
                    SUM(CASE WHEN i.Status = 'معلق' THEN i.Amount ELSE 0 END) as PendingAmount
                FROM Customers c
                LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
                LEFT JOIN Installments i ON s.SaleID = i.SaleID AND i.Status = 'معلق'
                WHERE c.IsActive = 1 AND c.Balance > 0
                GROUP BY c.CustomerID, c.CustomerName, c.Phone, c.Balance
                ORDER BY c.Balance DESC";
        
        $stmt = $this->db->query($sql);
        $customers = $this->db->fetchAll($stmt);
        
        $totalDebt = array_sum(array_column($customers, 'TotalDebt'));
        
        return [
            'customers' => $customers,
            'summary' => [
                'totalCustomers' => count($customers),
                'totalDebt' => $totalDebt
            ]
        ];
    }
}
