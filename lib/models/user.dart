class User {
  final int? id;
  final String name;
  final String phone;
  final String password;
  final String loginName;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.loginName,
    this.imagePath,
    this.isActive = true,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'password': password,
      'login_name': loginName,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      loginName: map['login_name'] as String,
      imagePath: map['image_path'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? phone,
    String? password,
    String? loginName,
    String? imagePath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      loginName: loginName ?? this.loginName,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
