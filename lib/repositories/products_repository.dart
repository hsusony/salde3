/// ========================================
/// مستودع المنتجات - Repository Pattern
/// Products Repository
/// ========================================
/// ⚠️ ملف معطل مؤقتاً - يتطلب إصلاح النموذج والاتصال بقاعدة البيانات
/// TODO: إعادة بناء هذا الملف بعد تفعيل الاتصال بـ SQL Server

/*
import 'dart:convert';
import '../core/enhanced_database_manager.dart';
import '../models/product.dart';

class ProductsRepository {
  final EnhancedDatabaseManager _db = EnhancedDatabaseManager();

  /// الحصول على جميع المنتجات
  Future<List<Product>> getAllProducts() async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, barcode, category, unit, 
               purchasePrice, sellingPrice, quantity, minQuantity, 
               isActive, notes, createdAt, updatedAt
        FROM Products
        WHERE isActive = 1
        ORDER BY name
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المنتجات: $e');
      return [];
    }
  }

  /// البحث عن منتج بالباركود
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, barcode, category, unit,
               purchasePrice, sellingPrice, quantity, minQuantity,
               isActive, notes, createdAt, updatedAt
        FROM Products
        WHERE barcode = '$barcode' AND isActive = 1
      ''');

      if (result == null || result.isEmpty || result == '[]') {
        return null;
      }

      final List<dynamic> data = jsonDecode(result);
      if (data.isEmpty) return null;

      return Product.fromJson(data.first);
    } catch (e) {
      print('❌ خطأ في البحث عن المنتج: $e');
      return null;
    }
  }

  /// البحث عن منتج بالاسم
  Future<List<Product>> searchProductsByName(String name) async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, barcode, category, unit,
               purchasePrice, sellingPrice, quantity, minQuantity,
               isActive, notes, createdAt, updatedAt
        FROM Products
        WHERE name LIKE '%$name%' AND isActive = 1
        ORDER BY name
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في البحث: $e');
      return [];
    }
  }

  /// إضافة منتج جديد
  Future<bool> addProduct(Product product) async {
    try {
      final query = '''
        INSERT INTO Products 
        (name, barcode, category, unit, purchasePrice, sellingPrice, 
         quantity, minQuantity, isActive, notes, createdAt, updatedAt)
        VALUES 
        (N'${product.name}', 
         '${product.barcode ?? ''}',
         N'${product.category ?? ''}',
         N'${product.unit ?? 'حبة'}',
         ${product.purchasePrice ?? 0},
         ${product.sellingPrice},
         ${product.quantity},
         ${product.minQuantity},
         ${product.isActive ? 1 : 0},
         N'${product.notes ?? ''}',
         GETDATE(),
         GETDATE())
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في إضافة المنتج: $e');
      return false;
    }
  }

  /// تحديث منتج
  Future<bool> updateProduct(Product product) async {
    try {
      final query = '''
        UPDATE Products SET
          name = N'${product.name}',
          barcode = '${product.barcode ?? ''}',
          category = N'${product.category ?? ''}',
          unit = N'${product.unit ?? 'حبة'}',
          purchasePrice = ${product.purchasePrice ?? 0},
          sellingPrice = ${product.sellingPrice},
          quantity = ${product.quantity},
          minQuantity = ${product.minQuantity},
          isActive = ${product.isActive ? 1 : 0},
          notes = N'${product.notes ?? ''}',
          updatedAt = GETDATE()
        WHERE id = ${product.id}
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في تحديث المنتج: $e');
      return false;
    }
  }

  /// حذف منتج (soft delete)
  Future<bool> deleteProduct(int id) async {
    try {
      final query = '''
        UPDATE Products 
        SET isActive = 0, updatedAt = GETDATE()
        WHERE id = $id
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في حذف المنتج: $e');
      return false;
    }
  }

  /// تحديث كمية المنتج
  Future<bool> updateProductQuantity(int productId, int newQuantity) async {
    try {
      final query = '''
        UPDATE Products 
        SET quantity = $newQuantity, updatedAt = GETDATE()
        WHERE id = $productId
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في تحديث الكمية: $e');
      return false;
    }
  }

  /// الحصول على المنتجات التي وصلت للحد الأدنى
  Future<List<Product>> getLowStockProducts() async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, barcode, category, unit,
               purchasePrice, sellingPrice, quantity, minQuantity,
               isActive, notes, createdAt, updatedAt
        FROM Products
        WHERE quantity <= minQuantity AND isActive = 1
        ORDER BY quantity ASC
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المنتجات منخفضة المخزون: $e');
      return [];
    }
  }

  /// الحصول على إحصائيات المنتجات
  Future<Map<String, dynamic>> getProductStatistics() async {
    try {
      final result = await _db.executeQuery('''
        SELECT 
          COUNT(*) as totalProducts,
          SUM(CASE WHEN quantity <= minQuantity THEN 1 ELSE 0 END) as lowStockCount,
          SUM(quantity * purchasePrice) as totalInventoryValue,
          AVG(quantity) as averageQuantity
        FROM Products
        WHERE isActive = 1
      ''');

      if (result == null || result.isEmpty) {
        return {};
      }

      final List<dynamic> data = jsonDecode(result);
      return data.first as Map<String, dynamic>;
    } catch (e) {
      print('❌ خطأ في جلب الإحصائيات: $e');
      return {};
    }
  }
}
*/
