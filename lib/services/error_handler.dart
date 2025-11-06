import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة معالجة الأخطاء المركزية
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// معالجة الأخطاء من HTTP Response
  static String handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return _parseErrorMessage(response, 'طلب غير صحيح');
      case 401:
        return 'غير مصرح - يرجى تسجيل الدخول';
      case 403:
        return 'ليس لديك صلاحية للقيام بهذا الإجراء';
      case 404:
        return 'البيانات المطلوبة غير موجودة';
      case 409:
        return _parseErrorMessage(response, 'تعارض في البيانات');
      case 422:
        return _parseErrorMessage(response, 'بيانات غير صالحة');
      case 500:
        return 'خطأ في الخادم - يرجى المحاولة لاحقاً';
      case 503:
        return 'الخدمة غير متوفرة - يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ غير متوقع (${response.statusCode})';
    }
  }

  /// استخراج رسالة الخطأ من الـ Response
  static String _parseErrorMessage(
      http.Response response, String defaultMessage) {
    try {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
      return defaultMessage;
    } catch (e) {
      return defaultMessage;
    }
  }

  /// معالجة استثناءات الشبكة
  static String handleNetworkException(dynamic error) {
    if (error is SocketException) {
      return 'لا يوجد اتصال بالإنترنت - يرجى التحقق من الاتصال';
    } else if (error is HttpException) {
      return 'خطأ في الاتصال بالخادم';
    } else if (error is FormatException) {
      return 'خطأ في تنسيق البيانات';
    } else if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال - يرجى المحاولة مرة أخرى';
    } else {
      return 'حدث خطأ غير متوقع: ${error.toString()}';
    }
  }

  /// عرض رسالة خطأ للمستخدم
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// عرض رسالة نجاح للمستخدم
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// عرض رسالة تحذير للمستخدم
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// عرض Dialog للأخطاء الحرجة
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  /// عرض Dialog للتأكيد
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}

/// Exception class مخصصة للتطبيق
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// استثناء اتصال بالشبكة
class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

/// استثناء خطأ من الخادم
class ServerException extends AppException {
  ServerException(String message, {dynamic details})
      : super(message, code: 'SERVER_ERROR', details: details);
}

/// استثناء بيانات غير صالحة
class ValidationException extends AppException {
  ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}

/// استثناء غير مصرح
class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, code: 'UNAUTHORIZED');
}

/// استثناء ممنوع
class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message, code: 'FORBIDDEN');
}

/// استثناء غير موجود
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, code: 'NOT_FOUND');
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message, code: 'TIMEOUT');
}
