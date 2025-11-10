import 'package:flutter/foundation.dart';

import '../models/warehouse.dart';
import '../models/packaging.dart';
import '../models/inventory_transaction.dart';
// import '../models/warehouse_stock.dart'; // معطل مؤقتاً
import '../services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();

  List<Warehouse> _warehouses = [];
  List<Packaging> _packaging = [];
  List<InventoryTransaction> _transactions = [];
  List<Map<String, dynamic>> _stockWithDetails = [];
  bool _isLoading = false;

  List<Warehouse> get warehouses => _warehouses;
  List<Packaging> get packaging => _packaging;
  List<InventoryTransaction> get transactions => _transactions;
  List<Map<String, dynamic>> get stockWithDetails => _stockWithDetails;
  bool get isLoading => _isLoading;

  // ===================== WAREHOUSES =====================

  Future<void> loadWarehouses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _warehouses = await _inventoryService.getAllWarehouses();
    } catch (e) {
      print('Error loading warehouses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWarehouse(Warehouse warehouse) async {
    try {
      await _inventoryService.addWarehouse(warehouse);
      await loadWarehouses();
      return true;
    } catch (e) {
      print('Error adding warehouse: $e');
      return false;
    }
  }

  Future<bool> updateWarehouse(Warehouse warehouse) async {
    try {
      await _inventoryService.updateWarehouse(warehouse);
      await loadWarehouses();
      return true;
    } catch (e) {
      print('Error updating warehouse: $e');
      return false;
    }
  }

  Future<bool> deleteWarehouse(int id) async {
    try {
      await _inventoryService.deleteWarehouse(id);
      await loadWarehouses();
      return true;
    } catch (e) {
      print('Error deleting warehouse: $e');
      return false;
    }
  }

  // ===================== PACKAGING =====================

  Future<void> loadPackaging() async {
    _isLoading = true;
    notifyListeners();
    try {
      _packaging = await _inventoryService.getAllPackaging();
    } catch (e) {
      print('Error loading packaging: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPackaging(Packaging packaging) async {
    try {
      await _inventoryService.addPackaging(packaging);
      await loadPackaging();
      return true;
    } catch (e) {
      print('Error adding packaging: $e');
      return false;
    }
  }

  Future<bool> updatePackaging(Packaging packaging) async {
    try {
      await _inventoryService.updatePackaging(packaging);
      await loadPackaging();
      return true;
    } catch (e) {
      print('Error updating packaging: $e');
      return false;
    }
  }

  Future<bool> deletePackaging(int id) async {
    try {
      await _inventoryService.deletePackaging(id);
      await loadPackaging();
      return true;
    } catch (e) {
      print('Error deleting packaging: $e');
      return false;
    }
  }

  // ===================== STOCK =====================

  Future<void> loadAllStock() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stockWithDetails = await _inventoryService.getAllStockWithDetails();
      debugPrint('📦 تم تحميل ${_stockWithDetails.length} سجل مخزون');
      if (_stockWithDetails.isNotEmpty) {
        debugPrint('🔍 أول سجل: ${_stockWithDetails.first}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل المخزون: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getWarehouseStock(int warehouseId) async {
    try {
      return await _inventoryService.getWarehouseStockWithProducts(warehouseId);
    } catch (e) {
      print('Error loading warehouse stock: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLowStockReport() async {
    try {
      return await _inventoryService.getLowStockReport();
    } catch (e) {
      print('Error loading low stock report: $e');
      return [];
    }
  }

  // ===================== TRANSACTIONS =====================

  Future<void> loadTransactions({
    InventoryTransactionType? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _inventoryService.getAllTransactions(
        type: type?.toString(),
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(InventoryTransaction transaction) async {
    try {
      await _inventoryService.addInventoryTransaction(transaction);
      await loadTransactions();
      await loadAllStock();
      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  Future<String> generateTransactionNumber(
      InventoryTransactionType type) async {
    try {
      return await _inventoryService.generateTransactionNumber(type);
    } catch (e) {
      print('Error generating transaction number: $e');
      return '';
    }
  }

  Future<List<InventoryTransaction>> getDamagedMaterialsReport({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _inventoryService.getDamagedMaterialsReport(
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      print('Error loading damaged materials report: $e');
      return [];
    }
  }

  Future<List<InventoryTransaction>> getConsumedMaterialsReport({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _inventoryService.getConsumedMaterialsReport(
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      print('Error loading consumed materials report: $e');
      return [];
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await _inventoryService.deleteTransaction(id);
      await loadTransactions();
      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }
}
