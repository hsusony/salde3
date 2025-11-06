import '../models/warehouse.dart';
import '../models/packaging.dart';
import '../models/inventory_transaction.dart';
import '../models/warehouse_stock.dart';

class InventoryService {
  Future<int> addWarehouse(Warehouse warehouse) async => 0;
  Future<List<Warehouse>> getAllWarehouses() async => [];
  Future<int> updateWarehouse(Warehouse warehouse) async => 0;
  Future<int> deleteWarehouse(int id) async => 0;

  Future<int> addPackaging(Packaging packaging) async => 0;
  Future<List<Packaging>> getAllPackagings() async => [];
  Future<List<Packaging>> getAllPackaging() async => [];
  Future<int> updatePackaging(Packaging packaging) async => 0;
  Future<int> deletePackaging(int id) async => 0;

  Future<List<InventoryTransaction>> getAllTransactions(
          {String? type, DateTime? fromDate, DateTime? toDate}) async =>
      [];
  Future<List<InventoryTransaction>> getTransactionsByWarehouse(
          int warehouseId) async =>
      [];
  Future<List<InventoryTransaction>> getTransactionsByProduct(
          int productId) async =>
      [];
  Future<int> addInventoryTransaction(InventoryTransaction transaction,
          {String? type, String? referenceNumber}) async =>
      0;
  Future<String> generateTransactionNumber(dynamic typeOrPrefix) async =>
      'TRX-001';
  Future<int> deleteTransaction(int id) async => 0;

  Future<int> addOrUpdateStock(WarehouseStock stock) async => 0;
  Future<WarehouseStock?> getStock(int warehouseId, int productId) async =>
      null;
  Future<List<WarehouseStock>> getWarehouseStocks(int warehouseId) async => [];
  Future<List<WarehouseStock>> getProductStocks(int productId) async => [];
  Future<List<WarehouseStock>> getAllStocks() async => [];
  Future<List<Map<String, dynamic>>> getAllStockWithDetails() async => [];
  Future<List<Map<String, dynamic>>> getWarehouseStockWithProducts(
          int warehouseId) async =>
      [];

  Future<bool> addStockForPurchase(
          {required int productId,
          required double quantity,
          required int warehouseId,
          int? purchaseId}) async =>
      false;
  Future<bool> deductStockForSale(
          {required int productId,
          required double quantity,
          required int warehouseId,
          int? saleId}) async =>
      false;
  Future<bool> deductStockForPurchaseReturn(
          {required int productId,
          required double quantity,
          required int warehouseId,
          int? returnId}) async =>
      false;
  Future<bool> returnStockForSaleReturn(
          {required int productId,
          required double quantity,
          required int warehouseId,
          int? returnId}) async =>
      false;

  Future<bool> recordPurchase(
          {required int warehouseId,
          required int productId,
          required double quantity,
          required String referenceType,
          required int referenceId}) async =>
      false;
  Future<bool> recordSale(
          {required int warehouseId,
          required int productId,
          required double quantity,
          required String referenceType,
          required int referenceId}) async =>
      false;
  Future<bool> recordTransfer(
          {required int fromWarehouseId,
          required int toWarehouseId,
          required int productId,
          required double quantity,
          required String notes}) async =>
      false;
  Future<bool> recordAdjustment(
          {required int warehouseId,
          required int productId,
          required double quantity,
          required String reason,
          required String notes}) async =>
      false;

  Future<Map<String, dynamic>> getInventoryReport() async => {};
  Future<List<Map<String, dynamic>>> getLowStockReport(
          {double threshold = 10}) async =>
      [];
  Future<List<Map<String, dynamic>>> getWarehouseReport(
          int warehouseId) async =>
      [];
  Future<List<Map<String, dynamic>>> getProductMovementReport(
          int productId) async =>
      [];
  Future<List<InventoryTransaction>> getDamagedMaterialsReport(
          {DateTime? fromDate, DateTime? toDate}) async =>
      [];
  Future<List<InventoryTransaction>> getConsumedMaterialsReport(
          {DateTime? fromDate, DateTime? toDate}) async =>
      [];
}
