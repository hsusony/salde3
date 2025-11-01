import 'package:flutter/material.dart';
import 'warehouses_screen.dart';
import 'packaging_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import 'stock_transfer_screen.dart';
import 'stock_adjustment_screen.dart';
import 'damaged_materials_screen.dart';
import 'consumed_materials_screen.dart';
import 'material_orders_screen.dart';
import 'material_donations_screen.dart';
import 'material_import_screen.dart';
import 'inventory_reports_screen.dart';
import 'barcode_print_screen.dart';
import 'multi_barcode_print_screen.dart';

class InventoryMenuScreen extends StatelessWidget {
  const InventoryMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [
                    const Color(0xFF1A237E),
                    const Color(0xFF0D47A1),
                    const Color(0xFF01579B),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                    const Color(0xFF90CAF9),
                  ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(40, 70, 40, 40),
              child: Column(
                children: [
                  // Icon with enhanced animation effect
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warehouse_rounded,
                              size: 70,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1565C0),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'نظام إدارة المخزون',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0D47A1),
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'إدارة شاملة للمخازن والحركات المخزنية',
                      style: TextStyle(
                        fontSize: 17,
                        color: isDark
                            ? Colors.white.withOpacity(0.95)
                            : const Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Grid
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, -8),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  child: GridView.count(
                    padding: const EdgeInsets.all(28),
                    crossAxisCount: 4,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.0,
                    physics: const BouncingScrollPhysics(),
                    children: _buildMenuItems(context, isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, bool isDark) {
    final menuItems = [
      _MenuItem(
        title: 'عرض المواد',
        icon: Icons.inventory_2_rounded,
        gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        screen: const InventoryReportsScreen(),
      ),
      _MenuItem(
        title: 'إضافة مخزن',
        icon: Icons.warehouse_rounded,
        gradient: const [Color(0xFF56AB2F), Color(0xFFA8E063)],
        screen: const WarehousesScreen(),
      ),
      _MenuItem(
        title: 'إضافة تعبئة',
        icon: Icons.inventory_rounded,
        gradient: const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        screen: const PackagingScreen(),
      ),
      _MenuItem(
        title: 'نقل بين مخازن',
        icon: Icons.swap_horiz_rounded,
        gradient: const [Color(0xFF834D9B), Color(0xFFD04ED6)],
        screen: const StockTransferScreen(),
      ),
      _MenuItem(
        title: 'المواد التالفة',
        icon: Icons.report_problem_rounded,
        gradient: const [Color(0xFFEB3349), Color(0xFFF45C43)],
        screen: const DamagedMaterialsScreen(),
      ),
      _MenuItem(
        title: 'المواد المستهلكة',
        icon: Icons.shopping_cart_rounded,
        gradient: const [Color(0xFF4E54C8), Color(0xFF8F94FB)],
        screen: const ConsumedMaterialsScreen(),
      ),
      _MenuItem(
        title: 'طلبية المواد',
        icon: Icons.shopping_bag_rounded,
        gradient: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
        screen: const MaterialOrdersScreen(),
      ),
      _MenuItem(
        title: 'تسوية مخزنية',
        icon: Icons.tune_rounded,
        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        screen: const StockAdjustmentScreen(),
      ),
      _MenuItem(
        title: 'طباعة باركود',
        icon: Icons.qr_code_rounded,
        gradient: const [Color(0xFF1FA2FF), Color(0xFF12D8FA)],
        screen: const BarcodePrintScreen(),
      ),
      _MenuItem(
        title: 'باركود متعدد',
        icon: Icons.qr_code_scanner_rounded,
        gradient: const [Color(0xFFB224EF), Color(0xFF7579FF)],
        screen: const MultiBarcodePrintScreen(),
      ),
      _MenuItem(
        title: 'استيراد مواد',
        icon: Icons.download_rounded,
        gradient: const [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
        screen: const MaterialImportScreen(),
      ),
      _MenuItem(
        title: 'إخراج مخزني',
        icon: Icons.logout_rounded,
        gradient: const [Color(0xFFFF512F), Color(0xFFF09819)],
        screen: const StockOutScreen(),
      ),
      _MenuItem(
        title: 'إدخال مخزني',
        icon: Icons.login_rounded,
        gradient: const [Color(0xFF06BEB6), Color(0xFF48B1BF)],
        screen: const StockInScreen(),
      ),
      _MenuItem(
        title: 'إهداء المواد',
        icon: Icons.card_giftcard_rounded,
        gradient: const [Color(0xFFFC466B), Color(0xFF3F5EFB)],
        screen: const MaterialDonationsScreen(),
      ),
    ];

    return menuItems
        .map((item) => _buildModernMenuCard(context, item, isDark))
        .toList();
  }

  Widget _buildModernMenuCard(
    BuildContext context,
    _MenuItem item,
    bool isDark,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradient,
                    stops: const [0.0, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.gradient[1].withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: item.gradient[0].withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item.screen),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon container with enhanced glow effect
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              size: 42,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Text with shadow for better readability
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Widget screen;

  _MenuItem({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.screen,
  });
}
