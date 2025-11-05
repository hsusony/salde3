import 'dart:convert';
import '../config/database_config.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  // ==================== PRODUCTS ====================

  Future<int> insertProduct(Product product) async {
    try {
      final query = '''
        INSERT INTO Products (
          name, barcode, category, purchase_price, selling_price, 
          quantity, min_quantity, description, createdAt
        )
        OUTPUT INSERTED.id
        VALUES (
          N'${_escape(product.name)}',
          N'${_escape(product.barcode)}',
          N'${_escape(product.category)}',
          ${product.purchasePrice},
          ${product.sellingPrice},
          ${product.quantity},
          ${product.minQuantity},
          N'${_escape(product.description ?? '')}',
          GETDATE()
        )
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result != null) {
        final data = jsonDecode(result);
        return data[0]['id'] as int;
      }
      return 0;
    } catch (e) {
      print('❌ خطأ في إضافة المنتج: $e');
      rethrow;
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final query = '''
        SELECT 
          id, name, barcode, category, purchase_price as purchasePrice,
          selling_price as sellingPrice, quantity, min_quantity as minQuantity,
          description, createdAt, updatedAt
        FROM Products
        WHERE isActive = 1
        ORDER BY name ASC
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المنتجات: $e');
      return [];
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      final query = '''
        SELECT 
          id, name, barcode, category, purchase_price as purchasePrice,
          selling_price as sellingPrice, quantity, min_quantity as minQuantity,
          description, createdAt, updatedAt
        FROM Products
        WHERE id = $id AND isActive = 1
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return null;

      final List<dynamic> data = jsonDecode(result);
      if (data.isEmpty) return null;
      return Product.fromMap(data.first);
    } catch (e) {
      print('❌ خطأ في جلب المنتج: $e');
      return null;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final query = '''
        SELECT 
          id, name, barcode, category, purchase_price as purchasePrice,
          selling_price as sellingPrice, quantity, min_quantity as minQuantity,
          description, createdAt, updatedAt
        FROM Products
        WHERE barcode = N'${_escape(barcode)}' AND isActive = 1
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return null;

      final List<dynamic> data = jsonDecode(result);
      if (data.isEmpty) return null;
      return Product.fromMap(data.first);
    } catch (e) {
      print('❌ خطأ في جلب المنتج بالباركود: $e');
      return null;
    }
  }

  Future<int> updateProduct(Product product) async {
    try {
      final query = '''
        UPDATE Products
        SET 
          name = N'${_escape(product.name)}',
          barcode = N'${_escape(product.barcode)}',
          category = N'${_escape(product.category)}',
          purchase_price = ${product.purchasePrice},
          selling_price = ${product.sellingPrice},
          quantity = ${product.quantity},
          min_quantity = ${product.minQuantity},
          description = N'${_escape(product.description ?? '')}',
          updatedAt = GETDATE()
        WHERE id = ${product.id}
      ''';

      final success = await DatabaseConfig.executeNonQuery(query);
      return success ? 1 : 0;
    } catch (e) {
      print('❌ خطأ في تحديث المنتج: $e');
      rethrow;
    }
  }

  Future<int> deleteProduct(int id, {String userName = 'المستخدم'}) async {
    try {
      // Soft delete
      final query = '''
        UPDATE Products
        SET isActive = 0, updatedAt = GETDATE()
        WHERE id = $id
      ''';

      final success = await DatabaseConfig.executeNonQuery(query);
      return success ? 1 : 0;
    } catch (e) {
      print('❌ خطأ في حذف المنتج: $e');
      return 0;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final searchQuery = '''
        SELECT 
          id, name, barcode, category, purchase_price as purchasePrice,
          selling_price as sellingPrice, quantity, min_quantity as minQuantity,
          description, createdAt, updatedAt
        FROM Products
        WHERE isActive = 1
        AND (
          name LIKE N'%${_escape(query)}%' OR
          barcode LIKE N'%${_escape(query)}%' OR
          category LIKE N'%${_escape(query)}%'
        )
        ORDER BY name ASC
      ''';

      final result = await DatabaseConfig.executeQuery(searchQuery);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في البحث عن المنتجات: $e');
      return [];
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      final query = '''
        SELECT 
          id, name, barcode, category, purchase_price as purchasePrice,
          selling_price as sellingPrice, quantity, min_quantity as minQuantity,
          description, createdAt, updatedAt
        FROM Products
        WHERE isActive = 1 AND quantity <= min_quantity
        ORDER BY quantity ASC
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المنتجات منخفضة المخزون: $e');
      return [];
    }
  }

  // ==================== CUSTOMERS ====================

  Future<int> insertCustomer(Customer customer) async {
    try {
      final query = '''
        INSERT INTO Customers (
          name, phone, address, balance, notes, createdAt
        )
        OUTPUT INSERTED.id
        VALUES (
          N'${_escape(customer.name)}',
          N'${_escape(customer.phone)}',
          N'${_escape(customer.address ?? '')}',
          ${customer.balance},
          N'${_escape(customer.notes ?? '')}',
          GETDATE()
        )
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result != null) {
        final data = jsonDecode(result);
        return data[0]['id'] as int;
      }
      return 0;
    } catch (e) {
      print('❌ خطأ في إضافة العميل: $e');
      rethrow;
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      final query = '''
        SELECT 
          id, name, phone, address, balance, notes, createdAt, updatedAt
        FROM Customers
        ORDER BY name ASC
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Customer.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب العملاء: $e');
      return [];
    }
  }

  Future<Customer?> getCustomerById(int id) async {
    try {
      final query = '''
        SELECT 
          id, name, phone, address, balance, notes, createdAt, updatedAt
        FROM Customers
        WHERE id = $id
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return null;

      final List<dynamic> data = jsonDecode(result);
      if (data.isEmpty) return null;
      return Customer.fromMap(data.first);
    } catch (e) {
      print('❌ خطأ في جلب العميل: $e');
      return null;
    }
  }

  Future<int> updateCustomer(Customer customer) async {
    try {
      final query = '''
        UPDATE Customers
        SET 
          name = N'${_escape(customer.name)}',
          phone = N'${_escape(customer.phone)}',
          address = N'${_escape(customer.address ?? '')}',
          balance = ${customer.balance},
          notes = N'${_escape(customer.notes ?? '')}',
          updatedAt = GETDATE()
        WHERE id = ${customer.id}
      ''';

      final success = await DatabaseConfig.executeNonQuery(query);
      return success ? 1 : 0;
    } catch (e) {
      print('❌ خطأ في تحديث العميل: $e');
      rethrow;
    }
  }

  Future<int> deleteCustomer(int id) async {
    try {
      final query = 'DELETE FROM Customers WHERE id = $id';
      final success = await DatabaseConfig.executeNonQuery(query);
      return success ? 1 : 0;
    } catch (e) {
      print('❌ خطأ في حذف العميل: $e');
      return 0;
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final searchQuery = '''
        SELECT 
          id, name, phone, address, balance, notes, createdAt, updatedAt
        FROM Customers
        WHERE 
          name LIKE N'%${_escape(query)}%' OR
          phone LIKE N'%${_escape(query)}%' OR
          address LIKE N'%${_escape(query)}%'
        ORDER BY name ASC
      ''';

      final result = await DatabaseConfig.executeQuery(searchQuery);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Customer.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في البحث عن العملاء: $e');
      return [];
    }
  }

  // ==================== SALES ====================

  Future<int> insertSale(Sale sale) async {
    try {
      // Start transaction
      await DatabaseConfig.executeNonQuery('BEGIN TRANSACTION');

      // Insert sale
      final saleQuery = '''
        INSERT INTO Sales (
          invoiceNumber, customerId, customerName, totalAmount, discount,
          netAmount, paidAmount, remainingAmount, paymentType, status,
          notes, saleDate
        )
        OUTPUT INSERTED.id
        VALUES (
          N'${_escape(sale.invoiceNumber)}',
          ${sale.customerId ?? 'NULL'},
          N'${_escape(sale.customerName ?? '')}',
          ${sale.totalAmount},
          ${sale.discount},
          ${sale.finalAmount},
          ${sale.paidAmount},
          ${sale.remainingAmount},
          N'${_escape(sale.paymentMethod)}',
          N'${_escape(sale.status)}',
          N'${_escape(sale.notes ?? '')}',
          GETDATE()
        )
      ''';

      final saleResult = await DatabaseConfig.executeQuery(saleQuery);
      int saleId = 0;
      if (saleResult != null) {
        final data = jsonDecode(saleResult);
        saleId = data[0]['id'] as int;
      }

      // Insert sale items and update product quantities
      for (var item in sale.items) {
        // Insert sale item
        await DatabaseConfig.executeNonQuery('''
          INSERT INTO SaleItems (
            saleId, productId, productName, quantity, unitPrice, totalPrice
          )
          VALUES (
            $saleId,
            ${item.productId},
            N'${_escape(item.productName)}',
            ${item.quantity},
            ${item.unitPrice},
            ${item.totalPrice}
          )
        ''');

        // Update product quantity
        await DatabaseConfig.executeNonQuery('''
          UPDATE Products
          SET quantity = quantity - ${item.quantity}
          WHERE id = ${item.productId}
        ''');
      }

      // Update customer balance if needed
      if (sale.customerId != null && sale.remainingAmount > 0) {
        await DatabaseConfig.executeNonQuery('''
          UPDATE Customers
          SET balance = balance + ${sale.remainingAmount}
          WHERE id = ${sale.customerId}
        ''');
      }

      // Commit transaction
      await DatabaseConfig.executeNonQuery('COMMIT TRANSACTION');

      return saleId;
    } catch (e) {
      // Rollback on error
      await DatabaseConfig.executeNonQuery('ROLLBACK TRANSACTION');
      print('❌ خطأ في إضافة عملية البيع: $e');
      rethrow;
    }
  }

  Future<List<Sale>> getAllSales() async {
    try {
      final query = '''
        SELECT 
          id, invoiceNumber, customerId, customerName, totalAmount, discount,
          netAmount, paidAmount, remainingAmount, paymentType, status,
          notes, saleDate as createdAt, updatedAt
        FROM Sales
        ORDER BY saleDate DESC
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Sale.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المبيعات: $e');
      return [];
    }
  }

  Future<Sale?> getSaleById(int id) async {
    try {
      final query = '''
        SELECT 
          id, invoiceNumber, customerId, customerName, totalAmount, discount,
          netAmount, paidAmount, remainingAmount, paymentType, status,
          notes, saleDate as createdAt, updatedAt
        FROM Sales
        WHERE id = $id
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return null;

      final List<dynamic> data = jsonDecode(result);
      if (data.isEmpty) return null;

      final sale = Sale.fromMap(data.first);
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
    } catch (e) {
      print('❌ خطأ في جلب تفاصيل البيع: $e');
      return null;
    }
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    try {
      final query = '''
        SELECT 
          id, saleId, productId, productName, quantity, unitPrice, totalPrice
        FROM SaleItems
        WHERE saleId = $saleId
      ''';

      final result = await DatabaseConfig.executeQuery(query);
      if (result == null || result.isEmpty) return [];

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => SaleItem.fromMap(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب أصناف البيع: $e');
      return [];
    }
  }

  Future<String> generateInvoiceNumber() async {
    try {
      final query = 'SELECT MAX(id) as maxId FROM Sales';
      final result = await DatabaseConfig.executeQuery(query);

      int maxId = 0;
      if (result != null && result.isNotEmpty) {
        final List<dynamic> data = jsonDecode(result);
        if (data.isNotEmpty && data.first['maxId'] != null) {
          maxId = data.first['maxId'] as int;
        }
      }

      final now = DateTime.now();
      return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(maxId + 1).toString().padLeft(4, '0')}';
    } catch (e) {
      print('❌ خطأ في توليد رقم الفاتورة: $e');
      final now = DateTime.now();
      return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0001';
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Total Sales Today
      final todayQuery = '''
        SELECT ISNULL(SUM(netAmount), 0) as total
        FROM Sales
        WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
        AND status = N'مكتمل'
      ''';
      final todayResult = await DatabaseConfig.executeQuery(todayQuery);
      double todaySales = 0;
      if (todayResult != null && todayResult.isNotEmpty) {
        final data = jsonDecode(todayResult);
        todaySales = (data[0]['total'] ?? 0).toDouble();
      }

      // Total Sales This Month
      final monthQuery = '''
        SELECT ISNULL(SUM(netAmount), 0) as total
        FROM Sales
        WHERE YEAR(saleDate) = YEAR(GETDATE())
        AND MONTH(saleDate) = MONTH(GETDATE())
        AND status = N'مكتمل'
      ''';
      final monthResult = await DatabaseConfig.executeQuery(monthQuery);
      double monthSales = 0;
      if (monthResult != null && monthResult.isNotEmpty) {
        final data = jsonDecode(monthResult);
        monthSales = (data[0]['total'] ?? 0).toDouble();
      }

      // Total Products
      final productsQuery =
          'SELECT COUNT(*) as count FROM Products WHERE isActive = 1';
      final productsResult = await DatabaseConfig.executeQuery(productsQuery);
      int productsCount = 0;
      if (productsResult != null && productsResult.isNotEmpty) {
        final data = jsonDecode(productsResult);
        productsCount = (data[0]['count'] ?? 0) as int;
      }

      // Total Customers
      final customersQuery = 'SELECT COUNT(*) as count FROM Customers';
      final customersResult = await DatabaseConfig.executeQuery(customersQuery);
      int customersCount = 0;
      if (customersResult != null && customersResult.isNotEmpty) {
        final data = jsonDecode(customersResult);
        customersCount = (data[0]['count'] ?? 0) as int;
      }

      // Low Stock Products
      final lowStockQuery = '''
        SELECT COUNT(*) as count
        FROM Products
        WHERE isActive = 1 AND quantity <= minQuantity
      ''';
      final lowStockResult = await DatabaseConfig.executeQuery(lowStockQuery);
      int lowStockCount = 0;
      if (lowStockResult != null && lowStockResult.isNotEmpty) {
        final data = jsonDecode(lowStockResult);
        lowStockCount = (data[0]['count'] ?? 0) as int;
      }

      // Total Balance
      final balanceQuery =
          'SELECT ISNULL(SUM(balance), 0) as total FROM Customers';
      final balanceResult = await DatabaseConfig.executeQuery(balanceQuery);
      double totalBalance = 0;
      if (balanceResult != null && balanceResult.isNotEmpty) {
        final data = jsonDecode(balanceResult);
        totalBalance = (data[0]['total'] ?? 0).toDouble();
      }

      return {
        'todaySales': todaySales,
        'monthSales': monthSales,
        'productsCount': productsCount,
        'customersCount': customersCount,
        'lowStockCount': lowStockCount,
        'totalBalance': totalBalance,
      };
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات الداشبورد: $e');
      return {
        'todaySales': 0.0,
        'monthSales': 0.0,
        'productsCount': 0,
        'customersCount': 0,
        'lowStockCount': 0,
        'totalBalance': 0.0,
      };
    }
  }

  Future<void> close() async {
    await DatabaseConfig.closeConnection();
  }

  // Helper method to escape SQL strings
  String _escape(String value) {
    return value.replaceAll("'", "''");
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
