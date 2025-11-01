class DatabaseConfig {
  // SQL Server Configuration
  static const String host = 'localhost'; // أو IP السيرفر
  static const int port = 1433; // Port افتراضي لـ SQL Server
  static const String database = 'sales_management_db';
  static const String username = 'sa'; // اسم المستخدم
  static const String password = 'your_password'; // كلمة المرور

  // Connection String
  static String get connectionString {
    return 'Server=$host,$port;Database=$database;User Id=$username;Password=$password;';
  }

  // Timeout Settings
  static const int connectionTimeout = 30;
  static const int commandTimeout = 30;

  // Pool Settings
  static const int minPoolSize = 5;
  static const int maxPoolSize = 100;
}
