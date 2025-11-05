import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  String _searchQuery = '';
  final _currencyFormat = NumberFormat('#,##0', 'ar');

  @override
  void initState() {
    super.initState();
    // تحميل البيانات من قاعدة البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadAllStock();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          if (inventoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final products =
              _getFilteredProducts(inventoryProvider.stockWithDetails);
          final summary = _calculateSummary(products);

          return Column(
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
          );
        },
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

  List<Map<String, dynamic>> _getFilteredProducts(
      List<Map<String, dynamic>> stockData) {
    // تحويل بيانات قاعدة البيانات إلى صيغة التقرير
    List<Map<String, dynamic>> products = stockData.map((stock) {
      final quantity = (stock['quantity'] ?? 0.0).toDouble();
      final costPrice = (stock['cost_price'] ?? 0.0).toDouble();
      final salePrice = (stock['sale_price'] ?? 0.0).toDouble();

      return {
        'code': stock['barcode'] ?? '',
        'name': stock['product_name'] ?? 'غير محدد',
        'category': stock['category'] ?? 'عام',
        'quantity': quantity.toInt(),
        'purchasePrice': costPrice,
        'salePrice': salePrice,
        'totalValue': quantity * costPrice,
      };
    }).toList();

    // تطبيق الفلتر
    return products.where((product) {
      final productName = (product['name'] ?? '').toString().toLowerCase();
      final barcode = (product['code'] ?? '').toString().toLowerCase();
      final searchLower = _searchQuery.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          productName.contains(searchLower) ||
          barcode.contains(searchLower);

      return matchesSearch;
    }).toList();
  }

  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> products) {
    double totalQuantity = 0;
    double totalValue = 0;
    int outOfStock = 0;

    for (var product in products) {
      final quantity = (product['quantity'] ?? 0);
      final totalVal = (product['totalValue'] ?? 0.0);

      totalQuantity += quantity;
      totalValue += totalVal;
      if (quantity == 0) {
        outOfStock++;
      }
    }

    return {
      'totalQuantity': totalQuantity,
      'totalValue': totalValue,
      'outOfStock': outOfStock,
    };
  }
}
