// قيد محاسبي - Journal Entry
class JournalEntry {
  final String? id;
  final String entryNumber;
  final DateTime date;
  final String debitAccount; // الحساب المدين
  final String creditAccount; // الحساب الدائن
  final double amount;
  final String currency;
  final String? description;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntry({
    this.id,
    required this.entryNumber,
    required this.date,
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    this.currency = 'دينار عراقي',
    this.description,
    this.referenceNumber,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryNumber': entryNumber,
      'date': date.toIso8601String(),
      'debitAccount': debitAccount,
      'creditAccount': creditAccount,
      'amount': amount,
      'currency': currency,
      'description': description,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      entryNumber: map['entryNumber'],
      date: DateTime.parse(map['date']),
      debitAccount: map['debitAccount'],
      creditAccount: map['creditAccount'],
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'دينار عراقي',
      description: map['description'],
      referenceNumber: map['referenceNumber'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

// قيد محاسبي متعدد - Multiple Journal Entry
class MultipleJournalEntry {
  final String? id;
  final String entryNumber;
  final DateTime date;
  final List<JournalEntryLine> entries;
  final double totalDebit;
  final double totalCredit;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MultipleJournalEntry({
    this.id,
    required this.entryNumber,
    required this.date,
    required this.entries,
    required this.totalDebit,
    required this.totalCredit,
    this.description,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isBalanced => totalDebit == totalCredit;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryNumber': entryNumber,
      'date': date.toIso8601String(),
      'entries': entries.map((entry) => entry.toMap()).toList(),
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MultipleJournalEntry.fromMap(Map<String, dynamic> map) {
    return MultipleJournalEntry(
      id: map['id'],
      entryNumber: map['entryNumber'],
      date: DateTime.parse(map['date']),
      entries: (map['entries'] as List)
          .map((entry) => JournalEntryLine.fromMap(entry))
          .toList(),
      totalDebit: map['totalDebit'].toDouble(),
      totalCredit: map['totalCredit'].toDouble(),
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class JournalEntryLine {
  final String accountName;
  final String accountType; // مدين، دائن
  final double amount;
  final String? description;

  JournalEntryLine({
    required this.accountName,
    required this.accountType,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'accountType': accountType,
      'amount': amount,
      'description': description,
    };
  }

  factory JournalEntryLine.fromMap(Map<String, dynamic> map) {
    return JournalEntryLine(
      accountName: map['accountName'],
      accountType: map['accountType'],
      amount: map['amount'].toDouble(),
      description: map['description'],
    );
  }
}

// قيد مركب - Compound Journal Entry
class CompoundJournalEntry {
  final String? id;
  final String entryNumber;
  final DateTime date;
  final List<DebitEntry> debitEntries;
  final List<CreditEntry> creditEntries;
  final double totalAmount;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CompoundJournalEntry({
    this.id,
    required this.entryNumber,
    required this.date,
    required this.debitEntries,
    required this.creditEntries,
    required this.totalAmount,
    this.description,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalDebit =>
      debitEntries.fold(0, (sum, entry) => sum + entry.amount);
  double get totalCredit =>
      creditEntries.fold(0, (sum, entry) => sum + entry.amount);
  bool get isBalanced => totalDebit == totalCredit;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryNumber': entryNumber,
      'date': date.toIso8601String(),
      'debitEntries': debitEntries.map((entry) => entry.toMap()).toList(),
      'creditEntries': creditEntries.map((entry) => entry.toMap()).toList(),
      'totalAmount': totalAmount,
      'description': description,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CompoundJournalEntry.fromMap(Map<String, dynamic> map) {
    return CompoundJournalEntry(
      id: map['id'],
      entryNumber: map['entryNumber'],
      date: DateTime.parse(map['date']),
      debitEntries: (map['debitEntries'] as List)
          .map((entry) => DebitEntry.fromMap(entry))
          .toList(),
      creditEntries: (map['creditEntries'] as List)
          .map((entry) => CreditEntry.fromMap(entry))
          .toList(),
      totalAmount: map['totalAmount'].toDouble(),
      description: map['description'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class DebitEntry {
  final String accountName;
  final double amount;
  final String? description;

  DebitEntry({
    required this.accountName,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'amount': amount,
      'description': description,
    };
  }

  factory DebitEntry.fromMap(Map<String, dynamic> map) {
    return DebitEntry(
      accountName: map['accountName'],
      amount: map['amount'].toDouble(),
      description: map['description'],
    );
  }
}

class CreditEntry {
  final String accountName;
  final double amount;
  final String? description;

  CreditEntry({
    required this.accountName,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'amount': amount,
      'description': description,
    };
  }

  factory CreditEntry.fromMap(Map<String, dynamic> map) {
    return CreditEntry(
      accountName: map['accountName'],
      amount: map['amount'].toDouble(),
      description: map['description'],
    );
  }
}
