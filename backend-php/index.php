<?php
/**
 * Sales Management System API
 * Professional PHP Backend with SQL Server 2008
 * 
 * @version 1.0.0
 * @author Sales Management Team
 */

// Enable error reporting for development
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_log('API Request: ' . $_SERVER['REQUEST_METHOD'] . ' ' . $_SERVER['REQUEST_URI']);

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Autoload helpers and models
require_once __DIR__ . '/helpers/Response.php';
require_once __DIR__ . '/helpers/Request.php';
require_once __DIR__ . '/helpers/Auth.php';
require_once __DIR__ . '/helpers/Logger.php';
require_once __DIR__ . '/helpers/Cache.php';
require_once __DIR__ . '/models/Customer.php';
require_once __DIR__ . '/models/Product.php';
require_once __DIR__ . '/models/Sale.php';
require_once __DIR__ . '/models/Category.php';
require_once __DIR__ . '/models/Unit.php';
require_once __DIR__ . '/models/Installment.php';
require_once __DIR__ . '/models/Report.php';
require_once __DIR__ . '/models/User.php';
require_once __DIR__ . '/models/Backup.php';

// Initialize request
$request = new Request();
$method = $request->getMethod();
$uri = $request->getUri();

// Log request
Logger::logRequest($method, $uri, $request->getParams());

// Remove base path
$uri = str_replace('/backend-php', '', $uri);
$uri = str_replace('/index.php', '', $uri);

// Parse URI
$parts = explode('/', trim($uri, '/'));
$endpoint = $parts[0] ?? '';
$resource = $parts[1] ?? '';
$id = $parts[2] ?? null;

