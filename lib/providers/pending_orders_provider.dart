import 'package:flutter/material.dart';
import '../models/pending_order.dart';
import '../services/database_helper.dart';

class PendingOrdersProvider with ChangeNotifier {
  List<PendingOrder> _pendingOrders = [];
  bool _isLoading = false;

  List<PendingOrder> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;

  /// توليد رقم طلب جديد
  Future<String> generateOrderNumber() async {
    final now = DateTime.now();
    final prefix = 'PO${now.year}${now.month.toString().padLeft(2, '0')}';
    final orders = await DatabaseHelper.instance.getAllPendingOrders();
    final count = orders.length + 1;
    return '$prefix${count.toString().padLeft(4, '0')}';
  }

  /// إضافة طلب جديد
  Future<void> addOrder(PendingOrder order) async {
    await addPendingOrder(order);
  }

  /// تحديث طلب موجود
  Future<void> updateOrder(PendingOrder order) async {
    await updatePendingOrder(order);
  }

  /// تحميل جميع الطلبات المعلقة
  Future<void> loadPendingOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseHelper.instance.getAllPendingOrders();
      _pendingOrders = data.map((map) {
        final items = (map['items'] as List<dynamic>)
            .map((item) =>
                PendingOrderItem.fromMap(item as Map<String, dynamic>))
            .toList();

        return PendingOrder.fromMap(map).copyWith(items: items);
      }).toList();
    } catch (e) {
      print('Error loading pending orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة طلب معلق جديد
  Future<bool> addPendingOrder(PendingOrder order) async {
    try {
      final orderMap = order.toMap();
      orderMap.remove('id'); // Remove id for auto-increment

      final items = order.items.map((item) {
        final map = item.toMap();
        map.remove('id');
        map.remove('pending_order_id');
        return map;
      }).toList();

      await DatabaseHelper.instance.insertPendingOrder(orderMap, items);
      await loadPendingOrders();
      return true;
    } catch (e) {
      print('Error adding pending order: $e');
      return false;
    }
  }

  /// تحديث طلب معلق
  Future<bool> updatePendingOrder(PendingOrder order) async {
    if (order.id == null) return false;

    try {
      final orderMap = order.toMap();
      orderMap.remove('id');

      final items = order.items.map((item) {
        final map = item.toMap();
        map.remove('id');
        map.remove('pending_order_id');
        return map;
      }).toList();

      await DatabaseHelper.instance.updatePendingOrder(
        order.id!,
        orderMap,
        items,
      );
      await loadPendingOrders();
      return true;
    } catch (e) {
      print('Error updating pending order: $e');
      return false;
    }
  }

  /// حذف طلب معلق
  Future<bool> deletePendingOrder(int id) async {
    try {
      await DatabaseHelper.instance.deletePendingOrder(id);
      await loadPendingOrders();
      return true;
    } catch (e) {
      print('Error deleting pending order: $e');
      return false;
    }
  }

  /// تحديث حالة الطلب
  Future<bool> updatePendingOrderStatus(int id, String status) async {
    try {
      await DatabaseHelper.instance.updatePendingOrderStatus(id, status);
      await loadPendingOrders();
      return true;
    } catch (e) {
      print('Error updating pending order status: $e');
      return false;
    }
  }

  /// توليد رقم طلب معلق جديد
  Future<String> generatePendingOrderNumber() async {
    try {
      return await DatabaseHelper.instance.generatePendingOrderNumber();
    } catch (e) {
      print('Error generating pending order number: $e');
      return 'PO-000001';
    }
  }

  /// الحصول على الطلبات حسب الحالة
  List<PendingOrder> getOrdersByStatus(String status) {
    return _pendingOrders.where((o) => o.status == status).toList();
  }

  /// الحصول على الطلبات المتأخرة
  List<PendingOrder> getOverdueOrders() {
    final now = DateTime.now();
    return _pendingOrders
        .where((o) =>
            o.deliveryDate != null &&
            o.deliveryDate!.isBefore(now) &&
            o.status == 'pending')
        .toList();
  }

  /// إحصائيات الطلبات المعلقة
  Map<String, dynamic> getStatistics() {
    final total = _pendingOrders.length;
    final pending = _pendingOrders.where((o) => o.status == 'pending').length;
    final completed =
        _pendingOrders.where((o) => o.status == 'completed').length;
    final cancelled =
        _pendingOrders.where((o) => o.status == 'cancelled').length;
    final overdue = getOverdueOrders().length;

    final totalAmount = _pendingOrders.fold<double>(
      0.0,
      (sum, o) => sum + o.finalAmount,
    );

    final totalDeposit = _pendingOrders.fold<double>(
      0.0,
      (sum, o) => sum + o.depositAmount,
    );

    final totalRemaining = _pendingOrders.fold<double>(
      0.0,
      (sum, o) => sum + o.remainingAmount,
    );

    return {
      'total': total,
      'pending': pending,
      'completed': completed,
      'cancelled': cancelled,
      'overdue': overdue,
      'totalAmount': totalAmount,
      'totalDeposit': totalDeposit,
      'totalRemaining': totalRemaining,
    };
  }
}
