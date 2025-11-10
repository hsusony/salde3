import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة API لإدارة سندات الدفع
/// Payment Voucher API Service
class PaymentVoucherApi {
  // عنوان الـ API
  static const String baseUrl = 'http://localhost:8000/api';

  // Headers افتراضية
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  // =====================================================
  // سندات الدفع العادية (Payment Vouchers)
  // =====================================================

  /// إضافة سند دفع جديد
  static Future<Map<String, dynamic>> addPaymentVoucher({
    required String voucherNumber,
    required DateTime voucherDate,
    required String accountName,
    required String cashAccount,
    required double amount,
    double discount = 0,
    String? amountInWords,
    String currency = 'دينار',
    double exchangeRate = 1.0,
    String? notes,
    String? description,
    double previousOrder = 0,
    double currentOrder = 0,
    int? createdBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment-vouchers'),
        headers: _headers,
        body: jsonEncode({
          'voucherNumber': voucherNumber,
          'voucherDate': voucherDate.toIso8601String(),
          'accountName': accountName,
          'cashAccount': cashAccount,
          'amount': amount,
          'discount': discount,
          'amountInWords': amountInWords,
          'currency': currency,
          'exchangeRate': exchangeRate,
          'notes': notes,
          'description': description,
          'previousOrder': previousOrder,
          'currentOrder': currentOrder,
          'createdBy': createdBy,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'تم إضافة سند الدفع بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في إضافة سند الدفع',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// الحصول على جميع سندات الدفع
  static Future<Map<String, dynamic>> getPaymentVouchers({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? accountName,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/payment-vouchers');

      // إضافة Query Parameters
      Map<String, String> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (accountName != null) {
        queryParams['accountName'] = accountName;
      }

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'count': data.length,
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في جلب سندات الدفع',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// الحصول على سند دفع بالمعرف
  static Future<Map<String, dynamic>> getPaymentVoucherById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment-vouchers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'سند الدفع غير موجود',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// تحديث سند دفع
  static Future<Map<String, dynamic>> updatePaymentVoucher({
    required int id,
    String? accountName,
    double? amount,
    double? discount,
    String? notes,
    String? status,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (accountName != null) updates['accountName'] = accountName;
      if (amount != null) updates['amount'] = amount;
      if (discount != null) updates['discount'] = discount;
      if (notes != null) updates['notes'] = notes;
      if (status != null) updates['status'] = status;

      final response = await http.put(
        Uri.parse('$baseUrl/payment-vouchers/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'تم تحديث سند الدفع بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في تحديث سند الدفع',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// حذف سند دفع
  static Future<Map<String, dynamic>> deletePaymentVoucher(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payment-vouchers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'تم حذف سند الدفع بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في حذف سند الدفع',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// طباعة سند دفع (تحديث حالة الطباعة)
  static Future<Map<String, dynamic>> printPaymentVoucher(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment-vouchers/$id/print'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'تم تسجيل الطباعة بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في تسجيل الطباعة',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  // =====================================================
  // الإحصائيات والتقارير (Statistics & Reports)
  // =====================================================

  /// الحصول على إحصائيات سندات الدفع
  static Future<Map<String, dynamic>> getPaymentVoucherStats({
    String? currency,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/payment-vouchers/stats');

      if (currency != null) {
        uri = uri.replace(queryParameters: {'currency': currency});
      }

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في جلب الإحصائيات',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// الحصول على المجموع حسب الفترة
  static Future<Map<String, dynamic>> getTotalByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String? currency,
  }) async {
    try {
      Map<String, String> queryParams = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (currency != null) {
        queryParams['currency'] = currency;
      }

      final uri = Uri.parse('$baseUrl/payment-vouchers/total').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في حساب المجموع',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// تقرير شهري
  static Future<Map<String, dynamic>> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl/payment-vouchers/reports/monthly').replace(
        queryParameters: {
          'year': year.toString(),
          'month': month.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في جلب التقرير',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  // =====================================================
  // أرصدة العملات (Currency Balances)
  // =====================================================

  /// الحصول على أرصدة العملات
  static Future<Map<String, dynamic>> getCurrencyBalances() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/currency-balances'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في جلب الأرصدة',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  /// تحديث رصيد عملة
  static Future<Map<String, dynamic>> updateCurrencyBalance({
    required String currency,
    required double balance,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/currency-balances'),
        headers: _headers,
        body: jsonEncode({
          'currency': currency,
          'balance': balance,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'تم تحديث الرصيد بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في تحديث الرصيد',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  // =====================================================
  // دوال مساعدة (Helper Functions)
  // =====================================================

  /// توليد رقم سند تلقائي
  static String generateVoucherNumber() {
    final now = DateTime.now();
    return 'PAY-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour}${now.minute}${now.second}';
  }

  /// تحويل الرقم إلى كلمات عربية (مبسط)
  static String numberToWords(double amount) {
    // يمكن تحسين هذه الدالة لاحقاً
    final intAmount = amount.toInt();
    if (intAmount < 1000) {
      return '$intAmount دينار';
    } else if (intAmount < 1000000) {
      final thousands = (intAmount / 1000).floor();
      return '$thousands ألف دينار';
    } else {
      final millions = (intAmount / 1000000).floor();
      return '$millions مليون دينار';
    }
  }

  /// التحقق من صحة رقم السند
  static bool isValidVoucherNumber(String voucherNumber) {
    // يجب أن يكون رقم السند بصيغة PAY-YYYYMMDD-HHMMSS
    final pattern = RegExp(r'^PAY-\d{8}-\d{6}$');
    return pattern.hasMatch(voucherNumber);
  }

  /// فحص اتصال الـ API
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ خطأ في الاتصال بالـ API: $e');
      return false;
    }
  }

  // =====================================================
  // سندات الدفع المتعددة (Multiple Payment Vouchers)
  // =====================================================

  /// إضافة سند دفع متعدد
  static Future<Map<String, dynamic>> addMultiplePaymentVoucher({
    required String voucherNumber,
    required DateTime voucherDate,
    required String beneficiaryName,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/multiple-payment-vouchers'),
        headers: _headers,
        body: jsonEncode({
          'voucherNumber': voucherNumber,
          'voucherDate': voucherDate.toIso8601String(),
          'beneficiaryName': beneficiaryName,
          'items': items,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'تم إضافة سند الدفع المتعدد بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في إضافة سند الدفع المتعدد',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }

  // =====================================================
  // سندات الدفع بعملتين (Dual Currency Payments)
  // =====================================================

  /// إضافة سند دفع بعملتين
  static Future<Map<String, dynamic>> addDualCurrencyPayment({
    required String voucherNumber,
    required DateTime voucherDate,
    required String beneficiaryName,
    required double amountIQD,
    required String paymentMethodIQD,
    required double amountUSD,
    required String paymentMethodUSD,
    required double exchangeRate,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dual-currency-payments'),
        headers: _headers,
        body: jsonEncode({
          'voucherNumber': voucherNumber,
          'voucherDate': voucherDate.toIso8601String(),
          'beneficiaryName': beneficiaryName,
          'amountIQD': amountIQD,
          'paymentMethodIQD': paymentMethodIQD,
          'amountUSD': amountUSD,
          'paymentMethodUSD': paymentMethodUSD,
          'exchangeRate': exchangeRate,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'تم إضافة سند الدفع بعملتين بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في إضافة سند الدفع بعملتين',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ في الاتصال: $e',
      };
    }
  }
}
