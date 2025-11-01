import 'package:flutter/material.dart';
import '../models/quotation.dart';
import '../services/database_helper.dart';

class QuotationsProvider with ChangeNotifier {
  List<Quotation> _quotations = [];
  bool _isLoading = false;

  List<Quotation> get quotations => _quotations;
  bool get isLoading => _isLoading;

  /// تحميل جميع عروض الأسعار
  Future<void> loadQuotations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseHelper.instance.getAllQuotations();
      _quotations = data.map((map) {
        final items = (map['items'] as List<dynamic>)
            .map((item) => QuotationItem.fromMap(item as Map<String, dynamic>))
            .toList();

        return Quotation.fromMap(map).copyWith(items: items);
      }).toList();
    } catch (e) {
      print('Error loading quotations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة عرض سعر جديد
  Future<bool> addQuotation(Quotation quotation) async {
    try {
      final quotationMap = quotation.toMap();
      quotationMap.remove('id'); // Remove id for auto-increment

      final items = quotation.items.map((item) {
        final map = item.toMap();
        map.remove('id');
        map.remove('quotation_id');
        return map;
      }).toList();

      await DatabaseHelper.instance.insertQuotation(quotationMap, items);
      await loadQuotations();
      return true;
    } catch (e) {
      print('Error adding quotation: $e');
      return false;
    }
  }

  /// تحديث عرض سعر
  Future<bool> updateQuotation(Quotation quotation) async {
    if (quotation.id == null) return false;

    try {
      final quotationMap = quotation.toMap();
      quotationMap.remove('id');

      final items = quotation.items.map((item) {
        final map = item.toMap();
        map.remove('id');
        map.remove('quotation_id');
        return map;
      }).toList();

      await DatabaseHelper.instance.updateQuotation(
        quotation.id!,
        quotationMap,
        items,
      );
      await loadQuotations();
      return true;
    } catch (e) {
      print('Error updating quotation: $e');
      return false;
    }
  }

  /// حذف عرض سعر
  Future<bool> deleteQuotation(int id) async {
    try {
      await DatabaseHelper.instance.deleteQuotation(id);
      await loadQuotations();
      return true;
    } catch (e) {
      print('Error deleting quotation: $e');
      return false;
    }
  }

  /// تحديث حالة عرض السعر
  Future<bool> updateQuotationStatus(int id, String status) async {
    try {
      await DatabaseHelper.instance.updateQuotationStatus(id, status);
      await loadQuotations();
      return true;
    } catch (e) {
      print('Error updating quotation status: $e');
      return false;
    }
  }

  /// توليد رقم عرض سعر جديد
  Future<String> generateQuotationNumber() async {
    try {
      return await DatabaseHelper.instance.generateQuotationNumber();
    } catch (e) {
      print('Error generating quotation number: $e');
      return 'QT-000001';
    }
  }

  /// الحصول على عروض الأسعار حسب الحالة
  List<Quotation> getQuotationsByStatus(String status) {
    return _quotations.where((q) => q.status == status).toList();
  }

  /// الحصول على عروض الأسعار المنتهية
  List<Quotation> getExpiredQuotations() {
    final now = DateTime.now();
    return _quotations
        .where((q) => q.validUntil.isBefore(now) && q.status == 'pending')
        .toList();
  }

  /// إحصائيات عروض الأسعار
  Map<String, dynamic> getStatistics() {
    final total = _quotations.length;
    final pending = _quotations.where((q) => q.status == 'pending').length;
    final approved = _quotations.where((q) => q.status == 'approved').length;
    final rejected = _quotations.where((q) => q.status == 'rejected').length;
    final converted =
        _quotations.where((q) => q.status == 'converted_to_sale').length;

    final totalAmount = _quotations.fold<double>(
      0.0,
      (sum, q) => sum + q.finalAmount,
    );

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'converted': converted,
      'totalAmount': totalAmount,
    };
  }
}
