import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/cash_voucher.dart';
import '../../providers/cash_provider.dart';

class DualCurrencyReceiptVoucherPage extends StatefulWidget {
  const DualCurrencyReceiptVoucherPage({super.key});

  @override
  State<DualCurrencyReceiptVoucherPage> createState() =>
      _DualCurrencyReceiptVoucherPageState();
}

class _DualCurrencyReceiptVoucherPageState
    extends State<DualCurrencyReceiptVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final _voucherNumberController = TextEditingController();
  final _customerNameController = TextEditingController();

  // العملة الأولى (دينار عراقي)
  final _amountIQDController = TextEditingController();
  String _paymentMethodIQD = 'نقدي';
  final _checkNumberIQDController = TextEditingController();
  final _bankNameIQDController = TextEditingController();
  DateTime? _checkDateIQD;

  // العملة الثانية (دولار)
  final _amountUSDController = TextEditingController();
  String _paymentMethodUSD = 'نقدي';
  final _checkNumberUSDController = TextEditingController();
  final _bankNameUSDController = TextEditingController();
  DateTime? _checkDateUSD;

  // سعر الصرف
  final _exchangeRateController = TextEditingController(text: '1500');

  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  // ReceiptVoucher? _editingVoucher; // معطل مؤقتاً - غير مستخدم
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generateNewVoucherNumber();
    _amountIQDController.addListener(_updateTotals);
    _amountUSDController.addListener(_updateTotals);
    _exchangeRateController.addListener(_updateTotals);
  }

  void _generateNewVoucherNumber() {
    _voucherNumberController.text =
        'DRV-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _updateTotals() {
    setState(() {});
  }

  @override
  void dispose() {
    _voucherNumberController.dispose();
    _customerNameController.dispose();
    _amountIQDController.dispose();
    _amountUSDController.dispose();
    _exchangeRateController.dispose();
    _notesController.dispose();
    _checkNumberIQDController.dispose();
    _bankNameIQDController.dispose();
    _checkNumberUSDController.dispose();
    _bankNameUSDController.dispose();
    super.dispose();
  }

  double get _amountIQD => double.tryParse(_amountIQDController.text) ?? 0;
  double get _amountUSD => double.tryParse(_amountUSDController.text) ?? 0;
  double get _exchangeRate =>
      double.tryParse(_exchangeRateController.text) ?? 1500;
  double get _usdToIQD => _amountUSD * _exchangeRate;
  double get _totalInIQD => _amountIQD + _usdToIQD;

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

  Future<void> _selectCheckDateIQD() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkDateIQD ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _checkDateIQD = picked;
      });
    }
  }

  Future<void> _selectCheckDateUSD() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkDateUSD ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _checkDateUSD = picked;
      });
    }
  }

  void _save() async {
    if (_amountIQD <= 0 && _amountUSD <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال مبلغ بإحدى العملتين على الأقل'),
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

      final cashProvider = Provider.of<CashProvider>(context, listen: false);

      // حفظ سند بالدينار إذا كان هناك مبلغ
      if (_amountIQD > 0) {
        final voucherIQD = ReceiptVoucher(
          voucherNumber: '${_voucherNumberController.text}-IQD',
          date: _selectedDate,
          customerName: _customerNameController.text.isEmpty
              ? null
              : _customerNameController.text,
          amount: _amountIQD,
          paymentMethod: _paymentMethodIQD,
          currency: 'دينار عراقي',
          notes: _notesController.text.isEmpty
              ? null
              : 'عملة مزدوجة - ${_notesController.text}',
          checkNumber: _checkNumberIQDController.text.isEmpty
              ? null
              : _checkNumberIQDController.text,
          checkDate: _checkDateIQD,
          bankName: _bankNameIQDController.text.isEmpty
              ? null
              : _bankNameIQDController.text,
        );
        cashProvider.addReceiptVoucher(voucherIQD);
      }

      // حفظ سند بالدولار إذا كان هناك مبلغ
      if (_amountUSD > 0) {
        final voucherUSD = ReceiptVoucher(
          voucherNumber: '${_voucherNumberController.text}-USD',
          date: _selectedDate,
          customerName: _customerNameController.text.isEmpty
              ? null
              : _customerNameController.text,
          amount: _amountUSD,
          paymentMethod: _paymentMethodUSD,
          currency: 'دولار أمريكي',
          notes: _notesController.text.isEmpty
              ? 'سعر الصرف: ${_exchangeRate.toStringAsFixed(0)} IQD'
              : 'عملة مزدوجة - سعر الصرف: ${_exchangeRate.toStringAsFixed(0)} - ${_notesController.text}',
          checkNumber: _checkNumberUSDController.text.isEmpty
              ? null
              : _checkNumberUSDController.text,
          checkDate: _checkDateUSD,
          bankName: _bankNameUSDController.text.isEmpty
              ? null
              : _bankNameUSDController.text,
        );
        cashProvider.addReceiptVoucher(voucherUSD);
      }

      setState(() {
        _isSaving = false;
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تم إضافة سند القبض بعملتين بنجاح ✓',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF3498DB),
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
      // _editingVoucher = null; // معطل مؤقتاً
      _voucherNumberController.clear();
      _customerNameController.clear();
      _amountIQDController.clear();
      _amountUSDController.clear();
      _notesController.clear();
      _checkNumberIQDController.clear();
      _bankNameIQDController.clear();
      _checkNumberUSDController.clear();
      _bankNameUSDController.clear();
      _selectedDate = DateTime.now();
      _checkDateIQD = null;
      _checkDateUSD = null;
      _paymentMethodIQD = 'نقدي';
      _paymentMethodUSD = 'نقدي';
      _exchangeRateController.text = '1500';
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
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
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
                            Icons.currency_exchange_rounded,
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
                                'سند قبض بعملتين',
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

                          // سعر الصرف
                          _buildTextField(
                            controller: _exchangeRateController,
                            label: 'سعر صرف الدولار (IQD)',
                            icon: Icons.currency_exchange,
                            keyboardType: TextInputType.number,
                            isBold: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'مطلوب';
                              if (double.tryParse(value!) == null) {
                                return 'أدخل رقماً صحيحاً';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // قسم الدينار العراقي
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF27AE60).withOpacity(0.3),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.attach_money_rounded,
                                        size: 28,
                                        color: Color(0xFF27AE60),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'دينار عراقي (IQD)',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF27AE60),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // المبلغ وطريقة الدفع
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildTextField(
                                        controller: _amountIQDController,
                                        label: 'المبلغ بالدينار',
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
                                        value: _paymentMethodIQD,
                                        items: ['نقدي', 'شيك', 'تحويل بنكي'],
                                        onChanged: (value) {
                                          setState(() {
                                            _paymentMethodIQD = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // معلومات الشيك
                                if (_paymentMethodIQD == 'شيك') ...[
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
                                                    _checkNumberIQDController,
                                                label: 'رقم الشيك',
                                                icon: Icons.numbers_rounded,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDateField(
                                                label: 'تاريخ الشيك',
                                                date: _checkDateIQD,
                                                onTap: _selectCheckDateIQD,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _bankNameIQDController,
                                          label: 'اسم البنك',
                                          icon: Icons.account_balance_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // قسم الدولار
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3498DB).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF3498DB).withOpacity(0.3),
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
                                        color: const Color(0xFF3498DB)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.attach_money_rounded,
                                        size: 28,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'دولار أمريكي (USD)',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // المبلغ وطريقة الدفع
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildTextField(
                                        controller: _amountUSDController,
                                        label: 'المبلغ بالدولار',
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
                                        value: _paymentMethodUSD,
                                        items: ['نقدي', 'شيك', 'تحويل بنكي'],
                                        onChanged: (value) {
                                          setState(() {
                                            _paymentMethodUSD = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // عرض القيمة بالدينار
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3498DB)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          color: Color(0xFF3498DB), size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'قيمة الدولار بالدينار: ${_usdToIQD.toStringAsFixed(2)} IQD',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3498DB),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // معلومات الشيك
                                if (_paymentMethodUSD == 'شيك') ...[
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
                                                    _checkNumberUSDController,
                                                label: 'رقم الشيك',
                                                icon: Icons.numbers_rounded,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDateField(
                                                label: 'تاريخ الشيك',
                                                date: _checkDateUSD,
                                                onTap: _selectCheckDateUSD,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _bankNameUSDController,
                                          label: 'اسم البنك',
                                          icon: Icons.account_balance_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

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
                                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF3498DB).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          '${_totalInIQD.toStringAsFixed(2)} IQD',
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
                                        Icons.currency_exchange_rounded,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(
                                    color: Colors.white, thickness: 1),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'دينار',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _amountIQD.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'دولار',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _amountUSD.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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
                              _isSaving ? 'جاري الحفظ...' : 'حفظ السند',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
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

        // Summary Section (Right Side)
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
                // Header
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calculate_rounded,
                          color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Text(
                        'ملخص العمليات',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // بطاقة سعر الصرف
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF39C12).withOpacity(0.1),
                                const Color(0xFFE67E22).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF39C12).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.currency_exchange,
                                      color: Color(0xFFF39C12), size: 28),
                                  SizedBox(width: 12),
                                  Text(
                                    'سعر الصرف',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF39C12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '1 USD = ${_exchangeRate.toStringAsFixed(0)} IQD',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // بطاقة الدينار
                        _buildCurrencyCard(
                          title: 'دينار عراقي',
                          amount: _amountIQD,
                          currency: 'IQD',
                          icon: Icons.account_balance_wallet,
                          color: const Color(0xFF27AE60),
                          paymentMethod: _paymentMethodIQD,
                        ),
                        const SizedBox(height: 20),

                        // بطاقة الدولار
                        _buildCurrencyCard(
                          title: 'دولار أمريكي',
                          amount: _amountUSD,
                          currency: 'USD',
                          icon: Icons.attach_money,
                          color: const Color(0xFF3498DB),
                          paymentMethod: _paymentMethodUSD,
                          equivalentInIQD: _usdToIQD,
                        ),
                        const SizedBox(height: 24),

                        // المجموع النهائي
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3498DB).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.summarize_rounded,
                                      color: Colors.white, size: 28),
                                  SizedBox(width: 12),
                                  Text(
                                    'المجموع الإجمالي',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_totalInIQD.toStringAsFixed(2)} IQD',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'شامل جميع العملات',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // معلومات إضافية
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Color(0xFF3498DB), size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'ملاحظة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3498DB),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'سيتم حفظ سندين منفصلين:\n• سند بالدينار العراقي\n• سند بالدولار الأمريكي',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyCard({
    required String title,
    required double amount,
    required String currency,
    required IconData icon,
    required Color color,
    required String paymentMethod,
    double? equivalentInIQD,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPaymentMethodColor(paymentMethod).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getPaymentMethodColor(paymentMethod),
              ),
            ),
            child: Text(
              paymentMethod,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getPaymentMethodColor(paymentMethod),
              ),
            ),
          ),
          if (equivalentInIQD != null && equivalentInIQD > 0) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calculate, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'المعادل: ${equivalentInIQD.toStringAsFixed(2)} IQD',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
            Icon(icon, size: 22, color: const Color(0xFF3498DB)),
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
                  const BorderSide(color: Color(0xFF3498DB), width: 2.5),
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
                size: 22, color: Color(0xFF3498DB)),
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
            Icon(icon, size: 22, color: const Color(0xFF3498DB)),
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
                  const BorderSide(color: Color(0xFF3498DB), width: 2.5),
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
