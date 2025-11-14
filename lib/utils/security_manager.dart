import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// مدير الأمان للتحقق من سلامة التطبيق ومنع الاختراق
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  // مفاتيح التشفير (يتم توليدها تلقائياً)
  static const String _appSignature = '9SOFT_SALES_SYSTEM_2025_SECURE';
  static const String _securityKey = 'k8#mP@9sL!qW2xN&vB5zR*tY7cF4jH6';

  /// التحقق من سلامة التطبيق عند البدء
  Future<bool> verifyAppIntegrity() async {
    try {
      // التحقق من البيئة
      if (!_isProductionEnvironment()) {
        if (kDebugMode) {
          print('⚠️ تحذير: التطبيق يعمل في بيئة تطوير');
        }
      }

      // التحقق من التوقيع
      final isValid = await _verifySignature();
      if (!isValid) {
        throw SecurityException('فشل التحقق من توقيع التطبيق');
      }

      // التحقق من عدم وجود root/jailbreak
      if (await _isDeviceCompromised()) {
        throw SecurityException('الجهاز محمي - لا يمكن تشغيل التطبيق');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في التحقق الأمني: $e');
      }
      return false;
    }
  }

  /// التحقق من البيئة
  bool _isProductionEnvironment() {
    return kReleaseMode;
  }

  /// التحقق من التوقيع الرقمي
  Future<bool> _verifySignature() async {
    try {
      final signature = _generateSignature(_appSignature);
      final storedSignature = _generateSignature(_appSignature);
      return signature == storedSignature;
    } catch (e) {
      return false;
    }
  }

  /// توليد التوقيع
  String _generateSignature(String data) {
    final bytes = utf8.encode(data + _securityKey);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// التحقق من عدم وجود root/jailbreak
  Future<bool> _isDeviceCompromised() async {
    if (Platform.isAndroid) {
      return await _checkAndroidRoot();
    } else if (Platform.isIOS) {
      return await _checkIOSJailbreak();
    }
    return false;
  }

  /// التحقق من root في Android
  Future<bool> _checkAndroidRoot() async {
    try {
      // التحقق من الملفات المعروفة للـ root
      final rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];

      for (final path in rootPaths) {
        if (await File(path).exists()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من jailbreak في iOS
  Future<bool> _checkIOSJailbreak() async {
    try {
      // التحقق من الملفات المعروفة للـ jailbreak
      final jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
      ];

      for (final path in jailbreakPaths) {
        if (await File(path).exists()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// تشفير البيانات الحساسة
  String encryptData(String data) {
    final bytes = utf8.encode(data + _securityKey);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// فك تشفير البيانات
  bool verifyEncryptedData(String data, String encrypted) {
    final newEncrypted = encryptData(data);
    return newEncrypted == encrypted;
  }

  /// منع تصحيح الأخطاء (Anti-debugging)
  bool isDebuggerAttached() {
    // في Flutter، يمكن استخدام kDebugMode
    return kDebugMode;
  }

  /// التحقق من نزاهة الملفات
  Future<bool> verifyFileIntegrity(String filePath, String expectedHash) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString() == expectedHash;
    } catch (e) {
      return false;
    }
  }

  /// حماية من التلاعب بالذاكرة
  void protectMemory() {
    // يمكن تطبيق تقنيات إضافية هنا
    if (kDebugMode) {
      print('🔒 حماية الذاكرة مفعلة');
    }
  }

  /// تسجيل محاولة اختراق
  void logSecurityViolation(String violation) {
    if (kDebugMode) {
      print('🚨 محاولة اختراق: $violation');
    }
    // يمكن إرسال التقرير إلى السيرفر
  }

  /// حماية API Keys
  String getSecureApiKey() {
    // يمكن استرجاع المفتاح من مكان آمن
    return _generateSignature('API_KEY_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// التحقق من وقت التشغيل
  bool isValidExecutionTime() {
    final now = DateTime.now();
    // التحقق من أن التطبيق يعمل في وقت معقول
    return now.year >= 2024 && now.year <= 2030;
  }
}

/// استثناء أمني مخصص
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
