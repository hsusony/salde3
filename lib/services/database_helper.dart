import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/cash_voucher.dart';
import '../models/payment_voucher.dart';
import '../models/transfer_voucher.dart';
import '../models/journal_entry.dart';

/// خدمة قاعدة البيانات المحلية - SQLite
/// يعمل بدون اتصال بالإنترنت (Offline-First)
/// جاهز للمزامنة مع SQL Server عبر REST API
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  /// الحصول على قاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// تهيئة قاعدة البيانات
  Future<Database> _initDatabase() async {
    // Initialize FFI for Windows/Linux/MacOS
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final databasesPath = Directory.current.path;
    final path = join(databasesPath, 'sales_management.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  /// إنشاء جداول قاعدة البيانات
  Future<void> _createDatabase(Database db, int version) async {
    // جدول سندات القبض - Receipt Vouchers
    await db.execute('''
      CREATE TABLE receipt_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول سندات القبض المتعددة - Multiple Receipt Vouchers
    await db.execute('''
      CREATE TABLE multiple_receipt_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود سندات القبض المتعددة
    await db.execute('''
      CREATE TABLE receipt_items (
        id TEXT PRIMARY KEY,
        voucher_id TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (voucher_id) REFERENCES multiple_receipt_vouchers (id) ON DELETE CASCADE
      )
    ''');

    // جدول سندات القبض بالعملتين - Dual Currency Receipts
    await db.execute('''
      CREATE TABLE dual_currency_receipts (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        amount_iqd REAL NOT NULL,
        amount_usd REAL NOT NULL,
        exchange_rate REAL NOT NULL,
        payment_method TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول سندات الدفع - Payment Vouchers
    await db.execute('''
      CREATE TABLE payment_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        beneficiary_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول سندات الدفع المتعددة - Multiple Payment Vouchers
    await db.execute('''
      CREATE TABLE multiple_payment_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        beneficiary_name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود سندات الدفع المتعددة
    await db.execute('''
      CREATE TABLE payment_items (
        id TEXT PRIMARY KEY,
        voucher_id TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (voucher_id) REFERENCES multiple_payment_vouchers (id) ON DELETE CASCADE
      )
    ''');

    // جدول سندات الدفع بالعملتين - Dual Currency Payments
    await db.execute('''
      CREATE TABLE dual_currency_payments (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        beneficiary_name TEXT NOT NULL,
        amount_iqd REAL NOT NULL,
        amount_usd REAL NOT NULL,
        exchange_rate REAL NOT NULL,
        payment_method TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول سندات الصرف - Disbursement Vouchers
    await db.execute('''
      CREATE TABLE disbursement_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        beneficiary_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        category TEXT NOT NULL,
        purpose TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول مستندات التحويل - Transfer Documents
    await db.execute('''
      CREATE TABLE transfer_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        sender_account TEXT NOT NULL,
        sender_bank TEXT NOT NULL,
        receiver_name TEXT NOT NULL,
        receiver_account TEXT NOT NULL,
        receiver_bank TEXT NOT NULL,
        amount REAL NOT NULL,
        transfer_type TEXT NOT NULL,
        transfer_fee REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول الحوالات - Remittance Vouchers
    await db.execute('''
      CREATE TABLE remittance_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        receiver_name TEXT NOT NULL,
        amount REAL NOT NULL,
        commission REAL NOT NULL,
        destination TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول الصيرفة - Exchange Vouchers
    await db.execute('''
      CREATE TABLE exchange_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        amount_from REAL NOT NULL,
        currency_from TEXT NOT NULL,
        amount_to REAL NOT NULL,
        currency_to TEXT NOT NULL,
        exchange_rate REAL NOT NULL,
        commission REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول توزيع الأرباح - Profit Distribution Vouchers
    await db.execute('''
      CREATE TABLE profit_distribution_vouchers (
        id TEXT PRIMARY KEY,
        voucher_number TEXT NOT NULL,
        date TEXT NOT NULL,
        total_profit REAL NOT NULL,
        distribution_method TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود توزيع الأرباح
    await db.execute('''
      CREATE TABLE profit_distribution_items (
        id TEXT PRIMARY KEY,
        voucher_id TEXT NOT NULL,
        partner_name TEXT NOT NULL,
        share_percentage REAL NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (voucher_id) REFERENCES profit_distribution_vouchers (id) ON DELETE CASCADE
      )
    ''');

    // جدول القيود المحاسبية - Journal Entries
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        entry_number TEXT NOT NULL,
        date TEXT NOT NULL,
        debit_account TEXT NOT NULL,
        credit_account TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        reference TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول القيود المحاسبية المتعددة - Multiple Journal Entries
    await db.execute('''
      CREATE TABLE multiple_journal_entries (
        id TEXT PRIMARY KEY,
        entry_number TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        total_debit REAL NOT NULL,
        total_credit REAL NOT NULL,
        reference TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود القيود المحاسبية المتعددة
    await db.execute('''
      CREATE TABLE journal_entry_items (
        id TEXT PRIMARY KEY,
        entry_id TEXT NOT NULL,
        account_name TEXT NOT NULL,
        debit REAL DEFAULT 0,
        credit REAL DEFAULT 0,
        FOREIGN KEY (entry_id) REFERENCES multiple_journal_entries (id) ON DELETE CASCADE
      )
    ''');

    // جدول القيود المركبة - Compound Journal Entries
    await db.execute('''
      CREATE TABLE compound_journal_entries (
        id TEXT PRIMARY KEY,
        entry_number TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        total_amount REAL NOT NULL,
        reference TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود القيود المركبة
    await db.execute('''
      CREATE TABLE compound_entry_items (
        id TEXT PRIMARY KEY,
        entry_id TEXT NOT NULL,
        account_name TEXT NOT NULL,
        debit REAL DEFAULT 0,
        credit REAL DEFAULT 0,
        FOREIGN KEY (entry_id) REFERENCES compound_journal_entries (id) ON DELETE CASCADE
      )
    ''');

    // جدول طابور المزامنة - Sync Queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // ============ الجداول الأساسية ============
    
    // جدول المنتجات - Products
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        category TEXT,
        unit TEXT DEFAULT 'قطعة',
        purchase_price REAL NOT NULL DEFAULT 0.0,
        selling_price REAL NOT NULL DEFAULT 0.0,
        quantity REAL NOT NULL DEFAULT 0.0,
        min_quantity REAL DEFAULT 0.0,
        max_quantity REAL,
        carton_quantity INTEGER DEFAULT 1,
        expiry_date TEXT,
        supplier TEXT,
        notes TEXT,
        image_path TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول العملاء - Customers
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        city TEXT,
        country TEXT DEFAULT 'العراق',
        balance REAL DEFAULT 0.0,
        credit_limit REAL DEFAULT 0.0,
        discount_percentage REAL DEFAULT 0.0,
        customer_type TEXT DEFAULT 'عادي',
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول المبيعات - Sales
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        customer_id INTEGER,
        customer_name TEXT,
        total_amount REAL NOT NULL DEFAULT 0.0,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_amount REAL NOT NULL DEFAULT 0.0,
        paid_amount REAL DEFAULT 0.0,
        remaining_amount REAL DEFAULT 0.0,
        payment_method TEXT DEFAULT 'نقدي',
        payment_status TEXT DEFAULT 'مدفوع',
        invoice_type TEXT DEFAULT 'بيع',
        notes TEXT,
        sale_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // جدول بنود المبيعات - Sale Items
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_price REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // جدول المشتريات - Purchases
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        supplier_name TEXT NOT NULL,
        supplier_phone TEXT,
        total_amount REAL NOT NULL DEFAULT 0.0,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_amount REAL NOT NULL DEFAULT 0.0,
        paid_amount REAL DEFAULT 0.0,
        remaining_amount REAL DEFAULT 0.0,
        payment_method TEXT DEFAULT 'نقدي',
        payment_status TEXT DEFAULT 'مدفوع',
        notes TEXT,
        purchase_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود المشتريات - Purchase Items
    await db.execute('''
      CREATE TABLE purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_price REAL NOT NULL,
        expiry_date TEXT,
        notes TEXT,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // جدول مرتجعات المبيعات - Sales Returns
    await db.execute('''
      CREATE TABLE sales_returns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_number TEXT NOT NULL UNIQUE,
        sale_id INTEGER,
        customer_id INTEGER,
        customer_name TEXT,
        total_amount REAL NOT NULL DEFAULT 0.0,
        refund_amount REAL NOT NULL DEFAULT 0.0,
        payment_method TEXT DEFAULT 'نقدي',
        reason TEXT,
        notes TEXT,
        return_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // جدول بنود مرتجعات المبيعات
    await db.execute('''
      CREATE TABLE sales_return_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (return_id) REFERENCES sales_returns (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // جدول مرتجعات المشتريات - Purchase Returns
    await db.execute('''
      CREATE TABLE purchase_returns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_number TEXT NOT NULL UNIQUE,
        purchase_id INTEGER,
        supplier_name TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0.0,
        refund_amount REAL NOT NULL DEFAULT 0.0,
        payment_method TEXT DEFAULT 'نقدي',
        reason TEXT,
        notes TEXT,
        return_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id)
      )
    ''');

    // جدول بنود مرتجعات المشتريات
    await db.execute('''
      CREATE TABLE purchase_return_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (return_id) REFERENCES purchase_returns (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // جدول الموردين - Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        city TEXT,
        country TEXT DEFAULT 'العراق',
        balance REAL DEFAULT 0.0,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول الأقساط - Installments
    await db.execute('''
      CREATE TABLE installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT,
        sale_id INTEGER,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        remaining_amount REAL NOT NULL,
        installment_amount REAL NOT NULL,
        frequency TEXT DEFAULT 'شهري',
        start_date TEXT NOT NULL,
        end_date TEXT,
        status TEXT DEFAULT 'نشط',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (sale_id) REFERENCES sales (id)
      )
    ''');

    // جدول دفعات الأقساط - Installment Payments
    await db.execute('''
      CREATE TABLE installment_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        installment_id INTEGER NOT NULL,
        payment_number TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT DEFAULT 'مستحق',
        payment_method TEXT DEFAULT 'نقدي',
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT,
        FOREIGN KEY (installment_id) REFERENCES installments (id) ON DELETE CASCADE
      )
    ''');

    // ============ نهاية الجداول الأساسية ============

    // جدول عروض الأسعار - Quotations
    await db.execute('''
      CREATE TABLE quotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_number TEXT NOT NULL UNIQUE,
        customer_id INTEGER,
        customer_name TEXT,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        notes TEXT,
        valid_until TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود عروض الأسعار - Quotation Items
    await db.execute('''
      CREATE TABLE quotation_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        FOREIGN KEY (quotation_id) REFERENCES quotations (id) ON DELETE CASCADE
      )
    ''');

    // جدول قوائم الانتظار - Pending Orders
    await db.execute('''
      CREATE TABLE pending_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT NOT NULL UNIQUE,
        customer_id INTEGER,
        customer_name TEXT,
        customer_phone TEXT,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        final_amount REAL NOT NULL,
        deposit_amount REAL DEFAULT 0.0,
        remaining_amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        notes TEXT,
        delivery_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول بنود قوائم الانتظار - Pending Order Items
    await db.execute('''
      CREATE TABLE pending_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pending_order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_barcode TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        discount REAL DEFAULT 0.0,
        notes TEXT,
        FOREIGN KEY (pending_order_id) REFERENCES pending_orders (id) ON DELETE CASCADE
      )
    ''');

    // ============ جداول المخزون ============
    
    // جدول المستودعات - Warehouses
    await db.execute('''
      CREATE TABLE warehouses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        location TEXT NOT NULL,
        description TEXT,
        manager TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        sync_id TEXT
      )
    ''');

    // جدول التعبئة والتغليف - Packaging
    await db.execute('''
      CREATE TABLE packaging (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity_per_unit REAL NOT NULL,
        barcode TEXT,
        product_id INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // جدول مخزون المستودعات - Warehouse Stock
    await db.execute('''
      CREATE TABLE warehouse_stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        min_quantity REAL DEFAULT 0,
        max_quantity REAL,
        location TEXT,
        last_updated TEXT NOT NULL,
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
        UNIQUE(warehouse_id, product_id)
      )
    ''');

    // جدول حركات المخزون - Inventory Transactions
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        transaction_number TEXT NOT NULL UNIQUE,
        product_id INTEGER,
        warehouse_from_id INTEGER,
        warehouse_to_id INTEGER,
        quantity REAL NOT NULL,
        unit_cost REAL,
        total_cost REAL,
        notes TEXT,
        reference TEXT,
        transaction_date TEXT NOT NULL,
        created_by TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_id TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (warehouse_from_id) REFERENCES warehouses (id),
        FOREIGN KEY (warehouse_to_id) REFERENCES warehouses (id)
      )
    ''');

    // ============ نهاية جداول المخزون ============

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('✅ قاعدة البيانات SQLite تم إنشاؤها بنجاح!');
    print('📁 الموقع: ${Directory.current.path}\\sales_management.db');
    print('📊 عدد الجداول: 35+ جدول');
    print('💾 جميع البيانات ستُحفظ تلقائياً في هذه القاعدة');
    print('🔄 البيانات ستبقى محفوظة حتى بعد إغلاق التطبيق');
    print('');
    print('📋 الجداول الرئيسية:');
    print('   - المنتجات (products)');
    print('   - العملاء (customers)');
    print('   - المبيعات (sales)');
    print('   - المشتريات (purchases)');
    print('   - الموردين (suppliers)');
    print('   - المستودعات (warehouses)');
    print('   - الأقساط (installments)');
    print('   - عروض الأسعار (quotations)');
    print('   - قوائم الانتظار (pending_orders)');
    print('   - السندات المالية (vouchers)');
    print('═══════════════════════════════════════════════════════════');
    print('');
  }

  /// تحديث قاعدة البيانات
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة جداول عروض الأسعار
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quotations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quotation_number TEXT NOT NULL UNIQUE,
          customer_id INTEGER,
          customer_name TEXT,
          total_amount REAL NOT NULL,
          discount REAL DEFAULT 0.0,
          tax REAL DEFAULT 0.0,
          final_amount REAL NOT NULL,
          status TEXT DEFAULT 'pending',
          notes TEXT,
          valid_until TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS quotation_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quotation_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          product_barcode TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          discount REAL DEFAULT 0.0,
          FOREIGN KEY (quotation_id) REFERENCES quotations (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      // إضافة جداول قوائم الانتظار
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_number TEXT NOT NULL UNIQUE,
          customer_id INTEGER,
          customer_name TEXT,
          customer_phone TEXT,
          total_amount REAL NOT NULL,
          discount REAL DEFAULT 0.0,
          tax REAL DEFAULT 0.0,
          final_amount REAL NOT NULL,
          deposit_amount REAL DEFAULT 0.0,
          remaining_amount REAL NOT NULL,
          status TEXT DEFAULT 'pending',
          notes TEXT,
          delivery_date TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pending_order_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          product_barcode TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          discount REAL DEFAULT 0.0,
          notes TEXT,
          FOREIGN KEY (pending_order_id) REFERENCES pending_orders (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 4) {
      // إضافة جداول المخزون
      await db.execute('''
        CREATE TABLE IF NOT EXISTS warehouses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          location TEXT NOT NULL,
          description TEXT,
          manager TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS packaging (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          quantity_per_unit REAL NOT NULL,
          barcode TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS warehouse_stock (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          warehouse_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity REAL NOT NULL DEFAULT 0,
          min_quantity REAL,
          max_quantity REAL,
          location TEXT,
          last_updated TEXT NOT NULL,
          FOREIGN KEY (warehouse_id) REFERENCES warehouses (id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
          UNIQUE(warehouse_id, product_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS inventory_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          transaction_number TEXT NOT NULL UNIQUE,
          product_id INTEGER,
          warehouse_from_id INTEGER,
          warehouse_to_id INTEGER,
          quantity REAL NOT NULL,
          unit_cost REAL,
          total_cost REAL,
          notes TEXT,
          reference TEXT,
          transaction_date TEXT NOT NULL,
          created_by TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (product_id) REFERENCES products (id),
          FOREIGN KEY (warehouse_from_id) REFERENCES warehouses (id),
          FOREIGN KEY (warehouse_to_id) REFERENCES warehouses (id)
        )
      ''');
    }

    if (oldVersion < 5) {
      // إضافة الجداول الأساسية الناقصة
      
      // جدول المنتجات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          barcode TEXT NOT NULL UNIQUE,
          category TEXT,
          unit TEXT DEFAULT 'قطعة',
          purchase_price REAL NOT NULL DEFAULT 0.0,
          selling_price REAL NOT NULL DEFAULT 0.0,
          quantity REAL NOT NULL DEFAULT 0.0,
          min_quantity REAL DEFAULT 0.0,
          max_quantity REAL,
          carton_quantity INTEGER DEFAULT 1,
          expiry_date TEXT,
          supplier TEXT,
          notes TEXT,
          image_path TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT
        )
      ''');

      // جدول العملاء
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT,
          address TEXT,
          city TEXT,
          country TEXT DEFAULT 'العراق',
          balance REAL DEFAULT 0.0,
          credit_limit REAL DEFAULT 0.0,
          discount_percentage REAL DEFAULT 0.0,
          customer_type TEXT DEFAULT 'عادي',
          notes TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT
        )
      ''');

      // جدول المبيعات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_number TEXT NOT NULL UNIQUE,
          customer_id INTEGER,
          customer_name TEXT,
          total_amount REAL NOT NULL DEFAULT 0.0,
          discount REAL DEFAULT 0.0,
          tax REAL DEFAULT 0.0,
          final_amount REAL NOT NULL DEFAULT 0.0,
          paid_amount REAL DEFAULT 0.0,
          remaining_amount REAL DEFAULT 0.0,
          payment_method TEXT DEFAULT 'نقدي',
          payment_status TEXT DEFAULT 'مدفوع',
          invoice_type TEXT DEFAULT 'بيع',
          notes TEXT,
          sale_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT,
          FOREIGN KEY (customer_id) REFERENCES customers (id)
        )
      ''');

      // جدول بنود المبيعات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sale_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          product_barcode TEXT NOT NULL,
          quantity REAL NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          discount REAL DEFAULT 0.0,
          tax REAL DEFAULT 0.0,
          final_price REAL NOT NULL,
          notes TEXT,
          FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');

      // جدول المشتريات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_number TEXT NOT NULL UNIQUE,
          supplier_name TEXT NOT NULL,
          supplier_phone TEXT,
          total_amount REAL NOT NULL DEFAULT 0.0,
          discount REAL DEFAULT 0.0,
          tax REAL DEFAULT 0.0,
          final_amount REAL NOT NULL DEFAULT 0.0,
          paid_amount REAL DEFAULT 0.0,
          remaining_amount REAL DEFAULT 0.0,
          payment_method TEXT DEFAULT 'نقدي',
          payment_status TEXT DEFAULT 'مدفوع',
          notes TEXT,
          purchase_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT
        )
      ''');

      // جدول بنود المشتريات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchase_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          purchase_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          product_barcode TEXT NOT NULL,
          quantity REAL NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          discount REAL DEFAULT 0.0,
          tax REAL DEFAULT 0.0,
          final_price REAL NOT NULL,
          expiry_date TEXT,
          notes TEXT,
          FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');

      // جدول الموردين
      await db.execute('''
        CREATE TABLE IF NOT EXISTS suppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT,
          address TEXT,
          city TEXT,
          country TEXT DEFAULT 'العراق',
          balance REAL DEFAULT 0.0,
          notes TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT
        )
      ''');

      // جدول الأقساط
      await db.execute('''
        CREATE TABLE IF NOT EXISTS installments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          customer_name TEXT NOT NULL,
          customer_phone TEXT,
          sale_id INTEGER,
          total_amount REAL NOT NULL,
          paid_amount REAL DEFAULT 0.0,
          remaining_amount REAL NOT NULL,
          installment_amount REAL NOT NULL,
          frequency TEXT DEFAULT 'شهري',
          start_date TEXT NOT NULL,
          end_date TEXT,
          status TEXT DEFAULT 'نشط',
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          sync_id TEXT,
          FOREIGN KEY (customer_id) REFERENCES customers (id),
          FOREIGN KEY (sale_id) REFERENCES sales (id)
        )
      ''');

      // جدول دفعات الأقساط
      await db.execute('''
        CREATE TABLE IF NOT EXISTS installment_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          installment_id INTEGER NOT NULL,
          payment_number TEXT NOT NULL,
          amount REAL NOT NULL,
          payment_date TEXT NOT NULL,
          due_date TEXT NOT NULL,
          status TEXT DEFAULT 'مستحق',
          payment_method TEXT DEFAULT 'نقدي',
          notes TEXT,
          created_at TEXT NOT NULL,
          synced INTEGER DEFAULT 0,
          sync_id TEXT,
          FOREIGN KEY (installment_id) REFERENCES installments (id) ON DELETE CASCADE
        )
      ''');

      // جداول المرتجعات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales_returns (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          return_number TEXT NOT NULL UNIQUE,
          sale_id INTEGER,
          customer_id INTEGER,
          customer_name TEXT,
          total_amount REAL NOT NULL DEFAULT 0.0,
          refund_amount REAL NOT NULL DEFAULT 0.0,
          payment_method TEXT DEFAULT 'نقدي',
          reason TEXT,
          notes TEXT,
          return_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          synced INTEGER DEFAULT 0,
          sync_id TEXT,
          FOREIGN KEY (sale_id) REFERENCES sales (id),
          FOREIGN KEY (customer_id) REFERENCES customers (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales_return_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          return_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          product_barcode TEXT NOT NULL,
          quantity REAL NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY (return_id) REFERENCES sales_returns (id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchase_returns (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          return_number TEXT NOT NULL UNIQUE,
          purchase_id INTEGER,
          supplier_name TEXT NOT NULL,
          total_amount REAL NOT NULL DEFAULT 0.0,
          refund_amount REAL NOT NULL DEFAULT 0.0,
          payment_method TEXT DEFAULT 'نقدي',
          reason TEXT,
          notes TEXT,
          return_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          synced INTEGER DEFAULT 0,
          sync_id TEXT,
          FOREIGN KEY (purchase_id) REFERENCES purchases (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchase_return_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          return_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          product_barcode TEXT NOT NULL,
          quantity REAL NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY (return_id) REFERENCES purchase_returns (id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');

      print('');
      print('✅ تم تحديث قاعدة البيانات إلى الإصدار 5');
      print('📊 تمت إضافة جميع الجداول الأساسية');
      print('');
    }
  }

  // ===================== RECEIPT VOUCHERS =====================

  /// إضافة سند قبض
  Future<int> insertReceiptVoucher(ReceiptVoucher voucher) async {
    final db = await database;
    return await db.insert('receipt_vouchers', {
      'id': voucher.id,
      'voucher_number': voucher.voucherNumber,
      'date': voucher.date.toIso8601String(),
      'customer_name': voucher.customerName ?? '',
      'amount': voucher.amount,
      'payment_method': voucher.paymentMethod,
      'category': voucher.currency, // استخدام العملة بدلاً من category
      'notes': voucher.notes,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  /// الحصول على جميع سندات القبض
  Future<List<ReceiptVoucher>> getAllReceiptVouchers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'receipt_vouchers',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return ReceiptVoucher(
        id: maps[i]['id'],
        voucherNumber: maps[i]['voucher_number'],
        date: DateTime.parse(maps[i]['date']),
        customerName: maps[i]['customer_name'],
        amount: maps[i]['amount'],
        paymentMethod: maps[i]['payment_method'],
        currency: maps[i]['category'], // category يُستخدم للعملة
        notes: maps[i]['notes'],
      );
    });
  }

  /// تحديث سند قبض
  Future<int> updateReceiptVoucher(ReceiptVoucher voucher) async {
    final db = await database;
    return await db.update(
      'receipt_vouchers',
      {
        'voucher_number': voucher.voucherNumber,
        'date': voucher.date.toIso8601String(),
        'customer_name': voucher.customerName ?? '',
        'amount': voucher.amount,
        'payment_method': voucher.paymentMethod,
        'category': voucher.currency,
        'notes': voucher.notes,
        'synced': 0, // Mark as unsynced after update
      },
      where: 'id = ?',
      whereArgs: [voucher.id],
    );
  }

  /// حذف سند قبض
  Future<int> deleteReceiptVoucher(String id) async {
    final db = await database;
    return await db.delete(
      'receipt_vouchers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== MULTIPLE RECEIPT VOUCHERS =====================

  /// إضافة سند قبض متعدد
  Future<int> insertMultipleReceiptVoucher(
      MultipleReceiptVoucher voucher) async {
    final db = await database;

    // Insert main voucher
    await db.insert('multiple_receipt_vouchers', {
      'id': voucher.id,
      'voucher_number': voucher.voucherNumber,
      'date': voucher.date.toIso8601String(),
      'customer_name':
          '', // MultipleReceipt لا يحتوي customerName - استخدام فارغ
      'total_amount': voucher.totalAmount,
      'notes': voucher.notes,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });

    // Insert items
    for (var item in voucher.items) {
      await db.insert('receipt_items', {
        'id': '${voucher.id}_${voucher.items.indexOf(item)}',
        'voucher_id': voucher.id,
        'description': item.customerName, // استخدام customerName كـ description
        'amount': item.amount,
      });
    }

    return 1;
  }

  /// الحصول على جميع سندات القبض المتعددة
  Future<List<MultipleReceiptVoucher>> getAllMultipleReceiptVouchers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'multiple_receipt_vouchers',
      orderBy: 'date DESC',
    );

    List<MultipleReceiptVoucher> vouchers = [];

    for (var map in maps) {
      // Get items for this voucher
      final items = await db.query(
        'receipt_items',
        where: 'voucher_id = ?',
        whereArgs: [map['id']],
      );

      vouchers.add(MultipleReceiptVoucher(
        id: map['id'],
        voucherNumber: map['voucher_number'],
        date: DateTime.parse(map['date']),
        items: items
            .map((i) => ReceiptItem(
                  customerName: i['description']?.toString() ?? '',
                  amount: (i['amount'] as num).toDouble(),
                ))
            .toList(),
        totalAmount: map['total_amount'],
        notes: map['notes'],
      ));
    }

    return vouchers;
  }

  /// حذف سند قبض متعدد
  Future<int> deleteMultipleReceiptVoucher(String id) async {
    final db = await database;
    // Items will be deleted automatically due to CASCADE
    return await db.delete(
      'multiple_receipt_vouchers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== DUAL CURRENCY RECEIPTS =====================

  /// إضافة سند قبض بالعملتين
  Future<int> insertDualCurrencyReceipt(DualCurrencyReceipt voucher) async {
    final db = await database;
    return await db.insert('dual_currency_receipts', {
      'id': voucher.id,
      'voucher_number': voucher.voucherNumber,
      'date': voucher.date.toIso8601String(),
      'customer_name': voucher.customerName ?? '',
      'amount_iqd': voucher.amountIQD,
      'amount_usd': voucher.amountUSD,
      'exchange_rate': voucher.exchangeRate,
      'payment_method': 'نقدي', // افتراضي
      'category': 'IQD+USD', // افتراضي
      'notes': voucher.notes,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  /// الحصول على جميع سندات القبض بالعملتين
  Future<List<DualCurrencyReceipt>> getAllDualCurrencyReceipts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dual_currency_receipts',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return DualCurrencyReceipt(
        id: maps[i]['id'],
        voucherNumber: maps[i]['voucher_number'],
        date: DateTime.parse(maps[i]['date']),
        customerName: maps[i]['customer_name'],
        amountIQD: maps[i]['amount_iqd'],
        amountUSD: maps[i]['amount_usd'],
        exchangeRate: maps[i]['exchange_rate'],
        notes: maps[i]['notes'],
      );
    });
  }

  /// حذف سند قبض بالعملتين
  Future<int> deleteDualCurrencyReceipt(String id) async {
    final db = await database;
    return await db.delete(
      'dual_currency_receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== STATISTICS =====================

  /// إحصائيات إجمالي المقبوضات
  Future<double> getTotalReceipts() async {
    final db = await database;

    final result1 =
        await db.rawQuery('SELECT SUM(amount) as total FROM receipt_vouchers');
    final result2 = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM multiple_receipt_vouchers');
    final result3 = await db.rawQuery(
        'SELECT SUM(amount_iqd) as total FROM dual_currency_receipts');

    double total = 0;
    if (result1.first['total'] != null) {
      total += result1.first['total'] as double;
    }
    if (result2.first['total'] != null) {
      total += result2.first['total'] as double;
    }
    if (result3.first['total'] != null) {
      total += result3.first['total'] as double;
    }

    return total;
  }

  /// الحصول على السندات غير المتزامنة
  Future<List<Map<String, dynamic>>> getUnsyncedReceipts() async {
    final db = await database;
    return await db.query(
      'receipt_vouchers',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  /// وضع علامة على السند كمتزامن
  Future<void> markReceiptAsSynced(String id, String syncId) async {
    final db = await database;
    await db.update(
      'receipt_vouchers',
      {'synced': 1, 'sync_id': syncId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// إغلاق قاعدة البيانات
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// حذف قاعدة البيانات (للاختبار فقط)
  Future<void> deleteDatabase() async {
    final databasesPath = Directory.current.path;
    final path = join(databasesPath, 'sales_management.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      _database = null;
      print('✅ Database deleted');
    }
  }

  // ===================== QUOTATIONS =====================

  /// إضافة عرض سعر
  Future<int> insertQuotation(
      Map<String, dynamic> quotation, List<Map<String, dynamic>> items) async {
    final db = await database;

    // Insert quotation
    final quotationId = await db.insert('quotations', quotation);

    // Insert quotation items
    for (var item in items) {
      await db.insert('quotation_items', {
        ...item,
        'quotation_id': quotationId,
      });
    }

    return quotationId;
  }

  /// الحصول على جميع عروض الأسعار
  Future<List<Map<String, dynamic>>> getAllQuotations() async {
    final db = await database;
    final quotations = await db.query(
      'quotations',
      orderBy: 'created_at DESC',
    );

    // Get items for each quotation
    List<Map<String, dynamic>> result = [];
    for (var quotation in quotations) {
      final items = await db.query(
        'quotation_items',
        where: 'quotation_id = ?',
        whereArgs: [quotation['id']],
      );

      result.add({
        ...quotation,
        'items': items,
      });
    }

    return result;
  }

  /// الحصول على عرض سعر بالمعرف
  Future<Map<String, dynamic>?> getQuotationById(int id) async {
    final db = await database;

    final quotations = await db.query(
      'quotations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (quotations.isEmpty) return null;

    final items = await db.query(
      'quotation_items',
      where: 'quotation_id = ?',
      whereArgs: [id],
    );

    return {
      ...quotations.first,
      'items': items,
    };
  }

  /// تحديث عرض سعر
  Future<int> updateQuotation(int id, Map<String, dynamic> quotation,
      List<Map<String, dynamic>> items) async {
    final db = await database;

    // Update quotation
    await db.update(
      'quotations',
      {...quotation, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Delete old items
    await db.delete(
      'quotation_items',
      where: 'quotation_id = ?',
      whereArgs: [id],
    );

    // Insert new items
    for (var item in items) {
      await db.insert('quotation_items', {
        ...item,
        'quotation_id': id,
      });
    }

    return id;
  }

  /// حذف عرض سعر
  Future<int> deleteQuotation(int id) async {
    final db = await database;
    // Items will be deleted automatically due to CASCADE
    return await db.delete(
      'quotations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// تحديث حالة عرض السعر
  Future<int> updateQuotationStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'quotations',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// توليد رقم عرض سعر جديد
  Future<String> generateQuotationNumber() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM quotations');
    final count = result.first['count'] as int;
    return 'QT-${(count + 1).toString().padLeft(6, '0')}';
  }

  // ===================== PENDING ORDERS =====================

  /// إضافة طلب معلق
  Future<int> insertPendingOrder(
      Map<String, dynamic> order, List<Map<String, dynamic>> items) async {
    final db = await database;

    // Insert pending order
    final orderId = await db.insert('pending_orders', order);

    // Insert pending order items
    for (var item in items) {
      await db.insert('pending_order_items', {
        ...item,
        'pending_order_id': orderId,
      });
    }

    return orderId;
  }

  /// الحصول على جميع الطلبات المعلقة
  Future<List<Map<String, dynamic>>> getAllPendingOrders() async {
    final db = await database;
    final orders = await db.query(
      'pending_orders',
      orderBy: 'created_at DESC',
    );

    // Get items for each order
    List<Map<String, dynamic>> result = [];
    for (var order in orders) {
      final items = await db.query(
        'pending_order_items',
        where: 'pending_order_id = ?',
        whereArgs: [order['id']],
      );

      result.add({
        ...order,
        'items': items,
      });
    }

    return result;
  }

  /// الحصول على طلب معلق بالمعرف
  Future<Map<String, dynamic>?> getPendingOrderById(int id) async {
    final db = await database;

    final orders = await db.query(
      'pending_orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (orders.isEmpty) return null;

    final items = await db.query(
      'pending_order_items',
      where: 'pending_order_id = ?',
      whereArgs: [id],
    );

    return {
      ...orders.first,
      'items': items,
    };
  }

  /// تحديث طلب معلق
  Future<int> updatePendingOrder(int id, Map<String, dynamic> order,
      List<Map<String, dynamic>> items) async {
    final db = await database;

    // Update pending order
    await db.update(
      'pending_orders',
      {...order, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Delete old items
    await db.delete(
      'pending_order_items',
      where: 'pending_order_id = ?',
      whereArgs: [id],
    );

    // Insert new items
    for (var item in items) {
      await db.insert('pending_order_items', {
        ...item,
        'pending_order_id': id,
      });
    }

    return id;
  }

  /// حذف طلب معلق
  Future<int> deletePendingOrder(int id) async {
    final db = await database;
    // Items will be deleted automatically due to CASCADE
    return await db.delete(
      'pending_orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// تحديث حالة الطلب المعلق
  Future<int> updatePendingOrderStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'pending_orders',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// توليد رقم طلب معلق جديد
  Future<String> generatePendingOrderNumber() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM pending_orders');
    final count = result.first['count'] as int;
    return 'PO-${(count + 1).toString().padLeft(6, '0')}';
  }
}
