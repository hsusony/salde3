import 'package:flutter/material.dart';

class JournalEntryPage extends StatefulWidget {
  const JournalEntryPage({super.key});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController(text: '1');
  final _fromAccountController = TextEditingController();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountInWordsController = TextEditingController();
  final _notesController = TextEditingController(
      text:
          'قيد محاسبي من حساب .. رأس المال المدفوع .. ايد حساب رأس المال المدفوع');

  DateTime _selectedDate = DateTime.now();
  String _currency = 'دينار';
  final String _previousOrderDebit = '0';
  final String _currentOrderDebit = '000';
  final String _previousOrderCredit = '000';
  final String _currentOrderCredit = '000';

  @override
  void initState() {
    super.initState();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ القيد المحاسبي بنجاح')),
      );
    }
  }

  void _clearForm() {
    _voucherNumberController.text = '1';
    _fromAccountController.clear();
    _toAccountController.clear();
    _amountController.clear();
    _amountInWordsController.clear();
    _notesController.text =
        'قيد محاسبي من حساب .. رأس المال المدفوع .. ايد حساب رأس المال المدفوع';
    setState(() => _selectedDate = DateTime.now());
  }

  void _showPreviousEntries() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('عرض السندات السابقة')),
    );
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _fromAccountController.dispose();
    _toAccountController.dispose();
    _amountController.dispose();
    _amountInWordsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with green background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'قيد محاسبي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main content with sidebar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main form area
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Row 1: رقم المستند والتاريخ
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _voucherNumberController,
                                decoration: InputDecoration(
                                  labelText: 'رقم المستند',
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
                                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                    ),
                                    decoration: InputDecoration(
                                      labelText:
                                          'التاريــــــــــــــــــــــخ',
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFF1F5F9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon:
                                          const Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // العملة
                        DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: InputDecoration(
                            labelText: 'العملــــــــــــــــــــــة',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ['دينار', 'دولار', 'يورو'].map((currency) {
                            return DropdownMenuItem(
                                value: currency, child: Text(currency));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _currency = value!),
                        ),

                        const SizedBox(height: 20),

                        // من حساب
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'من حساب',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: <String>[].map((account) {
                            return DropdownMenuItem(
                                value: account, child: Text(account));
                          }).toList(),
                          onChanged: (value) {},
                        ),

                        const SizedBox(height: 20),

                        // الى حساب
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'الى حساب',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: <String>[].map((account) {
                            return DropdownMenuItem(
                                value: account, child: Text(account));
                          }).toList(),
                          onChanged: (value) {},
                        ),

                        const SizedBox(height: 20),

                        // المبلــــــــــــــــــــــغ
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'المبلــــــــــــــــــــــغ',
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

                        const SizedBox(height: 20),

                        // المبلـــــــــــــــــــغ كتابياً
                        TextFormField(
                          controller: _amountInWordsController,
                          decoration: InputDecoration(
                            labelText: 'المبلـــــــــــــــــــغ كتابياً',
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

                        const SizedBox(height: 20),

                        // البيــــــــــــــــــــــــــان
                        TextFormField(
                          controller: _notesController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'البيــــــــــــــــــــــــــان',
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
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Sidebar
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        // الطلب السابق والحالي sections
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'الطلب الحالي',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _currentOrderDebit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'الطلب السابق',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _previousOrderDebit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Second row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'الطلب الحالي',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _currentOrderCredit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'الطلب السابق',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _previousOrderCredit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // السندات السابقة button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _showPreviousEntries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'السندات السابقة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.add_circle_outline, size: 24),
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
                        onPressed: _saveEntry,
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
                ],
              ),

              const SizedBox(height: 16),

              // Print checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('طباعة', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
