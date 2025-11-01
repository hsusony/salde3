import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpiryDatesReportScreen extends StatefulWidget {
  const ExpiryDatesReportScreen({super.key});

  @override
  State<ExpiryDatesReportScreen> createState() =>
      _ExpiryDatesReportScreenState();
}

class _ExpiryDatesReportScreenState extends State<ExpiryDatesReportScreen> {
  String _selectedFilter = 'الكل';
  String _searchQuery = '';

  final _currencyFormat = NumberFormat('#,##0', 'ar');
  final _dateFormat = DateFormat('yyyy-MM-dd', 'ar');

  @override
  Widget build(BuildContext context) {
    final products = _getFilteredProducts();
    final summary = _calculateSummary(products);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تقرير تاريخ الصلاحية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF59E0B),
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
                            value: _selectedFilter,
                            isExpanded: true,
                            items: [
                              'الكل',
                              'منتهية الصلاحية',
                              'خلال أسبوع',
                              'خلال شهر',
                              'خلال 3 أشهر',
                              'صالحة',
                            ]
                                .map((filter) => DropdownMenuItem(
                                      value: filter,
                                      child: Text(filter),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedFilter = value;
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
                      color: Color(0xFFF59E0B),
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
                        color: Color(0xFFF59E0B),
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
                    'منتهية الصلاحية',
                    '${summary['expired']}',
                    Icons.dangerous_rounded,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'خلال أسبوع',
                    '${summary['withinWeek']}',
                    Icons.warning_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'خلال شهر',
                    '${summary['withinMonth']}',
                    Icons.info_outline_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'صالحة',
                    '${summary['valid']}',
                    Icons.check_circle_outline_rounded,
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
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
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
                            'رقم الدفعة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'تاريخ الإنتاج',
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
                            'تاريخ الانتهاء',
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
                            'الأيام المتبقية',
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
                        final daysLeft = product['daysLeft'] as int;
                        final isExpired = daysLeft < 0;
                        final isUrgent = daysLeft >= 0 && daysLeft <= 7;
                        final isWarning = daysLeft > 7 && daysLeft <= 30;

                        Color statusColor;
                        String statusText;
                        if (isExpired) {
                          statusColor = const Color(0xFFEF4444);
                          statusText = 'منتهية';
                        } else if (isUrgent) {
                          statusColor = const Color(0xFFF59E0B);
                          statusText = 'عاجل';
                        } else if (isWarning) {
                          statusColor = const Color(0xFF3B82F6);
                          statusText = 'تحذير';
                        } else {
                          statusColor = const Color(0xFF10B981);
                          statusText = 'صالحة';
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isExpired
                                ? const Color(0xFFEF4444).withOpacity(0.05)
                                : isUrgent
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
                                  product['batchNumber'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _dateFormat.format(product['productionDate']),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _dateFormat.format(product['expiryDate']),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  isExpired
                                      ? 'منتهية منذ ${daysLeft.abs()} يوم'
                                      : '$daysLeft يوم',
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
                                  '${product['quantity']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
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
            textAlign: TextAlign.center,
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

      if (_selectedFilter == 'الكل') return matchesSearch;

      final daysLeft = product['daysLeft'] as int;
      switch (_selectedFilter) {
        case 'منتهية الصلاحية':
          return matchesSearch && daysLeft < 0;
        case 'خلال أسبوع':
          return matchesSearch && daysLeft >= 0 && daysLeft <= 7;
        case 'خلال شهر':
          return matchesSearch && daysLeft > 7 && daysLeft <= 30;
        case 'خلال 3 أشهر':
          return matchesSearch && daysLeft > 30 && daysLeft <= 90;
        case 'صالحة':
          return matchesSearch && daysLeft > 90;
        default:
          return matchesSearch;
      }
    }).toList();
  }

  Map<String, int> _calculateSummary(List<Map<String, dynamic>> products) {
    int expired = 0;
    int withinWeek = 0;
    int withinMonth = 0;
    int valid = 0;

    for (var product in products) {
      final daysLeft = product['daysLeft'] as int;
      if (daysLeft < 0) {
        expired++;
      } else if (daysLeft <= 7) {
        withinWeek++;
      } else if (daysLeft <= 30) {
        withinMonth++;
      } else {
        valid++;
      }
    }

    return {
      'expired': expired,
      'withinWeek': withinWeek,
      'withinMonth': withinMonth,
      'valid': valid,
    };
  }

  List<Map<String, dynamic>> _getDemoProducts() {
    final now = DateTime.now();
    return [
      {
        'name': 'حليب نادك كامل الدسم',
        'batchNumber': 'BT-2025-001',
        'productionDate': DateTime(2024, 12, 1),
        'expiryDate': DateTime(2025, 1, 15),
        'daysLeft': DateTime(2025, 1, 15).difference(now).inDays,
        'quantity': 50,
      },
      {
        'name': 'عصير برتقال طبيعي',
        'batchNumber': 'BT-2025-002',
        'productionDate': DateTime(2025, 1, 5),
        'expiryDate': DateTime(2025, 1, 20),
        'daysLeft': DateTime(2025, 1, 20).difference(now).inDays,
        'quantity': 120,
      },
      {
        'name': 'لبن زبادي',
        'batchNumber': 'BT-2024-458',
        'productionDate': DateTime(2024, 12, 25),
        'expiryDate': DateTime(2025, 1, 10),
        'daysLeft': DateTime(2025, 1, 10).difference(now).inDays,
        'quantity': 80,
      },
      {
        'name': 'جبن مثلثات',
        'batchNumber': 'BT-2025-015',
        'productionDate': DateTime(2025, 1, 1),
        'expiryDate': DateTime(2025, 3, 1),
        'daysLeft': DateTime(2025, 3, 1).difference(now).inDays,
        'quantity': 200,
      },
      {
        'name': 'معجون طماطم',
        'batchNumber': 'BT-2024-890',
        'productionDate': DateTime(2024, 6, 1),
        'expiryDate': DateTime(2025, 6, 1),
        'daysLeft': DateTime(2025, 6, 1).difference(now).inDays,
        'quantity': 150,
      },
      {
        'name': 'بسكويت شوكولاتة',
        'batchNumber': 'BT-2024-775',
        'productionDate': DateTime(2024, 10, 15),
        'expiryDate': DateTime(2025, 4, 15),
        'daysLeft': DateTime(2025, 4, 15).difference(now).inDays,
        'quantity': 300,
      },
      {
        'name': 'رز أبيض 5 كغم',
        'batchNumber': 'BT-2024-950',
        'productionDate': DateTime(2024, 8, 1),
        'expiryDate': DateTime(2026, 8, 1),
        'daysLeft': DateTime(2026, 8, 1).difference(now).inDays,
        'quantity': 500,
      },
      {
        'name': 'زيت نباتي',
        'batchNumber': 'BT-2024-235',
        'productionDate': DateTime(2024, 5, 1),
        'expiryDate': DateTime(2025, 11, 1),
        'daysLeft': DateTime(2025, 11, 1).difference(now).inDays,
        'quantity': 180,
      },
      {
        'name': 'مربى فراولة',
        'batchNumber': 'BT-2024-112',
        'productionDate': DateTime(2024, 3, 1),
        'expiryDate': DateTime(2025, 3, 1),
        'daysLeft': DateTime(2025, 3, 1).difference(now).inDays,
        'quantity': 90,
      },
      {
        'name': 'شاي أحمر',
        'batchNumber': 'BT-2023-890',
        'productionDate': DateTime(2023, 12, 1),
        'expiryDate': DateTime(2025, 12, 1),
        'daysLeft': DateTime(2025, 12, 1).difference(now).inDays,
        'quantity': 250,
      },
    ];
  }
}
