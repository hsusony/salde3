import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_client.dart';

class CustomersProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  DateTime? _lastLoadTime;
  static const cacheDuration = Duration(minutes: 5); // Cache لمدة 5 دقائق

  List<Customer> get customers => _filteredCustomers;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers({bool forceRefresh = false}) async {
    // استخدام الـ cache إذا كانت البيانات حديثة
    if (!forceRefresh &&
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < cacheDuration &&
        _customers.isNotEmpty) {
      debugPrint('📦 Using cached customers data');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/customers');
      _customers =
          (data as List).map((json) => Customer.fromMap(json)).toList();
      _lastLoadTime = DateTime.now(); // تحديث وقت آخر تحميل
      _filterCustomers();
    } catch (e) {
      debugPrint('Error loading customers: $e');
      _customers = [];
      _filterCustomers();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      final data = await ApiClient.post('/customers', {
        'Name': customer.name,
        'Phone': customer.phone,
        'Email': customer.email,
        'Address': customer.address,
        'Notes': customer.notes,
      });

      customer = customer.copyWith(id: data['id']);
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
      await ApiClient.put('/customers/${customer.id}', {
        'Name': customer.name,
        'Phone': customer.phone,
        'Email': customer.email,
        'Address': customer.address,
        'Notes': customer.notes,
      });

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
      await ApiClient.delete('/customers/$id');
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
