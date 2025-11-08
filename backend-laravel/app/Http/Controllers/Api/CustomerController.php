<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CustomerController extends Controller
{
    /**
     * عرض جميع العملاء
     */
    public function index()
    {
        try {
            $customers = Customer::where('IsActive', 1)
                ->orderBy('CustomerID', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $customers
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في جلب البيانات: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * عرض عميل محدد
     */
    public function show($id)
    {
        try {
            $customer = Customer::with(['sales', 'installments'])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $customer
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'العميل غير موجود'
            ], 404);
        }
    }

    /**
     * إضافة عميل جديد
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'CustomerName' => 'required|string|max:100',
            'Phone' => 'nullable|string|max:20',
            'Address' => 'nullable|string|max:255',
            'Email' => 'nullable|email|max:100',
            'TaxNumber' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $customer = Customer::create([
                'CustomerName' => $request->CustomerName,
                'Phone' => $request->Phone,
                'Address' => $request->Address,
                'Email' => $request->Email,
                'TaxNumber' => $request->TaxNumber,
                'Notes' => $request->Notes,
                'Balance' => 0,
                'IsActive' => 1,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إضافة العميل بنجاح',
                'data' => $customer
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في إضافة العميل: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * تحديث بيانات عميل
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'CustomerName' => 'required|string|max:100',
            'Phone' => 'nullable|string|max:20',
            'Address' => 'nullable|string|max:255',
            'Email' => 'nullable|email|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $customer = Customer::findOrFail($id);
            $customer->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث بيانات العميل بنجاح',
                'data' => $customer
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في التحديث: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * حذف عميل (Soft Delete)
     */
    public function destroy($id)
    {
        try {
            $customer = Customer::findOrFail($id);
            $customer->update(['IsActive' => 0]);

            return response()->json([
                'success' => true,
                'message' => 'تم حذف العميل بنجاح'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في الحذف: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * البحث عن عملاء
     */
    public function search(Request $request)
    {
        $query = Customer::where('IsActive', 1);

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('CustomerName', 'like', "%{$search}%")
                  ->orWhere('Phone', 'like', "%{$search}%")
                  ->orWhere('Email', 'like', "%{$search}%");
            });
        }

        $customers = $query->orderBy('CustomerID', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $customers
        ], 200);
    }
}
