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
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top bar with buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: isDark ? const Color(0xFF334155) : Colors.white,
              child: Row(
                children: [
                  // Left side buttons
                  Row(
                    children: [
                      _buildTopButton('الفرع', Colors.blue[900]!),
                      const SizedBox(width: 8),
                      _buildTopButton('مركز الكلفة', Colors.blue[700]!),
                      const SizedBox(width: 8),
                      _buildTopButton('طبع', Colors.grey[600]!),
                      const SizedBox(width: 8),
                      _buildTopButton('أطلب', Colors.blue[800]!),
                      const SizedBox(width: 8),
                      _buildTopButton('اطلب', Colors.blue[800]!),
                    ],
                  ),

                  const Spacer(),

                  // Right side - Date and Document number
                  Row(
                    children: [
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
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text:
                                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('من تاريخ', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _voucherNumberController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _buildHeaderCell('لسم الحساب', flex: 3, color: Colors.green),
                  _buildHeaderCell('المبلغ', flex: 1, color: Colors.green),
                  _buildHeaderCell('دائنية',
                      flex: 1, color: Colors.green[700]!),
                  _buildHeaderCell('كلف الحسابي', flex: 2, color: Colors.blue),
                  _buildHeaderCell('تفار', flex: 1, color: Colors.cyan),
                ],
              ),
            ),

            // Table Rows
            Expanded(
              child: ListView.builder(
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                      color: index % 2 == 0
                          ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                          : (isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[50]),
                    ),
                    child: Row(
                      children: [
                        // Delete button
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red, size: 20),
                            onPressed: () => _removeRow(index),
                          ),
                        ),

                        // Account name dropdown
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                              ),
                              items: <String>[].map((account) {
                                return DropdownMenuItem(
                                    value: account, child: Text(account));
                              }).toList(),
                              onChanged: (value) {},
                            ),
                          ),
                        ),

                        // Debit amount
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: TextFormField(
                              controller: _rows[index].debitController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => _calculateTotals(),
                            ),
                          ),
                        ),

                        // Credit amount
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: TextFormField(
                              controller: _rows[index].creditController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => _calculateTotals(),
                            ),
                          ),
                        ),

                        // Notes
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: TextFormField(
                              controller: _rows[index].noteController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),

                        // Number
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Totals Section
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF334155) : Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTotalBox(
                      'مجموع البيانات الدائن:', _totalCredit, Colors.red),
                  _buildTotalBox('عدد البيانات الدائن:',
                      _rows.length.toDouble(), Colors.blue),
                  _buildTotalBox(
                      'مجموع مبالغ المدين:', _totalDebit, Colors.green),
                ],
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('حفظ', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _addRow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('جديد', style: TextStyle(fontSize: 16)),
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

  Widget _buildTopButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              '0',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text,
      {required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: color,
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
      ),
    );
  }

  Widget _buildTotalBox(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
