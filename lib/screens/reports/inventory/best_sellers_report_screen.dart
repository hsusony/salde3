import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/sales_provider.dart';

class BestSellersReportScreen extends StatefulWidget {
  const BestSellersReportScreen({super.key});

  @override
  State<BestSellersReportScreen> createState() =>
      _BestSellersReportScreenState();
}

class _BestSellersReportScreenState extends State<BestSellersReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _searchQuery = '';

  final _currencyFormat = NumberFormat('#,##0', 'ar');
  final _dateFormat = DateFormat('yyyy-MM-dd', 'ar');

  @override
  void initState() {
    super.initState();
    // تحميل بيانات المبيعات من قاعدة البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        if (salesProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text(
                'تقرير المواد الأكثر مبيعاً',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final products = _getFilteredProducts(salesProvider.sales);

        return _buildReportContent(products);
      },
    );
  }

  Widget _buildReportContent(List<Map<String, dynamic>> products) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تقرير المواد الأكثر مبيعاً',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF10B981),
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
                                color: Color(0xFF10B981),
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
                                color: Color(0xFF10B981),
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
                      color: Color(0xFF10B981),
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
                        color: Color(0xFF10B981),
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
          // Top 3 Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (products.isNotEmpty) ...[
                  Expanded(
                    child: _buildTopProductCard(
                      products[0],
                      1,
                      const Color(0xFFFFD700),
                      Icons.emoji_events_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (products.length > 1) ...[
                  Expanded(
                    child: _buildTopProductCard(
                      products[1],
                      2,
                      const Color(0xFFC0C0C0),
                      Icons.workspace_premium_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (products.length > 2)
                  Expanded(
                    child: _buildTopProductCard(
                      products[2],
                      3,
                      const Color(0xFFCD7F32),
                      Icons.military_tech_rounded,
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
                      color: const Color(0xFF10B981).withOpacity(0.1),
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
                            'الترتيب',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
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
                            'الربح',
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
                        final isTopThree = index < 3;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isTopThree
                                ? const Color(0xFF10B981).withOpacity(0.05)
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
                                flex: 1,
                                child: Text(
                                  '${index + 1}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: isTopThree
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isTopThree
                                        ? const Color(0xFF10B981)
                                        : Colors.grey[600],
                                    fontSize: isTopThree ? 18 : 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontWeight: isTopThree
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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
                                flex: 2,
                                child: Text(
                                  _currencyFormat.format(product['quantity']),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(product['revenue'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(product['profit'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
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

  Widget _buildTopProductCard(
      Map<String, dynamic> product, int rank, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
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
          const SizedBox(height: 8),
          Text(
            'المرتبة $rank',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${_currencyFormat.format(product['quantity'])} قطعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currencyFormat.format(product['revenue'])} د.ع',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredProducts(List<dynamic> allSales) {
    // تجميع المبيعات حسب المنتج
    Map<int, Map<String, dynamic>> productSales = {};

    for (var sale in allSales) {
      final saleDate = DateTime.parse(sale.saleDate);

      // فلترة حسب التاريخ
      if (saleDate.isBefore(_fromDate) ||
          saleDate.isAfter(_toDate.add(const Duration(days: 1)))) {
        continue;
      }

      // تجميع عناصر كل منتج
      for (var item in sale.items) {
        final productId = item['product_id'] as int;
        final quantity = (item['quantity'] as num).toDouble();
        final totalPrice = (item['total_price'] as num).toDouble();
        final costPrice = (item['cost_price'] ?? 0) as num;
        final profit = totalPrice - (costPrice.toDouble() * quantity);

        if (productSales.containsKey(productId)) {
          productSales[productId]!['quantity'] += quantity;
          productSales[productId]!['revenue'] += totalPrice;
          productSales[productId]!['profit'] += profit;
        } else {
          productSales[productId] = {
            'product_id': productId,
            'name': item['product_name'] ?? 'غير محدد',
            'category': item['category'] ?? 'عام',
            'quantity': quantity,
            'revenue': totalPrice,
            'profit': profit,
          };
        }
      }
    }

    // تحويل إلى قائمة وترتيب حسب الكمية
    List<Map<String, dynamic>> products = productSales.values.toList();
    products.sort(
        (a, b) => (b['quantity'] as double).compareTo(a['quantity'] as double));

    // تطبيق فلتر البحث
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return products;
  }
}
