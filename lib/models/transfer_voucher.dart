// سند حوالة - Remittance Voucher
class RemittanceVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String senderName;
  final String receiverName;
  final double amount;
  final String currency;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RemittanceVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    required this.senderName,
    required this.receiverName,
    required this.amount,
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
      'senderName': senderName,
      'receiverName': receiverName,
      'amount': amount,
      'currency': currency,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RemittanceVoucher.fromMap(Map<String, dynamic> map) {
    return RemittanceVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      senderName: map['senderName'],
      receiverName: map['receiverName'],
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'دينار عراقي',
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

// سند صيرفة - Exchange Voucher
class ExchangeVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final double amountIQD;
  final double amountUSD;
  final double exchangeRate;
  final String exchangeType; // شراء دولار، بيع دولار
  final String? customerName;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExchangeVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    required this.amountIQD,
    required this.amountUSD,
    required this.exchangeRate,
    required this.exchangeType,
    this.customerName,
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
      'amountIQD': amountIQD,
      'amountUSD': amountUSD,
      'exchangeRate': exchangeRate,
      'exchangeType': exchangeType,
      'customerName': customerName,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ExchangeVoucher.fromMap(Map<String, dynamic> map) {
    return ExchangeVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      amountIQD: map['amountIQD'].toDouble(),
      amountUSD: map['amountUSD'].toDouble(),
      exchangeRate: map['exchangeRate'].toDouble(),
      exchangeType: map['exchangeType'],
      customerName: map['customerName'],
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

// سند تحويل - Transfer Voucher
class TransferVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final String fromAccount; // من: صندوق، خزينة، بنك
  final String toAccount; // إلى: صندوق، خزينة، بنك
  final String fromAccountName; // اسم الصندوق/الخزينة المصدر
  final String toAccountName; // اسم الصندوق/الخزينة المستلم
  final double amount;
  final String currency;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransferVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    required this.fromAccount,
    required this.toAccount,
    required this.fromAccountName,
    required this.toAccountName,
    required this.amount,
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
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'fromAccountName': fromAccountName,
      'toAccountName': toAccountName,
      'amount': amount,
      'currency': currency,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TransferVoucher.fromMap(Map<String, dynamic> map) {
    return TransferVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      fromAccount: map['fromAccount'],
      toAccount: map['toAccount'],
      fromAccountName: map['fromAccountName'],
      toAccountName: map['toAccountName'],
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'دينار عراقي',
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

// سند توزيع الأرباح - Profit Distribution Voucher
class ProfitDistributionVoucher {
  final String? id;
  final String voucherNumber;
  final DateTime date;
  final List<ProfitShare> shares;
  final double totalAmount;
  final String? period; // الفترة: شهري، ربع سنوي، سنوي
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProfitDistributionVoucher({
    this.id,
    required this.voucherNumber,
    required this.date,
    required this.shares,
    required this.totalAmount,
    this.period,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voucherNumber': voucherNumber,
      'date': date.toIso8601String(),
      'shares': shares.map((share) => share.toMap()).toList(),
      'totalAmount': totalAmount,
      'period': period,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ProfitDistributionVoucher.fromMap(Map<String, dynamic> map) {
    return ProfitDistributionVoucher(
      id: map['id'],
      voucherNumber: map['voucherNumber'],
      date: DateTime.parse(map['date']),
      shares: (map['shares'] as List)
          .map((share) => ProfitShare.fromMap(share))
          .toList(),
      totalAmount: map['totalAmount'].toDouble(),
      period: map['period'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class ProfitShare {
  final String partnerName;
  final double percentage; // النسبة المئوية
  final double amount;

  ProfitShare({
    required this.partnerName,
    required this.percentage,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'partnerName': partnerName,
      'percentage': percentage,
      'amount': amount,
    };
  }

  factory ProfitShare.fromMap(Map<String, dynamic> map) {
    return ProfitShare(
      partnerName: map['partnerName'],
      percentage: map['percentage'].toDouble(),
      amount: map['amount'].toDouble(),
    );
  }
}
