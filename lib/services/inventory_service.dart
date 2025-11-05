import 'database_helper.dart';
import '../models/warehouse.dart';
import '../models/packaging.dart';
import '../models/inventory_transaction.dart';
import '../models/warehouse_stock.dart';

class InventoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ===================== WAREHOUSES =====================

  /// إضافة مخزن جديد
  Future<int> addWarehouse(Warehouse warehouse) async {
    final db = await _dbHelper.database;
    return await db.insert('warehouses', warehouse.toMap());
  }

  /// الحصول على جميع المخازن
  Future<List<Warehouse>> getAllWarehouses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'warehouses',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Warehouse.fromMap(maps[i]));
  }

  /// تحديث مخزن
  Future<int> updateWarehouse(Warehouse warehouse) async {
    final db = await _dbHelper.database;
    return await db.update(
      'warehouses',
      warehouse.toMap(),
      where: 'id = ?',
      whereArgs: [warehouse.id],
    );
  }

  /// حذف مخزن (Soft Delete)
  Future<int> deleteWarehouse(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'warehouses',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== PACKAGING =====================

  /// إضافة تعبئة جديدة
  Future<int> addPackaging(Packaging packaging) async {
    final db = await _dbHelper.database;
    return await db.insert('packaging', packaging.toMap());
  }

  /// الحصول على جميع التعبئات
  Future<List<Packaging>> getAllPackaging() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'packaging',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Packaging.fromMap(maps[i]));
  }

  /// تحديث تعبئة
  Future<int> updatePackaging(Packaging packaging) async {
    final db = await _dbHelper.database;
    return await db.update(
      'packaging',
      packaging.toMap(),
      where: 'id = ?',
      whereArgs: [packaging.id],
    );
  }

  /// حذف تعبئة
  Future<int> deletePackaging(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'packaging',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== WAREHOUSE STOCK =====================

  /// الحصول على مخزون منتج في مخزن معين
  Future<WarehouseStock?> getWarehouseStock(
      int warehouseId, int productId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'warehouse_stock',
      where: 'warehouse_id = ? AND product_id = ?',
      whereArgs: [warehouseId, productId],
    );
    if (maps.isEmpty) return null;
    return WarehouseStock.fromMap(maps.first);
  }

  /// الحصول على جميع مخزون مخزن معين
  Future<List<Map<String, dynamic>>> getWarehouseStockWithProducts(
      int warehouseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT ws.*, p.name as product_name, p.barcode, p.unit, p.cost_price, p.selling_price
      FROM warehouse_stock ws
      INNER JOIN products p ON ws.product_id = p.id
      WHERE ws.warehouse_id = ?
      ORDER BY p.name ASC
    ''', [warehouseId]);
    return result;
  }

  /// الحصول على جميع المخزون لجميع المخازن
  Future<List<Map<String, dynamic>>> getAllStockWithDetails() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
             COALESCE(ws.id, 0) as id,
             p.id as product_id,
             COALESCE(w.id, 1) as warehouse_id,
             CAST(COALESCE(ws.quantity, 0.0) AS REAL) as quantity,
             CAST(ws.min_quantity AS REAL) as min_quantity,
             CAST(ws.max_quantity AS REAL) as max_quantity,
             ws.batch_number,
             ws.expiry_date,
             ws.last_restock_date,
             p.name as product_name, 
             p.barcode, 
             p.unit, 
             p.cost_price, 
             p.selling_price,
             COALESCE(w.name, 'مخزن افتراضي') as warehouse_name,
             COALESCE(w.location, '') as warehouse_location
      FROM products p
      LEFT JOIN warehouse_stock ws ON p.id = ws.product_id
      LEFT JOIN warehouses w ON ws.warehouse_id = w.id
      WHERE p.is_active = 1 AND (w.is_active = 1 OR w.id IS NULL)
      ORDER BY COALESCE(w.name, 'مخزن افتراضي'), p.name ASC
    ''');
    return result;
  }

  /// تحديث أو إضافة مخزون
  Future<void> updateOrInsertStock(WarehouseStock stock) async {
    final db = await _dbHelper.database;
    final existing = await getWarehouseStock(
      stock.warehouseId,
      stock.productId,
    );

    if (existing != null) {
      await db.update(
        'warehouse_stock',
        stock.toMap(),
        where: 'warehouse_id = ? AND product_id = ?',
        whereArgs: [stock.warehouseId, stock.productId],
      );
    } else {
      await db.insert('warehouse_stock', stock.toMap());
    }
  }

  // ===================== INVENTORY TRANSACTIONS =====================

  /// توليد رقم معاملة تلقائي
  Future<String> generateTransactionNumber(
      InventoryTransactionType type) async {
    final db = await _dbHelper.database;
    final typePrefix =
        type.toString().split('.').last.substring(0, 3).toUpperCase();
    final datePrefix =
        DateTime.now().toString().substring(0, 10).replaceAll('-', '');

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM inventory_transactions WHERE transaction_number LIKE ?',
      ['$typePrefix-$datePrefix%'],
    );

    final count = result.isNotEmpty ? (result.first['count'] as int? ?? 0) : 0;

    return '$typePrefix-$datePrefix-${(count + 1).toString().padLeft(4, '0')}';
  }

  /// إضافة معاملة مخزنية
  Future<int> addInventoryTransaction(InventoryTransaction transaction) async {
    final db = await _dbHelper.database;

    // حفظ المعاملة
    final transactionId = await db.insert(
      'inventory_transactions',
      transaction.toMap(),
    );

    // تحديث المخزون بناءً على نوع المعاملة
    await _updateStockFromTransaction(transaction);

    return transactionId;
  }

  /// تحديث المخزون بناءً على المعاملة
  Future<void> _updateStockFromTransaction(
      InventoryTransaction transaction) async {
    switch (transaction.type) {
      case InventoryTransactionType.stockIn:
      case InventoryTransactionType.import:
        // إدخال مخزني
        if (transaction.warehouseToId != null &&
            transaction.productId != null) {
          await _adjustStock(
            transaction.warehouseToId!,
            transaction.productId!,
            transaction.quantity,
          );
        }
        break;

      case InventoryTransactionType.stockOut:
      case InventoryTransactionType.consumed:
      case InventoryTransactionType.damaged:
      case InventoryTransactionType.donation:
        // إخراج مخزني
        if (transaction.warehouseFromId != null &&
            transaction.productId != null) {
          await _adjustStock(
            transaction.warehouseFromId!,
            transaction.productId!,
            -transaction.quantity,
          );
        }
        break;

      case InventoryTransactionType.transfer:
        // نقل بين مخازن
        if (transaction.warehouseFromId != null &&
            transaction.warehouseToId != null &&
            transaction.productId != null) {
          await _adjustStock(
            transaction.warehouseFromId!,
            transaction.productId!,
            -transaction.quantity,
          );
          await _adjustStock(
            transaction.warehouseToId!,
            transaction.productId!,
            transaction.quantity,
          );
        }
        break;

      case InventoryTransactionType.adjustment:
        // تسوية مخزنية - تحديث مباشر للكمية
        if (transaction.warehouseToId != null &&
            transaction.productId != null) {
          final stock = await getWarehouseStock(
            transaction.warehouseToId!,
            transaction.productId!,
          );
          if (stock != null) {
            await updateOrInsertStock(WarehouseStock(
              id: stock.id,
              warehouseId: transaction.warehouseToId!,
              productId: transaction.productId!,
              quantity: transaction.quantity,
              minQuantity: stock.minQuantity,
              maxQuantity: stock.maxQuantity,
              location: stock.location,
            ));
          }
        }
        break;

      case InventoryTransactionType.materialOrder:
        // طلبية مواد - لا تؤثر على المخزون مباشرة
        break;
    }
  }

  /// تعديل المخزون بإضافة أو طرح كمية
  Future<void> _adjustStock(
      int warehouseId, int productId, double quantityChange) async {
    final stock = await getWarehouseStock(warehouseId, productId);

    if (stock != null) {
      final newQuantity = stock.quantity + quantityChange;
      await updateOrInsertStock(WarehouseStock(
        id: stock.id,
        warehouseId: warehouseId,
        productId: productId,
        quantity: newQuantity,
        minQuantity: stock.minQuantity,
        maxQuantity: stock.maxQuantity,
        location: stock.location,
      ));
    } else {
      // إنشاء سجل جديد
      await updateOrInsertStock(WarehouseStock(
        warehouseId: warehouseId,
        productId: productId,
        quantity: quantityChange > 0 ? quantityChange : 0,
      ));
    }
  }

  /// الحصول على جميع المعاملات المخزنية
  Future<List<InventoryTransaction>> getAllTransactions({
    InventoryTransactionType? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClause = 'type = ?';
      whereArgs.add(type.toString().split('.').last);
    }

    if (fromDate != null) {
      whereClause +=
          (whereClause.isEmpty ? '' : ' AND ') + 'transaction_date >= ?';
      whereArgs.add(fromDate.toIso8601String());
    }

    if (toDate != null) {
      whereClause +=
          (whereClause.isEmpty ? '' : ' AND ') + 'transaction_date <= ?';
      whereArgs.add(toDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_transactions',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'transaction_date DESC, created_at DESC',
    );

    return List.generate(
        maps.length, (i) => InventoryTransaction.fromMap(maps[i]));
  }

  /// طرح الكمية من المخزون (عند البيع)
  /// warehouseId: معرف المخزن (افتراضي = 1)
  /// productId: معرف المنتج
  /// quantity: الكمية المباعة
  Future<bool> deductStockForSale({
    required int productId,
    required double quantity,
    int warehouseId = 1,
  }) async {
    try {
      final stock = await getWarehouseStock(warehouseId, productId);

      if (stock == null) {
        // إنشاء سجل جديد بكمية سالبة (للتنبيه)
        await updateOrInsertStock(WarehouseStock(
          warehouseId: warehouseId,
          productId: productId,
          quantity: -quantity,
        ));
        return false; // تنبيه: لا يوجد مخزون
      }

      // طرح الكمية من المخزون
      await _adjustStock(warehouseId, productId, -quantity);
      return true;
    } catch (e) {
      print('Error deducting stock: $e');
      return false;
    }
  }

  /// إضافة الكمية للمخزون (عند الشراء)
  /// warehouseId: معرف المخزن (افتراضي = 1)
  /// productId: معرف المنتج
  /// quantity: الكمية المشتراة
  Future<bool> addStockForPurchase({
    required int productId,
    required double quantity,
    int warehouseId = 1,
  }) async {
    try {
      await _adjustStock(warehouseId, productId, quantity);
      return true;
    } catch (e) {
      print('Error adding stock: $e');
      return false;
    }
  }

  /// إعادة الكمية للمخزون (عند مرتجع البيع)
  Future<bool> returnStockForSaleReturn({
    required int productId,
    required double quantity,
    int warehouseId = 1,
  }) async {
    return await addStockForPurchase(
      productId: productId,
      quantity: quantity,
      warehouseId: warehouseId,
    );
  }

  /// طرح الكمية من المخزون (عند مرتجع الشراء)
  Future<bool> deductStockForPurchaseReturn({
    required int productId,
    required double quantity,
    int warehouseId = 1,
  }) async {
    return await deductStockForSale(
      productId: productId,
      quantity: quantity,
      warehouseId: warehouseId,
    );
  }

  /// الحصول على تقرير المواد المنخفضة
  Future<List<Map<String, dynamic>>> getLowStockReport() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT ws.*, 
             p.name as product_name, 
             p.barcode, 
             p.unit,
             w.name as warehouse_name
      FROM warehouse_stock ws
      INNER JOIN products p ON ws.product_id = p.id
      INNER JOIN warehouses w ON ws.warehouse_id = w.id
      WHERE ws.min_quantity IS NOT NULL 
        AND ws.quantity <= ws.min_quantity
        AND w.is_active = 1
      ORDER BY (ws.quantity / NULLIF(ws.min_quantity, 0)) ASC
    ''');
    return result;
  }

  /// الحصول على تقرير المواد التالفة
  Future<List<InventoryTransaction>> getDamagedMaterialsReport({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await getAllTransactions(
      type: InventoryTransactionType.damaged,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// الحصول على تقرير المواد المستهلكة
  Future<List<InventoryTransaction>> getConsumedMaterialsReport({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await getAllTransactions(
      type: InventoryTransactionType.consumed,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// حذف معاملة مخزنية
  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inventory_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
