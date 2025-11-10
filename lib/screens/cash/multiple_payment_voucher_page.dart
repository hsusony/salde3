import 'package:flutter/material.dart';

class MultiplePaymentVoucherPage extends StatefulWidget {
  const MultiplePaymentVoucherPage({super.key});

  @override
  State<MultiplePaymentVoucherPage> createState() =>
      _MultiplePaymentVoucherPageState();
}

class _MultiplePaymentVoucherPageState
    extends State<MultiplePaymentVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  // قائمة الصفوف في الجدول
  final List<PaymentRow> _paymentRows = [];

  // مجاميع الأعمدة
  double _totalCurrentAmount = 0.0;
  double _totalPreviousAmount = 0.0;
  // double _totalTotalAmount = 0.0; // معطل مؤقتاً - غير مستخدم

  @override
  void initState() {
    super.initState();
    _generateVoucherNumber();
    // إضافة صف فارغ للبداية
    _addNewRow();
  }

  void _generateVoucherNumber() {
    final now = DateTime.now();
    _voucherNumberController.text =
        '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}';
  }

  void _addNewRow() {
    setState(() {
      _paymentRows.add(PaymentRow(
        accountNameController: TextEditingController(),
        currentAmountController: TextEditingController(text: '0'),
        previousAmountController: TextEditingController(text: '0'),
      ));
    });
  }

  void _deleteRow(int index) {
    setState(() {
      _paymentRows[index].dispose();
      _paymentRows.removeAt(index);
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    double currentTotal = 0.0;
    double previousTotal = 0.0;

    for (var row in _paymentRows) {
      currentTotal += double.tryParse(row.currentAmountController.text) ?? 0.0;
      previousTotal +=
          double.tryParse(row.previousAmountController.text) ?? 0.0;
    }

    setState(() {
      _totalCurrentAmount = currentTotal;
      _totalPreviousAmount = previousTotal;
      // _totalTotalAmount = currentTotal + previousTotal; // معطل مؤقتاً
    });
  }

  void _saveVoucher() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ سند الدفع المتعدد بنجاح')),
      );
    }
  }

  void _printVoucher() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الطباعة...')),
    );
  }

  void _clearForm() {
    _voucherNumberController.clear();
    for (var row in _paymentRows) {
      row.dispose();
    }
    _paymentRows.clear();
    _generateVoucherNumber();
    _addNewRow();
    _calculateTotals();
    setState(() {});
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    for (var row in _paymentRows) {
      row.dispose();
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
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                  // Row 1: رقم المستند والتاريخ
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _voucherNumberController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'اسم الحساب',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
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
                                    '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                              ),
                              decoration: InputDecoration(
                                labelText: 'التأريخ',
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Table Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(60), // #
                          1: FixedColumnWidth(80), // حذف
                          2: FlexColumnWidth(3), // اسم الحساب
                          3: FlexColumnWidth(1.5), // المبلغ
                          4: FlexColumnWidth(1.5), // الخصم
                          5: FlexColumnWidth(1.5), // ملاحظة
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell('#', isDark),
                              _buildHeaderCell('حذف', isDark,
                                  color: Colors.red),
                              _buildHeaderCell('اسم الحساب', isDark,
                                  color: Colors.cyan),
                              _buildHeaderCell('المبلغ', isDark,
                                  color: Colors.green),
                              _buildHeaderCell('الخصم', isDark,
                                  color: Colors.pink),
                              _buildHeaderCell('ملاحظة', isDark,
                                  color: Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Table Body (Scrollable)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                          columnWidths: const {
                            0: FixedColumnWidth(60),
                            1: FixedColumnWidth(80),
                            2: FlexColumnWidth(3),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1.5),
                            5: FlexColumnWidth(1.5),
                          },
                          children: [
                            ..._paymentRows.asMap().entries.map((entry) {
                              int index = entry.key;
                              PaymentRow row = entry.value;
                              return TableRow(
                                children: [
                                  _buildIndexCell('${index + 1}', isDark),
                                  _buildDeleteButtonCell(index, isDark),
                                  _buildTextFieldCell(
                                      row.accountNameController, isDark),
                                  _buildNumberFieldCell(
                                      row.currentAmountController,
                                      isDark,
                                      () => _calculateTotals()),
                                  _buildNumberFieldCell(
                                      row.previousAmountController,
                                      isDark,
                                      () => _calculateTotals()),
                                  _buildTextFieldCell(
                                      row.noteController, isDark),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Totals Row
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF1E40AF) : Colors.blue[50],
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(60),
                          1: FixedColumnWidth(80),
                          2: FlexColumnWidth(3),
                          3: FlexColumnWidth(1.5),
                          4: FlexColumnWidth(1.5),
                          5: FlexColumnWidth(1.5),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell(
                                  'مجموع مبالغ البيانات', isDark),
                              _buildTotalValueCell(
                                  _totalCurrentAmount, isDark, Colors.green),
                              _buildTotalValueCell(
                                  _totalPreviousAmount, isDark, Colors.pink),
                              _buildTotalLabelCell('', isDark),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell(
                                  'مجموع الخصم المدور', isDark),
                              _buildTotalValueCell(0.0, isDark, Colors.orange),
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell('', isDark),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell(
                                  'مجموع عدد السندات البيانات', isDark),
                              _buildTotalValueCell(
                                  _paymentRows.length.toDouble(),
                                  isDark,
                                  Colors.blue),
                              _buildTotalLabelCell('', isDark),
                              _buildTotalLabelCell('', isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _addNewRow,
                        icon: const Icon(Icons.add, size: 24),
                        label: const Text('جديد',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _saveVoucher,
                        icon: const Icon(Icons.save, size: 24),
                        label: const Text('حفظ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _printVoucher,
                        icon: const Icon(Icons.print, size: 24),
                        label: const Text('طباعة',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
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

  Widget _buildHeaderCell(String text, bool isDark, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color?.withOpacity(0.2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color ?? (isDark ? Colors.white : Colors.black87),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIndexCell(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDeleteButtonCell(int index, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteRow(index),
        tooltip: 'حذف',
      ),
    );
  }

  Widget _buildTextFieldCell(TextEditingController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNumberFieldCell(
      TextEditingController controller, bool isDark, VoidCallback onChanged) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  Widget _buildTotalLabelCell(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTotalValueCell(double value, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
      ),
      child: Text(
        value.toStringAsFixed(2),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PaymentRow {
  final TextEditingController accountNameController;
  final TextEditingController currentAmountController;
  final TextEditingController previousAmountController;
  final TextEditingController noteController;

  PaymentRow({
    required this.accountNameController,
    required this.currentAmountController,
    required this.previousAmountController,
  }) : noteController = TextEditingController();

  void dispose() {
    accountNameController.dispose();
    currentAmountController.dispose();
    previousAmountController.dispose();
    noteController.dispose();
  }
}
