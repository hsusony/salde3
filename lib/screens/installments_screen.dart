import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/installments_provider.dart';
import 'installments/add_installment_screen.dart';
import 'installments/installments_list_screen.dart';
import 'installments/pay_installment_screen.dart';
import 'installments/due_installments_screen.dart';
import 'installments/payments_history_screen.dart';
import 'installments/installments_reports_screen.dart';

class InstallmentsScreen extends StatefulWidget {
  const InstallmentsScreen({super.key});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  int _selectedIndex = 0;
  final _currencyFormat = NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  final List<Map<String, dynamic>> _subPages = [
    {
      'title': 'إضافة قسط',
      'icon': Icons.add_circle_outline_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'كشف الأقساط',
      'icon': Icons.list_alt_rounded,
      'color': const Color(0xFF6366F1),
    },
    {
      'title': 'تسديد أقساط',
      'icon': Icons.payment_rounded,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'الأقساط المستحقة',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'سجل الدفعات',
      'icon': Icons.history_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'كشف قوائم الأقساط',
      'icon': Icons.assessment_outlined,
      'color': const Color(0xFF3B82F6),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InstallmentsProvider>(context, listen: false).loadInstallments();
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const AddInstallmentScreen();
      case 1:
        return const InstallmentsListScreen();
      case 2:
        return const PayInstallmentScreen();
      case 3:
        return const DueInstallmentsScreen();
      case 4:
        return const PaymentsHistoryScreen();
      case 5:
        return const InstallmentsReportsScreen();
      default:
        return const AddInstallmentScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
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
                  color: (isDark ? Colors.black : Colors.grey.shade400).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.credit_card_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'نظام التقسيط',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Consumer<InstallmentsProvider>(
                        builder: (context, provider, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF334155), const Color(0xFF475569)]
                                    : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${provider.getActiveInstallmentsCount()}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'قسط نشط',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _subPages.length,
                    itemBuilder: (context, index) {
                      final page = _subPages[index];
                      final isSelected = _selectedIndex == index;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selectedIndex = index),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            (page['color'] as Color).withOpacity(0.15),
                                            (page['color'] as Color).withOpacity(0.1),
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? (page['color'] as Color).withOpacity(0.5)
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
                                            ? LinearGradient(
                                                colors: [
                                                  page['color'] as Color,
                                                  (page['color'] as Color).withOpacity(0.8),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        page['icon'],
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        page['title'],
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: isSelected
                                              ? (isDark ? Colors.white : page['color'] as Color)
                                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: page['color'] as Color,
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
                
                // Statistics
                Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                Consumer<InstallmentsProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildStatRow(
                            context,
                            'إجمالي الأقساط النشطة',
                            _currencyFormat.format(provider.getTotalActiveInstallments()),
                            const Color(0xFF10B981),
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            'المتأخرات',
                            _currencyFormat.format(provider.getTotalOverdueAmount()),
                            const Color(0xFFEF4444),
                            isDark,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: _getSelectedScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF334155), const Color(0xFF475569)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.attach_money_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
