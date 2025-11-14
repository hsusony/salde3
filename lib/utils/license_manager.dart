import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// مدير الترخيص والحماية من النسخ غير المصرح بها
class LicenseManager {
  static final LicenseManager _instance = LicenseManager._internal();
  factory LicenseManager() => _instance;
  LicenseManager._internal();

  // معلومات الترخيص
  static const String _licenseKey = '9SOFT-2025-SALES-SYSTEM';
  static const String _companyId = '9SOFT-IRAQ-BAGHDAD';
  
  // معرف الجهاز
  String? _deviceId;

  /// التحقق من صلاحية الترخيص
  Future<bool> validateLicense() async {
    try {
      // الحصول على معرف الجهاز
      _deviceId = await _getDeviceId();

      // التحقق من الترخيص
      final licenseHash = _generateLicenseHash(_deviceId!);
      
      // في نسخة الإنتاج، يمكن التحقق من قاعدة البيانات أو السيرفر
      return await _checkLicenseFile(licenseHash);
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في التحقق من الترخيص: $e');
      }
      return false;
    }
  }

  /// الحصول على معرف الجهاز الفريد
  Future<String> _getDeviceId() async {
    try {
      if (Platform.isWindows) {
        // الحصول على معرف الجهاز من Windows
        final result = await Process.run('wmic', ['csproduct', 'get', 'uuid']);
        final output = result.stdout.toString();
        final lines = output.split('\n');
        if (lines.length > 1) {
          return lines[1].trim();
        }
      } else if (Platform.isLinux) {
        // الحصول على معرف الجهاز من Linux
        final result = await Process.run('cat', ['/etc/machine-id']);
        return result.stdout.toString().trim();
      } else if (Platform.isMacOS) {
        // الحصول على معرف الجهاز من macOS
        final result = await Process.run('ioreg', ['-rd1', '-c', 'IOPlatformExpertDevice']);
        return result.stdout.toString().trim();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ تعذر الحصول على معرف الجهاز: $e');
      }
    }
    
    // في حالة الفشل، استخدم معرف افتراضي
    return 'DEFAULT-DEVICE-ID';
  }

  /// توليد hash للترخيص
  String _generateLicenseHash(String deviceId) {
    final data = '$_licenseKey-$_companyId-$deviceId';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// التحقق من ملف الترخيص
  Future<bool> _checkLicenseFile(String expectedHash) async {
    try {
      // في بيئة التطوير، السماح دائماً
      if (kDebugMode) {
        return true;
      }

      // البحث عن ملف الترخيص
      final licenseFile = File('license.dat');
      
      if (!await licenseFile.exists()) {
        // إنشاء ترخيص تجريبي
        await _createTrialLicense(licenseFile);
      }

      // قراءة والتحقق من الترخيص
      final content = await licenseFile.readAsString();
      final licenseData = _decodeLicense(content);

      // التحقق من تاريخ الانتهاء
      if (licenseData['expiry'] != null) {
        final expiry = DateTime.parse(licenseData['expiry']);
        if (DateTime.now().isAfter(expiry)) {
          throw LicenseException('انتهت صلاحية الترخيص');
        }
      }

      // التحقق من المعرف
      return licenseData['hash'] == expectedHash;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في التحقق من ملف الترخيص: $e');
      }
      return false;
    }
  }

  /// إنشاء ترخيص تجريبي
  Future<void> _createTrialLicense(File licenseFile) async {
    final expiry = DateTime.now().add(const Duration(days: 30));
    final hash = _generateLicenseHash(_deviceId ?? 'TRIAL');
    
    final licenseData = {
      'type': 'trial',
      'expiry': expiry.toIso8601String(),
      'hash': hash,
      'company': '9SOFT',
    };

    final encoded = _encodeLicense(licenseData);
    await licenseFile.writeAsString(encoded);

    if (kDebugMode) {
      print('✅ تم إنشاء ترخيص تجريبي لمدة 30 يوم');
    }
  }

  /// تشفير بيانات الترخيص
  String _encodeLicense(Map<String, dynamic> data) {
    final json = jsonEncode(data);
    final bytes = utf8.encode(json);
    return base64Encode(bytes);
  }

  /// فك تشفير بيانات الترخيص
  Map<String, dynamic> _decodeLicense(String encoded) {
    final bytes = base64Decode(encoded);
    final json = utf8.decode(bytes);
    return jsonDecode(json);
  }

  /// الحصول على معلومات الترخيص
  Future<Map<String, dynamic>> getLicenseInfo() async {
    try {
      final licenseFile = File('license.dat');
      if (!await licenseFile.exists()) {
        return {'type': 'none', 'status': 'غير مرخص'};
      }

      final content = await licenseFile.readAsString();
      final data = _decodeLicense(content);

      if (data['expiry'] != null) {
        final expiry = DateTime.parse(data['expiry']);
        final remaining = expiry.difference(DateTime.now()).inDays;
        data['remaining_days'] = remaining;
        data['status'] = remaining > 0 ? 'نشط' : 'منتهي';
      }

      return data;
    } catch (e) {
      return {'type': 'error', 'status': 'خطأ', 'message': e.toString()};
    }
  }

  /// تفعيل ترخيص جديد
  Future<bool> activateLicense(String licenseCode) async {
    try {
      // التحقق من رمز الترخيص مع السيرفر (في الإنتاج)
      // هنا مثال بسيط
      
      if (!_isValidLicenseCode(licenseCode)) {
        throw LicenseException('رمز ترخيص غير صالح');
      }

      final licenseFile = File('license.dat');
      final expiry = DateTime.now().add(const Duration(days: 365));
      final hash = _generateLicenseHash(_deviceId ?? await _getDeviceId());

      final licenseData = {
        'type': 'full',
        'expiry': expiry.toIso8601String(),
        'hash': hash,
        'company': '9SOFT',
        'code': licenseCode,
        'activated': DateTime.now().toIso8601String(),
      };

      final encoded = _encodeLicense(licenseData);
      await licenseFile.writeAsString(encoded);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ فشل تفعيل الترخيص: $e');
      }
      return false;
    }
  }

  /// التحقق من صحة رمز الترخيص
  bool _isValidLicenseCode(String code) {
    // التحقق من تنسيق رمز الترخيص
    final pattern = RegExp(r'^9SOFT-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return pattern.hasMatch(code);
  }

  /// حذف الترخيص
  Future<void> removeLicense() async {
    try {
      final licenseFile = File('license.dat');
      if (await licenseFile.exists()) {
        await licenseFile.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في حذف الترخيص: $e');
      }
    }
  }
}

/// استثناء الترخيص
class LicenseException implements Exception {
  final String message;
  LicenseException(this.message);

  @override
  String toString() => 'LicenseException: $message';
}
