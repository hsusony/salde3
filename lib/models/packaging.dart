class Packaging {
  final int? id;
  final String name;
  final double quantityPerUnit;
  final String? barcode;
  final bool isActive;
  final DateTime createdAt;

  Packaging({
    this.id,
    required this.name,
    required this.quantityPerUnit,
    this.barcode,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity_per_unit': quantityPerUnit,
      'barcode': barcode,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Packaging.fromMap(Map<String, dynamic> map) {
    return Packaging(
      id: map['id'],
      name: map['name'],
      quantityPerUnit: map['quantity_per_unit'],
      barcode: map['barcode'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
