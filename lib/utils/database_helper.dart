import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize SQLite for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    _database = await _initDB('sales_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await _getDbPath();
    final path = join(dbPath, filePath);
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4, // زيادة رقم النسخة لإضافة جداول الأقساط
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future<String> _getDbPath() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final appDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory(join(appDir.path, 'SalesManagementSystem'));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      return dbDir.path;
    }
    return await getDatabasesPath();
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة العمود additional_barcodes إذا لم يكن موجوداً
      try {
        await db.execute(
            'ALTER TABLE products ADD COLUMN additional_barcodes TEXT');
        print('✅ تم إضافة عمود additional_barcodes بنجاح');
      } catch (e) {
        // العمود موجود بالفعل
        print('⚠️ عمود additional_barcodes موجود بالفعل: $e');
      }
    }

    if (oldVersion < 3) {
      // إضافة العمود carton_quantity إذا لم يكن موجوداً
      try {
        await db
            .execute('ALTER TABLE products ADD COLUMN carton_quantity INTEGER');
        print('✅ تم إضافة عمود carton_quantity بنجاح');
      } catch (e) {
        // العمود موجود بالفعل
        print('⚠️ عمود carton_quantity موجود بالفعل: $e');
      }
    }

    if (oldVersion < 4) {
      // إضافة جداول الأقساط
      try {
        await db.execute('''
          CREATE TABLE installments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            customer_name TEXT NOT NULL,
            total_amount REAL NOT NULL,
            paid_amount REAL DEFAULT 0,
            remaining_amount REAL NOT NULL,
            number_of_installments INTEGER NOT NULL,
            paid_installments INTEGER DEFAULT 0,
            installment_amount REAL NOT NULL,
            start_date TEXT NOT NULL,
            notes TEXT,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE installment_payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            installment_id INTEGER NOT NULL,
            customer_name TEXT NOT NULL,
            amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            installment_number INTEGER NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (installment_id) REFERENCES installments (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
            'CREATE INDEX idx_installments_customer ON installments(customer_id)');
        await db.execute(
            'CREATE INDEX idx_installments_status ON installments(status)');
        await db.execute(
            'CREATE INDEX idx_installment_payments_installment ON installment_payments(installment_id)');

        print('✅ تم إضافة جداول الأقساط بنجاح');
      } catch (e) {
        print('⚠️ خطأ في إضافة جداول الأقساط: $e');
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Products Table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT UNIQUE NOT NULL,
        additional_barcodes TEXT,
        category TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        min_quantity INTEGER DEFAULT 5,
        carton_quantity INTEGER,
        description TEXT,
        image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        company TEXT,
        balance REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Sales Table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT UNIQUE NOT NULL,
        customer_id INTEGER,
        customer_name TEXT,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        final_amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        remaining_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Sale Items Table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        discount REAL DEFAULT 0,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Installments Table
    await db.execute('''
      CREATE TABLE installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0,
        remaining_amount REAL NOT NULL,
        number_of_installments INTEGER NOT NULL,
        paid_installments INTEGER DEFAULT 0,
        installment_amount REAL NOT NULL,
        start_date TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Installment Payments Table
    await db.execute('''
      CREATE TABLE installment_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        installment_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        installment_number INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (installment_id) REFERENCES installments (id) ON DELETE CASCADE
      )
    ''');

    // Create Indexes
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db
        .execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_customers_phone ON customers(phone)');
    await db.execute('CREATE INDEX idx_sales_invoice ON sales(invoice_number)');
    await db.execute('CREATE INDEX idx_sales_date ON sales(created_at)');
    await db.execute(
        'CREATE INDEX idx_installments_customer ON installments(customer_id)');
    await db.execute(
        'CREATE INDEX idx_installments_status ON installments(status)');
    await db.execute(
        'CREATE INDEX idx_installment_payments_installment ON installment_payments(installment_id)');
  }

  // ==================== PRODUCTS ====================
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final result =
        await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return Product.fromMap(result.first);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final result = await db.query('products',
        where: 'barcode = ?', whereArgs: [barcode], limit: 1);
    if (result.isEmpty) return null;
    return Product.fromMap(result.first);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id, {String userName = 'المستخدم'}) async {
    final db = await database;

    // جلب بيانات المنتج قبل الحذف
    final product = await getProductById(id);
    if (product == null) return 0;

    // تسجيل عملية الحذف في سجل التدقيق
    try {
      await db.insert('audit_log', {
        'operation_type': 'حذف',
        'table_name': 'products',
        'record_id': id,
        'record_name': product.name,
        'record_data':
            'باركود: ${product.barcode}, السعر: ${product.sellingPrice}',
        'user_name': userName,
        'operation_date': DateTime.now().toIso8601String(),
        'notes': 'تم حذف المنتج: ${product.name}',
        'synced': 0,
      });
    } catch (e) {
      print('Error logging deletion: $e');
    }

    // حذف المنتج
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT * FROM products WHERE quantity <= min_quantity');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // ==================== CUSTOMERS ====================
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final result =
        await db.query('customers', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final result = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  // ==================== SALES ====================
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final saleId = await db.insert('sales', sale.toMap());

    // Insert sale items
    for (var item in sale.items) {
      await db.insert('sale_items', item.copyWith(saleId: saleId).toMap());

      // Update product quantity
      await db.rawUpdate(
        'UPDATE products SET quantity = quantity - ? WHERE id = ?',
        [item.quantity, item.productId],
      );
    }

    // Update customer balance if exists
    if (sale.customerId != null && sale.remainingAmount > 0) {
      await db.rawUpdate(
        'UPDATE customers SET balance = balance + ? WHERE id = ?',
        [sale.remainingAmount, sale.customerId],
      );
    }

    return saleId;
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final result = await db.query('sales', orderBy: 'created_at DESC');
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await database;
    final result =
        await db.query('sales', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;

    final sale = Sale.fromMap(result.first);
    final items = await getSaleItems(id);
    return Sale(
      id: sale.id,
      invoiceNumber: sale.invoiceNumber,
      customerId: sale.customerId,
      customerName: sale.customerName,
      totalAmount: sale.totalAmount,
      discount: sale.discount,
      tax: sale.tax,
      finalAmount: sale.finalAmount,
      paidAmount: sale.paidAmount,
      remainingAmount: sale.remainingAmount,
      paymentMethod: sale.paymentMethod,
      status: sale.status,
      notes: sale.notes,
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
      items: items,
    );
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await database;
    final result =
        await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
    return result.map((json) => SaleItem.fromMap(json)).toList();
  }

  Future<String> generateInvoiceNumber() async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX(id) as max_id FROM sales');
    final maxId = result.first['max_id'] as int? ?? 0;
    final now = DateTime.now();
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(maxId + 1).toString().padLeft(4, '0')}';
  }

  // ==================== STATISTICS ====================
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    // Total Sales Today
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final todaySales = await db.rawQuery(
      'SELECT SUM(final_amount) as total, SUM(final_amount - total_amount) as profit FROM sales WHERE created_at >= ? AND status = "completed"',
      [startOfDay],
    );

    // Total Sales This Month
    final startOfMonth = DateTime(today.year, today.month, 1).toIso8601String();
    final monthSales = await db.rawQuery(
      'SELECT SUM(final_amount) as total, SUM(final_amount - total_amount) as profit FROM sales WHERE created_at >= ? AND status = "completed"',
      [startOfMonth],
    );

    // Sales Chart - Last 7 Days
    List<Map<String, dynamic>> salesChart = [];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day).toIso8601String();
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();
      
      final daySales = await db.rawQuery(
        'SELECT SUM(final_amount) as total FROM sales WHERE created_at >= ? AND created_at <= ? AND status = "completed"',
        [dayStart, dayEnd],
      );
      
      salesChart.add({
        'date': day,
        'total': (daySales.first['total'] as num?)?.toDouble() ?? 0.0,
      });
    }

    // Total Products
    final productsCount =
        await db.rawQuery('SELECT COUNT(*) as count FROM products');

    // Total Customers
    final customersCount =
        await db.rawQuery('SELECT COUNT(*) as count FROM customers');

    // Low Stock Products
    final lowStock = await db.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE quantity <= min_quantity');

    // Total Balance (Outstanding)
    final totalBalance =
        await db.rawQuery('SELECT SUM(balance) as total FROM customers');

    return {
      'todaySales': (todaySales.first['total'] as num?)?.toDouble() ?? 0.0,
      'monthSales': (monthSales.first['total'] as num?)?.toDouble() ?? 0.0,
      'todayProfit': (todaySales.first['profit'] as num?)?.toDouble() ?? 0.0,
      'monthProfit': (monthSales.first['profit'] as num?)?.toDouble() ?? 0.0,
      'salesChart': salesChart,
      'productsCount': productsCount.first['count'] ?? 0,
      'customersCount': customersCount.first['count'] ?? 0,
      'lowStockCount': lowStock.first['count'] ?? 0,
      'totalBalance': (totalBalance.first['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // ==================== INSTALLMENTS ====================
  Future<int> insertInstallment(Map<String, dynamic> installment) async {
    final db = await database;
    return await db.insert('installments', installment);
  }

  Future<List<Map<String, dynamic>>> getAllInstallments() async {
    final db = await database;
    return await db.query('installments', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getInstallmentById(int id) async {
    final db = await database;
    final result = await db.query('installments',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getInstallmentsByCustomerId(
      int customerId) async {
    final db = await database;
    return await db.query('installments',
        where: 'customer_id = ?', whereArgs: [customerId]);
  }

  Future<List<Map<String, dynamic>>> getInstallmentsByStatus(
      String status) async {
    final db = await database;
    return await db
        .query('installments', where: 'status = ?', whereArgs: [status]);
  }

  Future<int> updateInstallment(
      int id, Map<String, dynamic> installment) async {
    final db = await database;
    return await db
        .update('installments', installment, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteInstallment(int id) async {
    final db = await database;
    return await db.delete('installments', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== INSTALLMENT PAYMENTS ====================
  Future<int> insertInstallmentPayment(Map<String, dynamic> payment) async {
    final db = await database;
    final paymentId = await db.insert('installment_payments', payment);

    // Update installment after payment
    final installmentId = payment['installment_id'] as int;
    final amount = payment['amount'] as double;

    final installment = await getInstallmentById(installmentId);
    if (installment != null) {
      final paidAmount = (installment['paid_amount'] as double) + amount;
      final remainingAmount =
          (installment['total_amount'] as double) - paidAmount;
      final paidInstallments = (installment['paid_installments'] as int) + 1;
      final status = remainingAmount <= 0 ? 'completed' : 'active';

      await updateInstallment(installmentId, {
        'paid_amount': paidAmount,
        'remaining_amount': remainingAmount,
        'paid_installments': paidInstallments,
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return paymentId;
  }

  Future<List<Map<String, dynamic>>> getInstallmentPayments(
      int installmentId) async {
    final db = await database;
    return await db.query('installment_payments',
        where: 'installment_id = ?',
        whereArgs: [installmentId],
        orderBy: 'payment_date DESC');
  }

  Future<List<Map<String, dynamic>>> getAllInstallmentPayments() async {
    final db = await database;
    return await db.query('installment_payments', orderBy: 'payment_date DESC');
  }

  Future<int> deleteInstallmentPayment(int id) async {
    final db = await database;
    return await db
        .delete('installment_payments', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== INSTALLMENT STATISTICS ====================
  Future<Map<String, dynamic>> getInstallmentStats() async {
    final db = await database;

    // Total Active Installments Amount
    final activeTotal = await db.rawQuery(
        'SELECT SUM(remaining_amount) as total FROM installments WHERE status = "active"');

    // Total Overdue Installments Amount
    final overdueTotal = await db.rawQuery(
        'SELECT SUM(remaining_amount) as total FROM installments WHERE status = "overdue"');

    // Active Installments Count
    final activeCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM installments WHERE status = "active"');

    // Overdue Installments Count
    final overdueCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM installments WHERE status = "overdue"');

    // Total Paid This Month
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1).toIso8601String();
    final monthPayments = await db.rawQuery(
      'SELECT SUM(amount) as total FROM installment_payments WHERE payment_date >= ?',
      [startOfMonth],
    );

    return {
      'activeTotalAmount':
          (activeTotal.first['total'] as num?)?.toDouble() ?? 0.0,
      'overdueTotalAmount':
          (overdueTotal.first['total'] as num?)?.toDouble() ?? 0.0,
      'activeCount': activeCount.first['count'] ?? 0,
      'overdueCount': overdueCount.first['count'] ?? 0,
      'monthPayments':
          (monthPayments.first['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

extension SaleItemCopyWith on SaleItem {
  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    String? productBarcode,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? discount,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBarcode: productBarcode ?? this.productBarcode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
    );
  }
}
