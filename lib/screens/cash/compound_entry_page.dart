import 'package:flutter/material.dart';

class CompoundEntryPage extends StatefulWidget {
  const CompoundEntryPage({super.key});

  @override
  State<CompoundEntryPage> createState() => _CompoundEntryPageState();
}

class _CompoundEntryPageState extends State<CompoundEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController(text: '1');
  final _debitController = TextEditingController(text: '0');
  final _creditController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedAccount;

  final List<String> _accounts = [
    'حساب النقدية',
    'حساب البنك',
    'حساب العملاء',
    'حساب الموردين',
    'حساب المصروفات',
    'حساب الإيرادات',
  ];

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ القيد المركب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearForm() {
    _voucherNumberController.clear();
    _debitController.text = '0';
    _creditController.text = '0';
    _notesController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedAccount = null;
    });
  }

  void _deleteEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا القيد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف القيد')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _print() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الطباعة...')),
    );
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
            // Top section
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF334155) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.cyan),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('التاريخ', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _voucherNumberController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('الرقم', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            // Table header
            Container(
              color: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                children: [
                  SizedBox(
                      width: 60,
                      child: Center(
                          child: Text('-',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                  Expanded(
                      flex: 2,
                      child: Center(
                          child: Text('اسم الحساب',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                  Expanded(
                      child: Center(
                          child: Text('دائن',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                  Expanded(
                      child: Center(
                          child: Text('مدين',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                  Expanded(
                      flex: 2,
                      child: Center(
                          child: Text('البيان',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                ],
              ),
            ),

            // Single row
            Container(
              padding: const EdgeInsets.all(8),
              color: isDark ? const Color(0xFF334155) : Colors.white,
              child: Row(
                children: [
                  const SizedBox(
                      width: 60, child: Icon(Icons.close, color: Colors.red)),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedAccount,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                      hint: const Text('اختيار'),
                      items: _accounts.map((account) {
                        return DropdownMenuItem(
                            value: account, child: Text(account));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAccount = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _debitController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF334155) : Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _clearForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('جديد'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('حفظ'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _deleteEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('حذف'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: _print,
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('طباعة'),
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
      ),
    );
  }
}
