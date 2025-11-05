import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseConfig {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final databasesPath = Directory.current.path;
    final path = join(databasesPath, 'sales_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        role TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // جدول العملاء
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance REAL DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        notes TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT,
        category TEXT,
        purchasePrice REAL DEFAULT 0,
        sellingPrice REAL NOT NULL,
        quantity INTEGER DEFAULT 0,
        minQuantity INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        notes TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // جدول المبيعات
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL UNIQUE,
        customerId INTEGER,
        customerName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        discount REAL DEFAULT 0,
        paymentType TEXT NOT NULL,
        saleDate TEXT DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (customerId) REFERENCES Customers(id)
      )
    ''');

    // إدخال مستخدم افتراضي
    await db.insert('Users', {
      'username': 'admin',
      'password': 'admin123',
      'fullName': 'مدير النظام',
      'role': 'admin',
      'isActive': 1,
    });

    print('✅ تم إنشاء قاعدة البيانات بنجاح');
  }

  static Future<void> executeQuery(String query) async {
    final db = await database;
    await db.execute(query);
  }

  static Future<bool> executeNonQuery(String query) async {
    try {
      final db = await database;
      await db.execute(query);
      return true;
    } catch (e) {
      print('❌ خطأ: $e');
      return false;
    }
  }
}
