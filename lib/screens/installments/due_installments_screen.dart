import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/installments_provider.dart';
import '../../models/installment.dart';

class DueInstallmentsScreen extends StatefulWidget {
  const DueInstallmentsScreen({super.key});

  @override
  State<DueInstallmentsScreen> createState() => _DueInstallmentsScreenState();
}

class _DueInstallmentsScreenState extends State<DueInstallmentsScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _searchQuery = '';
  String _filterType = 'الكل';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header & Filters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Title Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.alarm_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الأقساط المستحقة',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'عرض الأقساط المستحقة والمتأخرة',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Print & Export Buttons
                    IconButton(
                      onPressed: () {
                        // Print functionality
                      },
                      icon: const Icon(Icons.print, color: Color(0xFF6366F1)),
                      tooltip: 'طباعة',
                    ),
                    IconButton(
                      onPressed: () {
                        // Export functionality
                      },
                      icon: const Icon(Icons.download, color: Color(0xFF10B981)),
                      tooltip: 'تصدير',
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Filters Row
                Row(
                  children: [
                    // From Date
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fromDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _fromDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF6366F1), width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF6366F1), size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'من تاريخ',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_fromDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // To Date
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _toDate,
                            firstDate: _fromDate,
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _toDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF6366F1), width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF6366F1), size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'إلى تاريخ',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_toDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Filter Type
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _filterType,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.filter_list, color: Color(0xFF10B981)),
                            border: InputBorder.none,
                          ),
                          items: ['الكل', 'مستحق اليوم', 'متأخر', 'قريب الاستحقاق'].map((type) {
                            return DropdownMenuItem(value: type, child: Text(type));
                          }).toList(),
                          onChanged: (value) => setState(() => _filterType = value!),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Search
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'بحث عن زبون...',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('ت', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('الحساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('عدد الاقساط المتبقية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('حالة القسط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('القسط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('تاريخ القسط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('البنك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('الهوان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('تفاصيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          
          // Data Table
          Expanded(
            child: Consumer<InstallmentsProvider>(
              builder: (context, provider, _) {
                // Filter installments based on criteria
                var filteredInstallments = provider.installments.where((inst) {
                  if (inst.status == 'completed') return false;
                  
                  // Search filter
                  if (_searchQuery.isNotEmpty && 
                      !inst.customerName.toLowerCase().contains(_searchQuery)) {
                    return false;
                  }
                  
                  // Type filter
                  if (_filterType == 'متأخر' && inst.status != 'overdue') return false;
                  if (_filterType == 'مستحق اليوم') {
                    // Check if due today
                    final dueDate = DateTime.parse(inst.startDate);
                    if (!_isSameDay(dueDate, DateTime.now())) return false;
                  }
                  
                  return true;
                }).toList();
                
                if (filteredInstallments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد أقساط مستحقة',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredInstallments.length,
                  itemBuilder: (context, index) {
                    final installment = filteredInstallments[index];
                    final isOverdue = installment.status == 'overdue';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOverdue ? const Color(0xFFEF4444) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : Colors.grey.shade200).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            // Number
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            
                            // Customer Name
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.person, color: Color(0xFF10B981), size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      installment.customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Remaining Installments
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${installment.numberOfInstallments - installment.paidInstallments}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                            
                            // Status
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFFFFA500),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isOverdue ? 'متأخر' : 'مستحق',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            
                            // Installment Amount
                            Expanded(
                              flex: 2,
                              child: Text(
                                currencyFormat.format(installment.installmentAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            
                            // Due Date
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(DateTime.parse(installment.startDate)),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            
                            // Bank (placeholder)
                            const Expanded(
                              flex: 2,
                              child: Text(
                                '-',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            
                            // Discount (placeholder)
                            const Expanded(
                              flex: 2,
                              child: Text(
                                '-',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            
                            // Details Button
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    _showInstallmentDetails(context, installment);
                                  },
                                  icon: const Icon(Icons.info_outline, color: Color(0xFF6366F1)),
                                  tooltip: 'التفاصيل',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Summary Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Consumer<InstallmentsProvider>(
              builder: (context, provider, _) {
                final overdueTotal = provider.getTotalOverdueAmount();
                final activeTotal = provider.getTotalActiveInstallments();
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard(
                      'إجمالي المتأخر',
                      currencyFormat.format(overdueTotal),
                      const Color(0xFFEF4444),
                      Icons.warning,
                    ),
                    _buildSummaryCard(
                      'إجمالي المستحق',
                      currencyFormat.format(activeTotal),
                      const Color(0xFFFFA500),
                      Icons.schedule,
                    ),
                    _buildSummaryCard(
                      'عدد الأقساط',
                      '${provider.getActiveInstallmentsCount()}',
                      const Color(0xFF6366F1),
                      Icons.receipt_long,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInstallmentDetails(BuildContext context, Installment installment) {
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل القسط'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('اسم الزبون', installment.customerName),
              _buildDetailRow('المبلغ الكلي', currencyFormat.format(installment.totalAmount)),
              _buildDetailRow('المبلغ المدفوع', currencyFormat.format(installment.paidAmount)),
              _buildDetailRow('المبلغ المتبقي', currencyFormat.format(installment.remainingAmount)),
              _buildDetailRow('عدد الأقساط', '${installment.numberOfInstallments}'),
              _buildDetailRow('الأقساط المسددة', '${installment.paidInstallments}'),
              _buildDetailRow('قيمة القسط', currencyFormat.format(installment.installmentAmount)),
              _buildDetailRow('تاريخ البدء', installment.startDate),
              _buildDetailRow('الحالة', installment.status == 'active' ? 'نشط' : installment.status == 'overdue' ? 'متأخر' : 'مكتمل'),
              if (installment.notes.isNotEmpty)
                _buildDetailRow('ملاحظات', installment.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
