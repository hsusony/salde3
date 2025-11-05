/// خدمة إدارة المستخدم الحالي
class UserService {
  static final UserService instance = UserService._internal();

  UserService._internal();

  String _currentUserName = 'المستخدم الافتراضي';

  /// الحصول على اسم المستخدم الحالي
  String get currentUserName => _currentUserName;

  /// تعيين اسم المستخدم الحالي
  void setCurrentUser(String userName) {
    _currentUserName = userName;
  }

  /// تسجيل الخروج
  void logout() {
    _currentUserName = 'المستخدم الافتراضي';
  }
}
