class AuditLog {
  final int? id;
  final String operationType; // حذف، تعديل، إضافة
  final String tableName; // products, customers, etc.
  final int recordId;
  final String recordName;
  final String? recordData;
  final String userName;
  final DateTime operationDate;
  final String? notes;
  final bool synced;
  final String? syncId;

  AuditLog({
    this.id,
    required this.operationType,
    required this.tableName,
    required this.recordId,
    required this.recordName,
    this.recordData,
    required this.userName,
    required this.operationDate,
    this.notes,
    this.synced = false,
    this.syncId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation_type': operationType,
      'table_name': tableName,
      'record_id': recordId,
      'record_name': recordName,
      'record_data': recordData,
      'user_name': userName,
      'operation_date': operationDate.toIso8601String(),
      'notes': notes,
      'synced': synced ? 1 : 0,
      'sync_id': syncId,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as int?,
      operationType: map['operation_type'] as String,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as int,
      recordName: map['record_name'] as String,
      recordData: map['record_data'] as String?,
      userName: map['user_name'] as String,
      operationDate: DateTime.parse(map['operation_date'] as String),
      notes: map['notes'] as String?,
      synced: map['synced'] == 1,
      syncId: map['sync_id'] as String?,
    );
  }

  AuditLog copyWith({
    int? id,
    String? operationType,
    String? tableName,
    int? recordId,
    String? recordName,
    String? recordData,
    String? userName,
    DateTime? operationDate,
    String? notes,
    bool? synced,
    String? syncId,
  }) {
    return AuditLog(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      recordName: recordName ?? this.recordName,
      recordData: recordData ?? this.recordData,
      userName: userName ?? this.userName,
      operationDate: operationDate ?? this.operationDate,
      notes: notes ?? this.notes,
      synced: synced ?? this.synced,
      syncId: syncId ?? this.syncId,
    );
  }
}
