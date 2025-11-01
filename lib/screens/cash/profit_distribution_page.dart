import 'package:flutter/material.dart';

class ProfitDistributionPage extends StatefulWidget {
  const ProfitDistributionPage({super.key});

  @override
  State<ProfitDistributionPage> createState() => _ProfitDistributionPageState();
}

class _ProfitDistributionPageState extends State<ProfitDistributionPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController(text: '1');
  final _currencyController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _percentageController = TextEditingController(text: '29');
  final _amountController = TextEditingController();
  final _amountInWordsController = TextEditingController();
  final _notesController = TextEditingController(
      text: 'توزيع ارباح من حساب .. ارباح الفروع .. للخساب ..');

  DateTime _selectedDate = DateTime.now();
  String _currency = 'دينار';

  @override
  void initState() {
    super.initState();
  }

  void _saveDistribution() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ سند توزيع الأرباح بنجاح')),
      );
    }
  }

  void _deleteDistribution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف سند توزيع الأرباح؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف السند')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _voucherNumberController.text = '1';
    _currencyController.clear();
    _accountNameController.clear();
    _percentageController.text = '29';
    _amountController.clear();
    _amountInWordsController.clear();
    _notesController.text = 'توزيع ارباح من حساب .. ارباح الفروع .. للخساب ..';
    setState(() => _selectedDate = DateTime.now());
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _currencyController.dispose();
    _accountNameController.dispose();
    _percentageController.dispose();
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
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                            labelText: 'التاريــــــــــــــــــــــخ',
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
                onChanged: (value) => setState(() => _currency = value!),
              ),

              const SizedBox(height: 20),

              // اسم الحساب مع النسبة
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _accountNameController,
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
                    flex: 1,
                    child: TextFormField(
                      controller: _percentageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
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
                ],
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

              const SizedBox(height: 32),

              // Action Buttons
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
                        onPressed: _saveDistribution,
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
                        onPressed: _deleteDistribution,
                        icon: const Icon(Icons.delete, size: 24),
                        label: const Text('حذف',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
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
