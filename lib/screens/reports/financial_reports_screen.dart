import 'package:flutter/material.dart';
import 'financial/account_balances_report_screen.dart';
import 'financial/account_statement_report_screen.dart';
import 'financial/accumulated_sales_report_screen.dart';
import 'financial/actual_value_report_screen.dart';
import 'financial/customer_movement_report_screen.dart';
import 'financial/financial_movements_report_screen.dart';
import 'financial/quotation_statement_report_screen.dart';
import 'financial/sales_and_report_screen.dart';
import '../sales_statement_screen.dart';
import '../accounts_summary_screen.dart';
import '../purchases_statement_screen.dart';
import '../customer_balances_screen.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _reports = [
    {
      'title': 'كشف مبيعات',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      'description': 'تقرير شامل للمبيعات',
      'badge': 'جديد',
    },
    {
      'title': 'ملخص الحسابات',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFF3B82F6),
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      'description': 'ملخص جميع الحسابات',
    },
    {
      'title': 'كشف حساب',
      'icon': Icons.description_rounded,
      'color': const Color(0xFF8B5CF6),
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      'description': 'تفاصيل حساب محدد',
    },
    {
      'title': 'أرصدة الحسابات',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFFF59E0B),
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'description': 'أرصدة جميع الحسابات',
      'badge': 'مهم',
    },
    {
      'title': 'أرصدة العملاء',
      'icon': Icons.people_rounded,
      'color': const Color(0xFFEC4899),
      'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      'description': 'أرصدة العملاء الحالية',
    },
    {
      'title': 'كشف عرض سعر',
      'icon': Icons.request_quote_rounded,
      'color': const Color(0xFF06B6D4),
      'gradient': [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      'description': 'تفاصيل عروض الأسعار',
    },
    {
      'title': 'كشف مشتريات',
      'icon': Icons.shopping_cart_rounded,
      'color': const Color(0xFFEF4444),
      'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      'description': 'تقرير المشتريات',
    },
    {
      'title': 'الحركات المالية',
      'icon': Icons.sync_alt_rounded,
      'color': const Color(0xFF14B8A6),
      'gradient': [const Color(0xFF14B8A6), const Color(0xFF0D9488)],
      'description': 'جميع الحركات المالية',
      'badge': 'شامل',
    },
    {
      'title': 'تقرير المبيعات',
      'icon': Icons.bar_chart_rounded,
      'color': const Color(0xFF6366F1),
      'gradient': [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      'description': 'تحليل المبيعات',
    },
    {
      'title': 'القيمة الفعلية',
      'icon': Icons.price_check_rounded,
      'color': const Color(0xFFA855F7),
      'gradient': [const Color(0xFFA855F7), const Color(0xFF9333EA)],
      'description': 'القيم الفعلية للأصول',
    },
    {
      'title': 'حركة العملاء',
      'icon': Icons.transfer_within_a_station_rounded,
      'color': const Color(0xFF22C55E),
      'gradient': [const Color(0xFF22C55E), const Color(0xFF16A34A)],
      'description': 'تتبع حركة العملاء',
    },
    {
      'title': 'المبيعات المتراكمة',
      'icon': Icons.stacked_line_chart_rounded,
      'color': const Color(0xFFF97316),
      'gradient': [const Color(0xFFF97316), const Color(0xFFEA580C)],
      'description': 'المبيعات التراكمية',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_searchQuery.isEmpty) {
      return _reports;
    }
    return _reports
        .where((report) =>
            report['title'].toString().toLowerCase().contains(_searchQuery) ||
            report['description']
                .toString()
                .toLowerCase()
                .contains(_searchQuery))
        .toList();
  }

  void _navigateToReport(BuildContext context, int index) {
    Widget? screen;
    switch (index) {
      case 0:
        screen = const SalesStatementScreen();
        break;
      case 1:
        screen = const AccountsSummaryScreen();
        break;
      case 2:
        screen = const AccountStatementReportScreen();
        break;
      case 3:
        screen = const AccountBalancesReportScreen();
        break;
      case 4:
        screen = const CustomerBalancesScreen();
        break;
      case 5:
        screen = const QuotationStatementReportScreen();
        break;
      case 6:
        screen = const PurchasesStatementScreen();
        break;
      case 7:
        screen = const FinancialMovementsReportScreen();
        break;
      case 8:
        screen = const SalesAndReportScreen();
        break;
      case 9:
        screen = const ActualValueReportScreen();
        break;
      case 10:
        screen = const CustomerMovementReportScreen();
        break;
      case 11:
        screen = const AccumulatedSalesReportScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    Colors.white,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header المحسن
            Container(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التقارير المالية',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'عرض شامل لجميع التقارير والحسابات المالية',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.library_books_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_reports.length} تقرير',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(14),
                        ),
                        tooltip: 'تصدير',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.print_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(14),
                        ),
                        tooltip: 'طباعة',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // شريط البحث
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن تقرير...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Grid التقارير
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _filteredReports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد تقارير مطابقة للبحث',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = _filteredReports[index];
                          final originalIndex = _reports.indexOf(report);
                          return TweenAnimationBuilder<double>(
                            duration:
                                Duration(milliseconds: 300 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildReportCard(
                              context: context,
                              report: report,
                              index: originalIndex,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required Map<String, dynamic> report,
    required int index,
    required bool isDark,
  }) {
    final hasBadge = report['badge'] != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToReport(context, index),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: report['gradient'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: report['color'].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Pattern Background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: _PatternPainter(),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        report['icon'],
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      report['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Badge
              if (hasBadge)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      report['badge'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: report['color'],
                      ),
                    ),
                  ),
                ),
              // Hover Effect Icon
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pattern Painter للخلفية
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        20.0 + (i * 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
