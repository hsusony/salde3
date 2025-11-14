/// تكوين التطبيق - إعدادات الأمان والحماية
class AppConfig {
  // معلومات التطبيق
  static const String appName = 'نظام إدارة المبيعات';
  static const String appVersion = '2.0.0';
  static const String companyName = '9SOFT';
  
  // إعدادات الأمان
  static const bool enableSecurity = true;
  static const bool enableLicenseCheck = true;
  static const bool enableObfuscation = true;
  
  // بيئة التشغيل
  static const String environment = String.fromEnvironment(
    'PRODUCTION',
    defaultValue: 'development',
  );
  
  // التحقق من البيئة
  static bool get isProduction => environment == 'true';
  static bool get isDevelopment => !isProduction;
  
  // إعدادات API
  static const String apiBaseUrl = 'http://localhost:8000';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // إعدادات قاعدة البيانات
  static const String dbHost = 'localhost';
  static const String dbName = 'sales_system';
  
  // مفاتيح التشفير (سيتم تشفيرها في النسخة النهائية)
  static const String encryptionKey = '9SOFT-SECURE-KEY-2025';
  
  // معلومات الترخيص
  static const int trialPeriodDays = 30;
  static const String licenseServerUrl = 'https://nine-soft.com/api/license';
}
