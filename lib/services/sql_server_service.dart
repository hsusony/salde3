import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة الاتصال بـ SQL Server عبر REST API
///
/// ملاحظة: هذه الخدمة تتطلب إنشاء Web API بـ ASP.NET Core
/// للاتصال المباشر بـ SQL Server
///
/// البديل: يمكنك استخدام SQLite محلياً (sqflite_common_ffi) الموجود بالفعل
///
class SqlServerService {
  static SqlServerService? _instance;

  // Singleton pattern
  static SqlServerService get instance {
    _instance ??= SqlServerService._internal();
    return _instance!;
  }

  SqlServerService._internal();

  // رابط API الخاص بك (Node.js Backend)
  final String _baseUrl = 'http://localhost/backend-php/api';

  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  // اختبار الاتصال بالـ API
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ الاتصال بـ API ناجح');
        return true;
      } else {
        print('❌ فشل الاتصال: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      return false;
    }
  }

  // ==================== سندات القبض ====================

  /// إضافة سند قبض
  Future<Map<String, dynamic>?> insertReceiptVoucher({
    required String voucherNumber,
    required DateTime date,
    String? customerName,
    required double amount,
    required String paymentMethod,
    required String currency,
    String? notes,
    String? checkNumber,
    DateTime? checkDate,
    String? bankName,
  }) async {
    try {
      final body = jsonEncode({
        'voucherNumber': voucherNumber,
        'date': date.toIso8601String(),
        'customerName': customerName,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'currency': currency,
        'notes': notes,
        'checkNumber': checkNumber,
        'checkDate': checkDate?.toIso8601String(),
        'bankName': bankName,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/receiptvouchers'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ تم إضافة سند القبض بنجاح');
        return jsonDecode(response.body);
      } else {
        print('❌ فشل إضافة سند القبض: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في إضافة سند القبض: $e');
      return null;
    }
  }

  /// قراءة جميع سندات القبض
  Future<List<Map<String, dynamic>>?> getAllReceiptVouchers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/receiptvouchers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ فشل قراءة سندات القبض: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في قراءة سندات القبض: $e');
      return null;
    }
  }

  /// حذف سند قبض
  Future<bool> deleteReceiptVoucher(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/receiptvouchers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ تم حذف سند القبض بنجاح');
        return true;
      } else {
        print('❌ فشل حذف سند القبض: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في حذف سند القبض: $e');
      return false;
    }
  }

  /// تحديث سند قبض
  Future<bool> updateReceiptVoucher({
    required int id,
    required String voucherNumber,
    required DateTime date,
    String? customerName,
    required double amount,
    required String paymentMethod,
    required String currency,
    String? notes,
    String? checkNumber,
    DateTime? checkDate,
    String? bankName,
  }) async {
    try {
      final body = jsonEncode({
        'id': id,
        'voucherNumber': voucherNumber,
        'date': date.toIso8601String(),
        'customerName': customerName,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'currency': currency,
        'notes': notes,
        'checkNumber': checkNumber,
        'checkDate': checkDate?.toIso8601String(),
        'bankName': bankName,
      });

      final response = await http.put(
        Uri.parse('$_baseUrl/receiptvouchers/$id'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ تم تحديث سند القبض بنجاح');
        return true;
      } else {
        print('❌ فشل تحديث سند القبض: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في تحديث سند القبض: $e');
      return false;
    }
  }

  // ==================== المنتجات ====================

  /// إضافة منتج
  Future<Map<String, dynamic>?> insertProduct({
    String? barcode,
    required String name,
    String? category,
    double? purchasePrice,
    required double sellingPrice,
    int stockQuantity = 0,
    int minStockLevel = 0,
    String? unit,
    String? description,
  }) async {
    try {
      final body = jsonEncode({
        'barcode': barcode,
        'name': name,
        'category': category,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'stockQuantity': stockQuantity,
        'minStockLevel': minStockLevel,
        'unit': unit,
        'description': description,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ تم إضافة المنتج بنجاح');
        return jsonDecode(response.body);
      } else {
        print('❌ فشل إضافة المنتج: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في إضافة المنتج: $e');
      return null;
    }
  }

  /// البحث عن منتج بالباركود
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/barcode/$barcode'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('⚠️ المنتج غير موجود');
        return null;
      } else {
        print('❌ فشل البحث عن المنتج: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في البحث عن المنتج: $e');
      return null;
    }
  }

  /// قراءة جميع المنتجات
  Future<List<Map<String, dynamic>>?> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ فشل قراءة المنتجات: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في قراءة المنتجات: $e');
      return null;
    }
  }

  // ==================== العملاء ====================

  /// إضافة عميل
  Future<Map<String, dynamic>?> insertCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    double balance = 0,
  }) async {
    try {
      final body = jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'balance': balance,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ تم إضافة العميل بنجاح');
        return jsonDecode(response.body);
      } else {
        print('❌ فشل إضافة العميل: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في إضافة العميل: $e');
      return null;
    }
  }

  /// قراءة جميع العملاء
  Future<List<Map<String, dynamic>>?> getAllCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ فشل قراءة العملاء: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في قراءة العملاء: $e');
      return null;
    }
  }
}

/// ===================================================================
/// ملاحظات مهمة للاستخدام:
/// ===================================================================
/// 
/// 1. هذه الخدمة تتطلب إنشاء Web API بـ ASP.NET Core للاتصال بـ SQL Server
/// 
/// 2. مثال على Controller في ASP.NET Core:
/// 
/// ```csharp
/// [ApiController]
/// [Route("api/[controller]")]
/// public class ReceiptVouchersController : ControllerBase
/// {
///     private readonly SqlConnection _connection;
///     
///     [HttpGet]
///     public async Task<IActionResult> GetAll()
///     {
///         // قراءة البيانات من SQL Server
///     }
///     
///     [HttpPost]
///     public async Task<IActionResult> Create([FromBody] ReceiptVoucher voucher)
///     {
///         // إضافة بيانات إلى SQL Server
///     }
/// }
/// ```
/// 
/// 3. البديل الأسهل: استخدام SQLite المحلي الموجود بالفعل (sqflite_common_ffi)
///    - لا يحتاج سيرفر
///    - يعمل مباشرة مع التطبيق
///    - مناسب للتطبيقات الصغيرة والمتوسطة
/// 
/// 4. للاستخدام في التطبيق:
/// ```dart
/// final sqlService = SqlServerService.instance;
/// 
/// // اختبار الاتصال
/// final connected = await sqlService.testConnection();
/// 
/// // إضافة سند قبض
/// await sqlService.insertReceiptVoucher(
///   voucherNumber: 'RV-001',
///   date: DateTime.now(),
///   amount: 5000,
///   paymentMethod: 'نقدي',
///   currency: 'دينار عراقي',
/// );
/// ```
/// ===================================================================

