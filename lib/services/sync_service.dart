import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'sql_server_service.dart';
import '../models/cash_voucher.dart';

/// خدمة المزامنة التلقائية مع SQL Server
/// تعمل في الخلفية لمزامنة البيانات المحلية مع السيرفر
class SyncService {
  static final SyncService instance = SyncService._internal();

  SyncService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final SqlServerService _api = SqlServerService.instance;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isEnabled = false;

  /// حالة المزامنة
  bool get isEnabled => _isEnabled;
  bool get isSyncing => _isSyncing;

  /// تفعيل المزامنة التلقائية
  /// [intervalMinutes] - فترة المزامنة بالدقائق (افتراضي: 5 دقائق)
  void enableAutoSync({int intervalMinutes = 5}) {
    if (_isEnabled) return;

    _isEnabled = true;
    _syncTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => syncAll(),
    );

    // First sync immediately
    syncAll();

    print('✅ Auto-sync enabled (every $intervalMinutes minutes)');
  }

  /// إيقاف المزامنة التلقائية
  void disableAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isEnabled = false;
    print('⏸️ Auto-sync disabled');
  }

  /// مزامنة جميع البيانات
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      print('⚠️ Sync already in progress');
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    print('🔄 Starting sync...');

    try {
      // اختبار الاتصال بالسيرفر أولاً
      final isConnected = await _api.testConnection();
      if (!isConnected) {
        print('❌ Server not reachable - sync skipped');
        return SyncResult(
          success: false,
          message: 'Server not reachable',
        );
      }

      int synced = 0;
      int failed = 0;

      // مزامنة سندات القبض غير المتزامنة
      final unsyncedReceipts = await _db.getUnsyncedReceipts();
      print('📤 Found ${unsyncedReceipts.length} unsynced receipts');

      for (var receiptData in unsyncedReceipts) {
        try {
          // إرسال إلى SQL Server عبر API
          final result = await _api.insertReceiptVoucher(
            voucherNumber: receiptData['voucher_number'],
            date: DateTime.parse(receiptData['date']),
            customerName: receiptData['customer_name'],
            amount: receiptData['amount'],
            paymentMethod: receiptData['payment_method'],
            currency: 'IQD',
            notes: receiptData['notes'],
          );

          if (result?['success'] == true) {
            // وضع علامة على السند كمتزامن
            await _db.markReceiptAsSynced(
              receiptData['id'],
              result?['id']?.toString() ?? receiptData['id'],
            );
            synced++;
            print('✅ Synced receipt: ${receiptData['voucher_number']}');
          } else {
            failed++;
            print('❌ Failed to sync receipt: ${receiptData['voucher_number']}');
          }
        } catch (e) {
          failed++;
          print('❌ Error syncing receipt: $e');
        }
      }

      _isSyncing = false;

      final result = SyncResult(
        success: true,
        message: 'Sync completed',
        syncedCount: synced,
        failedCount: failed,
      );

      print('✅ Sync completed: $synced synced, $failed failed');
      return result;
    } catch (e) {
      _isSyncing = false;
      print('❌ Sync error: $e');
      return SyncResult(
        success: false,
        message: 'Sync error: $e',
      );
    }
  }

  /// مزامنة سند محدد فوراً
  Future<bool> syncReceipt(ReceiptVoucher receipt) async {
    try {
      final result = await _api.insertReceiptVoucher(
        voucherNumber: receipt.voucherNumber,
        date: receipt.date,
        customerName: receipt.customerName,
        amount: receipt.amount,
        paymentMethod: receipt.paymentMethod,
        currency: 'IQD',
        notes: receipt.notes,
      );

      if (result?['success'] == true) {
        await _db.markReceiptAsSynced(
          receipt.id!,
          result?['id']?.toString() ?? receipt.id!,
        );
        print('✅ Receipt synced immediately: ${receipt.voucherNumber}');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error syncing receipt: $e');
      return false;
    }
  }

  /// استيراد البيانات من SQL Server
  /// مفيد للحصول على البيانات من أجهزة أخرى
  Future<SyncResult> pullFromServer() async {
    try {
      print('📥 Pulling data from server...');

      final receipts = await _api.getAllReceiptVouchers();
      int imported = 0;

      if (receipts != null) {
        for (var receiptData in receipts) {
          try {
            final receipt = ReceiptVoucher(
              id: receiptData['id']?.toString(),
              voucherNumber: receiptData['voucher_number'] ?? '',
              date: DateTime.parse(
                  receiptData['date'] ?? DateTime.now().toIso8601String()),
              customerName: receiptData['customer_name'] ?? '',
              amount: (receiptData['amount'] ?? 0).toDouble(),
              paymentMethod: receiptData['payment_method'] ?? '',
              notes: receiptData['notes'],
            );

            await _db.insertReceiptVoucher(receipt);
            imported++;
          } catch (e) {
            // السند موجود مسبقاً - تخطي
            if (kDebugMode) {
              print('Receipt already exists or error: $e');
            }
          }
        }
      }

      print('✅ Imported $imported receipts from server');
      return SyncResult(
        success: true,
        message: 'Imported $imported receipts',
        syncedCount: imported,
      );
    } catch (e) {
      print('❌ Error pulling from server: $e');
      return SyncResult(
        success: false,
        message: 'Error pulling from server: $e',
      );
    }
  }

  /// الحصول على إحصائيات المزامنة
  Future<SyncStats> getStats() async {
    try {
      final unsynced = await _db.getUnsyncedReceipts();
      final total = await _db.getTotalReceipts();

      return SyncStats(
        unsyncedCount: unsynced.length,
        totalReceipts: total,
        isServerOnline: await _api.testConnection(),
        lastSyncTime: DateTime.now(), // TODO: حفظ في SharedPreferences
      );
    } catch (e) {
      print('❌ Error getting sync stats: $e');
      return SyncStats(
        unsyncedCount: 0,
        totalReceipts: 0,
        isServerOnline: false,
        lastSyncTime: null,
      );
    }
  }

  /// تنظيف - إيقاف جميع العمليات
  void dispose() {
    disableAutoSync();
  }
}

/// نتيجة عملية المزامنة
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.failedCount = 0,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, synced: $syncedCount, failed: $failedCount, message: $message)';
  }
}

/// إحصائيات المزامنة
class SyncStats {
  final int unsyncedCount;
  final double totalReceipts;
  final bool isServerOnline;
  final DateTime? lastSyncTime;

  SyncStats({
    required this.unsyncedCount,
    required this.totalReceipts,
    required this.isServerOnline,
    this.lastSyncTime,
  });

  String get statusMessage {
    if (!isServerOnline) return 'السيرفر غير متصل';
    if (unsyncedCount == 0) return 'جميع البيانات متزامنة ✅';
    return '$unsyncedCount سند بانتظار المزامنة';
  }
}
