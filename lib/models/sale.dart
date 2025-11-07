class Sale {
  final int? id;
  final String invoiceNumber;
  final int? customerId;
  final String? customerName;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentMethod; // cash, credit, bank_transfer
  final String status; // completed, pending, cancelled
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.finalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.paymentMethod = 'cash',
    this.status = 'completed',
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.items = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'final_amount': finalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    // تحويل items من JSON إلى List<SaleItem>
    List<SaleItem> items = [];
    if (map['items'] != null && map['items'] is List) {
      items = (map['items'] as List)
          .map((item) => SaleItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return Sale(
      id: map['id'] ?? map['SaleID'],
      invoiceNumber: map['invoice_number'] ?? map['InvoiceNumber'] ?? '',
      customerId: map['customer_id'] ?? map['CustomerID'],
      customerName: map['customer_name'] ?? map['CustomerName'],
      totalAmount: (map['total_amount'] ?? map['TotalAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? map['Discount'] ?? 0).toDouble(),
      tax: (map['tax'] ?? map['Tax'] ?? 0).toDouble(),
      finalAmount: (map['final_amount'] ?? map['FinalAmount'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? map['PaidAmount'] ?? 0).toDouble(),
      remainingAmount:
          (map['remaining_amount'] ?? map['RemainingAmount'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? map['PaymentMethod'] ?? 'cash',
      status: map['status'] ?? map['Status'] ?? 'completed',
      notes: map['notes'] ?? map['Notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : (map['CreatedAt'] != null
              ? DateTime.parse(map['CreatedAt'])
              : DateTime.now()),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : (map['UpdatedAt'] != null
              ? DateTime.parse(map['UpdatedAt'])
              : null),
      items: items,
    );
  }

  Sale copyWith({
    int? id,
    String? invoiceNumber,
    int? customerId,
    String? customerName,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    double? paidAmount,
    double? remainingAmount,
    String? paymentMethod,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class SaleItem {
  final int? id;
  final int? saleId;
  final int productId;
  final String productName;
  final String productBarcode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discount;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'product_barcode': productBarcode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productBarcode: map['product_barcode'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'].toDouble(),
      totalPrice: map['total_price'].toDouble(),
      discount: map['discount']?.toDouble(),
    );
  }
}
