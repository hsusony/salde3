class Product {
  final int? id;
  final String name;
  final String barcode;
  final List<String>? additionalBarcodes; // باركودات إضافية
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final double? wholesalePrice; // سعر البيع بالجملة
  final int quantity;
  final int minQuantity;
  final int? cartonQuantity; // عدد القطع في الكارتون
  final double? cartonPurchasePrice; // سعر شراء الكارتونة
  final double? cartonSellingPrice; // سعر بيع الكارتونة
  final double? discountPercent; // نسبة الخصم
  final double? taxBuy; // ضريبة الشراء
  final double? taxSell; // ضريبة البيع
  final bool exemptFromTax; // معفاة من الضريبة
  final String? specifications; // المواصفات
  final String? source; // المصدر
  final String? unitNumber; // رقم الوحدة
  final String? location; // الموقع
  final double? minLimit; // الحد الأدنى
  final String? serialNumber; // تسلسل العادة
  final String? note; // الملاحظة
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.barcode,
    this.additionalBarcodes,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    this.wholesalePrice,
    required this.quantity,
    this.minQuantity = 5,
    this.cartonQuantity,
    this.cartonPurchasePrice,
    this.cartonSellingPrice,
    this.discountPercent,
    this.taxBuy,
    this.taxSell,
    this.exemptFromTax = false,
    this.specifications,
    this.source,
    this.unitNumber,
    this.location,
    this.minLimit,
    this.serialNumber,
    this.note,
    this.description,
    this.imageUrl,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get profit => sellingPrice - purchasePrice;
  double get profitMargin => ((profit / purchasePrice) * 100);
  bool get isLowStock => quantity <= minQuantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'additional_barcodes': additionalBarcodes?.join(','),
      'category': category,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'wholesale_price': wholesalePrice,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'carton_quantity': cartonQuantity,
      'carton_purchase_price': cartonPurchasePrice,
      'carton_selling_price': cartonSellingPrice,
      'discount_percent': discountPercent,
      'tax_buy': taxBuy,
      'tax_sell': taxSell,
      'exempt_from_tax': exemptFromTax ? 1 : 0,
      'specifications': specifications,
      'source': source,
      'unit_number': unitNumber,
      'location': location,
      'min_limit': minLimit,
      'serial_number': serialNumber,
      'note': note,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? map['ProductID'],
      name: map['name'] ?? map['Name'] ?? '',
      barcode: map['barcode'] ?? map['Barcode'] ?? '',
      additionalBarcodes: map['additional_barcodes'] != null &&
              map['additional_barcodes'].toString().isNotEmpty
          ? map['additional_barcodes'].toString().split(',')
          : null,
      category: map['category'] ??
          map['Category'] ??
          map['CategoryID']?.toString() ??
          '',
      purchasePrice:
          (map['purchase_price'] ?? map['BuyingPrice'] ?? 0).toDouble(),
      sellingPrice:
          (map['selling_price'] ?? map['SellingPrice'] ?? 0).toDouble(),
      wholesalePrice: map['wholesale_price'] != null
          ? (map['wholesale_price']).toDouble()
          : null,
      quantity: (map['quantity'] ?? map['Stock'] ?? 0).toInt(),
      minQuantity: (map['min_quantity'] ?? map['MinStock'] ?? 5).toInt(),
      cartonQuantity: map['carton_quantity'] ?? map['CartonQuantity'],
      cartonPurchasePrice: map['carton_purchase_price'] != null
          ? (map['carton_purchase_price']).toDouble()
          : null,
      cartonSellingPrice: map['carton_selling_price'] != null
          ? (map['carton_selling_price']).toDouble()
          : null,
      discountPercent: map['discount_percent'] != null
          ? (map['discount_percent']).toDouble()
          : null,
      taxBuy: map['tax_buy'] != null ? (map['tax_buy']).toDouble() : null,
      taxSell: map['tax_sell'] != null ? (map['tax_sell']).toDouble() : null,
      exemptFromTax: (map['exempt_from_tax'] ?? 0) == 1,
      specifications: map['specifications'],
      source: map['source'],
      unitNumber: map['unit_number'],
      location: map['location'],
      minLimit: map['min_limit'] != null ? (map['min_limit']).toDouble() : null,
      serialNumber: map['serial_number'],
      note: map['note'],
      description: map['description'] ?? map['Description'],
      imageUrl: map['image_url'] ?? map['ImageUrl'],
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
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    List<String>? additionalBarcodes,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    double? wholesalePrice,
    int? quantity,
    int? minQuantity,
    int? cartonQuantity,
    double? cartonPurchasePrice,
    double? cartonSellingPrice,
    double? discountPercent,
    double? taxBuy,
    double? taxSell,
    bool? exemptFromTax,
    String? specifications,
    String? source,
    String? unitNumber,
    String? location,
    double? minLimit,
    String? serialNumber,
    String? note,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      additionalBarcodes: additionalBarcodes ?? this.additionalBarcodes,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      cartonQuantity: cartonQuantity ?? this.cartonQuantity,
      cartonPurchasePrice: cartonPurchasePrice ?? this.cartonPurchasePrice,
      cartonSellingPrice: cartonSellingPrice ?? this.cartonSellingPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxBuy: taxBuy ?? this.taxBuy,
      taxSell: taxSell ?? this.taxSell,
      exemptFromTax: exemptFromTax ?? this.exemptFromTax,
      specifications: specifications ?? this.specifications,
      source: source ?? this.source,
      unitNumber: unitNumber ?? this.unitNumber,
      location: location ?? this.location,
      minLimit: minLimit ?? this.minLimit,
      serialNumber: serialNumber ?? this.serialNumber,
      note: note ?? this.note,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
