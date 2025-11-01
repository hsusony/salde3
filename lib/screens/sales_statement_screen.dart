import 'package:flutter/material.dart';

class SalesStatementScreen extends StatefulWidget {
  const SalesStatementScreen({super.key});

  @override
  State<SalesStatementScreen> createState() => _SalesStatementScreenState();
}

class _SalesStatementScreenState extends State<SalesStatementScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedInvoiceType = 'فاتورة المبيعات';
  final String _selectedAccount = 'اختيار الحساب';

  final List<String> _invoiceTypes = [
    'فاتورة المبيعات',
    'فاتورة مردودات',
    'عرض الأسعار',
    'الكل',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
      body: Column(
        children: [
          // Top filters section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // First row - Account selection
                Row(
                  children: [
                    // جديد button
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        child:
                            const Text('جديد', style: TextStyle(fontSize: 14)),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // المجموعات المستحقة button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('المجموعات المستحقة',
                              style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down,
                              size: 18, color: Colors.grey[600]),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (value) {},
                        ),
                        const Text('عرضة الفواتير المسددة',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),

                    const Spacer(),

                    // Account selection dropdown
                    Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAccount,
                          isExpanded: true,
                          items: [_selectedAccount].map((account) {
                            return DropdownMenuItem(
                              value: account,
                              child: Text(account,
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {},
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    const Text('اختيار الحساب',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),

                const SizedBox(height: 16),

                // Second row - Date and invoice type
                Row(
                  children: [
                    // From date
                    const Text('من تاريخ', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _fromDate = date);
                        }
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fromDate != null
                                  ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                                  : '10/25/2025',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // To date
                    const Text('الى تاريخ', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _toDate = date);
                        }
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _toDate != null
                                  ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                                  : '10/25/2025',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // نوع الفاتورة label and dropdown
                    const Text('نوع الفاتورة',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedInvoiceType,
                          isExpanded: true,
                          items: _invoiceTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type,
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedInvoiceType = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table header and data
          Container(
            color: Colors.cyan,
            child: Table(
              border: TableBorder.all(color: Colors.white, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(1),
                7: FlexColumnWidth(1),
                8: FlexColumnWidth(1.2),
                9: FlexColumnWidth(1),
                10: FlexColumnWidth(1.2),
                11: FlexColumnWidth(1),
                12: FlexColumnWidth(0.8),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('رقم الفاتورة'),
                    _buildHeaderCell('اسم الزبون'),
                    _buildHeaderCell('الربح'),
                    _buildHeaderCell('الخصومات'),
                    _buildHeaderCell('الضريبة'),
                    _buildHeaderCell('سعر البي...'),
                    _buildHeaderCell('سعر الش...'),
                    _buildHeaderCell('المجموع'),
                    _buildHeaderCell('التاريخ'),
                    _buildHeaderCell('عدد الفا...'),
                    _buildHeaderCell('اسم الصنف'),
                    _buildHeaderCell('الحسم'),
                    _buildHeaderCell('العدد'),
                  ],
                ),
              ],
            ),
          ),

          // Data rows
          Container(
            color: isDark ? const Color(0xFF334155) : Colors.white,
            child: Table(
              border: TableBorder.all(color: Colors.grey[300]!, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(1),
                7: FlexColumnWidth(1),
                8: FlexColumnWidth(1.2),
                9: FlexColumnWidth(1),
                10: FlexColumnWidth(1.2),
                11: FlexColumnWidth(1),
                12: FlexColumnWidth(0.8),
              },
              children: [
                TableRow(
                  children: [
                    _buildDataCell('001', align: TextAlign.center),
                    _buildDataCell('علي أحمد', align: TextAlign.center),
                    _buildDataCell('50,000', align: TextAlign.center),
                    _buildDataCell('10,000', align: TextAlign.center),
                    _buildDataCell('5,000', align: TextAlign.center),
                    _buildDataCell('200,000', align: TextAlign.center),
                    _buildDataCell('150,000', align: TextAlign.center),
                    _buildDataCell('195,000', align: TextAlign.center),
                    _buildDataCell('2025-01-15', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('لابتوب HP', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('2', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('002', align: TextAlign.center),
                    _buildDataCell('محمد حسن', align: TextAlign.center),
                    _buildDataCell('75,000', align: TextAlign.center),
                    _buildDataCell('5,000', align: TextAlign.center),
                    _buildDataCell('7,500', align: TextAlign.center),
                    _buildDataCell('300,000', align: TextAlign.center),
                    _buildDataCell('225,000', align: TextAlign.center),
                    _buildDataCell('302,500', align: TextAlign.center),
                    _buildDataCell('2025-01-16', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('طابعة Canon', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('3', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('003', align: TextAlign.center),
                    _buildDataCell('فاطمة علي', align: TextAlign.center),
                    _buildDataCell('30,000', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('4,000', align: TextAlign.center),
                    _buildDataCell('150,000', align: TextAlign.center),
                    _buildDataCell('120,000', align: TextAlign.center),
                    _buildDataCell('154,000', align: TextAlign.center),
                    _buildDataCell('2025-01-17', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('ماوس لاسلكي', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('5', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('004', align: TextAlign.center),
                    _buildDataCell('حسين جاسم', align: TextAlign.center),
                    _buildDataCell('100,000', align: TextAlign.center),
                    _buildDataCell('20,000', align: TextAlign.center),
                    _buildDataCell('10,000', align: TextAlign.center),
                    _buildDataCell('400,000', align: TextAlign.center),
                    _buildDataCell('300,000', align: TextAlign.center),
                    _buildDataCell('390,000', align: TextAlign.center),
                    _buildDataCell('2025-01-18', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('شاشة Samsung', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),

          // Empty content area
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF2C3E50) : const Color(0xFF37474F),
            ),
          ),

          // Bottom summary section
          Container(
            color: isDark ? const Color(0xFF334155) : Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox('عدد الفواتير:', '4', Colors.blue),
                _buildSummaryBox('صافي المبيعات', '1,041,500', Colors.green),
                _buildSummaryBox('مجموع الخصم', '35,000', Colors.red),
                _buildSummaryBox('مجموع الارباح', '255,000', Colors.orange),
                _buildSummaryBox('صافي الارباح', '220,000', Colors.teal),
              ],
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ايقاف التقسيط button
                SizedBox(
                  width: 140,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ايقاف التقسيط',
                        style: TextStyle(fontSize: 14)),
                  ),
                ),

                const SizedBox(width: 12),

                // تصدير button with icon
                SizedBox(
                  width: 120,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('تصدير', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // الموديل button
                Container(
                  width: 100,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('الموديل', style: TextStyle(fontSize: 14)),
                ),

                const SizedBox(width: 12),

                // Arrow down icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {TextAlign? align}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        textAlign: align ?? TextAlign.start,
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
