// نموذج سند القبض - Receipt Voucher
class ReceiptVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String? customerId;
  final String? customerName;
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

  ReceiptVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    this.customerId,
    this.customerName,
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
      'customerId': customerId,
      'customerName': customerName,
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

  factory ReceiptVoucher.fromMap(Map<String, dynamic> map) {
    return ReceiptVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      customerId: map['customerId'],
      customerName: map['customerName'],
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

  ReceiptVoucher copyWith({
    String? id,
    String? voucherNumber,
    DateTime? date,
    String? customerId,
    String? customerName,
    double? amount,
    String? paymentMethod,
    String? checkNumber,
    DateTime? checkDate,
    String? bankName,
    String? currency,
    String? description,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ReceiptVoucher(
      id: id ?? this.id,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      checkNumber: checkNumber ?? this.checkNumber,
      checkDate: checkDate ?? this.checkDate,
      bankName: bankName ?? this.bankName,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// سند قبض متعدد - Multiple Receipt Voucher
class MultipleReceiptVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final List<ReceiptItem> items;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MultipleReceiptVoucher({
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

  factory MultipleReceiptVoucher.fromMap(Map<String, dynamic> map) {
    return MultipleReceiptVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((item) => ReceiptItem.fromMap(item))
          .toList(),
      totalAmount: map['totalAmount'].toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class ReceiptItem {
  final String? customerId;
  final String customerName;
  final double amount;
  final String currency;
  final String? description;

  ReceiptItem({
    this.customerId,
    required this.customerName,
    required this.amount,
    this.currency = 'دينار عراقي',
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'currency': currency,
      'description': description,
    };
  }

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      customerId: map['customerId'],
      customerName: map['customerName'],
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'دينار عراقي',
      description: map['description'],
    );
  }
}

// سند قبض بعملتين - Dual Currency Receipt
class DualCurrencyReceipt {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String? customerId;
  final String? customerName;
  final double amountIQD; // المبلغ بالدينار
  final double amountUSD; // المبلغ بالدولار
  final double exchangeRate; // سعر الصرف
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DualCurrencyReceipt({
    this.id,
    required this.voucherNumber,
    required this.date,
    this.customerId,
    this.customerName,
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
      'customerId': customerId,
      'customerName': customerName,
      'amountIQD': amountIQD,
      'amountUSD': amountUSD,
      'exchangeRate': exchangeRate,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DualCurrencyReceipt.fromMap(Map<String, dynamic> map) {
    return DualCurrencyReceipt(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      customerId: map['customerId'],
      customerName: map['customerName'],
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
