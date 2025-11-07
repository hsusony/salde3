import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sale.dart';

class SalesProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  bool _isLoading = false;
  String _searchQuery = '';
  DateTime? _lastLoadTime;
  static const cacheDuration =
      Duration(minutes: 2); // Cache أقصر للمبيعات (بيانات تتغير بسرعة)

  static const String baseUrl = 'http://localhost:3000/api';

  // Dashboard stats
  double _todaySales = 0.0;
  double _monthSales = 0.0;
  double _todayProfit = 0.0;
  double _monthProfit = 0.0;
  List<Map<String, dynamic>> _salesChart = [];

  List<Sale> get sales => _filteredSales;
  bool get isLoading => _isLoading;
  double get todaySales => _todaySales;
  double get monthSales => _monthSales;
  double get todayProfit => _todayProfit;
  double get monthProfit => _monthProfit;
  List<Map<String, dynamic>> get salesChart => _salesChart;

  Map<String, dynamic> get dashboardStats => {
        'todaySales': _todaySales,
        'monthSales': _monthSales,
        'todayProfit': _todayProfit,
        'monthProfit': _monthProfit,
        'salesChart': _salesChart,
      };

  Future<void> loadSales({bool forceRefresh = false}) async {
    // استخدام الـ cache إذا كانت البيانات حديثة
    if (!forceRefresh &&
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < cacheDuration &&
        _sales.isNotEmpty) {
      debugPrint('📦 Using cached sales data');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/sales'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _sales = data.map((json) => Sale.fromMap(json)).toList();
        _lastLoadTime = DateTime.now(); // تحديث وقت آخر تحميل
      } else {
        throw Exception('فشل تحميل المبيعات');
      }
      _filterSales();
    } catch (e) {
      debugPrint('Error loading sales: $e');
      _sales = [];
      _filterSales();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      // For now, calculate from loaded sales
      // TODO: Create dedicated dashboard stats endpoint in backend
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final todaySalesList = _sales
          .where((s) =>
              s.createdAt.isAfter(today) || s.createdAt.isAtSameMomentAs(today))
          .toList();

      final monthSalesList = _sales
          .where((s) =>
              s.createdAt.isAfter(monthStart) ||
              s.createdAt.isAtSameMomentAs(monthStart))
          .toList();

      _todaySales = todaySalesList.fold(0.0, (sum, s) => sum + s.finalAmount);
      _monthSales = monthSalesList.fold(0.0, (sum, s) => sum + s.finalAmount);
      _todayProfit = todaySalesList.fold(
          0.0, (sum, s) => sum + (s.finalAmount - s.discount));
      _monthProfit = monthSalesList.fold(
          0.0, (sum, s) => sum + (s.finalAmount - s.discount));

      // Generate chart data for last 7 days
      _salesChart = List.generate(7, (index) {
        final day = now.subtract(Duration(days: 6 - index));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final daySales = _sales
            .where((s) =>
                s.createdAt.isAfter(dayStart) && s.createdAt.isBefore(dayEnd))
            .toList();

        return {
          'date': dayStart,
          'total': daySales.fold(0.0, (sum, s) => sum + s.finalAmount),
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      // Use default values
      _todaySales = 0.0;
      _monthSales = 0.0;
      _todayProfit = 0.0;
      _monthProfit = 0.0;
      _salesChart = [];
      notifyListeners();
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      final saleData = {
        'InvoiceNumber': sale.invoiceNumber,
        'SaleDate': sale.createdAt.toIso8601String(),
        'CustomerID': sale.customerId,
        'TotalAmount': sale.totalAmount,
        'Discount': sale.discount,
        'Tax': sale.tax,
        'FinalAmount': sale.finalAmount,
        'PaymentMethod': sale.paymentMethod,
        'PaidAmount': sale.paidAmount,
        'RemainingAmount': sale.remainingAmount,
        'Status': sale.status,
        'Notes': sale.notes,
        'Items': sale.items
            .map((item) => {
                  'ProductID': item.productId,
                  'Quantity': item.quantity,
                  'UnitPrice': item.unitPrice,
                  'Discount': item.discount ?? 0,
                  'TotalPrice': item.totalPrice,
                })
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(saleData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        sale = sale.copyWith(id: data['id']);
        _sales.insert(0, sale);
        _filterSales();
        notifyListeners();
      } else {
        throw Exception('فشل إضافة البيع');
      }
    } catch (e) {
      debugPrint('Error adding sale: $e');
      rethrow;
    }
  }

  Future<void> updateSale(Sale sale) async {
    try {
      final saleData = {
        'InvoiceNumber': sale.invoiceNumber,
        'SaleDate': sale.createdAt.toIso8601String(),
        'CustomerID': sale.customerId,
        'TotalAmount': sale.totalAmount,
        'Discount': sale.discount,
        'Tax': sale.tax,
        'FinalAmount': sale.finalAmount,
        'PaymentMethod': sale.paymentMethod,
        'PaidAmount': sale.paidAmount,
        'RemainingAmount': sale.remainingAmount,
        'Status': sale.status,
        'Notes': sale.notes,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/sales/${sale.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(saleData),
      );

      if (response.statusCode == 200) {
        final index = _sales.indexWhere((s) => s.id == sale.id);
        if (index != -1) {
          _sales[index] = sale;
          _filterSales();
          notifyListeners();
        }
      } else {
        throw Exception('فشل تحديث البيع');
      }
    } catch (e) {
      debugPrint('Error updating sale: $e');
      rethrow;
    }
  }

  Future<void> deleteSale(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sales/$id'),
      );

      if (response.statusCode == 200) {
        _sales.removeWhere((s) => s.id == id);
        _filterSales();
        notifyListeners();
      } else {
        throw Exception('فشل حذف البيع');
      }
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      rethrow;
    }
  }

  void searchSales(String query) {
    _searchQuery = query;
    _filterSales();
    notifyListeners();
  }

  void _filterSales() {
    if (_searchQuery.isEmpty) {
      _filteredSales = List.from(_sales);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredSales = _sales.where((sale) {
        return sale.invoiceNumber.toLowerCase().contains(lowerQuery) ||
            (sale.customerName?.toLowerCase().contains(lowerQuery) ?? false) ||
            sale.paymentMethod.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }
}
