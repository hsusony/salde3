/// SQL Server 2008 Integration via REST API
/// الاتصال بـ SQL Server 2008 عبر REST API

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/purchase.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // API Base URL - يمكن تغييرها حسب الحاجة
  static const String baseUrl = 'http://localhost/backend-php/api';

  DatabaseHelper._internal();

  // ============ Product Functions ============

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ تم تحميل ${data.length} منتج من قاعدة البيانات');
        return data.map((item) => Product.fromMap(_convertKeys(item))).toList();
      }
      print('⚠️ فشل تحميل المنتجات: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ خطأ في تحميل المنتجات: $e');
      return [];
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromMap(_convertKeys(json.decode(response.body)));
      }
      return null;
    } catch (e) {
      print('❌ Error fetching product: $e');
      return null;
    }
  }

  Future<int> insertProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(product.toMap()),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ تمت إضافة المنتج بنجاح');
        return data['id'] ?? 0;
      }
      print('⚠️ فشل إضافة المنتج: ${response.statusCode}');
      return 0;
    } catch (e) {
      print('❌ خطأ في إضافة المنتج: $e');
      return 0;
    }
  }

  Future<int> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(product.toMap()),
      );
      if (response.statusCode == 200) {
        print('✅ تم تحديث المنتج بنجاح');
        return 1;
      }
      print('⚠️ فشل تحديث المنتج: ${response.statusCode}');
      return 0;
    } catch (e) {
      print('❌ خطأ في تحديث المنتج: $e');
      return 0;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        print('✅ تم حذف المنتج بنجاح');
        return 1;
      }
      return 0;
    } catch (e) {
      print('❌ Error deleting product: $e');
      return 0;
    }
  }

  // ============ Customer Functions ============

  Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ تم تحميل ${data.length} عميل من قاعدة البيانات');
        return data
            .map((item) => Customer.fromMap(_convertKeys(item)))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching customers: $e');
      return [];
    }
  }

  Future<Customer?> getCustomer(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers/$id'));
      if (response.statusCode == 200) {
        return Customer.fromMap(_convertKeys(json.decode(response.body)));
      }
      return null;
    } catch (e) {
      print('❌ Error fetching customer: $e');
      return null;
    }
  }

  Future<int> insertCustomer(Customer customer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(customer.toMap()),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ تمت إضافة العميل بنجاح');
        return data['id'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error inserting customer: $e');
      return 0;
    }
  }

  Future<int> updateCustomer(Customer customer) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customers/${customer.id}'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(customer.toMap()),
      );
      if (response.statusCode == 200) {
        print('✅ تم تحديث العميل بنجاح');
        return 1;
      }
      return 0;
    } catch (e) {
      print('❌ Error updating customer: $e');
      return 0;
    }
  }

  Future<int> deleteCustomer(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/customers/$id'));
      if (response.statusCode == 200) {
        print('✅ تم حذف العميل بنجاح');
        return 1;
      }
      return 0;
    } catch (e) {
      print('❌ Error deleting customer: $e');
      return 0;
    }
  }

  // ============ Sale Functions ============

  Future<List<Sale>> getAllSales() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sales'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Sale.fromMap(_convertKeys(item))).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching sales: $e');
      return [];
    }
  }

  Future<int> insertSale(Sale sale) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(sale.toMap()),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ تمت إضافة البيع بنجاح');
        return data['id'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error inserting sale: $e');
      return 0;
    }
  }

  Future<int> deleteSale(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/sales/$id'));
      if (response.statusCode == 200) {
        print('✅ تم حذف البيع بنجاح');
        return 1;
      }
      return 0;
    } catch (e) {
      print('❌ Error deleting sale: $e');
      return 0;
    }
  }

  // ============ Helper Functions ============

  /// تحويل مفاتيح SQL Server (PascalCase) إلى Dart (camelCase)
  Map<String, dynamic> _convertKeys(Map<String, dynamic> map) {
    final converted = <String, dynamic>{};
    map.forEach((key, value) {
      // Convert first letter to lowercase
      final dartKey = key[0].toLowerCase() + key.substring(1);
      converted[dartKey] = value;
    });
    return converted;
  }

  // ============ Stub Functions (للتوافق مع الكود القديم) ============

  Future<Map<String, dynamic>> get database async => {'path': ''};
  String get path => '';
  Future<void> close() async {}

  Future<List<Map<String, dynamic>>> query(String table,
          {String? where, List? whereArgs, String? orderBy}) async =>
      [];
  Future<int> insert(String table, Map<String, dynamic> data) async => 0;
  Future<int> update(String table, Map<String, dynamic> data,
          {String? where, List? whereArgs}) async =>
      0;
  Future<int> delete(String table, {String? where, List? whereArgs}) async => 0;
  Future<List<Map<String, dynamic>>> rawQuery(String query,
          [List? args]) async =>
      [];
  Future<int> rawInsert(String query, [List? args]) async => 0;
  Future<int> rawUpdate(String query, [List? args]) async => 0;
  Future<int> rawDelete(String query, [List? args]) async => 0;

  // Supplier stubs
  Future<List<Map<String, dynamic>>> getAllSuppliers() async => [];
  Future<Map<String, dynamic>?> getSupplier(int id) async => null;
  Future<int> insertSupplier(Map<String, dynamic> supplier) async => 0;
  Future<int> updateSupplier(Map<String, dynamic> supplier) async => 0;
  Future<int> deleteSupplier(int id) async => 0;

  // Category stubs
  Future<List<Map<String, dynamic>>> getAllCategories() async => [];
  Future<Map<String, dynamic>?> getCategory(int id) async => null;
  Future<int> insertCategory(Map<String, dynamic> category) async => 0;
  Future<int> updateCategory(Map<String, dynamic> category) async => 0;
  Future<int> deleteCategory(int id) async => 0;

  // Purchase stubs
  Future<List<Purchase>> getAllPurchases() async => [];
  Future<int> insertPurchase(Purchase purchase) async => 0;
  Future<int> deletePurchase(int id) async => 0;

  // Other stubs
  Future<List<Map<String, dynamic>>> getSalesWithCustomerNames() async => [];
  Future<List<Map<String, dynamic>>> getPurchasesWithSupplierNames() async =>
      [];
  Future<List<Map<String, dynamic>>> getCustomersWithBalance() async => [];
  Future<List<Map<String, dynamic>>> getSuppliersWithBalance() async => [];
  Future<Map<String, dynamic>> getDashboardStats() async => {
        'totalSales': 0.0,
        'totalPurchases': 0.0,
        'totalProfit': 0.0,
        'productCount': 0,
        'customerCount': 0,
        'lowStockCount': 0,
      };

  Future<List<Map<String, dynamic>>> getLowStockProducts() async => [];
  Future<double> getCustomerBalance(int customerId) async => 0.0;
  Future<double> getSupplierBalance(int supplierId) async => 0.0;
  Future<List<Map<String, dynamic>>> getCustomerStatement(int customerId,
          {DateTime? startDate, DateTime? endDate}) async =>
      [];
  Future<List<Map<String, dynamic>>> getSupplierStatement(int supplierId,
          {DateTime? startDate, DateTime? endDate}) async =>
      [];

  // Receipt Vouchers
  Future<List<Map<String, dynamic>>> getAllReceiptVouchers() async => [];
  Future<List<Map<String, dynamic>>> getAllMultipleReceiptVouchers() async =>
      [];
  Future<List<Map<String, dynamic>>> getAllDualCurrencyReceipts() async => [];
  Future<int> insertReceiptVoucher(dynamic voucher) async => 0;
  Future<int> updateReceiptVoucher(dynamic voucher) async => 0;
  Future<int> deleteReceiptVoucher(dynamic id) async => 0;
  Future<int> insertMultipleReceiptVoucher(dynamic voucher) async => 0;
  Future<int> updateMultipleReceiptVoucher(dynamic voucher) async => 0;
  Future<int> deleteMultipleReceiptVoucher(dynamic id) async => 0;
  Future<int> insertDualCurrencyReceipt(dynamic receipt) async => 0;
  Future<int> deleteDualCurrencyReceipt(dynamic id) async => 0;

  // Payment Vouchers
  Future<List<Map<String, dynamic>>> getAllPaymentVouchers() async => [];
  Future<List<Map<String, dynamic>>> getAllMultiplePaymentVouchers() async =>
      [];
  Future<int> insertPaymentVoucher(dynamic voucher) async => 0;
  Future<int> updatePaymentVoucher(dynamic voucher) async => 0;
  Future<int> deletePaymentVoucher(dynamic id) async => 0;
  Future<int> insertMultiplePaymentVoucher(dynamic voucher) async => 0;
  Future<int> updateMultiplePaymentVoucher(dynamic voucher) async => 0;
  Future<int> deleteMultiplePaymentVoucher(dynamic id) async => 0;

  // Quotations
  Future<List<Map<String, dynamic>>> getAllQuotations() async => [];
  Future<int> insertQuotation(dynamic quotation, [dynamic items]) async => 0;
  Future<int> updateQuotation(dynamic id,
          [dynamic quotation, dynamic items]) async =>
      0;
  Future<int> deleteQuotation(int id) async => 0;
  Future<int> updateQuotationStatus(int id, String status) async => 0;
  Future<String> generateQuotationNumber() async => 'QT-001';

  // Pending Orders
  Future<List<Map<String, dynamic>>> getAllPendingOrders() async => [];
  Future<int> insertPendingOrder(dynamic order, [dynamic items]) async => 0;
  Future<int> updatePendingOrder(dynamic id,
          [dynamic order, dynamic items]) async =>
      0;
  Future<int> deletePendingOrder(int id) async => 0;
  Future<int> updatePendingOrderStatus(int id, String status) async => 0;
  Future<String> generatePendingOrderNumber() async => 'PO-001';

  // Logs & Reports
  Future<List<Map<String, dynamic>>> getDeletedProductsLog(
          {DateTime? fromDate, DateTime? toDate}) async =>
      [];

  // Account Statement
  Future<List<Map<String, dynamic>>> getAccountStatement(
          {DateTime? startDate, DateTime? endDate}) async =>
      [];
  Future<Map<String, dynamic>> getAccountBalance() async => {'balance': 0.0};
}
