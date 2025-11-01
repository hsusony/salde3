class Installment {
  final int? id;
  final int customerId;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final int numberOfInstallments;
  final int paidInstallments;
  final double installmentAmount;
  final String startDate;
  final String notes;
  final String status; // active, completed, overdue

  Installment({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.numberOfInstallments,
    required this.paidInstallments,
    required this.installmentAmount,
    required this.startDate,
    required this.notes,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'numberOfInstallments': numberOfInstallments,
      'paidInstallments': paidInstallments,
      'installmentAmount': installmentAmount,
      'startDate': startDate,
      'notes': notes,
      'status': status,
    };
  }

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      totalAmount: map['totalAmount'],
      paidAmount: map['paidAmount'],
      remainingAmount: map['remainingAmount'],
      numberOfInstallments: map['numberOfInstallments'],
      paidInstallments: map['paidInstallments'],
      installmentAmount: map['installmentAmount'],
      startDate: map['startDate'],
      notes: map['notes'],
      status: map['status'],
    );
  }

  Installment copyWith({
    int? id,
    int? customerId,
    String? customerName,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    int? numberOfInstallments,
    int? paidInstallments,
    double? installmentAmount,
    String? startDate,
    String? notes,
    String? status,
  }) {
    return Installment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      numberOfInstallments: numberOfInstallments ?? this.numberOfInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

class InstallmentPayment {
  final int? id;
  final int installmentId;
  final String customerName;
  final double amount;
  final String paymentDate;
  final int installmentNumber;
  final String notes;

  InstallmentPayment({
    this.id,
    required this.installmentId,
    required this.customerName,
    required this.amount,
    required this.paymentDate,
    required this.installmentNumber,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'installmentId': installmentId,
      'customerName': customerName,
      'amount': amount,
      'paymentDate': paymentDate,
      'installmentNumber': installmentNumber,
      'notes': notes,
    };
  }

  factory InstallmentPayment.fromMap(Map<String, dynamic> map) {
    return InstallmentPayment(
      id: map['id'],
      installmentId: map['installmentId'],
      customerName: map['customerName'],
      amount: map['amount'],
      paymentDate: map['paymentDate'],
      installmentNumber: map['installmentNumber'],
      notes: map['notes'],
    );
  }
}
