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
      customerId: map['customer_id'] ?? map['customerId'],
      customerName: map['customer_name'] ?? map['customerName'],
      totalAmount: (map['total_amount'] ?? map['totalAmount'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? map['paidAmount'] ?? 0).toDouble(),
      remainingAmount:
          (map['remaining_amount'] ?? map['remainingAmount'] ?? 0).toDouble(),
      numberOfInstallments:
          map['number_of_installments'] ?? map['numberOfInstallments'] ?? 0,
      paidInstallments:
          map['paid_installments'] ?? map['paidInstallments'] ?? 0,
      installmentAmount:
          (map['installment_amount'] ?? map['installmentAmount'] ?? 0)
              .toDouble(),
      startDate: map['start_date'] ?? map['startDate'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'active',
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
      installmentId: map['installment_id'] ?? map['installmentId'],
      customerName: map['customer_name'] ?? map['customerName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate: map['payment_date'] ?? map['paymentDate'] ?? '',
      installmentNumber:
          map['installment_number'] ?? map['installmentNumber'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }

  InstallmentPayment copyWith({
    int? id,
    int? installmentId,
    String? customerName,
    double? amount,
    String? paymentDate,
    int? installmentNumber,
    String? notes,
  }) {
    return InstallmentPayment(
      id: id ?? this.id,
      installmentId: installmentId ?? this.installmentId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      notes: notes ?? this.notes,
    );
  }
}
