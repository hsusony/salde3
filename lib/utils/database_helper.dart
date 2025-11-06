/// Stub file - SQLite removed, migrating to SQL Server 2008
/// هذا ملف مؤقت - تم إزالة SQLite، جاري الانتقال إلى SQL Server 2008

import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  // TODO: استبدال كل الدوال بـ API calls إلى SQL Server

  Future<Map<String, dynamic>> get database async {
    return {'path': ''}; // Return a map with path property for compatibility
  }

  String get path => '';

  Future<void> close() async {}

  // Basic CRUD operations
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List? whereArgs, String? orderBy}) async {
    print('⚠️ DatabaseHelper.query: SQLite removed - returning empty list');
    return [];
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    print('⚠️ DatabaseHelper.insert: SQLite removed - returning 0');
    return 0;
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {String? where, List? whereArgs}) async {
    print('⚠️ DatabaseHelper.update: SQLite removed - returning 0');
    return 0;
  }

  Future<int> delete(String table, {String? where, List? whereArgs}) async {
    print('⚠️ DatabaseHelper.delete: SQLite removed - returning 0');
    return 0;
  }

  Future<List<Map<String, dynamic>>> rawQuery(String query,
      [List? args]) async {
    print('⚠️ DatabaseHelper.rawQuery: SQLite removed - returning empty list');
    return [];
  }

  Future<int> rawInsert(String query, [List? args]) async {
    print('⚠️ DatabaseHelper.rawInsert: SQLite removed - returning 0');
    return 0;
  }

  Future<int> rawUpdate(String query, [List? args]) async {
    print('⚠️ DatabaseHelper.rawUpdate: SQLite removed - returning 0');
    return 0;
  }

  Future<int> rawDelete(String query, [List? args]) async {
    print('⚠️ DatabaseHelper.rawDelete: SQLite removed - returning 0');
    return 0;
  }

  // Products
  Future<int> insertProduct(dynamic product) async => 0;
  Future<List<Product>> getAllProducts() async => [];
  Future<Product?> getProductById(int id) async => null;
  Future<Product?> getProductByBarcode(String barcode) async => null;
  Future<int> updateProduct(dynamic product) async => 0;
  Future<int> deleteProduct(int id, {String userName = ''}) async => 0;
  Future<List<Product>> searchProducts(String query) async => [];
  Future<List<Product>> getLowStockProducts() async => [];

  // Customers
  Future<int> insertCustomer(dynamic customer) async => 0;
  Future<List<Customer>> getAllCustomers() async => [];
  Future<Customer?> getCustomerById(int id) async => null;
  Future<int> updateCustomer(dynamic customer) async => 0;
  Future<int> deleteCustomer(int id) async => 0;
  Future<List<Customer>> searchCustomers(String query) async => [];

  // Sales
  Future<int> insertSale(dynamic sale) async => 0;
  Future<List<Sale>> getAllSales() async => [];
  Future<Sale?> getSaleById(int id) async => null;
  Future<List<dynamic>> getSaleItems(int saleId) async => [];
  Future<String> generateInvoiceNumber() async => 'INV-001';

  // Cash Vouchers
  Future<List<dynamic>> getAllReceiptVouchers() async => [];
  Future<List<dynamic>> getAllMultipleReceiptVouchers() async => [];
  Future<List<dynamic>> getAllDualCurrencyReceipts() async => [];
  Future<int> insertReceiptVoucher(dynamic voucher) async => 0;
  Future<int> updateReceiptVoucher(dynamic voucher) async => 0;
  Future<int> deleteReceiptVoucher(String id) async => 0;

  // Quotations
  Future<List<dynamic>> getAllQuotations() async => [];
  Future<int> insertQuotation(Map<String, dynamic> quotation,
          List<Map<String, dynamic>> items) async =>
      0;
  Future<int> updateQuotation(int id, Map<String, dynamic> quotation,
          List<Map<String, dynamic>> items) async =>
      0;
  Future<int> deleteQuotation(int id) async => 0;
  Future<int> updateQuotationStatus(int id, String status) async => 0;
  Future<String> generateQuotationNumber() async => 'QT-000001';

  // Pending Orders
  Future<List<dynamic>> getAllPendingOrders() async => [];
  Future<int> insertPendingOrder(
          Map<String, dynamic> order, List<Map<String, dynamic>> items) async =>
      0;
  Future<int> updatePendingOrder(int id, Map<String, dynamic> order,
          List<Map<String, dynamic>> items) async =>
      0;
  Future<int> deletePendingOrder(int id) async => 0;
  Future<int> updatePendingOrderStatus(int id, String status) async => 0;
  Future<String> generatePendingOrderNumber() async => 'PO-000001';

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async => {
        'todaySales': 0.0,
        'monthSales': 0.0,
        'productsCount': 0,
        'customersCount': 0,
        'lowStockCount': 0,
        'totalBalance': 0.0,
      };

  // Installments
  Future<int> insertInstallment(dynamic installment,
          [List<dynamic>? payments]) async =>
      0;
  Future<List<dynamic>> getAllInstallments() async => [];
  Future<dynamic> getInstallmentById(int id) async => null;
  Future<List<dynamic>> getInstallmentsByCustomerId(int customerId) async => [];
  Future<List<dynamic>> getInstallmentsByStatus(String status) async => [];
  Future<int> updateInstallment(dynamic installmentOrId,
          [Map<String, dynamic>? data]) async =>
      0;
  Future<int> deleteInstallment(int id) async => 0;
  Future<int> insertInstallmentPayment(dynamic payment) async => 0;
  Future<List<dynamic>> getInstallmentPayments(int installmentId) async => [];
  Future<List<dynamic>> getAllInstallmentPayments() async => [];
  Future<int> deleteInstallmentPayment(int id) async => 0;
  Future<Map<String, dynamic>> getInstallmentStats() async => {
        'totalInstallments': 0,
        'activeInstallments': 0,
        'totalAmount': 0.0,
        'paidAmount': 0.0,
        'remainingAmount': 0.0,
      };

  // Logs and Reports
  Future<List<dynamic>> getDeletedProductsLog(
          {DateTime? fromDate, DateTime? toDate}) async =>
      [];
  Future<List<dynamic>> getDeletedMaterialsReport(
          {DateTime? fromDate, DateTime? toDate}) async =>
      [];
}
