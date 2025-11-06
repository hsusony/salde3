import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'sales_menu_screen.dart';
import 'customers_screen.dart';
import 'reports_screen.dart';
import 'installments_screen.dart';
import 'purchases_screen.dart';
import 'cash_screen.dart';
import 'inventory/inventory_menu_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'backup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SalesMenuScreen(),
    const PurchasesScreen(),
    const ProductsScreen(),
    const CustomersScreen(),
    const CashScreen(),
    const InstallmentsScreen(),
    const ReportsScreen(),
    const InventoryMenuScreen(),
    const SettingsScreen(),
    const BackupScreen(),
    const AboutScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.dashboard_rounded, label: 'لوحة التحكم'),
    NavigationItem(icon: Icons.shopping_cart_rounded, label: 'البيع'),
    NavigationItem(icon: Icons.shopping_bag_rounded, label: 'المشتريات'),
    NavigationItem(icon: Icons.inventory_2_rounded, label: 'المنتجات'),
    NavigationItem(icon: Icons.person_add_rounded, label: 'إضافة حساب'),
    NavigationItem(
        icon: Icons.account_balance_rounded, label: 'النقد والحسابات'),
    NavigationItem(icon: Icons.credit_card_rounded, label: 'نظام التقسيط'),
    NavigationItem(icon: Icons.analytics_rounded, label: 'التقارير'),
    NavigationItem(icon: Icons.warehouse_rounded, label: 'المخزون'),
    NavigationItem(icon: Icons.settings_rounded, label: 'الإعدادات'),
    NavigationItem(icon: Icons.backup_rounded, label: 'النسخ الاحتياطي'),
    NavigationItem(icon: Icons.info_rounded, label: 'حول'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            // Modern Sidebar Navigation
            Container(
              width: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [Colors.white, const Color(0xFFF8FAFC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey.shade400)
                        .withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Premium App Header
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE57330).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'نظام إدارة المبيعات',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE57330),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF334155),
                                      const Color(0xFF475569)
                                    ]
                                  : [
                                      const Color(0xFFE0E7FF),
                                      const Color(0xFFDDD6FE)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'إصدار 1.0 Pro',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? const Color(0xFFC7D2FE)
                                          : const Color(0xFF6366F1),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedIndex = index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              const Color(0xFF6366F1)
                                                  .withOpacity(0.15),
                                              const Color(0xFF8B5CF6)
                                                  .withOpacity(0.15),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                              .withOpacity(0.5)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF6366F1),
                                                    Color(0xFF8B5CF6)
                                                  ],
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : (isDark
                                                  ? const Color(0xFF334155)
                                                  : const Color(0xFFF1F5F9)),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _navItems[index].icon,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B)),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _navItems[index].label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: isSelected
                                                    ? (isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF6366F1))
                                                    : (isDark
                                                        ? const Color(
                                                            0xFF94A3B8)
                                                        : const Color(
                                                            0xFF64748B)),
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF6366F1),
                                                Color(0xFF8B5CF6)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Settings & Theme Toggle with modern design
                  Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF334155),
                                  const Color(0xFF475569)
                                ]
                              : [
                                  const Color(0xFFF1F5F9),
                                  const Color(0xFFE2E8F0)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              themeProvider.themeMode == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: const Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'الوضع الداكن',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.9,
                            child: Switch(
                              value: themeProvider.themeMode == ThemeMode.dark,
                              onChanged: (value) => themeProvider.toggleTheme(),
                              activeThumbColor: const Color(0xFF6366F1),
                              activeTrackColor:
                                  const Color(0xFF6366F1).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
