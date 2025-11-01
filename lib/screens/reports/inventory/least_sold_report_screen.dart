import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeastSoldReportScreen extends StatefulWidget {
  const LeastSoldReportScreen({super.key});

  @override
  State<LeastSoldReportScreen> createState() => _LeastSoldReportScreenState();
}

class _LeastSoldReportScreenState extends State<LeastSoldReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _searchQuery = '';

  final _currencyFormat = NumberFormat('#,##0', 'ar');
  final _dateFormat = DateFormat('yyyy-MM-dd', 'ar');

  @override
  Widget build(BuildContext context) {
    final products = _getFilteredProducts();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تقرير المواد الأقل مبيعاً',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print_rounded),
            tooltip: 'طباعة',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تصدير',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fromDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _fromDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(_dateFormat.format(_fromDate)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _toDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _toDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(_dateFormat.format(_toDate)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'بحث بـ اسم المنتج...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Warning Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildWarningCard(
                    'منتجات راكدة',
                    '${products.where((p) => p['quantity'] == 0).length}',
                    Icons.warning_rounded,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWarningCard(
                    'مبيعات ضعيفة',
                    '${products.where((p) => p['quantity'] > 0 && p['quantity'] < 10).length}',
                    Icons.trending_down_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWarningCard(
                    'يحتاج اهتمام',
                    '${products.where((p) => p['quantity'] >= 10 && p['quantity'] < 30).length}',
                    Icons.info_outline_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'اسم المنتج',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الفئة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الكمية المباعة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'المخزون الحالي',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الإيرادات',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الحالة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isStagnant = product['quantity'] == 0;
                        final isLowSales =
                            product['quantity'] > 0 && product['quantity'] < 10;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isStagnant
                                ? const Color(0xFFEF4444).withOpacity(0.05)
                                : null,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    if (isStagnant)
                                      const Icon(
                                        Icons.warning_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 20,
                                      ),
                                    if (isStagnant) const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  product['category'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _currencyFormat.format(product['quantity']),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isStagnant
                                        ? const Color(0xFFEF4444)
                                        : isLowSales
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _currencyFormat.format(product['stock']),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(product['revenue'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isStagnant
                                        ? const Color(0xFFEF4444)
                                            .withOpacity(0.1)
                                        : isLowSales
                                            ? const Color(0xFFF59E0B)
                                                .withOpacity(0.1)
                                            : const Color(0xFF3B82F6)
                                                .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isStagnant
                                        ? 'راكد'
                                        : isLowSales
                                            ? 'ضعيف'
                                            : 'عادي',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isStagnant
                                          ? const Color(0xFFEF4444)
                                          : isLowSales
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWarningCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    final allProducts = _getDemoProducts();
    return allProducts.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> _getDemoProducts() {
    return [
      {
        'name': 'طاولة طعام زجاجية',
        'category': 'أثاث',
        'quantity': 0,
        'stock': 15,
        'revenue': 0.0,
      },
      {
        'name': 'سماعات بلوتوث قديمة',
        'category': 'الكترونيات',
        'quantity': 2,
        'stock': 48,
        'revenue': 120000.0,
      },
      {
        'name': 'كرسي مكتب جلد',
        'category': 'أثاث',
        'quantity': 3,
        'stock': 22,
        'revenue': 750000.0,
      },
      {
        'name': 'مروحة سقف',
        'category': 'أدوات منزلية',
        'quantity': 5,
        'stock': 18,
        'revenue': 750000.0,
      },
      {
        'name': 'طابعة ليزر قديمة',
        'category': 'الكترونيات',
        'quantity': 1,
        'stock': 8,
        'revenue': 350000.0,
      },
      {
        'name': 'سجادة فارسية',
        'category': 'أدوات منزلية',
        'quantity': 4,
        'stock': 12,
        'revenue': 1600000.0,
      },
      {
        'name': 'تلفزيون 32 بوصة',
        'category': 'الكترونيات',
        'quantity': 7,
        'stock': 5,
        'revenue': 3500000.0,
      },
      {
        'name': 'مكتبة خشبية',
        'category': 'أثاث',
        'quantity': 0,
        'stock': 10,
        'revenue': 0.0,
      },
      {
        'name': 'مصباح طاولة',
        'category': 'أدوات منزلية',
        'quantity': 9,
        'stock': 35,
        'revenue': 450000.0,
      },
      {
        'name': 'كاميرا ويب',
        'category': 'الكترونيات',
        'quantity': 6,
        'stock': 25,
        'revenue': 720000.0,
      },
    ];
  }
}
