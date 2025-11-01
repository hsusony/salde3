import 'package:flutter/foundation.dart';
import '../models/installment.dart';

class InstallmentsProvider extends ChangeNotifier {
  List<Installment> _installments = [];
  List<InstallmentPayment> _payments = [];
  bool _isLoading = false;

  List<Installment> get installments => _installments;
  List<InstallmentPayment> get payments => _payments;
  List<InstallmentPayment> get allPayments => _payments;
  bool get isLoading => _isLoading;

  List<Installment> get activeInstallments =>
      _installments.where((i) => i.status == 'active').toList();

  List<Installment> get overdueInstallments =>
      _installments.where((i) => i.status == 'overdue').toList();

  List<Installment> get completedInstallments =>
      _installments.where((i) => i.status == 'completed').toList();

  InstallmentsProvider() {
    _loadDemoData();
  }

  void _loadDemoData() {
    // TODO: استبدل هذه الدالة بجلب البيانات من قاعدة البيانات
    // في النظام الحقيقي، يجب أن تجلب البيانات من قاعدة البيانات
    _installments = [];
    _payments = [];
    notifyListeners();
  }

  Future<void> loadInstallments() async {
    _isLoading = true;
    notifyListeners();

    // في التطبيق الفعلي، سيتم جلب البيانات من قاعدة البيانات
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addInstallment(Installment installment) async {
    final newInstallment = installment.copyWith(
      id: _installments.isEmpty ? 1 : _installments.map((e) => e.id!).reduce((a, b) => a > b ? a : b) + 1,
    );
    _installments.add(newInstallment);
    notifyListeners();
  }

  Future<void> updateInstallment(Installment installment) async {
    final index = _installments.indexWhere((i) => i.id == installment.id);
    if (index != -1) {
      _installments[index] = installment;
      notifyListeners();
    }
  }

  Future<void> deleteInstallment(int id) async {
    _installments.removeWhere((i) => i.id == id);
    _payments.removeWhere((p) => p.installmentId == id);
    notifyListeners();
  }

  Future<void> addPayment(InstallmentPayment payment) async {
    final newPayment = payment.copyWith(
      id: _payments.isEmpty ? 1 : _payments.map((e) => e.id!).reduce((a, b) => a > b ? a : b) + 1,
    );
    _payments.add(newPayment);

    // تحديث بيانات القسط
    final installmentIndex = _installments.indexWhere((i) => i.id == payment.installmentId);
    if (installmentIndex != -1) {
      final installment = _installments[installmentIndex];
      final newPaidAmount = installment.paidAmount + payment.amount;
      final newRemainingAmount = installment.totalAmount - newPaidAmount;
      final newPaidInstallments = installment.paidInstallments + 1;
      final newStatus = newRemainingAmount <= 0 ? 'completed' : 'active';

      _installments[installmentIndex] = installment.copyWith(
        paidAmount: newPaidAmount,
        remainingAmount: newRemainingAmount,
        paidInstallments: newPaidInstallments,
        status: newStatus,
      );
    }

    notifyListeners();
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
}

extension InstallmentPaymentCopyWith on InstallmentPayment {
  InstallmentPayment copyWith({
    int? id,
    int? installmentId,
    String? customerName,
    double? amount,
    String? paymentDate,
    int? installmentNumber,
    String? notes,
  }) {
    return InstallmentPayment(
      id: id ?? this.id,
      installmentId: installmentId ?? this.installmentId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      notes: notes ?? this.notes,
    );
  }
}
