import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/purchase.dart';
import '../models/purchase_return.dart';

class PurchasesProvider with ChangeNotifier {
  List<Purchase> _purchases = [];
  List<Purchase> _filteredPurchases = [];
  List<PurchaseReturn> _returns = [];
  List<PurchaseReturn> _filteredReturns = [];
  bool _isLoading = false;
  String _searchQuery = '';

  static const String baseUrl = 'http://localhost:3000/api';

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
      final response = await http.get(Uri.parse('$baseUrl/purchases'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _purchases = data.map((json) => Purchase.fromMap(json)).toList();
      } else {
        throw Exception('فشل تحميل المشتريات');
      }

      // TODO: Load returns from API when endpoint is ready
      _returns = [];

      _filterPurchases();
      _filterReturns();
    } catch (e) {
      debugPrint('Error loading purchases: $e');
      _purchases = [];
      _returns = [];
      _filterPurchases();
      _filterReturns();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPurchase(Purchase purchase) async {
    try {
      final purchaseData = {
        'InvoiceNumber': purchase.invoiceNumber,
        'PurchaseDate': purchase.createdAt.toIso8601String(),
        'SupplierId': purchase.supplierId,
        'TotalAmount': purchase.totalAmount,
        'Discount': purchase.discount,
        'Tax': purchase.tax,
        'FinalAmount': purchase.finalAmount,
        'PaidAmount': purchase.paidAmount,
        'RemainingAmount': purchase.remainingAmount,
        'PaymentMethod': purchase.paymentMethod,
        'Status': purchase.status,
        'Notes': purchase.notes,
        'Items': purchase.items
            .map((item) => {
                  'ProductId': item.productId,
                  'Quantity': item.quantity,
                  'UnitPrice': item.unitPrice,
                  'TotalPrice': item.totalPrice,
                })
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/purchases'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(purchaseData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final newPurchase = purchase.copyWith(id: data['id']);
        _purchases.insert(0, newPurchase);
        _filterPurchases();
        notifyListeners();
      } else {
        throw Exception('فشل إضافة المشتريات');
      }
    } catch (e) {
      debugPrint('Error adding purchase: $e');
      rethrow;
    }
  }

  Future<void> updatePurchase(Purchase purchase) async {
    try {
      final purchaseData = {
        'InvoiceNumber': purchase.invoiceNumber,
        'PurchaseDate': purchase.createdAt.toIso8601String(),
        'SupplierId': purchase.supplierId,
        'TotalAmount': purchase.totalAmount,
        'Discount': purchase.discount,
        'Tax': purchase.tax,
        'FinalAmount': purchase.finalAmount,
        'PaidAmount': purchase.paidAmount,
        'RemainingAmount': purchase.remainingAmount,
        'PaymentMethod': purchase.paymentMethod,
        'Status': purchase.status,
        'Notes': purchase.notes,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/purchases/${purchase.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(purchaseData),
      );

      if (response.statusCode == 200) {
        final index = _purchases.indexWhere((p) => p.id == purchase.id);
        if (index != -1) {
          _purchases[index] = purchase.copyWith(updatedAt: DateTime.now());
          _filterPurchases();
          notifyListeners();
        }
      } else {
        throw Exception('فشل تحديث المشتريات');
      }
    } catch (e) {
      debugPrint('Error updating purchase: $e');
      rethrow;
    }
  }

  Future<void> deletePurchase(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/purchases/$id'),
      );

      if (response.statusCode == 200) {
        _purchases.removeWhere((p) => p.id == id);
        _filterPurchases();
        notifyListeners();
      } else {
        throw Exception('فشل حذف المشتريات');
      }
    } catch (e) {
      debugPrint('Error deleting purchase: $e');
      rethrow;
    }
  }

  Future<void> addReturn(PurchaseReturn returnItem) async {
    try {
      // TODO: Implement purchase returns API endpoint
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
      // TODO: Implement purchase returns API endpoint
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
      // TODO: Implement purchase returns API endpoint
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
