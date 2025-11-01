// Stub implementation for web platform
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  Future<dynamic> get database async => null;
  
  // Stub methods
  Future<int> insertProduct(dynamic product) async => 0;
  Future<List<dynamic>> getAllProducts() async => [];
  Future<dynamic> getProductById(int id) async => null;
  Future<dynamic> getProductByBarcode(String barcode) async => null;
  Future<int> updateProduct(dynamic product) async => 0;
  Future<int> deleteProduct(int id) async => 0;
  Future<List<dynamic>> searchProducts(String query) async => [];
  Future<List<dynamic>> getLowStockProducts() async => [];
  
  Future<int> insertCustomer(dynamic customer) async => 0;
  Future<List<dynamic>> getAllCustomers() async => [];
  Future<dynamic> getCustomerById(int id) async => null;
  Future<int> updateCustomer(dynamic customer) async => 0;
  Future<int> deleteCustomer(int id) async => 0;
  Future<List<dynamic>> searchCustomers(String query) async => [];
  
  Future<int> insertSale(dynamic sale) async => 0;
  Future<List<dynamic>> getAllSales() async => [];
  Future<dynamic> getSaleById(int id) async => null;
  Future<List<dynamic>> getSaleItems(int saleId) async => [];
  Future<String> generateInvoiceNumber() async => 'INV-WEB-001';
  
  Future<Map<String, dynamic>> getDashboardStats() async => {
    'todaySales': 0.0,
    'monthSales': 0.0,
    'productsCount': 0,
    'customersCount': 0,
    'lowStockCount': 0,
    'totalBalance': 0.0,
  };
  
  Future<void> close() async {}
}
