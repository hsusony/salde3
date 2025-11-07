import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'error_handler.dart';

/// HTTP Client مع معالجة أخطاء متقدمة
class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout =
      Duration(seconds: 5); // تقليل من 30 إلى 5 ثوانٍ للأداء الأفضل

  /// GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(uri).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'لا يوجد اتصال بالخادم - تأكد من تشغيل الـ Backend');
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال - يرجى المحاولة مرة أخرى');
    } catch (e) {
      throw AppException('حدث خطأ: ${e.toString()}');
    }
  }

  /// POST request
  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode(data),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'لا يوجد اتصال بالخادم - تأكد من تشغيل الـ Backend');
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال - يرجى المحاولة مرة أخرى');
    } catch (e) {
      throw AppException('حدث خطأ: ${e.toString()}');
    }
  }

  /// PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode(data),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'لا يوجد اتصال بالخادم - تأكد من تشغيل الـ Backend');
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال - يرجى المحاولة مرة أخرى');
    } catch (e) {
      throw AppException('حدث خطأ: ${e.toString()}');
    }
  }

  /// DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'لا يوجد اتصال بالخادم - تأكد من تشغيل الـ Backend');
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال - يرجى المحاولة مرة أخرى');
    } catch (e) {
      throw AppException('حدث خطأ: ${e.toString()}');
    }
  }

  /// معالجة الـ Response
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw AppException('خطأ في تحليل البيانات من الخادم');
      }
    }

    // Error responses
    String errorMessage = _extractErrorMessage(response);

    switch (statusCode) {
      case 400:
        throw ValidationException(errorMessage);
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 409:
        throw ValidationException(errorMessage);
      case 422:
        throw ValidationException(errorMessage);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage);
      default:
        throw ServerException('خطأ غير متوقع من الخادم ($statusCode)');
    }
  }

  /// استخراج رسالة الخطأ من الـ Response
  static String _extractErrorMessage(http.Response response) {
    try {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
    } catch (e) {
      // ignore
    }

    // Default error messages
    switch (response.statusCode) {
      case 400:
        return 'طلب غير صحيح';
      case 401:
        return 'غير مصرح - يرجى تسجيل الدخول';
      case 403:
        return 'ليس لديك صلاحية للقيام بهذا الإجراء';
      case 404:
        return 'البيانات المطلوبة غير موجودة';
      case 409:
        return 'تعارض في البيانات';
      case 422:
        return 'بيانات غير صالحة';
      case 500:
        return 'خطأ في الخادم - يرجى المحاولة لاحقاً';
      case 503:
        return 'الخدمة غير متوفرة - يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ غير متوقع (${response.statusCode})';
    }
  }

  /// Check if backend is accessible
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
