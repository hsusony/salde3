import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quotation.dart';

class QuotationsProvider with ChangeNotifier {
  static const String baseUrl = 'http://localhost/backend-php/api';
  List<Quotation> _quotations = [];
  bool _isLoading = false;

  List<Quotation> get quotations => _quotations;
  bool get isLoading => _isLoading;

  /// تحميل جميع عروض الأسعار
  Future<void> loadQuotations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quotations'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _quotations = data.map((json) => Quotation.fromMap(json)).toList();
      }
    } catch (e) {
      print('❌ Error loading quotations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة عرض سعر جديد
  Future<bool> addQuotation(Quotation quotation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quotations'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(quotation.toMap()),
      );

      if (response.statusCode == 201) {
        await loadQuotations();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding quotation: $e');
      return false;
    }
  }

  /// تحديث عرض سعر
  Future<bool> updateQuotation(Quotation quotation) async {
    if (quotation.id == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quotations/${quotation.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(quotation.toMap()),
      );

      if (response.statusCode == 200) {
        await loadQuotations();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating quotation: $e');
      return false;
    }
  }

  /// حذف عرض سعر
  Future<bool> deleteQuotation(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quotations/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        await loadQuotations();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting quotation: $e');
      return false;
    }
  }

  /// تحديث حالة عرض السعر
  Future<bool> updateQuotationStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/quotations/$id/status'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await loadQuotations();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating quotation status: $e');
      return false;
    }
  }

  /// توليد رقم عرض سعر جديد
  Future<String> generateQuotationNumber() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quotations/generate/number'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['quotationNumber'];
      }
      return 'QT-000001';
    } catch (e) {
      print('❌ Error generating quotation number: $e');
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
