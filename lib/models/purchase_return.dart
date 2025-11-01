class PurchaseReturn {
  final int? id;
  final String returnNumber;
  final DateTime createdAt;
  final int? purchaseId;
  final String? purchaseInvoiceNumber;
  final int? supplierId;
  final String? supplierName;
  final List<PurchaseReturnItem> items;
  final double totalAmount;
  final String reason; // سبب الإرجاع
  final String status; // مكتملة، معلقة
  final String? notes;
  final DateTime? updatedAt;

  PurchaseReturn({
    this.id,
    required this.returnNumber,
    required this.createdAt,
    this.purchaseId,
    this.purchaseInvoiceNumber,
    this.supplierId,
    this.supplierName,
    required this.items,
    required this.totalAmount,
    required this.reason,
    this.status = 'completed',
    this.notes,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'return_number': returnNumber,
      'created_at': createdAt.toIso8601String(),
      'purchase_id': purchaseId,
      'purchase_invoice_number': purchaseInvoiceNumber,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'total_amount': totalAmount,
      'reason': reason,
      'status': status,
      'notes': notes,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PurchaseReturn.fromMap(Map<String, dynamic> map) {
    return PurchaseReturn(
      id: map['id'],
      returnNumber: map['return_number'],
      createdAt: DateTime.parse(map['created_at']),
      purchaseId: map['purchase_id'],
      purchaseInvoiceNumber: map['purchase_invoice_number'],
      supplierId: map['supplier_id'],
      supplierName: map['supplier_name'],
      items: [], // سيتم جلبها من جدول منفصل
      totalAmount: map['total_amount'].toDouble(),
      reason: map['reason'],
      status: map['status'],
      notes: map['notes'],
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  PurchaseReturn copyWith({
    int? id,
    String? returnNumber,
    DateTime? createdAt,
    int? purchaseId,
    String? purchaseInvoiceNumber,
    int? supplierId,
    String? supplierName,
    List<PurchaseReturnItem>? items,
    double? totalAmount,
    String? reason,
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PurchaseReturn(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      createdAt: createdAt ?? this.createdAt,
      purchaseId: purchaseId ?? this.purchaseId,
      purchaseInvoiceNumber:
          purchaseInvoiceNumber ?? this.purchaseInvoiceNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PurchaseReturnItem {
  final int? id;
  final int? returnId;
  final int productId;
  final String productName;
  final String productBarcode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  PurchaseReturnItem({
    this.id,
    this.returnId,
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
      'return_id': returnId,
      'product_id': productId,
      'product_name': productName,
      'product_barcode': productBarcode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory PurchaseReturnItem.fromMap(Map<String, dynamic> map) {
    return PurchaseReturnItem(
      id: map['id'],
      returnId: map['return_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productBarcode: map['product_barcode'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'].toDouble(),
      totalPrice: map['total_price'].toDouble(),
    );
  }
}
