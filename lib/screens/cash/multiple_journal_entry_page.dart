import 'package:flutter/material.dart';

class MultipleJournalEntryRow {
  TextEditingController accountController = TextEditingController();
  TextEditingController debitController = TextEditingController(text: '0');
  TextEditingController creditController = TextEditingController(text: '0');
  TextEditingController noteController = TextEditingController();
}

class MultipleJournalEntryPage extends StatefulWidget {
  const MultipleJournalEntryPage({super.key});

  @override
  State<MultipleJournalEntryPage> createState() =>
      _MultipleJournalEntryPageState();
}

class _MultipleJournalEntryPageState extends State<MultipleJournalEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController();
  final List<MultipleJournalEntryRow> _rows = [];

  DateTime _selectedDate = DateTime.now();
  double _totalDebit = 0;
  double _totalCredit = 0;

  @override
  void initState() {
    super.initState();
    // Add initial empty row
    _addRow();
  }

  void _addRow() {
    setState(() {
      _rows.add(MultipleJournalEntryRow());
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows[index].accountController.dispose();
        _rows[index].debitController.dispose();
        _rows[index].creditController.dispose();
        _rows[index].noteController.dispose();
        _rows.removeAt(index);
        _calculateTotals();
      });
    }
  }

  void _calculateTotals() {
    double debit = 0;
    double credit = 0;

    for (var row in _rows) {
      debit += double.tryParse(row.debitController.text) ?? 0;
      credit += double.tryParse(row.creditController.text) ?? 0;
    }

    setState(() {
      _totalDebit = debit;
      _totalCredit = credit;
    });
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ القيد المحاسبي المتعدد بنجاح')),
      );
    }
  }

  void _clearForm() {
    _voucherNumberController.clear();
    setState(() {
      for (var row in _rows) {
        row.accountController.dispose();
        row.debitController.dispose();
        row.creditController.dispose();
        row.noteController.dispose();
      }
      _rows.clear();
      _addRow();
      _selectedDate = DateTime.now();
      _totalDebit = 0;
      _totalCredit = 0;
    });
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    for (var row in _rows) {
      row.accountController.dispose();
      row.debitController.dispose();
      row.creditController.dispose();
      row.noteController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Professional Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF334155),
                          const Color(0xFF475569)
                        ]
                      : [
                          const Color(0xFF6366F1),
                          const Color(0xFF7C3AED),
                          const Color(0xFF8B5CF6)
                        ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF6366F1))
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
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
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'سند قيد محاسبي متعدد',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Multiple Journal Entry Voucher',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date and Document Number
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'التاريخ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 150,
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (date != null) {
                                        setState(() => _selectedDate = date);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.numbers_rounded,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'رقم السند',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 120,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _voucherNumberController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons Row
                  Row(
                    children: [
                      _buildModernButton(
                        label: 'الفرع',
                        icon: Icons.account_tree_rounded,
                        color: const Color(0xFF0EA5E9),
                        count: '0',
                      ),
                      const SizedBox(width: 12),
                      _buildModernButton(
                        label: 'مركز الكلفة',
                        icon: Icons.account_balance_rounded,
                        color: const Color(0xFF8B5CF6),
                        count: '0',
                      ),
                      const SizedBox(width: 12),
                      _buildModernButton(
                        label: 'طبع',
                        icon: Icons.print_rounded,
                        color: const Color(0xFF10B981),
                        count: null,
                      ),
                      const SizedBox(width: 12),
                      _buildModernButton(
                        label: 'تصدير',
                        icon: Icons.file_download_rounded,
                        color: const Color(0xFFF59E0B),
                        count: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Modern Table Header
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF7C3AED),
                    Color(0xFF8B5CF6)
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    _buildModernHeaderCell('ت',
                        flex: 1, icon: Icons.tag_rounded),
                    _buildModernHeaderCell('ملاحظات',
                        flex: 2, icon: Icons.notes_rounded),
                    _buildModernHeaderCell('المبلغ الدائن',
                        flex: 1, icon: Icons.arrow_downward_rounded),
                    _buildModernHeaderCell('المبلغ المدين',
                        flex: 1, icon: Icons.arrow_upward_rounded),
                    _buildModernHeaderCell('اسم الحساب',
                        flex: 3, icon: Icons.account_circle_rounded),
                    const SizedBox(width: 50), // للزر الحذف
                  ],
                ),
              ),
            ),

            // Modern Table Rows
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, animValue, child) {
                        return Opacity(
                          opacity: animValue,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - animValue)),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF334155),
                                          const Color(0xFF475569)
                                        ]
                                      : [const Color(0xFFFAFAFA), Colors.white],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Row Number
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6366F1),
                                              Color(0xFF8B5CF6)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6366F1)
                                                  .withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Notes
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: TextFormField(
                                          controller:
                                              _rows[index].noteController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'ملاحظات...',
                                            isDense: true,
                                          ),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Credit amount
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFEF4444)
                                                  .withOpacity(0.1),
                                              const Color(0xFFDC2626)
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFEF4444)
                                                .withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller:
                                              _rows[index].creditController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            isDense: true,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFEF4444),
                                          ),
                                          onChanged: (value) =>
                                              _calculateTotals(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Debit amount
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF10B981)
                                                  .withOpacity(0.1),
                                              const Color(0xFF059669)
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFF10B981)
                                                .withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller:
                                              _rows[index].debitController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            isDense: true,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                          onChanged: (value) =>
                                              _calculateTotals(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Account name dropdown
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'اختر الحساب...',
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          items: <String>[].map((account) {
                                            return DropdownMenuItem(
                                                value: account,
                                                child: Text(account));
                                          }).toList(),
                                          onChanged: (value) {},
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Delete button
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEF4444),
                                            Color(0xFFDC2626)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFEF4444)
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close_rounded,
                                            color: Colors.white, size: 20),
                                        onPressed: () => _removeRow(index),
                                        tooltip: 'حذف',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Professional Totals Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF334155),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF8FAFC),
                        ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModernTotalCard(
                    title: 'مجموع المدين',
                    value: _totalDebit,
                    icon: Icons.arrow_upward_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    shadowColor: const Color(0xFF10B981),
                  ),
                  _buildModernTotalCard(
                    title: 'عدد الحركات',
                    value: _rows.length.toDouble(),
                    icon: Icons.format_list_numbered_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    shadowColor: const Color(0xFF6366F1),
                    isCount: true,
                  ),
                  _buildModernTotalCard(
                    title: 'مجموع الدائن',
                    value: _totalCredit,
                    icon: Icons.arrow_downward_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    shadowColor: const Color(0xFFEF4444),
                  ),
                  // Balance Indicator
                  _buildBalanceCard(
                    isDark: isDark,
                    isBalanced: (_totalDebit - _totalCredit).abs() < 0.01,
                    difference: (_totalDebit - _totalCredit).abs(),
                  ),
                ],
              ),
            ),

            // Modern Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'إضافة صف جديد',
                      icon: Icons.add_circle_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      onPressed: _addRow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      label: 'مسح الكل',
                      icon: Icons.refresh_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      onPressed: _clearForm,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      label: 'حفظ القيد',
                      icon: Icons.save_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      onPressed: _saveEntry,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String label,
    required IconData icon,
    required Color color,
    String? count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernHeaderCell(String text,
      {required int flex, required IconData icon}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTotalCard({
    required String title,
    required double value,
    required IconData icon,
    required LinearGradient gradient,
    required Color shadowColor,
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isCount
                ? value.toStringAsFixed(0)
                : '${value.toStringAsFixed(2)} د.ع',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required bool isDark,
    required bool isBalanced,
    required double difference,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBalanced
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isBalanced ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                    .withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isBalanced ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            isBalanced ? 'القيد متوازن' : 'القيد غير متوازن',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (!isBalanced)
            Text(
              'الفرق: ${difference.toStringAsFixed(2)} د.ع',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (isBalanced)
            const Text(
              '✓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
