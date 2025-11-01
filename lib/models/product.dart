class Product {
  final int? id;
  final String name;
  final String barcode;
  final List<String>? additionalBarcodes; // باركودات إضافية
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final int minQuantity;
  final int? cartonQuantity; // عدد القطع في الكارتون
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
    required this.quantity,
    this.minQuantity = 5,
    this.cartonQuantity,
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
      'quantity': quantity,
      'min_quantity': minQuantity,
      'carton_quantity': cartonQuantity,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      additionalBarcodes: map['additional_barcodes'] != null &&
              map['additional_barcodes'].toString().isNotEmpty
          ? map['additional_barcodes'].toString().split(',')
          : null,
      category: map['category'],
      purchasePrice: map['purchase_price'].toDouble(),
      sellingPrice: map['selling_price'].toDouble(),
      quantity: map['quantity'],
      minQuantity: map['min_quantity'] ?? 5,
      cartonQuantity: map['carton_quantity'],
      description: map['description'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
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
    int? quantity,
    int? minQuantity,
    int? cartonQuantity,
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
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      cartonQuantity: cartonQuantity ?? this.cartonQuantity,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
