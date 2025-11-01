import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/customer.dart';
import '../utils/database_helper_stub.dart'
    if (dart.library.io) '../utils/database_helper.dart';

class CustomersProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Customer> get customers => _filteredCustomers;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Use demo data for web
        _customers = _getDemoCustomers();
      } else {
        final maps = await DatabaseHelper.instance.getAllCustomers();
        _customers = (maps)
            .cast<Map<String, dynamic>>()
            .map((map) => Customer.fromMap(map))
            .toList();
      }
      _filterCustomers();
    } catch (e) {
      debugPrint('Error loading customers: $e');
      // Fallback to demo data
      _customers = _getDemoCustomers();
      _filterCustomers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Customer> _getDemoCustomers() {
    // TODO: استبدل هذه الدالة بجلب البيانات من قاعدة البيانات
    // في النظام الحقيقي، يجب أن تجلب البيانات من قاعدة البيانات
    return [];
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      if (!kIsWeb) {
        final id = await DatabaseHelper.instance.insertCustomer(customer);
        customer = customer.copyWith(id: id);
      } else {
        customer = customer.copyWith(
          id: _customers.isEmpty
              ? 1
              : _customers
                      .map((c) => c.id ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  1,
        );
      }
      _customers.add(customer);
      _filterCustomers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      if (!kIsWeb) {
        await DatabaseHelper.instance.updateCustomer(customer);
      }
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        _filterCustomers();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      if (!kIsWeb) {
        await DatabaseHelper.instance.deleteCustomer(id);
      }
      _customers.removeWhere((c) => c.id == id);
      _filterCustomers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      rethrow;
    }
  }

  void searchCustomers(String query) {
    _searchQuery = query;
    _filterCustomers();
    notifyListeners();
  }

  void _filterCustomers() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(lowerQuery) ||
            customer.phone.toLowerCase().contains(lowerQuery) ||
            (customer.email?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }
  }
}
