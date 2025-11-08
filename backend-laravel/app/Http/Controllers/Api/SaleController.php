<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use App\Models\SaleDetail;
use App\Models\Product;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SaleController extends Controller
{
    /**
     * عرض جميع الفواتير
     */
    public function index()
    {
        try {
            $sales = Sale::with(['customer', 'details.product'])
                ->orderBy('SaleID', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $sales
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في جلب البيانات: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * عرض فاتورة محددة
     */
    public function show($id)
    {
        try {
            $sale = Sale::with(['customer', 'details.product', 'installments'])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $sale
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'الفاتورة غير موجودة'
            ], 404);
        }
    }

    /**
     * إضافة فاتورة جديدة
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'CustomerID' => 'required|exists:Customers,CustomerID',
            'PaymentMethod' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.ProductID' => 'required|exists:Products,ProductID',
            'items.*.Quantity' => 'required|numeric|min:0.01',
            'items.*.UnitPrice' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();
        
        try {
            // حساب المجاميع
            $totalAmount = 0;
            foreach ($request->items as $item) {
                $totalAmount += $item['Quantity'] * $item['UnitPrice'];
            }

            $discount = $request->Discount ?? 0;
            $tax = $request->Tax ?? 0;
            $finalAmount = $totalAmount - $discount + $tax;

            // إنشاء رقم الفاتورة
            $invoiceNumber = 'INV-' . date('Ymd') . '-' . str_pad(Sale::count() + 1, 4, '0', STR_PAD_LEFT);

            // إنشاء الفاتورة
            $sale = Sale::create([
                'InvoiceNumber' => $invoiceNumber,
                'CustomerID' => $request->CustomerID,
                'SaleDate' => now(),
                'TotalAmount' => $totalAmount,
                'Discount' => $discount,
                'Tax' => $tax,
                'FinalAmount' => $finalAmount,
                'PaymentMethod' => $request->PaymentMethod,
                'Status' => 'مكتملة',
                'Notes' => $request->Notes,
            ]);

            // إضافة تفاصيل الفاتورة
            foreach ($request->items as $item) {
                $totalPrice = $item['Quantity'] * $item['UnitPrice'];
                
                SaleDetail::create([
                    'SaleID' => $sale->SaleID,
                    'ProductID' => $item['ProductID'],
                    'Quantity' => $item['Quantity'],
                    'UnitPrice' => $item['UnitPrice'],
                    'TotalPrice' => $totalPrice,
                ]);

                // تحديث المخزون
                $product = Product::find($item['ProductID']);
                $product->Stock -= $item['Quantity'];
                $product->save();
            }

            // تحديث رصيد العميل
            $customer = Customer::find($request->CustomerID);
            $customer->Balance += $finalAmount;
            $customer->save();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'تم إضافة الفاتورة بنجاح',
                'data' => $sale->load(['customer', 'details.product'])
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'خطأ في إضافة الفاتورة: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * حذف فاتورة
     */
    public function destroy($id)
    {
        DB::beginTransaction();
        
        try {
            $sale = Sale::with('details')->findOrFail($id);

            // إرجاع المخزون
            foreach ($sale->details as $detail) {
                $product = Product::find($detail->ProductID);
                $product->Stock += $detail->Quantity;
                $product->save();
            }

            // تحديث رصيد العميل
            $customer = Customer::find($sale->CustomerID);
            $customer->Balance -= $sale->FinalAmount;
            $customer->save();

            // حذف التفاصيل والفاتورة
            $sale->details()->delete();
            $sale->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الفاتورة بنجاح'
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'خطأ في الحذف: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * تقرير المبيعات اليومية
     */
    public function dailyReport(Request $request)
    {
        try {
            $date = $request->date ?? now()->format('Y-m-d');
            
            $sales = Sale::with(['customer', 'details'])
                ->whereDate('SaleDate', $date)
                ->get();

            $totalSales = $sales->sum('FinalAmount');
            $totalDiscount = $sales->sum('Discount');
            $totalTax = $sales->sum('Tax');

            return response()->json([
                'success' => true,
                'data' => [
                    'sales' => $sales,
                    'summary' => [
                        'totalSales' => $totalSales,
                        'totalDiscount' => $totalDiscount,
                        'totalTax' => $totalTax,
                        'count' => $sales->count()
                    ]
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في جلب التقرير: ' . $e->getMessage()
            ], 500);
        }
    }
}