try {
    
    // ===========================================
    // API INFO
    // ===========================================
    if (($endpoint === '' || $endpoint === 'api') && empty($resource)) {
        Response::success([
            'name' => 'Sales Management System API',
            'version' => '1.0.0',
            'description' => 'Professional REST API with PHP and SQL Server 2008',
            'endpoints' => [
                '/api/health' => 'Health check',
                '/api/auth/login' => 'User login',
                '/api/auth/register' => 'User registration',
                '/api/customers' => 'Customer management',
                '/api/products' => 'Product management',
                '/api/sales' => 'Sales management',
                '/api/categories' => 'Category management',
                '/api/units' => 'Unit management',
                '/api/installments' => 'Installment management',
                '/api/backup/create' => 'Create database backup',
                '/api/backup/list' => 'List all backups',
                '/api/backup/export' => 'Export data as JSON',
                '/api/reports/daily-sales' => 'Daily sales report',
                '/api/reports/monthly-sales' => 'Monthly sales report',
                '/api/reports/top-selling' => 'Top selling products',
                '/api/reports/top-customers' => 'Top customers',
                '/api/reports/profit' => 'Profit report',
                '/api/reports/inventory' => 'Inventory report',
                '/api/reports/debts' => 'Debts report',
                '/api/dashboard/stats' => 'Dashboard statistics'
            ]
        ]);
    }
    
    // ===========================================
    // HEALTH CHECK
    // ===========================================
    if ($endpoint === 'api' && $resource === 'health') {
        $db = Database::getInstance();
        $conn = $db->getConnection();
        
        Response::success([
            'status' => 'OK',
            'message' => 'Connected to SQL Server 2008',
            'database' => 'SalesManagementDB',
            'timestamp' => date('Y-m-d H:i:s')
        ]);
    }
    
    // ===========================================
    // AUTHENTICATION
    // ===========================================
    if ($endpoint === 'api' && $resource === 'auth') {
        $userModel = new User();
        
        // Login
        if ($method === 'POST' && $id === 'login') {
            $request->validate([
                'username' => 'required',
                'password' => 'required'
            ]);
            
            $result = $userModel->login(
                $request->input('username'),
                $request->input('password')
            );
            
            if ($result['success']) {
                Response::success($result);
            } else {
                Response::error($result['message'], 401);
            }
        }
        
        // Register
        if ($method === 'POST' && $id === 'register') {
            Auth::authenticate(); // Only authenticated users can register new users
            
            $request->validate([
                'Username' => 'required',
                'Password' => 'required',
                'FullName' => 'required'
            ]);
            
            $user = $userModel->create($request->getBody());
            Response::created($user, 'تم إنشاء المستخدم بنجاح');
        }
        
        // Get current user info
        if ($method === 'GET' && $id === 'me') {
            $currentUser = Auth::authenticate();
            $user = $userModel->getById($currentUser['user_id']);
            Response::success($user);
        }
    }
    
    // ===========================================
    // BACKUP & RESTORE
    // ===========================================
    if ($endpoint === 'api' && $resource === 'backup') {
        Auth::authenticate(); // Require authentication
        
        $backupModel = new Backup();
        
        // Create backup
        if ($method === 'POST' && $id === 'create') {
            $result = $backupModel->createBackup();
            Response::created($result, 'تم إنشاء النسخة الاحتياطية بنجاح');
        }
        
        // List backups
        if ($method === 'GET' && $id === 'list') {
            $backups = $backupModel->listBackups();
            Response::success($backups);
        }
        
        // Delete backup
        if ($method === 'DELETE' && $id) {
            $success = $backupModel->deleteBackup($id);
            if ($success) {
                Response::success(null, 'تم حذف النسخة الاحتياطية بنجاح');
            } else {
                Response::notFound('النسخة الاحتياطية غير موجودة');
            }
        }
        
        // Export as JSON
        if ($method === 'POST' && $id === 'export') {
            $tables = $request->input('tables', []);
            $result = $backupModel->exportJSON($tables);
            Response::created($result, 'تم تصدير البيانات بنجاح');
        }
    }
    
    // ===========================================
    // CUSTOMERS API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'customers') {
        $customerModel = new Customer();
        
        // GET all customers
        if ($method === 'GET' && !$id) {
            $search = $request->getParam('search');
            
            if ($search) {
                $customers = $customerModel->search($search);
            } else {
                $customers = $customerModel->getAll();
            }
            
            Response::success($customers);
        }
        
        // GET customer by ID
        if ($method === 'GET' && $id) {
            $customer = $customerModel->getById($id);
            
            if (!$customer) {
                Response::notFound('العميل غير موجود');
            }
            
            Response::success($customer);
        }
        
        // POST create customer
        if ($method === 'POST') {
            $request->validate([
                'CustomerName' => 'required|max:100',
                'Phone' => 'max:20',
                'Email' => 'email'
            ]);
            
            $customer = $customerModel->create($request->getBody());
            Response::created($customer, 'تم إضافة العميل بنجاح');
        }
        
        // PUT update customer
        if ($method === 'PUT' && $id) {
            $request->validate([
                'CustomerName' => 'required|max:100'
            ]);
            
            $customer = $customerModel->update($id, $request->getBody());
            Response::success($customer, 'تم تحديث بيانات العميل بنجاح');
        }
        
        // DELETE customer
        if ($method === 'DELETE' && $id) {
            $customerModel->delete($id);
            Response::success(null, 'تم حذف العميل بنجاح');
        }
    }
    
    // ===========================================
    // PRODUCTS API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'products') {
        $productModel = new Product();
        
        // GET all products
        if ($method === 'GET' && !$id) {
            $search = $request->getParam('search');
            $lowStock = $request->getParam('lowStock');
            
            if ($search) {
                $products = $productModel->search($search);
            } elseif ($lowStock) {
                $products = $productModel->getLowStock();
            } else {
                $products = $productModel->getAll();
            }
            
            Response::success($products);
        }
        
        // GET product by ID
        if ($method === 'GET' && $id) {
            $product = $productModel->getById($id);
            
            if (!$product) {
                Response::notFound('المنتج غير موجود');
            }
            
            Response::success($product);
        }
        
        // POST create product
        if ($method === 'POST') {
            $request->validate([
                'ProductName' => 'required|max:100',
                'CategoryID' => 'required|numeric',
                'UnitID' => 'required|numeric',
                'PurchasePrice' => 'required|numeric',
                'SalePrice' => 'required|numeric'
            ]);
            
            $product = $productModel->create($request->getBody());
            Response::created($product, 'تم إضافة المنتج بنجاح');
        }
        
        // PUT update product
        if ($method === 'PUT' && $id) {
            $request->validate([
                'ProductName' => 'required|max:100'
            ]);
            
            $product = $productModel->update($id, $request->getBody());
            Response::success($product, 'تم تحديث بيانات المنتج بنجاح');
        }
        
        // DELETE product
        if ($method === 'DELETE' && $id) {
            $productModel->delete($id);
            Response::success(null, 'تم حذف المنتج بنجاح');
        }
    }
    
    // ===========================================
    // SALES API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'sales') {
        $saleModel = new Sale();
        
        // GET all sales
        if ($method === 'GET' && !$id) {
            $date = $request->getParam('date');
            
            if ($date) {
                $report = $saleModel->getDailyReport($date);
                Response::success($report);
            } else {
                $sales = $saleModel->getAll();
                Response::success($sales);
            }
        }
        
        // GET sale by ID
        if ($method === 'GET' && $id) {
            $sale = $saleModel->getById($id);
            
            if (!$sale) {
                Response::notFound('الفاتورة غير موجودة');
            }
            
            Response::success($sale);
        }
        
        // POST create sale
        if ($method === 'POST') {
            $request->validate([
                'PaymentMethod' => 'required',
                'items' => 'required'
            ]);
            
            $sale = $saleModel->create($request->getBody());
            Response::created($sale, 'تم إضافة الفاتورة بنجاح');
        }
    }
    
    // ===========================================
    // CATEGORIES API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'categories') {
        $categoryModel = new Category();
        
        // GET all categories
        if ($method === 'GET' && !$id) {
            $withCount = $request->getParam('withCount');
            
            if ($withCount) {
                $categories = $categoryModel->getWithProductCount();
            } else {
                $categories = $categoryModel->getAll();
            }
            
            Response::success($categories);
        }
        
        // GET category by ID
        if ($method === 'GET' && $id) {
            $category = $categoryModel->getById($id);
            
            if (!$category) {
                Response::notFound('الفئة غير موجودة');
            }
            
            Response::success($category);
        }
        
        // POST create category
        if ($method === 'POST') {
            $request->validate([
                'CategoryName' => 'required|max:100'
            ]);
            
            $category = $categoryModel->create($request->getBody());
            Response::created($category, 'تم إضافة الفئة بنجاح');
        }
        
        // PUT update category
        if ($method === 'PUT' && $id) {
            $request->validate([
                'CategoryName' => 'required|max:100'
            ]);
            
            $category = $categoryModel->update($id, $request->getBody());
            Response::success($category, 'تم تحديث الفئة بنجاح');
        }
        
        // DELETE category
        if ($method === 'DELETE' && $id) {
            $categoryModel->delete($id);
            Response::success(null, 'تم حذف الفئة بنجاح');
        }
    }
    
    // ===========================================
    // UNITS API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'units') {
        $unitModel = new Unit();
        
        // GET all units
        if ($method === 'GET' && !$id) {
            $units = $unitModel->getAll();
            Response::success($units);
        }
        
        // GET unit by ID
        if ($method === 'GET' && $id) {
            $unit = $unitModel->getById($id);
            
            if (!$unit) {
                Response::notFound('الوحدة غير موجودة');
            }
            
            Response::success($unit);
        }
        
        // POST create unit
        if ($method === 'POST') {
            $request->validate([
                'UnitName' => 'required|max:50'
            ]);
            
            $unit = $unitModel->create($request->getBody());
            Response::created($unit, 'تم إضافة الوحدة بنجاح');
        }
        
        // PUT update unit
        if ($method === 'PUT' && $id) {
            $request->validate([
                'UnitName' => 'required|max:50'
            ]);
            
            $unit = $unitModel->update($id, $request->getBody());
            Response::success($unit, 'تم تحديث الوحدة بنجاح');
        }
        
        // DELETE unit
        if ($method === 'DELETE' && $id) {
            $unitModel->delete($id);
            Response::success(null, 'تم حذف الوحدة بنجاح');
        }
    }
    
    // ===========================================
    // INSTALLMENTS API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'installments') {
        $installmentModel = new Installment();
        
        // GET installments by sale
        if ($method === 'GET' && !$id) {
            $saleId = $request->getParam('saleId');
            $customerId = $request->getParam('customerId');
            $status = $request->getParam('status');
            
            if ($saleId) {
                $installments = $installmentModel->getAllBySale($saleId);
            } elseif ($customerId) {
                $installments = $installmentModel->getCustomerInstallments($customerId);
            } elseif ($status === 'due') {
                $installments = $installmentModel->getDueInstallments();
            } elseif ($status === 'overdue') {
                $installments = $installmentModel->getOverdueInstallments();
            } else {
                Response::error('يرجى تحديد saleId أو customerId أو status');
            }
            
            Response::success($installments);
        }
        
        // GET installment by ID
        if ($method === 'GET' && $id) {
            $installment = $installmentModel->getById($id);
            
            if (!$installment) {
                Response::notFound('القسط غير موجود');
            }
            
            Response::success($installment);
        }
        
        // POST create installment
        if ($method === 'POST') {
            $request->validate([
                'SaleID' => 'required|numeric',
                'Amount' => 'required|numeric',
                'DueDate' => 'required'
            ]);
            
            $installment = $installmentModel->create($request->getBody());
            Response::created($installment, 'تم إضافة القسط بنجاح');
        }
        
        // PUT pay installment
        if ($method === 'PUT' && $id) {
            $body = $request->getBody();
            $paidAmount = $body['PaidAmount'] ?? $body['Amount'];
            $paidDate = $body['PaidDate'] ?? null;
            
            $installment = $installmentModel->payInstallment($id, $paidAmount, $paidDate);
            Response::success($installment, 'تم دفع القسط بنجاح');
        }
    }
    
    // ===========================================
    // REPORTS API
    // ===========================================
    if ($endpoint === 'api' && $resource === 'reports') {
        $reportModel = new Report();
        
        // Daily sales report
        if ($method === 'GET' && $id === 'daily-sales') {
            $date = $request->getParam('date');
            $report = $reportModel->getDailySales($date);
            Response::success($report);
        }
        
        // Monthly sales report
        if ($method === 'GET' && $id === 'monthly-sales') {
            $year = $request->getParam('year');
            $month = $request->getParam('month');
            $report = $reportModel->getMonthlySales($year, $month);
            Response::success($report);
        }
        
        // Top selling products
        if ($method === 'GET' && $id === 'top-selling') {
            $limit = $request->getParam('limit', 10);
            $report = $reportModel->getTopSellingProducts($limit);
            Response::success($report);
        }
        
        // Top customers
        if ($method === 'GET' && $id === 'top-customers') {
            $limit = $request->getParam('limit', 10);
            $report = $reportModel->getTopCustomers($limit);
            Response::success($report);
        }
        
        // Profit report
        if ($method === 'GET' && $id === 'profit') {
            $startDate = $request->getParam('startDate');
            $endDate = $request->getParam('endDate');
            $report = $reportModel->getProfitReport($startDate, $endDate);
            Response::success($report);
        }
        
        // Inventory report
        if ($method === 'GET' && $id === 'inventory') {
            $report = $reportModel->getInventoryReport();
            Response::success($report);
        }
        
        // Debts report
        if ($method === 'GET' && $id === 'debts') {
            $report = $reportModel->getDebtsReport();
            Response::success($report);
        }
    }
    
    // ===========================================
    // DASHBOARD STATS
    // ===========================================
    if ($endpoint === 'api' && $resource === 'dashboard' && $id === 'stats') {
        $db = Database::getInstance();
        
        $customersSql = "SELECT COUNT(*) as count FROM Customers WHERE IsActive = 1";
        $customersStmt = $db->query($customersSql);
        $customersRow = $db->fetchOne($customersStmt);
        
        $productsSql = "SELECT COUNT(*) as count FROM Products WHERE IsActive = 1";
        $productsStmt = $db->query($productsSql);
        $productsRow = $db->fetchOne($productsStmt);
        
        $salesSql = "SELECT COUNT(*) as count FROM Sales";
        $salesStmt = $db->query($salesSql);
        $salesRow = $db->fetchOne($salesStmt);
        
        $todaySalesSql = "SELECT ISNULL(SUM(FinalAmount), 0) as total FROM Sales WHERE CAST(SaleDate AS DATE) = CAST(GETDATE() AS DATE)";
        $todaySalesStmt = $db->query($todaySalesSql);
        $todaySalesRow = $db->fetchOne($todaySalesStmt);
        
        $lowStockSql = "SELECT COUNT(*) as count FROM Products WHERE IsActive = 1 AND Stock <= MinimumStock";
        $lowStockStmt = $db->query($lowStockSql);
        $lowStockRow = $db->fetchOne($lowStockStmt);
        
        $debtsSql = "SELECT ISNULL(SUM(Balance), 0) as total FROM Customers WHERE IsActive = 1";
        $debtsStmt = $db->query($debtsSql);
        $debtsRow = $db->fetchOne($debtsStmt);
        
        Response::success([
            'totalCustomers' => $customersRow['count'],
            'totalProducts' => $productsRow['count'],
            'totalSales' => $salesRow['count'],
            'todaySales' => $todaySalesRow['total'],
            'lowStockProducts' => $lowStockRow['count'],
            'totalDebts' => $debtsRow['total']
        ]);
    }
    
    // Not found
    Response::notFound('Endpoint not found');
    
} catch (Exception $e) {
    Logger::error('Server Error: ' . $e->getMessage(), [
        'trace' => $e->getTraceAsString()
    ]);
    Response::serverError('خطأ: ' . $e->getMessage());
}
