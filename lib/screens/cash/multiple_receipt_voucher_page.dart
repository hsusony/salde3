import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/cash_voucher.dart';
import '../../providers/cash_provider.dart';

class MultipleReceiptVoucherPage extends StatefulWidget {
  const MultipleReceiptVoucherPage({super.key});

  @override
  State<MultipleReceiptVoucherPage> createState() =>
      _MultipleReceiptVoucherPageState();
}

class _MultipleReceiptVoucherPageState
    extends State<MultipleReceiptVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _currency = 'دينار عراقي';
  bool _isSaving = false;

  // قائمة العملاء والمبالغ
  final List<ReceiptItem> _receiptItems = [];

  // حقول إضافة عميل جديد
  final _customerNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _paymentMethod = 'نقدي';
  final _checkNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  DateTime? _checkDate;

  @override
  void initState() {
    super.initState();
    _generateNewVoucherNumber();
  }

  void _generateNewVoucherNumber() {
    _voucherNumberController.text =
        'MRV-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _notesController.dispose();
    _customerNameController.dispose();
    _amountController.dispose();
    _checkNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _receiptItems.fold(0, (sum, item) => sum + item.amount);
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

  void _addReceiptItem() {
    if (_customerNameController.text.isEmpty ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم العميل والمبلغ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال مبلغ صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _receiptItems.add(ReceiptItem(
        customerName: _customerNameController.text,
        amount: amount,
        paymentMethod: _paymentMethod,
        checkNumber: _checkNumberController.text.isEmpty
            ? null
            : _checkNumberController.text,
        bankName:
            _bankNameController.text.isEmpty ? null : _bankNameController.text,
        checkDate: _checkDate,
      ));

      // مسح الحقول
      _customerNameController.clear();
      _amountController.clear();
      _checkNumberController.clear();
      _bankNameController.clear();
      _checkDate = null;
      _paymentMethod = 'نقدي';
    });
  }

  void _removeReceiptItem(int index) {
    setState(() {
      _receiptItems.removeAt(index);
    });
  }

  void _editReceiptItem(int index) {
    final item = _receiptItems[index];
    setState(() {
      _customerNameController.text = item.customerName;
      _amountController.text = item.amount.toString();
      _paymentMethod = item.paymentMethod;
      _checkNumberController.text = item.checkNumber ?? '';
      _bankNameController.text = item.bankName ?? '';
      _checkDate = item.checkDate;
      _receiptItems.removeAt(index);
    });
  }

  void _save() async {
    if (_receiptItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة عميل واحد على الأقل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // حفظ كل عميل كسند قبض منفصل
      final cashProvider = Provider.of<CashProvider>(context, listen: false);

      for (var item in _receiptItems) {
        final voucher = ReceiptVoucher(
          voucherNumber:
              '${_voucherNumberController.text}-${_receiptItems.indexOf(item) + 1}',
          date: _selectedDate,
          customerName: item.customerName,
          amount: item.amount,
          paymentMethod: item.paymentMethod,
          currency: _currency,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          checkNumber: item.checkNumber,
          checkDate: item.checkDate,
          bankName: item.bankName,
        );
        cashProvider.addReceiptVoucher(voucher);
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
                    'تم إضافة ${_receiptItems.length} سند قبض بنجاح ✓',
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
      _voucherNumberController.clear();
      _notesController.clear();
      _customerNameController.clear();
      _amountController.clear();
      _checkNumberController.clear();
      _bankNameController.clear();
      _selectedDate = DateTime.now();
      _checkDate = null;
      _paymentMethod = 'نقدي';
      _currency = 'دينار عراقي';
      _receiptItems.clear();
      _generateNewVoucherNumber();
    });
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
                        colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
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
                              const Text(
                                'سند قبض متعدد',
                                style: TextStyle(
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
                      ],
                    ),
                  ),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 32),

                          // قسم إضافة العملاء
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E44AD).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF8E44AD).withOpacity(0.3),
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
                                        color: const Color(0xFF8E44AD)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.person_add_rounded,
                                        size: 28,
                                        color: Color(0xFF8E44AD),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'إضافة عميل',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8E44AD),
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
                                ),
                                const SizedBox(height: 20),

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
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDropdownField(
                                        label: 'طريقة الدفع',
                                        icon: Icons
                                            .account_balance_wallet_outlined,
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
                                const SizedBox(height: 20),

                                // معلومات الشيك
                                if (_paymentMethod == 'شيك') ...[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller:
                                                    _checkNumberController,
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
                                  const SizedBox(height: 20),
                                ],

                                // زر الإضافة
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addReceiptItem,
                                    icon: const Icon(Icons.add_circle_rounded,
                                        size: 24),
                                    label: const Text(
                                      'إضافة العميل للقائمة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8E44AD),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // الملاحظات
                          _buildTextField(
                            controller: _notesController,
                            label: 'الملاحظات العامة',
                            icon: Icons.note_alt_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // صندوق المجموع
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF8E44AD).withOpacity(0.4),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      'عدد العملاء: ${_receiptItems.length}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
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
                                    Icons.groups_rounded,
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
                              _isSaving ? 'جاري الحفظ...' : 'حفظ جميع السندات',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E44AD),
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

        // Items List Section (Right Side)
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
                      colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
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
                      const Icon(Icons.list_alt_rounded,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      const Text(
                        'قائمة العملاء',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_receiptItems.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Items List
                Expanded(
                  child: _receiptItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لم يتم إضافة عملاء بعد',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'قم بإضافة عملاء في النموذج',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _receiptItems.length,
                          itemBuilder: (context, index) {
                            final item = _receiptItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF8E44AD).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF8E44AD).withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E44AD)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8E44AD),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                size: 18,
                                                color: Color(0xFF8E44AD)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item.customerName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF333333),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.payments,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${item.amount.toStringAsFixed(2)} IQD',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF8E44AD),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getPaymentMethodColor(
                                                        item.paymentMethod)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _getPaymentMethodColor(
                                                      item.paymentMethod),
                                                ),
                                              ),
                                              child: Text(
                                                item.paymentMethod,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getPaymentMethodColor(
                                                      item.paymentMethod),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item.checkNumber != null) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'شيك: ${item.checkNumber} - ${item.bankName}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 22),
                                    color: Colors.blue,
                                    onPressed: () => _editReceiptItem(index),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 22),
                                    color: Colors.red,
                                    onPressed: () => _removeReceiptItem(index),
                                    tooltip: 'حذف',
                                  ),
                                ],
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF8E44AD)),
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
                  const BorderSide(color: Color(0xFF8E44AD), width: 2.5),
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
                size: 22, color: Color(0xFF8E44AD)),
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
            Icon(icon, size: 22, color: const Color(0xFF8E44AD)),
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
                  const BorderSide(color: Color(0xFF8E44AD), width: 2.5),
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

// نموذج بيانات العميل
class ReceiptItem {
  final String customerName;
  final double amount;
  final String paymentMethod;
  final String? checkNumber;
  final String? bankName;
  final DateTime? checkDate;

  ReceiptItem({
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    this.checkNumber,
    this.bankName,
    this.checkDate,
  });
}
