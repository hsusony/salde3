class Purchase {
  final int? id;
  final String invoiceNumber;
  final DateTime createdAt;
  final int? supplierId;
  final String? supplierName;
  final List<PurchaseItem> items;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;
  final String paymentMethod; // نقدي، آجل، بطاقة
  final double paidAmount;
  final double remainingAmount;
  final String status; // مكتملة، معلقة
  final String? notes;
  final DateTime? updatedAt;

  Purchase({
    this.id,
    required this.invoiceNumber,
    required this.createdAt,
    this.supplierId,
    this.supplierName,
    required this.items,
    required this.totalAmount,
    this.discount = 0,
    this.tax = 0,
    required this.finalAmount,
    required this.paymentMethod,
    required this.paidAmount,
    this.remainingAmount = 0,
    this.status = 'completed',
    this.notes,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'created_at': createdAt.toIso8601String(),
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'notes': notes,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'] ?? map['PurchaseID'],
      invoiceNumber: map['invoice_number'] ?? map['InvoiceNumber'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : (map['PurchaseDate'] != null
              ? DateTime.parse(map['PurchaseDate'])
              : DateTime.now()),
      supplierId: map['supplier_id'] ?? map['SupplierID'],
      supplierName: map['supplier_name'] ?? map['SupplierName'],
      items: [], // سيتم جلبها من جدول منفصل
      totalAmount: (map['total_amount'] ?? map['TotalAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? map['Discount'] ?? 0).toDouble(),
      tax: (map['tax'] ?? map['Tax'] ?? 0).toDouble(),
      finalAmount: (map['final_amount'] ?? map['FinalAmount'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? map['PaymentMethod'] ?? 'cash',
      paidAmount: (map['paid_amount'] ?? map['PaidAmount'] ?? 0).toDouble(),
      remainingAmount:
          (map['remaining_amount'] ?? map['RemainingAmount'] ?? 0).toDouble(),
      status: map['status'] ?? map['Status'] ?? 'completed',
      notes: map['notes'] ?? map['Notes'],
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : (map['UpdatedAt'] != null
              ? DateTime.parse(map['UpdatedAt'])
              : null),
    );
  }

  Purchase copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? createdAt,
    int? supplierId,
    String? supplierName,
    List<PurchaseItem>? items,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    String? paymentMethod,
    double? paidAmount,
    double? remainingAmount,
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdAt: createdAt ?? this.createdAt,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PurchaseItem {
  final int? id;
  final int? purchaseId;
  final int productId;
  final String productName;
  final String productBarcode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  PurchaseItem({
    this.id,
    this.purchaseId,
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'product_name': productName,
      'product_barcode': productBarcode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'],
      purchaseId: map['purchase_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productBarcode: map['product_barcode'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'].toDouble(),
      totalPrice: map['total_price'].toDouble(),
    );
  }
}
