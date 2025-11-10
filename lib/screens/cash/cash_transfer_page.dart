import 'package:flutter/material.dart';

class CashTransferPage extends StatefulWidget {
  const CashTransferPage({super.key});

  @override
  State<CashTransferPage> createState() => _CashTransferPageState();
}

class _CashTransferPageState extends State<CashTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController(text: '1');
  final _sourceAmountController = TextEditingController(text: '0');
  final _destinationAmountController = TextEditingController(text: '0');
  final _transferAmountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _sourceCashbox = 'صندوق 181';
  String _destinationCashbox = 'صندوق 181';
  final String _sourceCurrency = 'دينار';
  final String _destinationCurrency = 'دينار';

  @override
  void initState() {
    super.initState();
  }

  void _saveTransfer() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ سند التحويل بنجاح')),
      );
    }
  }

  // TODO: تفعيل دالة مسح النموذج عند الحاجة
  // void _clearForm() {
  //   _voucherNumberController.text = '1';
  //   _sourceAmountController.text = '0';
  //   _destinationAmountController.text = '0';
  //   _transferAmountController.clear();
  //   setState(() => _selectedDate = DateTime.now());
  // }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _sourceAmountController.dispose();
    _destinationAmountController.dispose();
    _transferAmountController.dispose();
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
              // Header
              Text(
                'تحويل نقد من الصندوق الى الخزينة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
              ),

              const SizedBox(height: 32),

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
                                '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}',
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

              const SizedBox(height: 32),

              // Two columns layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Right side - الصندوق
                  Expanded(
                    child: Column(
                      children: [
                        // Header - الصندوق
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'الصندوق',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Dropdown - الصندوق
                        DropdownButtonFormField<String>(
                          initialValue: _sourceCashbox,
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
                          items: ['صندوق 181', 'صندوق 182', 'صندوق 183']
                              .map((box) {
                            return DropdownMenuItem(
                                value: box, child: Text(box));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _sourceCashbox = value!),
                        ),

                        const SizedBox(height: 24),

                        // رصيد الصندوق section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ارصدة الصندوق',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Table header
                              Container(
                                color: Colors.cyan,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'الرصيد',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'العملة',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Table content
                              Container(
                                color: Colors.cyan,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          _sourceAmountController.text,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          _sourceCurrency,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
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
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Left side - الخزينة
                  Expanded(
                    child: Column(
                      children: [
                        // Header - الخزينة
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'ارصدة الخزينة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Dropdown - الخزينة
                        DropdownButtonFormField<String>(
                          initialValue: _destinationCashbox,
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
                          items: ['صندوق 181', 'صندوق 182', 'صندوق 183']
                              .map((box) {
                            return DropdownMenuItem(
                                value: box, child: Text(box));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _destinationCashbox = value!),
                        ),

                        const SizedBox(height: 24),

                        // رصيد الخزينة section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ارصدة الصندوق',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Table header
                              Container(
                                color: Colors.cyan,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'الرصيد',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'العملة',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Table content
                              Container(
                                color: Colors.cyan,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          _destinationAmountController.text,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          _destinationCurrency,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
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
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // مبلغ التحويل
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مبلغ التحويل',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _transferAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Button - حفظ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveTransfer,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text('حفظ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
