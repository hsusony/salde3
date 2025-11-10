import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/warehouse.dart';

class WarehousesProvider with ChangeNotifier {
  List<Warehouse> _warehouses = [];
  bool _isLoading = false;
  String? _error;

  final String baseUrl = 'http://localhost/backend-php/api';

  List<Warehouse> get warehouses => _warehouses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Warehouse> get activeWarehouses =>
      _warehouses.where((w) => w.isActive).toList();

  Future<void> loadWarehouses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/warehouses'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          throw Exception('صيغة غير متوقعة للبيانات');
        }
        _warehouses = data.map((json) => Warehouse.fromMap(json)).toList();
        debugPrint('✅ تم تحميل ${_warehouses.length} مخزن من API');
        _error = null;
      } else {
        _error = 'خطأ في تحميل المخازن: ${response.statusCode}';
        debugPrint('❌ $_error');
      }
    } catch (e) {
      _error = 'خطأ في الاتصال: $e';
      debugPrint('❌ Error loading warehouses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWarehouse(Warehouse warehouse) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http
          .post(
            Uri.parse('$baseUrl/warehouses'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(warehouse.toMap()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadWarehouses();
        debugPrint('✅ تم إضافة المخزن بنجاح');
        return true;
      } else {
        _error = 'فشل إضافة المخزن: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'خطأ في إضافة المخزن: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWarehouse(Warehouse warehouse) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http
          .put(
            Uri.parse('$baseUrl/warehouses/${warehouse.id}'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(warehouse.toMap()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await loadWarehouses();
        debugPrint('✅ تم تحديث المخزن بنجاح');
        return true;
      } else {
        _error = 'فشل تحديث المخزن: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'خطأ في تحديث المخزن: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWarehouse(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$baseUrl/warehouses/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await loadWarehouses();
        debugPrint('✅ تم حذف المخزن بنجاح');
        return true;
      } else {
        _error = 'فشل حذف المخزن: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'خطأ في حذف المخزن: $e';
      debugPrint('❌ $_error');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleWarehouseStatus(int id, bool isActive) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/warehouses/$id/status'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'is_active': isActive ? 1 : 0}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await loadWarehouses();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling warehouse status: $e');
      return false;
    }
  }

  Warehouse? getWarehouseById(int id) {
    try {
      return _warehouses.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Warehouse? getWarehouseByName(String name) {
    try {
      return _warehouses.firstWhere((w) => w.name == name);
    } catch (e) {
      return null;
    }
  }
}
