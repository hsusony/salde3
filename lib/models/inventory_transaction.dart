enum InventoryTransactionType {
  stockIn, // إدخال مخزني
  stockOut, // إخراج مخزني
  transfer, // نقل بين مخازن
  adjustment, // تسوية مخزنية
  damaged, // مواد تالفة
  consumed, // مواد مستهلكة
  donation, // إهداء مواد
  import, // استيراد مواد
  materialOrder, // طلبية مواد
}

class InventoryTransaction {
  final int? id;
  final InventoryTransactionType type;
  final String transactionNumber;
  final int? productId;
  final int? warehouseFromId;
  final int? warehouseToId;
  final double quantity;
  final double? unitCost;
  final double? totalCost;
  final String? notes;
  final String? reference;
  final DateTime transactionDate;
  final String? createdBy;
  final DateTime createdAt;

  InventoryTransaction({
    this.id,
    required this.type,
    required this.transactionNumber,
    this.productId,
    this.warehouseFromId,
    this.warehouseToId,
    required this.quantity,
    this.unitCost,
    this.totalCost,
    this.notes,
    this.reference,
    DateTime? transactionDate,
    this.createdBy,
    DateTime? createdAt,
  })  : transactionDate = transactionDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'transaction_number': transactionNumber,
      'product_id': productId,
      'warehouse_from_id': warehouseFromId,
      'warehouse_to_id': warehouseToId,
      'quantity': quantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'notes': notes,
      'reference': reference,
      'transaction_date': transactionDate.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'],
      type: InventoryTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      transactionNumber: map['transaction_number'],
      productId: map['product_id'],
      warehouseFromId: map['warehouse_from_id'],
      warehouseToId: map['warehouse_to_id'],
      quantity: map['quantity'],
      unitCost: map['unit_cost'],
      totalCost: map['total_cost'],
      notes: map['notes'],
      reference: map['reference'],
      transactionDate: DateTime.parse(map['transaction_date']),
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String getTypeLabel() {
    switch (type) {
      case InventoryTransactionType.stockIn:
        return 'إدخال مخزني';
      case InventoryTransactionType.stockOut:
        return 'إخراج مخزني';
      case InventoryTransactionType.transfer:
        return 'نقل بين مخازن';
      case InventoryTransactionType.adjustment:
        return 'تسوية مخزنية';
      case InventoryTransactionType.damaged:
        return 'مواد تالفة';
      case InventoryTransactionType.consumed:
        return 'مواد مستهلكة';
      case InventoryTransactionType.donation:
        return 'إهداء مواد';
      case InventoryTransactionType.import:
        return 'استيراد مواد';
      case InventoryTransactionType.materialOrder:
        return 'طلبية مواد';
    }
  }
}
