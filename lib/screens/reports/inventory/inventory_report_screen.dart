import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
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
          'تقرير الجرد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
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
          // Filters Section
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
                            hint: const Text('اختر الفئة'),
                            items: [
                              'الكل',
                              'الكترونيات',
                              'ملابس',
                              'أثاث',
                              'أدوات منزلية',
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
                    hintText: 'بحث بـ اسم المنتج أو الباركود...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8B5CF6),
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
                        color: Color(0xFF8B5CF6),
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
                    'إجمالي المنتجات',
                    '${products.length}',
                    Icons.inventory_2_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'إجمالي الكمية',
                    _currencyFormat.format(summary['totalQuantity']),
                    Icons.widgets_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'قيمة المخزون',
                    '${_currencyFormat.format(summary['totalValue'])} د.ع',
                    Icons.attach_money_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'منتجات نفذت',
                    '${summary['outOfStock']}',
                    Icons.warning_rounded,
                    const Color(0xFFEF4444),
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
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'الرمز',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
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
                            'الكمية',
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
                            'سعر البيع',
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
                            'القيمة الإجمالية',
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
                  // Table Body
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isLowStock = product['quantity'] < 10;
                        final isOutOfStock = product['quantity'] == 0;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
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
                                flex: 1,
                                child: Text(
                                  product['code'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                  '${product['quantity']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isOutOfStock
                                        ? const Color(0xFFEF4444)
                                        : isLowStock
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF10B981),
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
                                  '${_currencyFormat.format(product['salePrice'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(product['totalValue'])} د.ع',
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
                                    color: isOutOfStock
                                        ? const Color(0xFFEF4444)
                                            .withOpacity(0.1)
                                        : isLowStock
                                            ? const Color(0xFFF59E0B)
                                                .withOpacity(0.1)
                                            : const Color(0xFF10B981)
                                                .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isOutOfStock
                                        ? 'نفذ'
                                        : isLowStock
                                            ? 'منخفض'
                                            : 'متوفر',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isOutOfStock
                                          ? const Color(0xFFEF4444)
                                          : isLowStock
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF10B981),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
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
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product['code'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> products) {
    int totalQuantity = 0;
    double totalValue = 0;
    int outOfStock = 0;

    for (var product in products) {
      totalQuantity += product['quantity'] as int;
      totalValue += product['totalValue'] as double;
      if (product['quantity'] == 0) {
        outOfStock++;
      }
    }

    return {
      'totalQuantity': totalQuantity,
      'totalValue': totalValue,
      'outOfStock': outOfStock,
    };
  }

  List<Map<String, dynamic>> _getDemoProducts() {
    return [
      {
        'code': 'P001',
        'name': 'لابتوب HP ProBook',
        'category': 'الكترونيات',
        'quantity': 15,
        'purchasePrice': 800000.0,
        'salePrice': 1000000.0,
        'totalValue': 15000000.0,
      },
      {
        'code': 'P002',
        'name': 'طابعة Canon',
        'category': 'الكترونيات',
        'quantity': 8,
        'purchasePrice': 250000.0,
        'salePrice': 350000.0,
        'totalValue': 2800000.0,
      },
      {
        'code': 'P003',
        'name': 'قميص رجالي',
        'category': 'ملابس',
        'quantity': 50,
        'purchasePrice': 25000.0,
        'salePrice': 40000.0,
        'totalValue': 2000000.0,
      },
      {
        'code': 'P004',
        'name': 'كرسي مكتب',
        'category': 'أثاث',
        'quantity': 0,
        'purchasePrice': 150000.0,
        'salePrice': 250000.0,
        'totalValue': 0.0,
      },
      {
        'code': 'P005',
        'name': 'ماوس لاسلكي',
        'category': 'الكترونيات',
        'quantity': 100,
        'purchasePrice': 15000.0,
        'salePrice': 25000.0,
        'totalValue': 2500000.0,
      },
      {
        'code': 'P006',
        'name': 'شاشة Samsung 24"',
        'category': 'الكترونيات',
        'quantity': 12,
        'purchasePrice': 300000.0,
        'salePrice': 450000.0,
        'totalValue': 5400000.0,
      },
      {
        'code': 'P007',
        'name': 'مكنسة كهربائية',
        'category': 'أدوات منزلية',
        'quantity': 5,
        'purchasePrice': 120000.0,
        'salePrice': 180000.0,
        'totalValue': 900000.0,
      },
      {
        'code': 'P008',
        'name': 'طاولة طعام خشبية',
        'category': 'أثاث',
        'quantity': 3,
        'purchasePrice': 500000.0,
        'salePrice': 750000.0,
        'totalValue': 2250000.0,
      },
      {
        'code': 'P009',
        'name': 'كيبورد ميكانيكي',
        'category': 'الكترونيات',
        'quantity': 25,
        'purchasePrice': 80000.0,
        'salePrice': 120000.0,
        'totalValue': 3000000.0,
      },
      {
        'code': 'P010',
        'name': 'بنطلون جينز',
        'category': 'ملابس',
        'quantity': 0,
        'purchasePrice': 30000.0,
        'salePrice': 50000.0,
        'totalValue': 0.0,
      },
    ];
  }
}
