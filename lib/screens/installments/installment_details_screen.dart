import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/installments_provider.dart';
import '../../models/installment.dart';

class InstallmentDetailsScreen extends StatelessWidget {
  final Installment installment;

  const InstallmentDetailsScreen({super.key, required this.installment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat =
        NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (installment.status) {
      case 'active':
        statusColor = const Color(0xFF10B981);
        statusText = 'نشط';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'completed':
        statusColor = const Color(0xFF3B82F6);
        statusText = 'مكتمل';
        statusIcon = Icons.done_all_rounded;
        break;
      case 'overdue':
        statusColor = const Color(0xFFEF4444);
        statusText = 'متأخر';
        statusIcon = Icons.warning_rounded;
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusText = 'غير معروف';
        statusIcon = Icons.help_rounded;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                    : [statusColor.withOpacity(0.8), statusColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل القسط',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم القسط: #${installment.id}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info Card
                  _buildSection(
                    title: 'معلومات العميل',
                    icon: Icons.person_rounded,
                    color: const Color(0xFF6366F1),
                    isDark: isDark,
                    child: Column(
                      children: [
                        _buildInfoRow('اسم العميل', installment.customerName,
                            Icons.person_outline_rounded, isDark),
                        _buildInfoRow(
                            'رقم العميل',
                            '#${installment.customerId}',
                            Icons.tag_rounded,
                            isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Financial Info Card
                  _buildSection(
                    title: 'المعلومات المالية',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'المبلغ الإجمالي',
                            currencyFormat.format(installment.totalAmount),
                            Icons.attach_money_rounded,
                            isDark),
                        _buildInfoRow(
                            'المبلغ المدفوع',
                            currencyFormat.format(installment.paidAmount),
                            Icons.payment_rounded,
                            isDark),
                        _buildInfoRow(
                            'المبلغ المتبقي',
                            currencyFormat.format(installment.remainingAmount),
                            Icons.account_balance_wallet_rounded,
                            isDark),
                        const Divider(height: 32),
                        _buildInfoRow(
                            'قيمة القسط',
                            currencyFormat
                                .format(installment.installmentAmount),
                            Icons.monetization_on_rounded,
                            isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Installments Info Card
                  _buildSection(
                    title: 'معلومات الأقساط',
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'عدد الأقساط',
                            '${installment.numberOfInstallments} قسط',
                            Icons.numbers_rounded,
                            isDark),
                        _buildInfoRow(
                            'الأقساط المدفوعة',
                            '${installment.paidInstallments} قسط',
                            Icons.check_circle_outline_rounded,
                            isDark),
                        _buildInfoRow(
                            'الأقساط المتبقية',
                            '${installment.numberOfInstallments - installment.paidInstallments} قسط',
                            Icons.pending_outlined,
                            isDark),
                        const Divider(height: 32),
                        _buildInfoRow('تاريخ البدء', installment.startDate,
                            Icons.calendar_today_rounded, isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress Card
                  _buildSection(
                    title: 'التقدم',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${installment.paidInstallments} من ${installment.numberOfInstallments} أقساط',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              '${((installment.paidInstallments / installment.numberOfInstallments) * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: installment.paidInstallments /
                                installment.numberOfInstallments,
                            minHeight: 12,
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (installment.notes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'الملاحظات',
                      icon: Icons.notes_rounded,
                      color: const Color(0xFFEC4899),
                      isDark: isDark,
                      child: Text(
                        installment.notes,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Payments History
                  Consumer<InstallmentsProvider>(
                    builder: (context, provider, _) {
                      final payments =
                          provider.getPaymentsByInstallmentId(installment.id!);

                      if (payments.isEmpty) {
                        return _buildSection(
                          title: 'سجل الدفعات',
                          icon: Icons.history_rounded,
                          color: const Color(0xFF06B6D4),
                          isDark: isDark,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'لا توجد دفعات بعد',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return _buildSection(
                        title: 'سجل الدفعات (${payments.length})',
                        icon: Icons.history_rounded,
                        color: const Color(0xFF06B6D4),
                        isDark: isDark,
                        child: Column(
                          children: payments.map((payment) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF10B981),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'القسط رقم ${payment.installmentNumber}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 14,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              payment.paymentDate,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(payment.amount),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
