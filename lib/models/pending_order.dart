class PendingOrder {
  final int? id;
  final String orderNumber;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;
  final double depositAmount; // المبلغ المدفوع مقدماً
  final double remainingAmount;
  final String status; // pending, completed, cancelled
  final String? notes;
  final DateTime? deliveryDate; // تاريخ التسليم المتوقع
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PendingOrderItem> items;

  PendingOrder({
    this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.totalAmount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.finalAmount,
    this.depositAmount = 0.0,
    required this.remainingAmount,
    this.status = 'pending',
    this.notes,
    this.deliveryDate,
    DateTime? createdAt,
    this.updatedAt,
    this.items = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'final_amount': finalAmount,
      'deposit_amount': depositAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'notes': notes,
      'delivery_date': deliveryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PendingOrder.fromMap(Map<String, dynamic> map) {
    return PendingOrder(
      id: map['id'],
      orderNumber: map['order_number'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      totalAmount: map['total_amount'].toDouble(),
      discount: map['discount']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      finalAmount: map['final_amount'].toDouble(),
      depositAmount: map['deposit_amount']?.toDouble() ?? 0.0,
      remainingAmount: map['remaining_amount'].toDouble(),
      status: map['status'],
      notes: map['notes'],
      deliveryDate: map['delivery_date'] != null
          ? DateTime.parse(map['delivery_date'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  PendingOrder copyWith({
    int? id,
    String? orderNumber,
    int? customerId,
    String? customerName,
    String? customerPhone,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    double? depositAmount,
    double? remainingAmount,
    String? status,
    String? notes,
    DateTime? deliveryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PendingOrderItem>? items,
  }) {
    return PendingOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class PendingOrderItem {
  final int? id;
  final int? pendingOrderId;
  final int productId;
  final String productName;
  final String productBarcode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discount;
  final String? notes; // ملاحظات خاصة بالمنتج

  PendingOrderItem({
    this.id,
    this.pendingOrderId,
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discount,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pending_order_id': pendingOrderId,
      'product_id': productId,
      'product_name': productName,
      'product_barcode': productBarcode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
      'notes': notes,
    };
  }

  factory PendingOrderItem.fromMap(Map<String, dynamic> map) {
    return PendingOrderItem(
      id: map['id'],
      pendingOrderId: map['pending_order_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productBarcode: map['product_barcode'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'].toDouble(),
      totalPrice: map['total_price'].toDouble(),
      discount: map['discount']?.toDouble(),
      notes: map['notes'],
    );
  }

  PendingOrderItem copyWith({
    int? id,
    int? pendingOrderId,
    int? productId,
    String? productName,
    String? productBarcode,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? discount,
    String? notes,
  }) {
    return PendingOrderItem(
      id: id ?? this.id,
      pendingOrderId: pendingOrderId ?? this.pendingOrderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBarcode: productBarcode ?? this.productBarcode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
    );
  }
}
