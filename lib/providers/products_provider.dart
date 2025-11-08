import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider extends ChangeNotifier {
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
      // استخدام API بدلاً من SQLite
      final response = await http.get(
        Uri.parse('http://localhost/backend-php/api/products'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        // PHP API يرجع البيانات في data
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          throw Exception('صيغة غير متوقعة للبيانات');
        }
        _products = data.map((json) => Product.fromMap(json)).toList();
        debugPrint('✅ تم تحميل ${_products.length} منتج من API');
      } else {
        throw Exception('فشل تحميل المنتجات: ${response.statusCode}');
      }
      _filterProducts();
    } catch (e) {
      debugPrint('❌ خطأ في تحميل المنتجات: $e');
      _products = [];
      _filterProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      debugPrint('📝 إضافة منتج جديد');
      debugPrint('   الاسم: ${product.name}');
      debugPrint('   الباركود: ${product.barcode}');
      debugPrint('   سعر الشراء: ${product.purchasePrice}');
      debugPrint('   سعر البيع: ${product.sellingPrice}');
      debugPrint('   الكمية: ${product.quantity}');

      // استخدام API لإضافة المنتج
      final response = await http
          .post(
            Uri.parse('http://localhost/backend-php/api/products'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'Name': product.name,
              'Barcode': product.barcode,
              'BuyingPrice': product.purchasePrice,
              'SellingPrice': product.sellingPrice,
              'Stock': product.quantity,
              'MinStock': product.minQuantity,
              'Description': product.description,
              'CategoryID': null,
              'SupplierID': null,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📡 رد الخادم: ${response.statusCode}');
      debugPrint('   الرد: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // إذا كان الرد يحتوي على ID جديد، نستخدمه
        if (data['id'] != null) {
          product = Product(
            id: data['id'],
            name: product.name,
            barcode: product.barcode,
            category: product.category,
            purchasePrice: product.purchasePrice,
            sellingPrice: product.sellingPrice,
            quantity: product.quantity,
            minQuantity: product.minQuantity,
            description: product.description,
            imageUrl: product.imageUrl,
            createdAt: DateTime.now(),
          );
        }
        _products.add(product);
        _filterProducts();
        notifyListeners();
        debugPrint('✅ تم إضافة المنتج بنجاح - ID: ${product.id}');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception(
            'فشل إضافة المنتج: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إضافة المنتج: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      debugPrint('🔄 تحديث المنتج ID: ${product.id}');
      debugPrint('   الاسم: ${product.name}');
      debugPrint('   الباركود: ${product.barcode}');
      debugPrint('   سعر الشراء: ${product.purchasePrice}');
      debugPrint('   سعر البيع: ${product.sellingPrice}');
      debugPrint('   الكمية: ${product.quantity}');

      // استخدام API لتحديث المنتج
      final response = await http
          .put(
            Uri.parse(
                'http://localhost/backend-php/api/products/${product.id}'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'Name': product.name,
              'Barcode': product.barcode,
              'BuyingPrice': product.purchasePrice,
              'SellingPrice': product.sellingPrice,
              'Stock': product.quantity,
              'MinStock': product.minQuantity,
              'Description': product.description,
              'CategoryID': null, // يمكن إضافة دعم الفئات لاحقاً
              'SupplierID': null, // يمكن إضافة دعم الموردين لاحقاً
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📡 رد الخادم: ${response.statusCode}');
      debugPrint('   الرد: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
          _filterProducts();
          notifyListeners();
        }
        debugPrint('✅ تم تحديث المنتج بنجاح في القائمة المحلية');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception(
            'فشل تحديث المنتج: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحديث المنتج: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id, {String userName = 'المستخدم'}) async {
    try {
      // استخدام API لحذف المنتج
      final response = await http.delete(
        Uri.parse('http://localhost/backend-php/api/products/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _products.removeWhere((p) => p.id == id);
        _filterProducts();
        notifyListeners();
        debugPrint('✅ تم حذف المنتج بنجاح');
      } else {
        throw Exception('فشل حذف المنتج: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف المنتج: $e');
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
    debugPrint(
        '🔍 البحث: "$_searchQuery" | إجمالي المنتجات: ${_products.length} | المنتجات المعروضة: ${_filteredProducts.length}');
  }
}
