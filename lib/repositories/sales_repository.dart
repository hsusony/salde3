/// ========================================
/// مستودع المبيعات - Repository Pattern
/// Sales Repository
/// ========================================

import 'dart:convert';
import '../core/enhanced_database_manager.dart';
import '../models/sale.dart';

class SalesRepository {
  final EnhancedDatabaseManager _db = EnhancedDatabaseManager();

  /// إضافة فاتورة مبيعات جديدة
  Future<bool> createSale(Sale sale) async {
    try {
      final query = '''
        INSERT INTO Sales 
        (invoiceNumber, customerId, customerName, totalAmount, 
         discount, paymentType, saleDate, notes, createdAt, updatedAt)
        VALUES 
        ('${sale.invoiceNumber}',
         ${sale.customerId ?? 'NULL'},
         N'${sale.customerName}',
         ${sale.totalAmount},
         ${sale.discount},
         N'${sale.paymentType}',
         GETDATE(),
         N'${sale.notes ?? ''}',
         GETDATE(),
         GETDATE())
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في إضافة فاتورة المبيعات: $e');
      return false;
    }
  }

  /// الحصول على جميع المبيعات
  Future<List<Sale>> getAllSales() async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, invoiceNumber, customerId, customerName,
               totalAmount, discount, paymentType, saleDate,
               notes, createdAt, updatedAt
        FROM Sales
        ORDER BY saleDate DESC
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Sale.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المبيعات: $e');
      return [];
    }
  }

  /// الحصول على مبيعات اليوم
  Future<List<Sale>> getTodaySales() async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, invoiceNumber, customerId, customerName,
               totalAmount, discount, paymentType, saleDate,
               notes, createdAt, updatedAt
        FROM Sales
        WHERE CONVERT(DATE, saleDate) = CONVERT(DATE, GETDATE())
        ORDER BY saleDate DESC
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Sale.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب مبيعات اليوم: $e');
      return [];
    }
  }

  /// الحصول على إجمالي مبيعات اليوم
  Future<double> getTodayTotalSales() async {
    try {
      final result = await _db.executeQuery('''
        SELECT ISNULL(SUM(totalAmount - discount), 0) as total
        FROM Sales
        WHERE CONVERT(DATE, saleDate) = CONVERT(DATE, GETDATE())
      ''');

      if (result == null || result.isEmpty) {
        return 0.0;
      }

      final List<dynamic> data = jsonDecode(result);
      return (data.first['total'] ?? 0.0).toDouble();
    } catch (e) {
      print('❌ خطأ في حساب إجمالي المبيعات: $e');
      return 0.0;
    }
  }

  /// الحصول على تقرير المبيعات بين تاريخين
  Future<List<Sale>> getSalesByDateRange(DateTime from, DateTime to) async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, invoiceNumber, customerId, customerName,
               totalAmount, discount, paymentType, saleDate,
               notes, createdAt, updatedAt
        FROM Sales
        WHERE saleDate BETWEEN '${from.toIso8601String()}' AND '${to.toIso8601String()}'
        ORDER BY saleDate DESC
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Sale.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب تقرير المبيعات: $e');
      return [];
    }
  }

  /// حذف فاتورة مبيعات
  Future<bool> deleteSale(int saleId) async {
    try {
      final query = '''
        DELETE FROM Sales WHERE id = $saleId
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في حذف فاتورة المبيعات: $e');
      return false;
    }
  }

  /// الحصول على إحصائيات المبيعات
  Future<Map<String, dynamic>> getSalesStatistics() async {
    try {
      final result = await _db.executeQuery('''
        SELECT 
          COUNT(*) as totalInvoices,
          SUM(totalAmount - discount) as totalRevenue,
          AVG(totalAmount - discount) as averageInvoice,
          MAX(totalAmount - discount) as maxInvoice
        FROM Sales
        WHERE CONVERT(DATE, saleDate) = CONVERT(DATE, GETDATE())
      ''');

      if (result == null || result.isEmpty) {
        return {};
      }

      final List<dynamic> data = jsonDecode(result);
      return data.first as Map<String, dynamic>;
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات المبيعات: $e');
      return {};
    }
  }
}
