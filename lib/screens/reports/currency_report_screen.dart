import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyReportScreen extends StatefulWidget {
  const CurrencyReportScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyReportScreen> createState() => _CurrencyReportScreenState();
}

class _CurrencyReportScreenState extends State<CurrencyReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('تقارير العملات'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Export to Excel
            },
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تصدير',
          ),
          IconButton(
            onPressed: () {
              // Print
            },
            icon: const Icon(Icons.print_rounded),
            tooltip: 'طباعة',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // From Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'من تاريخ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fromDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _fromDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_fromDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // To Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إلى',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _toDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _toDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_toDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Report Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                              width: 80,
                              child: Text('المستخدم',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(width: 20),
                          Expanded(
                              child: Text('العملة',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('سعر الصرف الجديد',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('سعر الصرف القديم',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('تاريخ التغيير',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),

                    // Sample Data Rows
                    _buildDataRow(
                      isDark: isDark,
                      user: 'المستخدم',
                      currency: 'دولار',
                      newRate: '1,460',
                      oldRate: '1,450',
                      date: '02/11/2025',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Export to Excel
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('تصدير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Print
                  },
                  icon: const Icon(Icons.print_rounded, size: 20),
                  label: const Text('طباعة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required bool isDark,
    required String user,
    required String currency,
    required String newRate,
    required String oldRate,
    required String date,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
                ),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              user,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text(currency)),
          Expanded(
            child: Text(
              newRate,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              oldRate,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(date)),
        ],
      ),
    );
  }
}
