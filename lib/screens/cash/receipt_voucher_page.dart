import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/cash_voucher.dart';
import '../../providers/cash_provider.dart';

class ReceiptVoucherPage extends StatefulWidget {
  const ReceiptVoucherPage({super.key});

  @override
  State<ReceiptVoucherPage> createState() => _ReceiptVoucherPageState();
}

class _ReceiptVoucherPageState extends State<ReceiptVoucherPage> {
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
  ReceiptVoucher? _editingVoucher;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generateNewVoucherNumber();
  }

  void _generateNewVoucherNumber() {
    _voucherNumberController.text =
        'RV-${DateTime.now().millisecondsSinceEpoch}';
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

  Future<void> _selectCheckDate() async {
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
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final voucher = ReceiptVoucher(
        id: _editingVoucher?.id,
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

      try {
        if (_editingVoucher == null) {
          print('🔵 إضافة سند قبض جديد: ${voucher.voucherNumber}');
          await cashProvider.addReceiptVoucher(voucher);
          print('✅ تم حفظ السند بنجاح في قاعدة البيانات!');
        } else {
          print('🔵 تعديل سند قبض: ${voucher.voucherNumber}');
          await cashProvider.updateReceiptVoucher(voucher);
          print('✅ تم تحديث السند بنجاح في قاعدة البيانات!');
        }
      } catch (e) {
        print('❌ خطأ في حفظ السند: $e');
      }

      setState(() {
        _isSaving = false;
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _editingVoucher == null
                        ? 'تم إضافة سند القبض بنجاح ✓'
                        : 'تم تحديث سند القبض بنجاح ✓',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF27AE60),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _editingVoucher = null;
      _voucherNumberController.clear();
      _customerNameController.clear();
      _amountController.clear();
      _notesController.clear();
      _checkNumberController.clear();
      _bankNameController.clear();
      _selectedDate = DateTime.now();
      _checkDate = null;
      _paymentMethod = 'نقدي';
      _currency = 'دينار عراقي';
      _generateNewVoucherNumber();
    });
  }

  void _editVoucher(ReceiptVoucher voucher) {
    setState(() {
      _editingVoucher = voucher;
      _voucherNumberController.text = voucher.voucherNumber;
      _customerNameController.text = voucher.customerName ?? '';
      _amountController.text = voucher.amount.toString();
      _notesController.text = voucher.notes ?? '';
      _checkNumberController.text = voucher.checkNumber ?? '';
      _bankNameController.text = voucher.bankName ?? '';
      _selectedDate = voucher.date;
      _checkDate = voucher.checkDate;
      _paymentMethod = voucher.paymentMethod;
      _currency = voucher.currency;
    });
  }

  void _deleteVoucher(ReceiptVoucher voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content:
            Text('هل أنت متأكد من حذف سند القبض رقم ${voucher.voucherNumber}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final cashProvider =
                  Provider.of<CashProvider>(context, listen: false);
              cashProvider.deleteReceiptVoucher(voucher.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف سند القبض'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Form Section (Left Side)
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF229954)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _editingVoucher == null
                                    ? 'سند قبض جديد'
                                    : 'تعديل سند قبض',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy/MM/dd - hh:mm a')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_editingVoucher != null)
                          IconButton(
                            onPressed: _clearForm,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                            tooltip: 'سند جديد',
                          ),
                      ],
                    ),
                  ),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // رقم السند والتاريخ
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _voucherNumberController,
                                  label: 'رقم السند',
                                  icon: Icons.tag_rounded,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'مطلوب' : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDateField(
                                  label: 'التاريخ',
                                  date: _selectedDate,
                                  onTap: _selectDate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // اسم العميل
                          _buildTextField(
                            controller: _customerNameController,
                            label: 'اسم العميل',
                            icon: Icons.person_outline_rounded,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 24),

                          // المبلغ وطريقة الدفع
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _amountController,
                                  label: 'المبلغ',
                                  icon: Icons.payments_outlined,
                                  keyboardType: TextInputType.number,
                                  isBold: true,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'مطلوب';
                                    if (double.tryParse(value!) == null) {
                                      return 'أدخل رقماً صحيحاً';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'طريقة الدفع',
                                  icon: Icons.account_balance_wallet_outlined,
                                  value: _paymentMethod,
                                  items: ['نقدي', 'شيك', 'تحويل بنكي'],
                                  onChanged: (value) {
                                    setState(() {
                                      _paymentMethod = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // معلومات الشيك
                          if (_paymentMethod == 'شيك') ...[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF27AE60).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF27AE60).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF27AE60)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_rounded,
                                          size: 24,
                                          color: Color(0xFF27AE60),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'معلومات الشيك',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF27AE60),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _checkNumberController,
                                          label: 'رقم الشيك',
                                          icon: Icons.numbers_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDateField(
                                          label: 'تاريخ الشيك',
                                          date: _checkDate,
                                          onTap: _selectCheckDate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _bankNameController,
                                    label: 'اسم البنك',
                                    icon: Icons.account_balance_rounded,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // الملاحظات
                          _buildTextField(
                            controller: _notesController,
                            label: 'الملاحظات',
                            icon: Icons.note_alt_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // صندوق المجموع
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF27AE60), Color(0xFF229954)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF27AE60).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'المبلغ الإجمالي',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_totalAmount.toStringAsFixed(2)} IQD',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.attach_money_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save_rounded, size: 24),
                            label: Text(
                              _isSaving
                                  ? 'جاري الحفظ...'
                                  : (_editingVoucher == null
                                      ? 'حفظ السند'
                                      : 'تحديث السند'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27AE60),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('الطباعة قريباً')),
                            );
                          },
                          icon: const Icon(Icons.print_outlined, size: 22),
                          label: const Text(
                            'طباعة',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFECF0F1),
                            foregroundColor: const Color(0xFF333333),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Table Section (Right Side)
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF27AE60), Color(0xFF229954)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      const Text(
                        'سندات القبض المسجلة',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Consumer<CashProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${provider.receiptVouchers.length}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Table Content
                Expanded(
                  child: Consumer<CashProvider>(
                    builder: (context, provider, child) {
                      if (provider.receiptVouchers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد سندات قبض بعد',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'قم بإضافة سند قبض جديد',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xFF27AE60).withOpacity(0.1),
                            ),
                            headingTextStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                            ),
                            dataTextStyle: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                            columns: const [
                              DataColumn(label: Text('رقم السند')),
                              DataColumn(label: Text('التاريخ')),
                              DataColumn(label: Text('العميل')),
                              DataColumn(label: Text('المبلغ')),
                              DataColumn(label: Text('طريقة الدفع')),
                              DataColumn(label: Text('إجراءات')),
                            ],
                            rows: provider.receiptVouchers.map((voucher) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      voucher.voucherNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF27AE60),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(DateFormat('yyyy/MM/dd')
                                        .format(voucher.date)),
                                  ),
                                  DataCell(
                                    Text(voucher.customerName ?? '-'),
                                  ),
                                  DataCell(
                                    Text(
                                      '${voucher.amount.toStringAsFixed(2)} IQD',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF27AE60),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getPaymentMethodColor(
                                                voucher.paymentMethod)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getPaymentMethodColor(
                                              voucher.paymentMethod),
                                        ),
                                      ),
                                      child: Text(
                                        voucher.paymentMethod,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _getPaymentMethodColor(
                                              voucher.paymentMethod),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 20),
                                          color: Colors.blue,
                                          onPressed: () =>
                                              _editVoucher(voucher),
                                          tooltip: 'تعديل',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 20),
                                          color: Colors.red,
                                          onPressed: () =>
                                              _deleteVoucher(voucher),
                                          tooltip: 'حذف',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'نقدي':
        return const Color(0xFF27AE60);
      case 'شيك':
        return const Color(0xFF3498DB);
      case 'تحويل بنكي':
        return const Color(0xFF9B59B6);
      default:
        return Colors.grey;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isBold = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF27AE60)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF27AE60), width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: maxLines > 1 ? 16 : 18,
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 22, color: Color(0xFF27AE60)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('yyyy/MM/dd').format(date)
                        : 'اختر التاريخ',
                    style: TextStyle(
                      fontSize: 16,
                      color: date != null
                          ? const Color(0xFF333333)
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded,
                    size: 28, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF27AE60)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF27AE60), width: 2.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
