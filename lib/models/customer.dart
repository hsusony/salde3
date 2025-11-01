class Customer {
  final int? id;
  final String name;
  final String? customerCode; // كود العميل
  final String phone;
  final String? email;
  final String? address;
  final String? company;
  final double balance; // المستحقات
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.customerCode,
    required this.phone,
    this.email,
    this.address,
    this.company,
    this.balance = 0.0,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'customer_code': customerCode,
      'phone': phone,
      'email': email,
      'address': address,
      'company': company,
      'balance': balance,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      customerCode: map['customer_code'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      company: map['company'],
      balance: map['balance']?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? customerCode,
    String? phone,
    String? email,
    String? address,
    String? company,
    double? balance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      customerCode: customerCode ?? this.customerCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      company: company ?? this.company,
      balance: balance ?? this.balance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
