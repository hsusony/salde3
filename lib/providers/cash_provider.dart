import 'package:flutter/foundation.dart';
import '../models/cash_voucher.dart';
import '../models/payment_voucher.dart';
import '../models/transfer_voucher.dart';
import '../models/journal_entry.dart';
import '../services/database_helper.dart';

class CashProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Receipt Vouchers
  List<ReceiptVoucher> _receiptVouchers = [];
  List<MultipleReceiptVoucher> _multipleReceiptVouchers = [];
  List<DualCurrencyReceipt> _dualCurrencyReceipts = [];

  // Payment Vouchers
  final List<PaymentVoucher> _paymentVouchers = [];
  final List<MultiplePaymentVoucher> _multiplePaymentVouchers = [];
  final List<DualCurrencyPayment> _dualCurrencyPayments = [];
  final List<DisbursementVoucher> _disbursementVouchers = [];

  // Transfer Vouchers
  final List<TransferVoucher> _transferVouchers = [];
  final List<RemittanceVoucher> _remittanceVouchers = [];
  final List<ExchangeVoucher> _exchangeVouchers = [];
  final List<ProfitDistributionVoucher> _profitDistributions = [];

  // Journal Entries
  final List<JournalEntry> _journalEntries = [];
  final List<MultipleJournalEntry> _multipleJournalEntries = [];
  final List<CompoundJournalEntry> _compoundJournalEntries = [];

  // Getters
  List<ReceiptVoucher> get receiptVouchers => [..._receiptVouchers];
  List<MultipleReceiptVoucher> get multipleReceiptVouchers =>
      [..._multipleReceiptVouchers];
  List<DualCurrencyReceipt> get dualCurrencyReceipts =>
      [..._dualCurrencyReceipts];

  List<PaymentVoucher> get paymentVouchers => [..._paymentVouchers];
  List<MultiplePaymentVoucher> get multiplePaymentVouchers =>
      [..._multiplePaymentVouchers];
  List<DualCurrencyPayment> get dualCurrencyPayments =>
      [..._dualCurrencyPayments];
  List<DisbursementVoucher> get disbursementVouchers =>
      [..._disbursementVouchers];

  List<TransferVoucher> get transferVouchers => [..._transferVouchers];
  List<RemittanceVoucher> get remittanceVouchers => [..._remittanceVouchers];
  List<ExchangeVoucher> get exchangeVouchers => [..._exchangeVouchers];
  List<ProfitDistributionVoucher> get profitDistributions =>
      [..._profitDistributions];

  List<JournalEntry> get journalEntries => [..._journalEntries];
  List<MultipleJournalEntry> get multipleJournalEntries =>
      [..._multipleJournalEntries];
  List<CompoundJournalEntry> get compoundJournalEntries =>
      [..._compoundJournalEntries];

  // Initialize and load data from database
  Future<void> loadData() async {
    try {
      print('🔄 بدء تحميل البيانات من قاعدة البيانات SQLite...');
      _receiptVouchers =
          (await _db.getAllReceiptVouchers()).cast<ReceiptVoucher>();
      print('📥 تم تحميل ${_receiptVouchers.length} سند قبض من قاعدة البيانات');

      _multipleReceiptVouchers = (await _db.getAllMultipleReceiptVouchers())
          .cast<MultipleReceiptVoucher>();
      print('📥 تم تحميل ${_multipleReceiptVouchers.length} سند قبض متعدد');

      _dualCurrencyReceipts =
          (await _db.getAllDualCurrencyReceipts()).cast<DualCurrencyReceipt>();
      print('📥 تم تحميل ${_dualCurrencyReceipts.length} سند قبض بالعملتين');

      notifyListeners();
      print('✅ اكتمل تحميل جميع البيانات من SQLite بنجاح!');
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');
    }
  }

  // Statistics
  double get totalReceipts {
    double total = 0;
    total += _receiptVouchers.fold(0, (sum, v) => sum + v.amount);
    total += _multipleReceiptVouchers.fold(0, (sum, v) => sum + v.totalAmount);
    total += _dualCurrencyReceipts.fold(0, (sum, v) => sum + v.amountIQD);
    return total;
  }

  double get totalPayments {
    double total = 0;
    total += _paymentVouchers.fold(0, (sum, v) => sum + v.amount);
    total += _multiplePaymentVouchers.fold(0, (sum, v) => sum + v.totalAmount);
    total += _dualCurrencyPayments.fold(0, (sum, v) => sum + v.amountIQD);
    total += _disbursementVouchers.fold(0, (sum, v) => sum + v.amount);
    return total;
  }

  double get netCashFlow => totalReceipts - totalPayments;

  // Receipt Voucher CRUD
  Future<void> addReceiptVoucher(ReceiptVoucher voucher) async {
    try {
      await _db.insertReceiptVoucher(voucher);
      _receiptVouchers.add(voucher);
      notifyListeners();
      print('✅ Receipt voucher added: ${voucher.voucherNumber}');
    } catch (e) {
      print('❌ Error adding receipt voucher: $e');
      rethrow;
    }
  }

  Future<void> updateReceiptVoucher(ReceiptVoucher voucher) async {
    try {
      await _db.updateReceiptVoucher(voucher);
      final index = _receiptVouchers.indexWhere((v) => v.id == voucher.id);
      if (index != -1) {
        _receiptVouchers[index] = voucher;
        notifyListeners();
        print('✅ Receipt voucher updated: ${voucher.voucherNumber}');
      }
    } catch (e) {
      print('❌ Error updating receipt voucher: $e');
      rethrow;
    }
  }

  Future<void> deleteReceiptVoucher(String id) async {
    try {
      await _db.deleteReceiptVoucher(id);
      _receiptVouchers.removeWhere((v) => v.id == id);
      notifyListeners();
      print('✅ Receipt voucher deleted: $id');
    } catch (e) {
      print('❌ Error deleting receipt voucher: $e');
      rethrow;
    }
  }

  // Multiple Receipt Voucher CRUD
  Future<void> addMultipleReceiptVoucher(MultipleReceiptVoucher voucher) async {
    try {
      await _db.insertMultipleReceiptVoucher(voucher);
      _multipleReceiptVouchers.add(voucher);
      notifyListeners();
      print('✅ Multiple receipt voucher added: ${voucher.voucherNumber}');
    } catch (e) {
      print('❌ Error adding multiple receipt voucher: $e');
      rethrow;
    }
  }

  Future<void> updateMultipleReceiptVoucher(
      MultipleReceiptVoucher voucher) async {
    try {
      final index =
          _multipleReceiptVouchers.indexWhere((v) => v.id == voucher.id);
      if (index != -1) {
        _multipleReceiptVouchers[index] = voucher;
        notifyListeners();
        print('✅ Multiple receipt voucher updated: ${voucher.voucherNumber}');
      }
    } catch (e) {
      print('❌ Error updating multiple receipt voucher: $e');
      rethrow;
    }
  }

  Future<void> deleteMultipleReceiptVoucher(String id) async {
    try {
      await _db.deleteMultipleReceiptVoucher(id);
      _multipleReceiptVouchers.removeWhere((v) => v.id == id);
      notifyListeners();
      print('✅ Multiple receipt voucher deleted: $id');
    } catch (e) {
      print('❌ Error deleting multiple receipt voucher: $e');
      rethrow;
    }
  }

  // Dual Currency Receipt CRUD
  Future<void> addDualCurrencyReceipt(DualCurrencyReceipt voucher) async {
    try {
      await _db.insertDualCurrencyReceipt(voucher);
      _dualCurrencyReceipts.add(voucher);
      notifyListeners();
      print('✅ Dual currency receipt added: ${voucher.voucherNumber}');
    } catch (e) {
      print('❌ Error adding dual currency receipt: $e');
      rethrow;
    }
  }

  Future<void> updateDualCurrencyReceipt(DualCurrencyReceipt voucher) async {
    try {
      final index = _dualCurrencyReceipts.indexWhere((v) => v.id == voucher.id);
      if (index != -1) {
        _dualCurrencyReceipts[index] = voucher;
        notifyListeners();
        print('✅ Dual currency receipt updated: ${voucher.voucherNumber}');
      }
    } catch (e) {
      print('❌ Error updating dual currency receipt: $e');
      rethrow;
    }
  }

  Future<void> deleteDualCurrencyReceipt(String id) async {
    try {
      await _db.deleteDualCurrencyReceipt(id);
      _dualCurrencyReceipts.removeWhere((v) => v.id == id);
      notifyListeners();
      print('✅ Dual currency receipt deleted: $id');
    } catch (e) {
      print('❌ Error deleting dual currency receipt: $e');
      rethrow;
    }
  }

  // Payment Voucher CRUD
  Future<void> addPaymentVoucher(PaymentVoucher voucher) async {
    _paymentVouchers.add(voucher);
    notifyListeners();
  }

  Future<void> updatePaymentVoucher(PaymentVoucher voucher) async {
    final index = _paymentVouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _paymentVouchers[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deletePaymentVoucher(String id) async {
    _paymentVouchers.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Multiple Payment Voucher CRUD
  Future<void> addMultiplePaymentVoucher(MultiplePaymentVoucher voucher) async {
    _multiplePaymentVouchers.add(voucher);
    notifyListeners();
  }

  Future<void> updateMultiplePaymentVoucher(
      MultiplePaymentVoucher voucher) async {
    final index =
        _multiplePaymentVouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _multiplePaymentVouchers[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteMultiplePaymentVoucher(String id) async {
    _multiplePaymentVouchers.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Dual Currency Payment CRUD
  Future<void> addDualCurrencyPayment(DualCurrencyPayment voucher) async {
    _dualCurrencyPayments.add(voucher);
    notifyListeners();
  }

  Future<void> updateDualCurrencyPayment(DualCurrencyPayment voucher) async {
    final index = _dualCurrencyPayments.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _dualCurrencyPayments[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteDualCurrencyPayment(String id) async {
    _dualCurrencyPayments.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Disbursement Voucher CRUD
  Future<void> addDisbursementVoucher(DisbursementVoucher voucher) async {
    _disbursementVouchers.add(voucher);
    notifyListeners();
  }

  Future<void> updateDisbursementVoucher(DisbursementVoucher voucher) async {
    final index = _disbursementVouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _disbursementVouchers[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteDisbursementVoucher(String id) async {
    _disbursementVouchers.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Transfer Voucher CRUD
  Future<void> addTransferVoucher(TransferVoucher voucher) async {
    _transferVouchers.add(voucher);
    notifyListeners();
  }

  Future<void> updateTransferVoucher(TransferVoucher voucher) async {
    final index = _transferVouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _transferVouchers[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteTransferVoucher(String id) async {
    _transferVouchers.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Remittance Voucher CRUD
  Future<void> addRemittanceVoucher(RemittanceVoucher voucher) async {
    _remittanceVouchers.add(voucher);
    notifyListeners();
  }

  Future<void> updateRemittanceVoucher(RemittanceVoucher voucher) async {
    final index = _remittanceVouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _remittanceVouchers[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteRemittanceVoucher(String id) async {
    _remittanceVouchers.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Exchange Voucher CRUD
  Future<void> addExchangeVoucher(ExchangeVoucher voucher) async {
    _exchangeVouchers.add(voucher);
    notifyListeners();
  }

  Future<void> updateExchangeVoucher(ExchangeVoucher voucher) async {
    final index = _exchangeVouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _exchangeVouchers[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteExchangeVoucher(String id) async {
    _exchangeVouchers.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Profit Distribution CRUD
  Future<void> addProfitDistribution(ProfitDistributionVoucher voucher) async {
    _profitDistributions.add(voucher);
    notifyListeners();
  }

  Future<void> updateProfitDistribution(
      ProfitDistributionVoucher voucher) async {
    final index = _profitDistributions.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _profitDistributions[index] = voucher;
      notifyListeners();
    }
  }

  Future<void> deleteProfitDistribution(String id) async {
    _profitDistributions.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Journal Entry CRUD
  Future<void> addJournalEntry(JournalEntry entry) async {
    _journalEntries.add(entry);
    notifyListeners();
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    final index = _journalEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _journalEntries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    _journalEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Multiple Journal Entry CRUD
  Future<void> addMultipleJournalEntry(MultipleJournalEntry entry) async {
    _multipleJournalEntries.add(entry);
    notifyListeners();
  }

  Future<void> updateMultipleJournalEntry(MultipleJournalEntry entry) async {
    final index = _multipleJournalEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _multipleJournalEntries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> deleteMultipleJournalEntry(String id) async {
    _multipleJournalEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Compound Journal Entry CRUD
  Future<void> addCompoundJournalEntry(CompoundJournalEntry entry) async {
    _compoundJournalEntries.add(entry);
    notifyListeners();
  }

  Future<void> updateCompoundJournalEntry(CompoundJournalEntry entry) async {
    final index = _compoundJournalEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _compoundJournalEntries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> deleteCompoundJournalEntry(String id) async {
    _compoundJournalEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
