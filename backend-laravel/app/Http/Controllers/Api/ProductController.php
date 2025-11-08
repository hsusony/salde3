<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * عرض جميع المنتجات
     */
    public function index()
    {
        try {
            $products = Product::with(['category', 'unit'])
                ->where('IsActive', 1)
                ->orderBy('ProductID', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $products
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في جلب البيانات: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * عرض منتج محدد
     */
    public function show($id)
    {
        try {
            $product = Product::with(['category', 'unit'])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $product
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'المنتج غير موجود'
            ], 404);
        }
    }

    /**
     * إضافة منتج جديد
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ProductName' => 'required|string|max:100',
            'Barcode' => 'nullable|string|max:50',
            'CategoryID' => 'required|exists:Categories,CategoryID',
            'UnitID' => 'required|exists:Units,UnitID',
            'PurchasePrice' => 'required|numeric|min:0',
            'SalePrice' => 'required|numeric|min:0',
            'Stock' => 'required|numeric|min:0',
            'MinimumStock' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $product = Product::create([
                'ProductName' => $request->ProductName,
                'Barcode' => $request->Barcode,
                'CategoryID' => $request->CategoryID,
                'UnitID' => $request->UnitID,
                'PurchasePrice' => $request->PurchasePrice,
                'SalePrice' => $request->SalePrice,
                'Stock' => $request->Stock,
                'MinimumStock' => $request->MinimumStock ?? 0,
                'ExpiryDate' => $request->ExpiryDate,
                'Notes' => $request->Notes,
                'IsActive' => 1,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إضافة المنتج بنجاح',
                'data' => $product
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في إضافة المنتج: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * تحديث بيانات منتج
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'ProductName' => 'required|string|max:100',
            'PurchasePrice' => 'required|numeric|min:0',
            'SalePrice' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $product = Product::findOrFail($id);
            $product->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث بيانات المنتج بنجاح',
                'data' => $product
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في التحديث: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * حذف منتج
     */
    public function destroy($id)
    {
        try {
            $product = Product::findOrFail($id);
            $product->update(['IsActive' => 0]);

            return response()->json([
                'success' => true,
                'message' => 'تم حذف المنتج بنجاح'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في الحذف: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * البحث عن منتجات
     */
    public function search(Request $request)
    {
        $query = Product::with(['category', 'unit'])->where('IsActive', 1);

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('ProductName', 'like', "%{$search}%")
                  ->orWhere('Barcode', 'like', "%{$search}%");
            });
        }

        $products = $query->orderBy('ProductID', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $products
        ], 200);
    }

    /**
     * المنتجات التي وصلت للحد الأدنى
     */
    public function lowStock()
    {
        try {
            $products = Product::whereColumn('Stock', '<=', 'MinimumStock')
                ->where('IsActive', 1)
                ->with(['category', 'unit'])
                ->get();

            return response()->json([
                'success' => true,
                'data' => $products
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في جلب البيانات: ' . $e->getMessage()
            ], 500);
        }
    }
}
