import 'package:flutter/material.dart';
import 'reports/financial_reports_screen.dart';
import 'reports/nutrition_reports_screen.dart';
import 'reports/inventory_reports_screen.dart';
import 'reports/profit_reports_screen.dart';
import 'reports/control_reports_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _reportCategories = [
    {
      'title': 'تقارير مالية',
      'icon': Icons.attach_money_rounded,
      'color': const Color(0xFF10B981), // Green
    },
    {
      'title': 'تقارير نقدية',
      'icon': Icons.payments_rounded,
      'color': const Color(0xFFEC4899), // Pink
    },
    {
      'title': 'تقارير المخازن',
      'icon': Icons.warehouse_rounded,
      'color': const Color(0xFF8B5CF6), // Purple
    },
    {
      'title': 'تقارير الارباح',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFFF59E0B), // Orange
    },
    {
      'title': 'تقارير رقابية',
      'icon': Icons.shield_rounded,
      'color': const Color(0xFF3B82F6), // Blue
    },
  ];

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const FinancialReportsScreen();
      case 1:
        return const NutritionReportsScreen();
      case 2:
        return const InventoryReportsScreen();
      case 3:
        return const ProfitReportsScreen();
      case 4:
        return const ControlReportsScreen();
      default:
        return const FinancialReportsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final surfaceColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[700]!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: Row(
          children: [
            // القائمة الجانبية
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF16A085),
                          const Color(0xFF16A085).withOpacity(0.8),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
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
                            Icons.assessment_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'التقارير',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // القائمة
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _reportCategories.length,
                      itemBuilder: (context, index) {
                        final category = _reportCategories[index];
                        final isSelected = _selectedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? category['color']
                                          .withOpacity(isDark ? 0.15 : 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? category['color']
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? category['color']
                                            : category['color'].withOpacity(
                                                isDark ? 0.15 : 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        category['icon'],
                                        color: isSelected
                                            ? Colors.white
                                            : category['color'],
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        category['title'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? category['color']
                                              : secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.chevron_left_rounded,
                                        color: category['color'],
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // المحتوى
            Expanded(
              child: _getSelectedScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
