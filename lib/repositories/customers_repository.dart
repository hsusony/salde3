/// ========================================
/// مستودع العملاء - Repository Pattern
/// Customers Repository
/// ========================================
/// ⚠️ ملف معطل مؤقتاً - يتطلب إصلاح النموذج والاتصال بقاعدة البيانات
/// TODO: إعادة بناء هذا الملف بعد تفعيل الاتصال بـ SQL Server

/*
import 'dart:convert';
import '../config/database_config.dart';
import '../models/customer.dart';

class CustomersRepository {

  /// الحصول على جميع العملاء
  Future<List<Customer>> getAllCustomers() async {
    try {
      final result = await DatabaseConfig.executeQuery('''
        SELECT id, name, phone, email, address, balance, 
               isActive, notes, createdAt, updatedAt
        FROM Customers
        WHERE isActive = 1
        ORDER BY name
      ''');

      if (result.isEmpty) {
        return [];
      }

      return result.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب العملاء: $e');
      return [];
    }
  }

  /// البحث عن عميل بالاسم أو الهاتف
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, phone, email, address, balance,
               isActive, notes, createdAt, updatedAt
        FROM Customers
        WHERE (name LIKE '%$query%' OR phone LIKE '%$query%') 
          AND isActive = 1
        ORDER BY name
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في البحث: $e');
      return [];
    }
  }

  /// الحصول على عميل بالمعرف
  Future<Customer?> getCustomerById(int id) async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, phone, email, address, balance,
               isActive, notes, createdAt, updatedAt
        FROM Customers
        WHERE id = $id
      ''');

      if (result == null || result.isEmpty || result == '[]') {
        return null;
      }

      final List<dynamic> data = jsonDecode(result);
      if (data.isEmpty) return null;

      return Customer.fromJson(data.first);
    } catch (e) {
      print('❌ خطأ في جلب العميل: $e');
      return null;
    }
  }

  /// إضافة عميل جديد
  Future<bool> addCustomer(Customer customer) async {
    try {
      final query = '''
        INSERT INTO Customers 
        (name, phone, email, address, balance, isActive, notes, createdAt, updatedAt)
        VALUES 
        (N'${customer.name}',
         '${customer.phone ?? ''}',
         '${customer.email ?? ''}',
         N'${customer.address ?? ''}',
         ${customer.balance},
         ${customer.isActive ? 1 : 0},
         N'${customer.notes ?? ''}',
         GETDATE(),
         GETDATE())
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في إضافة العميل: $e');
      return false;
    }
  }

  /// تحديث عميل
  Future<bool> updateCustomer(Customer customer) async {
    try {
      final query = '''
        UPDATE Customers SET
          name = N'${customer.name}',
          phone = '${customer.phone ?? ''}',
          email = '${customer.email ?? ''}',
          address = N'${customer.address ?? ''}',
          balance = ${customer.balance},
          isActive = ${customer.isActive ? 1 : 0},
          notes = N'${customer.notes ?? ''}',
          updatedAt = GETDATE()
        WHERE id = ${customer.id}
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في تحديث العميل: $e');
      return false;
    }
  }

  /// حذف عميل (soft delete)
  Future<bool> deleteCustomer(int id) async {
    try {
      final query = '''
        UPDATE Customers 
        SET isActive = 0, updatedAt = GETDATE()
        WHERE id = $id
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في حذف العميل: $e');
      return false;
    }
  }

  /// تحديث رصيد عميل
  Future<bool> updateCustomerBalance(int customerId, double newBalance) async {
    try {
      final query = '''
        UPDATE Customers 
        SET balance = $newBalance, updatedAt = GETDATE()
        WHERE id = $customerId
      ''';

      return await _db.executeNonQuery(query);
    } catch (e) {
      print('❌ خطأ في تحديث الرصيد: $e');
      return false;
    }
  }

  /// الحصول على العملاء المدينين
  Future<List<Customer>> getCustomersWithDebt() async {
    try {
      final result = await _db.executeQuery('''
        SELECT id, name, phone, email, address, balance,
               isActive, notes, createdAt, updatedAt
        FROM Customers
        WHERE balance > 0 AND isActive = 1
        ORDER BY balance DESC
      ''');

      if (result == null || result.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(result);
      return data.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('❌ خطأ في جلب العملاء المدينين: $e');
      return [];
    }
  }

  /// الحصول على إحصائيات العملاء
  Future<Map<String, dynamic>> getCustomerStatistics() async {
    try {
      final result = await _db.executeQuery('''
        SELECT 
          COUNT(*) as totalCustomers,
          SUM(CASE WHEN balance > 0 THEN 1 ELSE 0 END) as customersWithDebt,
          SUM(balance) as totalDebt,
          AVG(balance) as averageBalance
        FROM Customers
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
