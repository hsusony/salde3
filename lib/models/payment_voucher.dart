// نموذج سند الدفع - Payment Voucher
class PaymentVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String? supplierId;
  final String? supplierName;
  final String? beneficiaryName; // اسم المستفيد
  final double amount;
  final String paymentMethod; // نقدي، شيك، تحويل
  final String? checkNumber;
  final DateTime? checkDate;
  final String? bankName;
  final String currency; // دينار عراقي، دولار
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    this.supplierId,
    this.supplierName,
    this.beneficiaryName,
    required this.amount,
    this.paymentMethod = 'نقدي',
    this.checkNumber,
    this.checkDate,
    this.bankName,
    this.currency = 'دينار عراقي',
    this.description,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voucherNumber': voucherNumber,
      'date': date.toIso8601String(),
      'supplierId': supplierId,
      'supplierName': supplierName,
      'beneficiaryName': beneficiaryName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'checkNumber': checkNumber,
      'checkDate': checkDate?.toIso8601String(),
      'bankName': bankName,
      'currency': currency,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PaymentVoucher.fromMap(Map<String, dynamic> map) {
    return PaymentVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      beneficiaryName: map['beneficiaryName'],
      amount: map['amount'].toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'نقدي',
      checkNumber: map['checkNumber'],
      checkDate:
          map['checkDate'] != null ? DateTime.parse(map['checkDate']) : null,
      bankName: map['bankName'],
      currency: map['currency'] ?? 'دينار عراقي',
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

// سند دفع متعدد - Multiple Payment Voucher
class MultiplePaymentVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final List<PaymentItem> items;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MultiplePaymentVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voucherNumber': voucherNumber,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MultiplePaymentVoucher.fromMap(Map<String, dynamic> map) {
    return MultiplePaymentVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((item) => PaymentItem.fromMap(item))
          .toList(),
      totalAmount: map['totalAmount'].toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class PaymentItem {
  final String? supplierId;
  final String beneficiaryName;
  final double amount;
  final String currency;
  final String? description;

  PaymentItem({
    this.supplierId,
    required this.beneficiaryName,
    required this.amount,
    this.currency = 'دينار عراقي',
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'beneficiaryName': beneficiaryName,
      'amount': amount,
      'currency': currency,
      'description': description,
    };
  }

  factory PaymentItem.fromMap(Map<String, dynamic> map) {
    return PaymentItem(
      supplierId: map['supplierId'],
      beneficiaryName: map['beneficiaryName'],
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'دينار عراقي',
      description: map['description'],
    );
  }
}

// سند دفع بعملتين - Dual Currency Payment
class DualCurrencyPayment {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String? supplierId;
  final String? beneficiaryName;
  final double amountIQD;
  final double amountUSD;
  final double exchangeRate;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DualCurrencyPayment({
    this.id,
    required this.voucherNumber,
    required this.date,
    this.supplierId,
    this.beneficiaryName,
    required this.amountIQD,
    required this.amountUSD,
    required this.exchangeRate,
    this.description,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voucherNumber': voucherNumber,
      'date': date.toIso8601String(),
      'supplierId': supplierId,
      'beneficiaryName': beneficiaryName,
      'amountIQD': amountIQD,
      'amountUSD': amountUSD,
      'exchangeRate': exchangeRate,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DualCurrencyPayment.fromMap(Map<String, dynamic> map) {
    return DualCurrencyPayment(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      supplierId: map['supplierId'],
      beneficiaryName: map['beneficiaryName'],
      amountIQD: map['amountIQD'].toDouble(),
      amountUSD: map['amountUSD'].toDouble(),
      exchangeRate: map['exchangeRate'].toDouble(),
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

// سند صرف - Disbursement Voucher
class DisbursementVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String beneficiaryName;
  final double amount;
  final String currency;
  final String expenseType; // نوع المصروف: رواتب، إيجار، صيانة، أخرى
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DisbursementVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    required this.beneficiaryName,
    required this.amount,
    this.currency = 'دينار عراقي',
    required this.expenseType,
    this.description,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voucherNumber': voucherNumber,
      'date': date.toIso8601String(),
      'beneficiaryName': beneficiaryName,
      'amount': amount,
      'currency': currency,
      'expenseType': expenseType,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DisbursementVoucher.fromMap(Map<String, dynamic> map) {
    return DisbursementVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      beneficiaryName: map['beneficiaryName'],
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'دينار عراقي',
      expenseType: map['expenseType'],
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
