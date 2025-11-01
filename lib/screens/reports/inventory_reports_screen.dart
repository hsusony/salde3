import 'package:flutter/material.dart';
import 'inventory/inventory_report_screen.dart';
import 'inventory/best_sellers_report_screen.dart';
import 'inventory/least_sold_report_screen.dart';
import 'inventory/expiry_dates_report_screen.dart';
import 'inventory/minimum_stock_report_screen.dart';

class InventoryReportsScreen extends StatelessWidget {
  const InventoryReportsScreen({super.key});

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
                    const Color(0xFF8B5CF6),
                    const Color(0xFF8B5CF6).withOpacity(0.8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
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
                      Icons.warehouse_rounded,
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
                          'تقارير المخازن',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'عرض وإدارة تقارير المخازن',
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
                      context: context,
                      title: 'فترة او نسبة المواد',
                      icon: Icons.percent_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'تاريخ الصلاحية',
                      icon: Icons.event_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ExpiryDatesReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'الاقل مبيعا',
                      icon: Icons.trending_down_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeastSoldReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'الأكثر مبيعا',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BestSellersReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'المواد الراكدة',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'مواد الحد الادنى',
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MinimumStockReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'سعر البيع اقل من',
                      icon: Icons.price_check_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'الرصيد اصغر من',
                      icon: Icons.inventory_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'الهدايا المكتسبة',
                      icon: Icons.card_giftcard_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'نقل بين المخازن',
                      icon: Icons.swap_horiz_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'المواد المستهلكة',
                      icon: Icons.shopping_bag_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'المواد التالفة',
                      icon: Icons.delete_forever_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'الهدايا الممنوحة',
                      icon: Icons.redeem_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'تقرير التجهيز',
                      icon: Icons.build_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'كشف اخراج',
                      icon: Icons.outbox_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'كشف ادخال مخزني',
                      icon: Icons.inbox_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'كشف نقل مخزني',
                      icon: Icons.move_to_inbox_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'التسوية المخزنية',
                      icon: Icons.balance_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'تقرير طلبات المواد',
                      icon: Icons.request_page_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _buildReportCard(
                      context: context,
                      title: 'تقرير المواد',
                      icon: Icons.description_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {},
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
    required BuildContext context,
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
