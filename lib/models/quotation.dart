class Quotation {
  final int? id;
  final String quotationNumber;
  final int? customerId;
  final String? customerName;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;
  final String status; // pending, approved, rejected, converted_to_sale
  final String? notes;
  final DateTime validUntil;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<QuotationItem> items;

  Quotation({
    this.id,
    required this.quotationNumber,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.finalAmount,
    this.status = 'pending',
    this.notes,
    DateTime? validUntil,
    DateTime? createdAt,
    this.updatedAt,
    this.items = const [],
  })  : validUntil = validUntil ?? DateTime.now().add(const Duration(days: 30)),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quotation_number': quotationNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'final_amount': finalAmount,
      'status': status,
      'notes': notes,
      'valid_until': validUntil.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Quotation.fromMap(Map<String, dynamic> map) {
    return Quotation(
      id: map['id'],
      quotationNumber: map['quotation_number'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      totalAmount: map['total_amount'].toDouble(),
      discount: map['discount']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      finalAmount: map['final_amount'].toDouble(),
      status: map['status'],
      notes: map['notes'],
      validUntil: DateTime.parse(map['valid_until']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Quotation copyWith({
    int? id,
    String? quotationNumber,
    int? customerId,
    String? customerName,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    String? status,
    String? notes,
    DateTime? validUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuotationItem>? items,
  }) {
    return Quotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class QuotationItem {
  final int? id;
  final int? quotationId;
  final int productId;
  final String productName;
  final String productBarcode;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discount;

  QuotationItem({
    this.id,
    this.quotationId,
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
      'quotation_id': quotationId,
      'product_id': productId,
      'product_name': productName,
      'product_barcode': productBarcode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
    };
  }

  factory QuotationItem.fromMap(Map<String, dynamic> map) {
    return QuotationItem(
      id: map['id'],
      quotationId: map['quotation_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productBarcode: map['product_barcode'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'].toDouble(),
      totalPrice: map['total_price'].toDouble(),
      discount: map['discount']?.toDouble(),
    );
  }

  QuotationItem copyWith({
    int? id,
    int? quotationId,
    int? productId,
    String? productName,
    String? productBarcode,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? discount,
  }) {
    return QuotationItem(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBarcode: productBarcode ?? this.productBarcode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
    );
  }
}
