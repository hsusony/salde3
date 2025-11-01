class WarehouseStock {
  final int? id;
  final int warehouseId;
  final int productId;
  final double quantity;
  final double? minQuantity;
  final double? maxQuantity;
  final String? location; // موقع المادة في المخزن
  final DateTime lastUpdated;

  WarehouseStock({
    this.id,
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    this.minQuantity,
    this.maxQuantity,
    this.location,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'warehouse_id': warehouseId,
      'product_id': productId,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'location': location,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory WarehouseStock.fromMap(Map<String, dynamic> map) {
    return WarehouseStock(
      id: map['id'],
      warehouseId: map['warehouse_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      minQuantity: map['min_quantity'],
      maxQuantity: map['max_quantity'],
      location: map['location'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }

  bool get isLowStock {
    if (minQuantity == null) return false;
    return quantity <= minQuantity!;
  }

  bool get isOverStock {
    if (maxQuantity == null) return false;
    return quantity >= maxQuantity!;
  }
}
