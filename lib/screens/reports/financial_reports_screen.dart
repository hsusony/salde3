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

class FinancialReportsScreen extends StatelessWidget {
  const FinancialReportsScreen({super.key});

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
                    Colors.grey[50]!,
                    Colors.white,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981),
                    const Color(0xFF10B981).withOpacity(0.8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.attach_money_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التقارير المالية',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'عرض وإدارة التقارير المالية',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.print_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content - Grid of Report Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    _buildReportCard(
                      title: 'كشف مبيعات',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesStatementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'ملخص الحسابات',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountsSummaryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'كشف حساب',
                      icon: Icons.description_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AccountStatementReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'ارصدة الحسابات',
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AccountBalancesReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'كشف حساب',
                      icon: Icons.search_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      title: 'ارصدة العملاء',
                      icon: Icons.receipt_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerBalancesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'كشف عرض سعر',
                      icon: Icons.label_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const QuotationStatementReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'كشف مشتريات',
                      icon: Icons.shopping_cart_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PurchasesStatementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'الحركات المالية',
                      icon: Icons.sync_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FinancialMovementsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'كشف مبيعات و',
                      icon: Icons.insert_chart_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesAndReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'القيمة الفعلية',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ActualValueReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'حركة العملاء',
                      icon: Icons.people_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerMovementReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'المبيعات المتراكمة',
                      icon: Icons.layers_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AccumulatedSalesReportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E4D45),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
