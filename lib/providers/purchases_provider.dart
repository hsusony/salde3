import 'package:flutter/foundation.dart';
import '../models/purchase.dart';
import '../models/purchase_return.dart';

class PurchasesProvider with ChangeNotifier {
  List<Purchase> _purchases = [];
  List<Purchase> _filteredPurchases = [];
  List<PurchaseReturn> _returns = [];
  List<PurchaseReturn> _filteredReturns = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Purchase> get purchases => _filteredPurchases;
  List<PurchaseReturn> get returns => _filteredReturns;
  bool get isLoading => _isLoading;

  PurchasesProvider() {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: جلب البيانات من قاعدة البيانات
      _purchases = [];
      _returns = [];
      _filterPurchases();
      _filterReturns();
    } catch (e) {
      debugPrint('Error loading purchases: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPurchase(Purchase purchase) async {
    try {
      // TODO: حفظ في قاعدة البيانات
      final newId = _purchases.isEmpty
          ? 1
          : _purchases.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) +
              1;
      final newPurchase = purchase.copyWith(id: newId);
      _purchases.insert(0, newPurchase);
      _filterPurchases();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding purchase: $e');
      rethrow;
    }
  }

  Future<void> updatePurchase(Purchase purchase) async {
    try {
      // TODO: تحديث في قاعدة البيانات
      final index = _purchases.indexWhere((p) => p.id == purchase.id);
      if (index != -1) {
        _purchases[index] = purchase.copyWith(updatedAt: DateTime.now());
        _filterPurchases();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating purchase: $e');
      rethrow;
    }
  }

  Future<void> deletePurchase(int id) async {
    try {
      // TODO: حذف من قاعدة البيانات
      _purchases.removeWhere((p) => p.id == id);
      _filterPurchases();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting purchase: $e');
      rethrow;
    }
  }

  Future<void> addReturn(PurchaseReturn returnItem) async {
    try {
      // TODO: حفظ في قاعدة البيانات
      final newId = _returns.isEmpty
          ? 1
          : _returns.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      final newReturn = returnItem.copyWith(id: newId);
      _returns.insert(0, newReturn);
      _filterReturns();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding return: $e');
      rethrow;
    }
  }

  Future<void> updateReturn(PurchaseReturn returnItem) async {
    try {
      // TODO: تحديث في قاعدة البيانات
      final index = _returns.indexWhere((r) => r.id == returnItem.id);
      if (index != -1) {
        _returns[index] = returnItem.copyWith(updatedAt: DateTime.now());
        _filterReturns();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating return: $e');
      rethrow;
    }
  }

  Future<void> deleteReturn(int id) async {
    try {
      // TODO: حذف من قاعدة البيانات
      _returns.removeWhere((r) => r.id == id);
      _filterReturns();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting return: $e');
      rethrow;
    }
  }

  void searchPurchases(String query) {
    _searchQuery = query;
    _filterPurchases();
    _filterReturns();
    notifyListeners();
  }

  void _filterPurchases() {
    if (_searchQuery.isEmpty) {
      _filteredPurchases = List.from(_purchases);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredPurchases = _purchases.where((purchase) {
        return purchase.invoiceNumber.toLowerCase().contains(lowerQuery) ||
            (purchase.supplierName?.toLowerCase().contains(lowerQuery) ??
                false);
      }).toList();
    }
  }

  void _filterReturns() {
    if (_searchQuery.isEmpty) {
      _filteredReturns = List.from(_returns);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredReturns = _returns.where((returnItem) {
        return returnItem.returnNumber.toLowerCase().contains(lowerQuery) ||
            (returnItem.supplierName?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (returnItem.purchaseInvoiceNumber
                    ?.toLowerCase()
                    .contains(lowerQuery) ??
                false);
      }).toList();
    }
  }

  // إحصائيات سريعة
  double get totalPurchasesAmount {
    return _purchases.fold(0, (sum, p) => sum + p.finalAmount);
  }

  double get totalReturnsAmount {
    return _returns.fold(0, (sum, r) => sum + r.totalAmount);
  }

  int get pendingPurchasesCount {
    return _purchases.where((p) => p.status == 'معلقة').length;
  }
}
