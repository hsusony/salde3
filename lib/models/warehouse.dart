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
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'manager': manager,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      description: map['description'],
      manager: map['manager'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
