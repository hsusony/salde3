import 'package:flutter/material.dart';

class PurchasesStatementScreen extends StatefulWidget {
  const PurchasesStatementScreen({super.key});

  @override
  State<PurchasesStatementScreen> createState() =>
      _PurchasesStatementScreenState();
}

class _PurchasesStatementScreenState extends State<PurchasesStatementScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedInvoiceType = 'نوع الفاتورة';
  final String _selectedAccount = 'عينة المورد';

  final List<String> _invoiceTypes = [
    'نوع الفاتورة',
    'فاتورة مشتريات',
    'فاتورة مردودات',
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
                // First row
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
                      width: 200,
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
                    const Text('اختيار المورد',
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
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(1),
                7: FlexColumnWidth(1),
                8: FlexColumnWidth(1.2),
                9: FlexColumnWidth(1),
                10: FlexColumnWidth(1.5),
                11: FlexColumnWidth(0.8),
                12: FlexColumnWidth(0.8),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('رقم الفاتورة'),
                    _buildHeaderCell('اسم المزود'),
                    _buildHeaderCell('الاحمر ربح'),
                    _buildHeaderCell('ملاحظات'),
                    _buildHeaderCell('الضم'),
                    _buildHeaderCell('الخصم'),
                    _buildHeaderCell('المجموع'),
                    _buildHeaderCell('التاريخ'),
                    _buildHeaderCell('اسم المورد'),
                    _buildHeaderCell('ت...'),
                    _buildHeaderCell('عدد البالية'),
                    _buildHeaderCell('سعر البيع'),
                    _buildHeaderCell('سعر الش...'),
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
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(1),
                7: FlexColumnWidth(1),
                8: FlexColumnWidth(1.2),
                9: FlexColumnWidth(1),
                10: FlexColumnWidth(1.5),
                11: FlexColumnWidth(0.8),
                12: FlexColumnWidth(0.8),
              },
              children: [
                TableRow(
                  children: [
                    _buildDataCell('P001', align: TextAlign.center),
                    _buildDataCell('شركة التقنية', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('بضاعة جيدة', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('5,000', align: TextAlign.center),
                    _buildDataCell('145,000', align: TextAlign.center),
                    _buildDataCell('2025-01-10', align: TextAlign.center),
                    _buildDataCell('المورد 1', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('10', align: TextAlign.center),
                    _buildDataCell('200,000', align: TextAlign.center),
                    _buildDataCell('150,000', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('P002', align: TextAlign.center),
                    _buildDataCell('شركة الكمبيوتر', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('سريع', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('10,000', align: TextAlign.center),
                    _buildDataCell('290,000', align: TextAlign.center),
                    _buildDataCell('2025-01-12', align: TextAlign.center),
                    _buildDataCell('المورد 2', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('5', align: TextAlign.center),
                    _buildDataCell('300,000', align: TextAlign.center),
                    _buildDataCell('230,000', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('P003', align: TextAlign.center),
                    _buildDataCell('الموزع الرئيسي', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('-', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('180,000', align: TextAlign.center),
                    _buildDataCell('2025-01-14', align: TextAlign.center),
                    _buildDataCell('المورد 3', align: TextAlign.center),
                    _buildDataCell('1', align: TextAlign.center),
                    _buildDataCell('15', align: TextAlign.center),
                    _buildDataCell('150,000', align: TextAlign.center),
                    _buildDataCell('120,000', align: TextAlign.center),
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
                _buildSummaryBox('عدد الفواتير', '3', Colors.blue),
                _buildSummaryBox('صافي المشتريات', '615,000', Colors.red),
                _buildSummaryBox('مجموع الخصم', '15,000', Colors.orange),
                _buildSummaryBox('مجموع تكشيفات', '500,000', Colors.green),
                _buildSummaryBox('صافي المشتريات', '600,000', Colors.teal),
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

                // طباعة button with icon
                SizedBox(
                  width: 120,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('طباعة', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
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
