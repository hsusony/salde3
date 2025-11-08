<?php

/*
|--------------------------------------------------------------------------
| API Routes for Sales Management System
|--------------------------------------------------------------------------
*/

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

// Test API
Route::get('/test', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Laravel API is working!',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
});

// Health check
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        $dbName = DB::connection()->getDatabaseName();
        
        return response()->json([
            'status' => 'OK',
            'message' => 'Connected to SQL Server',
            'database' => $dbName,
            'timestamp' => now()
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'ERROR',
            'message' => $e->getMessage()
        ], 500);
    }
});

// Customers endpoints
Route::get('/customers', function () {
    try {
        $customers = DB::table('Customers')
            ->where('IsActive', 1)
            ->orderBy('CustomerID', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => $customers,
            'count' => $customers->count()
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

Route::get('/customers/{id}', function ($id) {
    try {
        $customer = DB::table('Customers')
            ->where('CustomerID', $id)
            ->first();
        
        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Customer not found'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => $customer
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

Route::post('/customers', function (Request $request) {
    try {
        $data = $request->validate([
            'CustomerName' => 'required|string|max:100',
            'Phone' => 'nullable|string|max:20',
            'Address' => 'nullable|string|max:255',
            'Email' => 'nullable|email|max:100'
        ]);
        
        $id = DB::table('Customers')->insertGetId([
            'CustomerName' => $data['CustomerName'],
            'Phone' => $data['Phone'] ?? null,
            'Address' => $data['Address'] ?? null,
            'Email' => $data['Email'] ?? null,
            'Balance' => 0,
            'IsActive' => 1
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'تم إضافة العميل بنجاح',
            'data' => DB::table('Customers')->where('CustomerID', $id)->first()
        ], 201);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

// Products endpoints
Route::get('/products', function () {
    try {
        $products = DB::table('Products')
            ->where('IsActive', 1)
            ->orderBy('ProductID', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => $products,
            'count' => $products->count()
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

Route::get('/products/{id}', function ($id) {
    try {
        $product = DB::table('Products')
            ->where('ProductID', $id)
            ->first();
        
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => $product
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

// Sales endpoints
Route::get('/sales', function () {
    try {
        $sales = DB::table('Sales as s')
            ->leftJoin('Customers as c', 's.CustomerID', '=', 'c.CustomerID')
            ->select('s.*', 'c.CustomerName')
            ->orderBy('s.SaleID', 'desc')
            ->get();
        
        // Get items for each sale
        foreach ($sales as $sale) {
            $sale->items = DB::table('SaleDetails as sd')
                ->join('Products as p', 'sd.ProductID', '=', 'p.ProductID')
                ->where('sd.SaleID', $sale->SaleID)
                ->select('sd.*', 'p.ProductName', 'p.Barcode')
                ->get();
        }
        
        return response()->json([
            'success' => true,
            'data' => $sales,
            'count' => $sales->count()
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

Route::post('/sales', function (Request $request) {
    try {
        $data = $request->validate([
            'CustomerID' => 'nullable|integer',
            'PaymentMethod' => 'required|string',
            'Discount' => 'nullable|numeric',
            'Tax' => 'nullable|numeric',
            'items' => 'required|array|min:1',
            'items.*.ProductID' => 'required|integer',
            'items.*.Quantity' => 'required|numeric|min:0.01',
            'items.*.UnitPrice' => 'required|numeric|min:0'
        ]);
        
        DB::beginTransaction();
        
        // Calculate totals
        $totalAmount = 0;
        foreach ($data['items'] as $item) {
            $totalAmount += $item['Quantity'] * $item['UnitPrice'];
        }
        
        $discount = $data['Discount'] ?? 0;
        $tax = $data['Tax'] ?? 0;
        $finalAmount = $totalAmount - $discount + $tax;
        
        // Generate invoice number
        $count = DB::table('Sales')->count();
        $invoiceNumber = 'INV-' . date('Ymd') . '-' . str_pad($count + 1, 4, '0', STR_PAD_LEFT);
        
        // Create sale
        $saleId = DB::table('Sales')->insertGetId([
            'InvoiceNumber' => $invoiceNumber,
            'CustomerID' => $data['CustomerID'] ?? null,
            'SaleDate' => now(),
            'TotalAmount' => $totalAmount,
            'Discount' => $discount,
            'Tax' => $tax,
            'FinalAmount' => $finalAmount,
            'PaymentMethod' => $data['PaymentMethod'],
            'Status' => 'مكتملة'
        ]);
        
        // Add sale details
        foreach ($data['items'] as $item) {
            $totalPrice = $item['Quantity'] * $item['UnitPrice'];
            
            DB::table('SaleDetails')->insert([
                'SaleID' => $saleId,
                'ProductID' => $item['ProductID'],
                'Quantity' => $item['Quantity'],
                'UnitPrice' => $item['UnitPrice'],
                'TotalPrice' => $totalPrice
            ]);
            
            // Update stock
            DB::table('Products')
                ->where('ProductID', $item['ProductID'])
                ->decrement('Stock', $item['Quantity']);
        }
        
        // Update customer balance
        if ($data['CustomerID']) {
            DB::table('Customers')
                ->where('CustomerID', $data['CustomerID'])
                ->increment('Balance', $finalAmount);
        }
        
        DB::commit();
        
        return response()->json([
            'success' => true,
            'message' => 'تم إضافة الفاتورة بنجاح',
            'data' => [
                'SaleID' => $saleId,
                'InvoiceNumber' => $invoiceNumber,
                'FinalAmount' => $finalAmount
            ]
        ], 201);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

// Dashboard stats
Route::get('/dashboard/stats', function () {
    try {
        $stats = [
            'totalCustomers' => DB::table('Customers')->where('IsActive', 1)->count(),
            'totalProducts' => DB::table('Products')->where('IsActive', 1)->count(),
            'totalSales' => DB::table('Sales')->count(),
            'todaySales' => DB::table('Sales')
                ->whereDate('SaleDate', today())
                ->sum('FinalAmount'),
            'lowStockProducts' => DB::table('Products')
                ->whereColumn('Stock', '<=', 'MinimumStock')
                ->count()
        ];
        
        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

// Categories
Route::get('/categories', function () {
    try {
        $categories = DB::table('Categories')->get();
        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});

// Units
Route::get('/units', function () {
    try {
        $units = DB::table('Units')->get();
        return response()->json([
            'success' => true,
            'data' => $units
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
});
