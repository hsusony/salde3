import 'package:flutter/foundation.dart';
import '../models/installment.dart';
import '../repositories/installments_repository.dart';

class InstallmentsProvider extends ChangeNotifier {
  final InstallmentsRepository _repository = InstallmentsRepository();

  List<Installment> _installments = [];
  List<InstallmentPayment> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<Installment> get installments => _installments;
  List<InstallmentPayment> get payments => _payments;
  List<InstallmentPayment> get allPayments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Installment> get activeInstallments =>
      _installments.where((i) => i.status == 'active').toList();

  List<Installment> get overdueInstallments =>
      _installments.where((i) => i.status == 'overdue').toList();

  List<Installment> get completedInstallments =>
      _installments.where((i) => i.status == 'completed').toList();

  InstallmentsProvider() {
    loadInstallments();
  }

  Future<void> loadInstallments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _installments = await _repository.getAllInstallments();
      _payments = await _repository.getAllPayments();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading installments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInstallment(Installment installment) async {
    try {
      final id = await _repository.addInstallment(installment);
      final newInstallment = installment.copyWith(id: id);
      _installments.add(newInstallment);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding installment: $e');
      rethrow;
    }
  }

  Future<void> updateInstallment(Installment installment) async {
    try {
      await _repository.updateInstallment(installment);
      final index = _installments.indexWhere((i) => i.id == installment.id);
      if (index != -1) {
        _installments[index] = installment;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating installment: $e');
      rethrow;
    }
  }

  Future<void> deleteInstallment(int id) async {
    try {
      await _repository.deleteInstallment(id);
      _installments.removeWhere((i) => i.id == id);
      _payments.removeWhere((p) => p.installmentId == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting installment: $e');
      rethrow;
    }
  }

  Future<void> addPayment(InstallmentPayment payment) async {
    try {
      final id = await _repository.addPayment(payment);
      final newPayment = payment.copyWith(id: id);
      _payments.add(newPayment);

      // Reload installment to get updated data
      final installmentIndex =
          _installments.indexWhere((i) => i.id == payment.installmentId);
      if (installmentIndex != -1) {
        final updatedInstallment =
            await _repository.getInstallmentById(payment.installmentId);
        if (updatedInstallment != null) {
          _installments[installmentIndex] = updatedInstallment;
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding payment: $e');
      rethrow;
    }
  }

  List<InstallmentPayment> getPaymentsByInstallmentId(int installmentId) {
    return _payments.where((p) => p.installmentId == installmentId).toList();
  }

  double getTotalActiveInstallments() {
    return _installments
        .where((i) => i.status == 'active')
        .fold(0, (sum, i) => sum + i.remainingAmount);
  }

  double getTotalOverdueAmount() {
    return _installments
        .where((i) => i.status == 'overdue')
        .fold(0, (sum, i) => sum + i.remainingAmount);
  }

  int getActiveInstallmentsCount() {
    return _installments.where((i) => i.status == 'active').length;
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _repository.getInstallmentStats();
    } catch (e) {
      debugPrint('Error getting installment stats: $e');
      return {
        'activeTotalAmount': 0.0,
        'overdueTotalAmount': 0.0,
        'activeCount': 0,
        'overdueCount': 0,
        'monthPayments': 0.0,
      };
    }
  }
}
