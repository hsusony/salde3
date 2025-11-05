import '../models/installment.dart';
import '../utils/database_helper.dart';

class InstallmentsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== INSTALLMENTS CRUD ====================

  /// Add new installment to database
  Future<int> addInstallment(Installment installment) async {
    try {
      final data = {
        'customer_id': installment.customerId,
        'customer_name': installment.customerName,
        'total_amount': installment.totalAmount,
        'paid_amount': installment.paidAmount,
        'remaining_amount': installment.remainingAmount,
        'number_of_installments': installment.numberOfInstallments,
        'paid_installments': installment.paidInstallments,
        'installment_amount': installment.installmentAmount,
        'start_date': installment.startDate,
        'notes': installment.notes,
        'status': installment.status,
        'created_at': DateTime.now().toIso8601String(),
      };

      return await _dbHelper.insertInstallment(data);
    } catch (e) {
      throw Exception('خطأ في إضافة القسط: $e');
    }
  }

  /// Get all installments
  Future<List<Installment>> getAllInstallments() async {
    try {
      final data = await _dbHelper.getAllInstallments();
      return data.map((json) => Installment.fromMap(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الأقساط: $e');
    }
  }

  /// Get installment by ID
  Future<Installment?> getInstallmentById(int id) async {
    try {
      final data = await _dbHelper.getInstallmentById(id);
      if (data == null) return null;
      return Installment.fromMap(data);
    } catch (e) {
      throw Exception('خطأ في جلب القسط: $e');
    }
  }

  /// Get installments by customer ID
  Future<List<Installment>> getInstallmentsByCustomerId(int customerId) async {
    try {
      final data = await _dbHelper.getInstallmentsByCustomerId(customerId);
      return data.map((json) => Installment.fromMap(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب أقساط العميل: $e');
    }
  }

  /// Get installments by status (active, completed, overdue)
  Future<List<Installment>> getInstallmentsByStatus(String status) async {
    try {
      final data = await _dbHelper.getInstallmentsByStatus(status);
      return data.map((json) => Installment.fromMap(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الأقساط بالحالة: $e');
    }
  }

  /// Update installment
  Future<void> updateInstallment(Installment installment) async {
    try {
      if (installment.id == null) {
        throw Exception('معرف القسط مطلوب للتحديث');
      }

      final data = {
        'customer_id': installment.customerId,
        'customer_name': installment.customerName,
        'total_amount': installment.totalAmount,
        'paid_amount': installment.paidAmount,
        'remaining_amount': installment.remainingAmount,
        'number_of_installments': installment.numberOfInstallments,
        'paid_installments': installment.paidInstallments,
        'installment_amount': installment.installmentAmount,
        'start_date': installment.startDate,
        'notes': installment.notes,
        'status': installment.status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _dbHelper.updateInstallment(installment.id!, data);
    } catch (e) {
      throw Exception('خطأ في تحديث القسط: $e');
    }
  }

  /// Delete installment
  Future<void> deleteInstallment(int id) async {
    try {
      await _dbHelper.deleteInstallment(id);
    } catch (e) {
      throw Exception('خطأ في حذف القسط: $e');
    }
  }

  // ==================== INSTALLMENT PAYMENTS ====================

  /// Add payment for installment
  Future<int> addPayment(InstallmentPayment payment) async {
    try {
      final data = {
        'installment_id': payment.installmentId,
        'customer_name': payment.customerName,
        'amount': payment.amount,
        'payment_date': payment.paymentDate,
        'installment_number': payment.installmentNumber,
        'notes': payment.notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      return await _dbHelper.insertInstallmentPayment(data);
    } catch (e) {
      throw Exception('خطأ في إضافة الدفعة: $e');
    }
  }

  /// Get all payments for a specific installment
  Future<List<InstallmentPayment>> getPaymentsByInstallmentId(
      int installmentId) async {
    try {
      final data = await _dbHelper.getInstallmentPayments(installmentId);
      return data.map((json) => InstallmentPayment.fromMap(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب دفعات القسط: $e');
    }
  }

  /// Get all payments
  Future<List<InstallmentPayment>> getAllPayments() async {
    try {
      final data = await _dbHelper.getAllInstallmentPayments();
      return data.map((json) => InstallmentPayment.fromMap(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الدفعات: $e');
    }
  }

  /// Delete payment
  Future<void> deletePayment(int id) async {
    try {
      await _dbHelper.deleteInstallmentPayment(id);
    } catch (e) {
      throw Exception('خطأ في حذف الدفعة: $e');
    }
  }

  // ==================== STATISTICS ====================

  /// Get installment statistics
  Future<Map<String, dynamic>> getInstallmentStats() async {
    try {
      return await _dbHelper.getInstallmentStats();
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات الأقساط: $e');
    }
  }

  /// Get active installments
  Future<List<Installment>> getActiveInstallments() async {
    return await getInstallmentsByStatus('active');
  }

  /// Get overdue installments
  Future<List<Installment>> getOverdueInstallments() async {
    return await getInstallmentsByStatus('overdue');
  }

  /// Get completed installments
  Future<List<Installment>> getCompletedInstallments() async {
    return await getInstallmentsByStatus('completed');
  }

  /// Get total active amount
  Future<double> getTotalActiveAmount() async {
    try {
      final stats = await getInstallmentStats();
      return stats['activeTotalAmount'] ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get total overdue amount
  Future<double> getTotalOverdueAmount() async {
    try {
      final stats = await getInstallmentStats();
      return stats['overdueTotalAmount'] ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get active installments count
  Future<int> getActiveInstallmentsCount() async {
    try {
      final stats = await getInstallmentStats();
      return stats['activeCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
