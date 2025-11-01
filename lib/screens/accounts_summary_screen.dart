import 'package:flutter/material.dart';

class AccountsSummaryScreen extends StatefulWidget {
  const AccountsSummaryScreen({super.key});

  @override
  State<AccountsSummaryScreen> createState() => _AccountsSummaryScreenState();
}

class _AccountsSummaryScreenState extends State<AccountsSummaryScreen> {
  String _selectedCurrency = 'دينار';
  String _selectedAccountType = 'نوع الحساب';

  final List<String> _currencies = ['دينار', 'دولار'];
  final List<String> _accountTypes = [
    'نوع الحساب',
    'الحسابات المدينة',
    'الحسابات الدائنة',
    'الحسابات المتوازنة',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
      body: Column(
        children: [
          // Top filters bar
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
            child: Row(
              children: [
                // Update button with refresh icon
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('تحديث'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),

                const Spacer(),

                // Currency dropdown
                Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      items: _currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency,
                              style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCurrency = value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Account type dropdown
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAccountType,
                      isExpanded: true,
                      items: _accountTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child:
                              Text(type, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAccountType = value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                const Text('العملة',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          // Table header and data
          Container(
            color: Colors.cyan,
            child: Table(
              border: TableBorder.all(color: Colors.white, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('الفترة'),
                    _buildHeaderCell('الدليل المحاسبي'),
                    _buildHeaderCell('دينار'),
                    _buildHeaderCell('دولار'),
                    _buildHeaderCell('الرصيد النهائي...'),
                    _buildHeaderCell('نوع الحساب'),
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
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    _buildDataCell('2025-01-01 - 2025-01-31',
                        align: TextAlign.center),
                    _buildDataCell('الصندوق', align: TextAlign.center),
                    _buildDataCell('1,500,000', align: TextAlign.center),
                    _buildDataCell('2,000', align: TextAlign.center),
                    _buildDataCell('1,502,000', align: TextAlign.center),
                    _buildDataCell('أصول', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('2025-01-01 - 2025-01-31',
                        align: TextAlign.center),
                    _buildDataCell('البنك', align: TextAlign.center),
                    _buildDataCell('3,200,000', align: TextAlign.center),
                    _buildDataCell('5,000', align: TextAlign.center),
                    _buildDataCell('3,205,000', align: TextAlign.center),
                    _buildDataCell('أصول', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('2025-01-01 - 2025-01-31',
                        align: TextAlign.center),
                    _buildDataCell('المخزون', align: TextAlign.center),
                    _buildDataCell('5,000,000', align: TextAlign.center),
                    _buildDataCell('0', align: TextAlign.center),
                    _buildDataCell('5,000,000', align: TextAlign.center),
                    _buildDataCell('أصول', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('2025-01-01 - 2025-01-31',
                        align: TextAlign.center),
                    _buildDataCell('المبيعات', align: TextAlign.center),
                    _buildDataCell('8,500,000', align: TextAlign.center),
                    _buildDataCell('10,000', align: TextAlign.center),
                    _buildDataCell('8,510,000', align: TextAlign.center),
                    _buildDataCell('إيرادات', align: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    _buildDataCell('2025-01-01 - 2025-01-31',
                        align: TextAlign.center),
                    _buildDataCell('المشتريات', align: TextAlign.center),
                    _buildDataCell('4,800,000', align: TextAlign.center),
                    _buildDataCell('6,000', align: TextAlign.center),
                    _buildDataCell('4,806,000', align: TextAlign.center),
                    _buildDataCell('مصروفات', align: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),

          // Summary rows (المجموع)
          Container(
            color: Colors.cyan,
            child: Table(
              border: TableBorder.all(color: Colors.white, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                _buildSummaryRow(
                    'المـجــمــوع', '23,000,000', '23,000', '23,023,000', ''),
              ],
            ),
          ),

          // Second summary row
          Container(
            color: isDark ? const Color(0xFF334155) : Colors.white,
            child: Table(
              border: TableBorder.all(color: Colors.grey[300]!, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    _buildDataCell('', align: TextAlign.center),
                    _buildDataCell('', align: TextAlign.center),
                    _buildDataCell('23,000,000', align: TextAlign.center),
                    _buildDataCell('23,000', align: TextAlign.center),
                    _buildDataCell('23,023,000', align: TextAlign.center),
                    _buildDataCell('', align: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),

          // Spacer for empty content area
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF2C3E50) : const Color(0xFF37474F),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Export button
                SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري التصدير...')),
                      );
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('تصدير', style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Print button
                SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري الطباعة...')),
                      );
                    },
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('طباعة', style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  TableRow _buildSummaryRow(String label, String value1, String value2,
      String value3, String value4) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        _buildSummaryCell(value1),
        _buildSummaryCell(value2),
        _buildSummaryCell(value3),
        _buildSummaryCell(value4),
        _buildSummaryCell(''),
      ],
    );
  }

  Widget _buildSummaryCell(String text) {
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
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {TextAlign align = TextAlign.start}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
