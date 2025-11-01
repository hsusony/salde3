import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/cash_voucher.dart';
import '../../providers/cash_provider.dart';

class ReceiptVoucherDialog extends StatefulWidget {
  final ReceiptVoucher? voucher;

  const ReceiptVoucherDialog({super.key, this.voucher});

  @override
  State<ReceiptVoucherDialog> createState() => _ReceiptVoucherDialogState();
}

class _ReceiptVoucherDialogState extends State<ReceiptVoucherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _bankNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _checkDate;
  String _paymentMethod = 'نقدي';
  String _currency = 'دينار عراقي';

  @override
  void initState() {
    super.initState();
    if (widget.voucher != null) {
      _voucherNumberController.text = widget.voucher!.voucherNumber;
      _customerNameController.text = widget.voucher!.customerName ?? '';
      _amountController.text = widget.voucher!.amount.toString();
      _notesController.text = widget.voucher!.notes ?? '';
      _checkNumberController.text = widget.voucher!.checkNumber ?? '';
      _bankNameController.text = widget.voucher!.bankName ?? '';
      _selectedDate = widget.voucher!.date;
      _checkDate = widget.voucher!.checkDate;
      _paymentMethod = widget.voucher!.paymentMethod;
      _currency = widget.voucher!.currency;
    } else {
      // Generate new voucher number
      _voucherNumberController.text =
          'RV-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _customerNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _checkNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final voucher = ReceiptVoucher(
        id: widget.voucher?.id,
        voucherNumber: _voucherNumberController.text,
        date: _selectedDate,
        customerName: _customerNameController.text.isEmpty
            ? null
            : _customerNameController.text,
        amount: double.parse(_amountController.text),
        paymentMethod: _paymentMethod,
        currency: _currency,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        checkNumber: _checkNumberController.text.isEmpty
            ? null
            : _checkNumberController.text,
        checkDate: _checkDate,
        bankName:
            _bankNameController.text.isEmpty ? null : _bankNameController.text,
      );

      final cashProvider = Provider.of<CashProvider>(context, listen: false);

      if (widget.voucher == null) {
        cashProvider.addReceiptVoucher(voucher);
      } else {
        cashProvider.updateReceiptVoucher(voucher);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.voucher == null
              ? 'تم إضافة سند القبض بنجاح'
              : 'تم تحديث سند القبض بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF10B981),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.voucher == null
                              ? 'سند قبض جديد'
                              : 'تعديل سند قبض',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'إدخال معلومات سند القبض',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Row 1: رقم السند والتاريخ
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _voucherNumberController,
                              decoration: const InputDecoration(
                                labelText: 'رقم السند',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'مطلوب' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'التاريخ',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat('yyyy/MM/dd - HH:mm')
                                      .format(_selectedDate),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 2: اسم العميل
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم العميل',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Row 3: المبلغ والعملة
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'المبلغ',
                                prefixIcon: Icon(Icons.money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'مطلوب';
                                if (double.tryParse(value!) == null) {
                                  return 'أدخل رقم صحيح';
                                }
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _currency,
                              decoration: const InputDecoration(
                                labelText: 'العملة',
                                border: OutlineInputBorder(),
                              ),
                              items: ['دينار عراقي', 'دولار', 'يورو']
                                  .map((currency) => DropdownMenuItem(
                                        value: currency,
                                        child: Text(currency),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _currency = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 4: طريقة الدفع
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'طريقة الدفع',
                          prefixIcon: Icon(Icons.payment),
                          border: OutlineInputBorder(),
                        ),
                        items: ['نقدي', 'شيك', 'تحويل بنكي', 'بطاقة ائتمان']
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // معلومات الشيك (إذا كانت طريقة الدفع شيك)
                      if (_paymentMethod == 'شيك') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _checkNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الشيك',
                                  prefixIcon: Icon(Icons.numbers),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _checkDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _checkDate = picked;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'تاريخ الشيك',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _checkDate != null
                                        ? DateFormat('yyyy/MM/dd')
                                            .format(_checkDate!)
                                        : 'اختر التاريخ',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bankNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم البنك',
                            prefixIcon: Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // الملاحظات
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'الملاحظات',
                          prefixIcon: Icon(Icons.notes),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Total Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المبلغ الإجمالي',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,##0').format(_totalAmount)} $_currency',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Print functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('الطباعة قريباً')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
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
