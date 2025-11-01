import 'package:flutter/material.dart';
import 'edit_sale_screen.dart';
import 'sales_return_screen.dart';
import 'edit_sales_return_screen.dart';
import 'quotations_screen.dart';
import 'pending_orders_screen.dart';

class SalesMenuScreen extends StatelessWidget {
  const SalesMenuScreen({super.key});

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
                      Icons.shopping_cart_rounded,
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
                          'البيع',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'إدارة عمليات البيع والفواتير',
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
                    icon: const Icon(Icons.settings_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content - Grid of Sales Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSalesCard(
                      context: context,
                      title: 'نقطة البيع',
                      icon: Icons.point_of_sale_rounded,
                      color: const Color(0xFF10B981),
                      description: 'واجهة البيع السريع',
                      onTap: () {
                        Navigator.pushNamed(context, '/pos');
                      },
                    ),
                    _buildSalesCard(
                      context: context,
                      title: 'قائمة البيع',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF3B82F6),
                      description: 'عرض جميع فواتير البيع',
                      onTap: () {
                        Navigator.pushNamed(context, '/sales');
                      },
                    ),
                    _buildSalesCard(
                      context: context,
                      title: 'تعديل بيع',
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFFF59E0B),
                      description: 'تعديل فواتير البيع',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditSaleScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSalesCard(
                      context: context,
                      title: 'إرجاع بيع',
                      icon: Icons.keyboard_return_rounded,
                      color: const Color(0xFFEF4444),
                      description: 'إرجاع المبيعات',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesReturnScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSalesCard(
                      context: context,
                      title: 'تعديل إرجاع بيع',
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF8B5CF6),
                      description: 'تعديل مرتجعات البيع',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditSalesReturnScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSalesCard(
                      context: context,
                      title: 'قائمة عرض سعر',
                      icon: Icons.price_check_rounded,
                      color: const Color(0xFF06B6D4),
                      description: 'عروض الأسعار',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuotationsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSalesCard(
                      context: context,
                      title: 'قوائم الانتظار',
                      icon: Icons.hourglass_empty_rounded,
                      color: const Color(0xFFEC4899),
                      description: 'الطلبات قيد الانتظار',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PendingOrdersScreen(),
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

  Widget _buildSalesCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F9) : Colors.black87;
    final descColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[600]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: descColor,
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
