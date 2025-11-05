import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/sale.dart';
import '../services/inventory_service.dart';
import '../utils/database_helper_stub.dart'
    if (dart.library.io) '../utils/database_helper.dart';

class SalesProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  bool _isLoading = false;
  String _searchQuery = '';

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

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Use demo data for web
        _sales = _getDemoSales();
      } else {
        final maps = await DatabaseHelper.instance.getAllSales();
        _sales = (maps)
            .cast<Map<String, dynamic>>()
            .map((map) => Sale.fromMap(map))
            .toList();
      }
      _filterSales();
    } catch (e) {
      debugPrint('Error loading sales: $e');
      // Fallback to demo data
      _sales = _getDemoSales();
      _filterSales();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      if (kIsWeb) {
        // Calculate demo stats
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final monthStart = DateTime(now.year, now.month, 1);

        final todaySalesList = _getDemoSales()
            .where((s) =>
                s.createdAt.isAfter(today) ||
                s.createdAt.isAtSameMomentAs(today))
            .toList();

        final monthSalesList = _getDemoSales()
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

          final daySales = _getDemoSales()
              .where((s) =>
                  s.createdAt.isAfter(dayStart) && s.createdAt.isBefore(dayEnd))
              .toList();

          return {
            'date': dayStart,
            'total': daySales.fold(0.0, (sum, s) => sum + s.finalAmount),
          };
        }).toList();
      } else {
        final stats = await DatabaseHelper.instance.getDashboardStats();
        _todaySales = stats['todaySales'];
        _monthSales = stats['monthSales'];
        _todayProfit = stats['todayProfit'];
        _monthProfit = stats['monthProfit'];
        _salesChart = stats['salesChart'];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      // Use default values
      _todaySales = 15750.0;
      _monthSales = 125500.0;
      _todayProfit = 3250.0;
      _monthProfit = 28500.0;
      _salesChart = _getDefaultChartData();
      notifyListeners();
    }
  }

  List<Sale> _getDemoSales() {
    // TODO: استبدل هذه الدالة بجلب البيانات من قاعدة البيانات
    // في النظام الحقيقي، يجب أن تجلب البيانات من قاعدة البيانات
    return [];
  }

  List<Map<String, dynamic>> _getDefaultChartData() {
    // TODO: استبدل هذه الدالة بجلب البيانات من قاعدة البيانات
    return [];
  }

  Future<void> addSale(Sale sale) async {
    try {
      if (!kIsWeb) {
        final id = await DatabaseHelper.instance.insertSale(sale);
        sale = Sale(
          id: id,
          invoiceNumber: sale.invoiceNumber,
          createdAt: sale.createdAt,
          customerId: sale.customerId,
          customerName: sale.customerName,
          items: sale.items,
          totalAmount: sale.totalAmount,
          discount: sale.discount,
          tax: sale.tax,
          finalAmount: sale.finalAmount,
          paymentMethod: sale.paymentMethod,
          paidAmount: sale.paidAmount,
          remainingAmount: sale.remainingAmount,
          status: sale.status,
          notes: sale.notes,
        );

        // ✅ تحديث المخزون - طرح الكميات المباعة
        for (var item in sale.items) {
          await _inventoryService.deductStockForSale(
            productId: item.productId,
            quantity: item.quantity.toDouble(),
            warehouseId: 1, // يمكنك تغيير هذا ليكون ديناميكي
          );
        }
      } else {
        final newId = _sales.isEmpty
            ? 1
            : _sales.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
        sale = Sale(
          id: newId,
          invoiceNumber: sale.invoiceNumber,
          createdAt: sale.createdAt,
          customerId: sale.customerId,
          customerName: sale.customerName,
          items: sale.items,
          totalAmount: sale.totalAmount,
          discount: sale.discount,
          tax: sale.tax,
          finalAmount: sale.finalAmount,
          paymentMethod: sale.paymentMethod,
          paidAmount: sale.paidAmount,
          remainingAmount: sale.remainingAmount,
          status: sale.status,
          notes: sale.notes,
        );
      }
      _sales.insert(0, sale); // Add to beginning
      _filterSales();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding sale: $e');
      rethrow;
    }
  }

  Future<void> updateSale(Sale sale) async {
    try {
      if (!kIsWeb) {
        // await DatabaseHelper.instance.updateSale(sale.toMap());
      }
      final index = _sales.indexWhere((s) => s.id == sale.id);
      if (index != -1) {
        _sales[index] = sale;
        _filterSales();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating sale: $e');
      rethrow;
    }
  }

  Future<void> deleteSale(int id) async {
    try {
      if (!kIsWeb) {
        // await DatabaseHelper.instance.deleteSale(id);
      }
      _sales.removeWhere((s) => s.id == id);
      _filterSales();
      notifyListeners();
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
