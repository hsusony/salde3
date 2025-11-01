import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MinimumStockReportScreen extends StatefulWidget {
  const MinimumStockReportScreen({super.key});

  @override
  State<MinimumStockReportScreen> createState() =>
      _MinimumStockReportScreenState();
}

class _MinimumStockReportScreenState extends State<MinimumStockReportScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  final _currencyFormat = NumberFormat('#,##0', 'ar');

  @override
  Widget build(BuildContext context) {
    final products = _getFilteredProducts();
    final summary = _calculateSummary(products);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تقرير مواد الحد الأدنى',
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: [
                              'الكل',
                              'الكترونيات',
                              'ملابس',
                              'أثاث',
                              'أدوات منزلية',
                              'مواد غذائية',
                            ]
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
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
          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'نفذت',
                    '${summary['outOfStock']}',
                    Icons.remove_shopping_cart_rounded,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'أقل من الحد',
                    '${summary['belowMinimum']}',
                    Icons.warning_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'على الحد',
                    '${summary['atMinimum']}',
                    Icons.info_outline_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'قيمة الطلبات',
                    '${_currencyFormat.format(summary['orderValue'])} د.ع',
                    Icons.attach_money_rounded,
                    const Color(0xFF10B981),
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
                          flex: 1,
                          child: Text(
                            'المخزون',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'الحد الأدنى',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'المطلوب',
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
                            'سعر الشراء',
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
                            'قيمة الطلب',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
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
                        final current = product['currentStock'] as int;
                        final minimum = product['minimumStock'] as int;
                        final needed = product['neededQuantity'] as int;

                        final isOutOfStock = current == 0;
                        final isBelowMinimum = current > 0 && current < minimum;
                        final isAtMinimum = current == minimum;

                        Color statusColor;
                        String statusText;
                        if (isOutOfStock) {
                          statusColor = const Color(0xFFEF4444);
                          statusText = 'نفذ';
                        } else if (isBelowMinimum) {
                          statusColor = const Color(0xFFF59E0B);
                          statusText = 'حرج';
                        } else {
                          statusColor = const Color(0xFF3B82F6);
                          statusText = 'تحذير';
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? const Color(0xFFEF4444).withOpacity(0.05)
                                : isBelowMinimum
                                    ? const Color(0xFFF59E0B).withOpacity(0.05)
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
                                    if (isOutOfStock)
                                      const Icon(
                                        Icons.error_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 20,
                                      ),
                                    if (isOutOfStock) const SizedBox(width: 8),
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
                                flex: 1,
                                child: Text(
                                  '$current',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '$minimum',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$needed',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(product['purchasePrice'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(product['orderValue'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    statusText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
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

  Widget _buildSummaryCard(
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              fontSize: 18,
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
      final matchesCategory = _selectedCategory == 'الكل' ||
          product['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> products) {
    int outOfStock = 0;
    int belowMinimum = 0;
    int atMinimum = 0;
    double orderValue = 0;

    for (var product in products) {
      final current = product['currentStock'] as int;
      final minimum = product['minimumStock'] as int;

      if (current == 0) {
        outOfStock++;
      } else if (current < minimum) {
        belowMinimum++;
      } else if (current == minimum) {
        atMinimum++;
      }

      orderValue += product['orderValue'] as double;
    }

    return {
      'outOfStock': outOfStock,
      'belowMinimum': belowMinimum,
      'atMinimum': atMinimum,
      'orderValue': orderValue,
    };
  }

  List<Map<String, dynamic>> _getDemoProducts() {
    return [
      {
        'name': 'لابتوب HP ProBook',
        'category': 'الكترونيات',
        'currentStock': 0,
        'minimumStock': 10,
        'neededQuantity': 15,
        'purchasePrice': 800000.0,
        'orderValue': 12000000.0,
      },
      {
        'name': 'طابعة Canon',
        'category': 'الكترونيات',
        'currentStock': 3,
        'minimumStock': 8,
        'neededQuantity': 12,
        'purchasePrice': 250000.0,
        'orderValue': 3000000.0,
      },
      {
        'name': 'قميص رجالي',
        'category': 'ملابس',
        'currentStock': 20,
        'minimumStock': 20,
        'neededQuantity': 30,
        'purchasePrice': 25000.0,
        'orderValue': 750000.0,
      },
      {
        'name': 'كرسي مكتب',
        'category': 'أثاث',
        'currentStock': 5,
        'minimumStock': 15,
        'neededQuantity': 20,
        'purchasePrice': 150000.0,
        'orderValue': 3000000.0,
      },
      {
        'name': 'ماوس لاسلكي',
        'category': 'الكترونيات',
        'currentStock': 45,
        'minimumStock': 50,
        'neededQuantity': 55,
        'purchasePrice': 15000.0,
        'orderValue': 825000.0,
      },
      {
        'name': 'شاشة Samsung 24"',
        'category': 'الكترونيات',
        'currentStock': 8,
        'minimumStock': 12,
        'neededQuantity': 15,
        'purchasePrice': 300000.0,
        'orderValue': 4500000.0,
      },
      {
        'name': 'مكنسة كهربائية',
        'category': 'أدوات منزلية',
        'currentStock': 0,
        'minimumStock': 5,
        'neededQuantity': 10,
        'purchasePrice': 120000.0,
        'orderValue': 1200000.0,
      },
      {
        'name': 'رز أبيض 5 كغم',
        'category': 'مواد غذائية',
        'currentStock': 100,
        'minimumStock': 100,
        'neededQuantity': 150,
        'purchasePrice': 15000.0,
        'orderValue': 2250000.0,
      },
      {
        'name': 'كيبورد ميكانيكي',
        'category': 'الكترونيات',
        'currentStock': 12,
        'minimumStock': 25,
        'neededQuantity': 30,
        'purchasePrice': 80000.0,
        'orderValue': 2400000.0,
      },
      {
        'name': 'بنطلون جينز',
        'category': 'ملابس',
        'currentStock': 15,
        'minimumStock': 30,
        'neededQuantity': 40,
        'purchasePrice': 30000.0,
        'orderValue': 1200000.0,
      },
    ];
  }
}
