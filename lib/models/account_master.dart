/// نموذج الأستاذ (حساب في شجرة الحسابات)
class AccountMaster {
  final int? id;
  final String accountNumber; // رقم الأستاذ
  final String accountName; // اسم الأستاذ
  final bool canUse; // استخدام
  final bool canDelete; // إزالة
  final String? category; // التصنيف (أصول، خصوم، إيرادات، مصروفات)
  final String? parentAccount; // الحساب الأب
  final double balance; // الرصيد
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountMaster({
    this.id,
    required this.accountNumber,
    required this.accountName,
    this.canUse = true,
    this.canDelete = false,
    this.category,
    this.parentAccount,
    this.balance = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory AccountMaster.fromJson(Map<String, dynamic> json) {
    return AccountMaster(
      id: json['id'],
      accountNumber: json['accountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      canUse: json['canUse'] == 1 || json['canUse'] == true,
      canDelete: json['canDelete'] == 1 || json['canDelete'] == true,
      category: json['category'],
      parentAccount: json['parentAccount'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'canUse': canUse ? 1 : 0,
      'canDelete': canDelete ? 1 : 0,
      'category': category,
      'parentAccount': parentAccount,
      'balance': balance,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  AccountMaster copyWith({
    int? id,
    String? accountNumber,
    String? accountName,
    bool? canUse,
    bool? canDelete,
    String? category,
    String? parentAccount,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountMaster(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      canUse: canUse ?? this.canUse,
      canDelete: canDelete ?? this.canDelete,
      category: category ?? this.category,
      parentAccount: parentAccount ?? this.parentAccount,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
