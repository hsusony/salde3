import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';
import '../services/inventory_service.dart';
import '../utils/database_helper_stub.dart'
    if (dart.library.io) '../utils/database_helper.dart';

class ProductsProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Use demo data for web
        _products = _getDemoProducts();
      } else {
        _products = await DatabaseHelper.instance.getAllProducts();
      }
      _filterProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
      // Fallback to demo data
      _products = _getDemoProducts();
      _filterProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> _getDemoProducts() {
    // TODO: استبدل هذه الدالة بجلب البيانات من قاعدة البيانات
    // في النظام الحقيقي، يجب أن تجلب البيانات من قاعدة البيانات
    return [];
  }

  Future<void> addProduct(Product product) async {
    try {
      if (!kIsWeb) {
        final id = await DatabaseHelper.instance.insertProduct(product);
        product = product.copyWith(id: id);

        // ✅ إنشاء سجل مخزون تلقائي للمنتج الجديد بكمية 0 في المخزن الافتراضي
        try {
          // الحصول على المخازن المتوفرة
          final warehouses = await _inventoryService.getAllWarehouses();

          if (warehouses.isNotEmpty) {
            // إنشاء سجل في المخزن الأول (الافتراضي)
            await _inventoryService.addStockForPurchase(
              productId: id,
              quantity: 0,
              warehouseId: warehouses.first.id!,
            );
          }
        } catch (e) {
          debugPrint('Warning: Could not create warehouse stock entry: $e');
          // لا نريد أن يفشل إضافة المنتج إذا فشل إنشاء المخزون
        }
      } else {
        // For web, just add to list with new ID
        product = product.copyWith(
          id: _products.isEmpty
              ? 1
              : _products
                      .map((p) => p.id ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  1,
        );
      }
      _products.add(product);
      _filterProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      if (!kIsWeb) {
        await DatabaseHelper.instance.updateProduct(product);
      }
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _filterProducts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id, {String userName = 'المستخدم'}) async {
    try {
      if (!kIsWeb) {
        await DatabaseHelper.instance.deleteProduct(id, userName: userName);
      }
      _products.removeWhere((p) => p.id == id);
      _filterProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _filterProducts();
    notifyListeners();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.barcode.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }
}
