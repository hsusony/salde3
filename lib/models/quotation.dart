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
      'quotationNumber': quotationNumber,
      'customerId': customerId,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'discount': discount,
      'tax': tax,
      'finalAmount': finalAmount,
      'status': status,
      'notes': notes,
      'validUntil': validUntil.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Quotation.fromMap(Map<String, dynamic> map) {
    // Parse items if available
    List<QuotationItem> itemsList = [];
    if (map['items'] != null && map['items'] is List) {
      itemsList = (map['items'] as List)
          .map((item) => QuotationItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return Quotation(
      id: map['QuotationID'] ?? map['id'],
      quotationNumber: map['QuotationNumber'] ?? map['quotation_number'] ?? '',
      customerId: map['CustomerID'] ?? map['customer_id'],
      customerName:
          map['CustomerName'] ?? map['customer_name'] ?? map['customerName'],
      totalAmount: (map['TotalAmount'] ?? map['total_amount'] ?? 0).toDouble(),
      discount: (map['Discount'] ?? map['discount'] ?? 0).toDouble(),
      tax: (map['Tax'] ?? map['tax'] ?? 0).toDouble(),
      finalAmount: (map['FinalAmount'] ?? map['final_amount'] ?? 0).toDouble(),
      status: map['Status'] ?? map['status'] ?? 'pending',
      notes: map['Notes'] ?? map['notes'],
      validUntil: map['ValidUntil'] != null
          ? DateTime.parse(map['ValidUntil'])
          : (map['valid_until'] != null
              ? DateTime.parse(map['valid_until'])
              : DateTime.now().add(const Duration(days: 30))),
      createdAt: map['CreatedDate'] != null
          ? DateTime.parse(map['CreatedDate'])
          : (map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now()),
      updatedAt: map['UpdatedDate'] != null
          ? DateTime.parse(map['UpdatedDate'])
          : (map['updated_at'] != null
              ? DateTime.parse(map['updated_at'])
              : null),
      items: itemsList,
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
      'productId': productId,
      'productName': productName,
      'productBarcode': productBarcode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discount': discount,
    };
  }

  factory QuotationItem.fromMap(Map<String, dynamic> map) {
    return QuotationItem(
      id: map['QuotationItemID'] ?? map['id'],
      quotationId: map['QuotationID'] ?? map['quotation_id'],
      productId: map['ProductID'] ?? map['product_id'] ?? 0,
      productName: map['ProductName'] ?? map['product_name'] ?? '',
      productBarcode: map['ProductBarcode'] ?? map['product_barcode'] ?? '',
      quantity: map['Quantity'] ?? map['quantity'] ?? 0,
      unitPrice: (map['UnitPrice'] ?? map['unit_price'] ?? 0).toDouble(),
      totalPrice: (map['TotalPrice'] ?? map['total_price'] ?? 0).toDouble(),
      discount: (map['Discount'] ?? map['discount'] ?? 0).toDouble(),
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
