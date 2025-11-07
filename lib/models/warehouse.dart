class Warehouse {
  final int? id;
  final String name;
  final String location;
  final String? description;
  final String? manager;
  final bool isActive;
  final DateTime createdAt;

  Warehouse({
    this.id,
    required this.name,
    required this.location,
    this.description,
    this.manager,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'description': description,
      'notes': description, // للتوافق مع DB
      'manager': manager,
      'is_active': isActive ? 1 : 0,
      'isActive': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'] ?? map['WarehouseID'],
      name: map['name'] ?? map['Name'] ?? '',
      location: map['location'] ?? map['Location'] ?? '',
      description: map['description'] ?? map['Description'] ?? map['notes'],
      manager: map['manager'] ?? map['Manager'],
      isActive: map['is_active'] == 1 ||
          map['isActive'] == true ||
          map['isActive'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : (map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now()),
    );
  }
}
