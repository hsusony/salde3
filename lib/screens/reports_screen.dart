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

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _reportCategories = [
    {
      'title': 'تقارير مالية',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF10B981), // Green
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      'description': 'عرض شامل للحسابات المالية',
    },
    {
      'title': 'تقارير نقدية',
      'icon': Icons.payments_rounded,
      'color': const Color(0xFFEC4899), // Pink
      'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      'description': 'متابعة الحركة النقدية',
    },
    {
      'title': 'تقارير المخازن',
      'icon': Icons.warehouse_rounded,
      'color': const Color(0xFF8B5CF6), // Purple
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      'description': 'جرد وحركة المخزون',
    },
    {
      'title': 'تقارير الارباح',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFFF59E0B), // Orange
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'description': 'تحليل الأرباح والخسائر',
    },
    {
      'title': 'تقارير رقابية',
      'icon': Icons.shield_rounded,
      'color': const Color(0xFF3B82F6), // Blue
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      'description': 'مراقبة وتدقيق العمليات',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            // القائمة الجانبية المحسنة
            Container(
              width: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFFAFAFA),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header المحسن
                  Container(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
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
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.assessment_rounded,
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
                                    'التقارير',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'لوحة التحكم والتحليل',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // إحصائيات سريعة
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickStat(
                                '5',
                                'أقسام',
                                Icons.category_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickStat(
                                '24',
                                'تقرير',
                                Icons.description_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // القائمة المحسنة
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      itemCount: _reportCategories.length,
                      itemBuilder: (context, index) {
                        final category = _reportCategories[index];
                        final isSelected = _selectedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TweenAnimationBuilder<double>(
                            duration:
                                Duration(milliseconds: 200 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                  _animationController.reset();
                                  _animationController.forward();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: category['gradient'],
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : isDark
                                            ? const Color(0xFF1E293B)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : isDark
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.grey.withOpacity(0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: category['color']
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  isDark ? 0.2 : 0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.25)
                                              : category['color'].withOpacity(
                                                  isDark ? 0.2 : 0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: Icon(
                                          category['icon'],
                                          color: isSelected
                                              ? Colors.white
                                              : category['color'],
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category['title'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.white
                                                    : isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1E293B),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              category['description'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? Colors.white
                                                        .withOpacity(0.85)
                                                    : secondaryTextColor
                                                        .withOpacity(0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedRotation(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        turns: isSelected ? 0 : 0.5,
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: isSelected
                                              ? Colors.white
                                              : category['color'],
                                          size: 18,
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
                ],
              ),
            ),
            // المحتوى مع انيميشن
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _getSelectedScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
