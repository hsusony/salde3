import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/cash_voucher.dart';
import '../../providers/cash_provider.dart';

class TransferDocumentPage extends StatefulWidget {
  const TransferDocumentPage({super.key});

  @override
  State<TransferDocumentPage> createState() => _TransferDocumentPageState();
}

class _TransferDocumentPageState extends State<TransferDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _transferType = 'حوالة داخلية';
  String _currency = 'دينار عراقي';
  String _status = 'قيد الإنتظار';

  // معلومات المرسل
  final _senderNameController = TextEditingController();
  final _senderAccountController = TextEditingController();
  final _senderBankController = TextEditingController();

  // معلومات المستلم
  final _receiverNameController = TextEditingController();
  final _receiverAccountController = TextEditingController();
  final _receiverBankController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generateNewDocumentNumber();
  }

  void _generateNewDocumentNumber() {
    _documentNumberController.text =
        'TRF-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _customerNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _senderNameController.dispose();
    _senderAccountController.dispose();
    _senderBankController.dispose();
    _receiverNameController.dispose();
    _receiverAccountController.dispose();
    _receiverBankController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  double get _transferFee {
    // رسوم تحويل افتراضية 1%
    return _totalAmount * 0.01;
  }

  double get _totalWithFee {
    return _totalAmount + _transferFee;
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

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // هنا يمكن حفظ مستند التحويل في قاعدة البيانات
      // حالياً سنعرض رسالة نجاح فقط

      setState(() {
        _isSaving = false;
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تم حفظ مستند التحويل بنجاح ✓',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE67E22),
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
      _documentNumberController.clear();
      _customerNameController.clear();
      _amountController.clear();
      _notesController.clear();
      _senderNameController.clear();
      _senderAccountController.clear();
      _senderBankController.clear();
      _receiverNameController.clear();
      _receiverAccountController.clear();
      _receiverBankController.clear();
      _selectedDate = DateTime.now();
      _transferType = 'حوالة داخلية';
      _currency = 'دينار عراقي';
      _status = 'قيد الإنتظار';
      _generateNewDocumentNumber();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'قيد الإنتظار':
        return const Color(0xFFF39C12);
      case 'تم التنفيذ':
        return const Color(0xFF27AE60);
      case 'ملغي':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
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
                        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
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
                            Icons.transform_rounded,
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
                                'مستند تحويل',
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
                          // رقم المستند والتاريخ
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _documentNumberController,
                                  label: 'رقم المستند',
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

                          // نوع التحويل والحالة
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'نوع التحويل',
                                  icon: Icons.swap_horiz_rounded,
                                  value: _transferType,
                                  items: [
                                    'حوالة داخلية',
                                    'حوالة خارجية',
                                    'تحويل دولي',
                                    'تحويل فوري'
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _transferType = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'الحالة',
                                  icon: Icons.info_outline_rounded,
                                  value: _status,
                                  items: ['قيد الإنتظار', 'تم التنفيذ', 'ملغي'],
                                  onChanged: (value) {
                                    setState(() {
                                      _status = value!;
                                    });
                                  },
                                  color: _getStatusColor(_status),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // قسم المرسل
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
                                        Icons.upload_rounded,
                                        size: 28,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'معلومات المرسل',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _senderNameController,
                                  label: 'اسم المرسل',
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'مطلوب' : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _senderAccountController,
                                        label: 'رقم الحساب',
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        validator: (value) =>
                                            value?.isEmpty ?? true
                                                ? 'مطلوب'
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _senderBankController,
                                        label: 'اسم البنك',
                                        icon: Icons.account_balance_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // قسم المستلم
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
                                        Icons.download_rounded,
                                        size: 28,
                                        color: Color(0xFF27AE60),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'معلومات المستلم',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF27AE60),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _receiverNameController,
                                  label: 'اسم المستلم',
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'مطلوب' : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _receiverAccountController,
                                        label: 'رقم الحساب',
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        validator: (value) =>
                                            value?.isEmpty ?? true
                                                ? 'مطلوب'
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _receiverBankController,
                                        label: 'اسم البنك',
                                        icon: Icons.account_balance_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // المبلغ والعملة
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _amountController,
                                  label: 'مبلغ التحويل',
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
                                  label: 'العملة',
                                  icon: Icons.attach_money_rounded,
                                  value: _currency,
                                  items: [
                                    'دينار عراقي',
                                    'دولار أمريكي',
                                    'يورو'
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _currency = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
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

                          // صندوق التكاليف
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFE67E22).withOpacity(0.4),
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
                                    const Text(
                                      'مبلغ التحويل:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _totalAmount.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'رسوم التحويل (1%):',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _transferFee.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                    color: Colors.white,
                                    height: 32,
                                    thickness: 1),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'المجموع الإجمالي',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_totalWithFee.toStringAsFixed(2)} $_currency',
                                          style: const TextStyle(
                                            fontSize: 32,
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
                                        Icons.transform_rounded,
                                        size: 48,
                                        color: Colors.white,
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
                              _isSaving ? 'جاري الحفظ...' : 'حفظ المستند',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE67E22),
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
                      colors: [Color(0xFFE67E22), Color(0xFFD35400)],
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
                      Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Text(
                        'تفاصيل التحويل',
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
                        // بطاقة الحالة
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getStatusColor(_status).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.info_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'حالة التحويل',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _status,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(_status),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // مخطط التحويل
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade50,
                                Colors.grey.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              // المرسل
                              _buildPartyCard(
                                title: 'المرسل',
                                name: _senderNameController.text.isEmpty
                                    ? '........'
                                    : _senderNameController.text,
                                account: _senderAccountController.text.isEmpty
                                    ? '............'
                                    : _senderAccountController.text,
                                bank: _senderBankController.text.isEmpty
                                    ? '............................'
                                    : _senderBankController.text,
                                color: const Color(0xFF3498DB),
                                icon: Icons.upload_rounded,
                              ),

                              // السهم
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 36,
                                  color: Color(0xFFE67E22),
                                ),
                              ),

                              // المبلغ
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE67E22).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE67E22),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'مبلغ التحويل: ${_totalAmount.toStringAsFixed(2)} $_currency',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE67E22),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // السهم
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 36,
                                  color: Color(0xFFE67E22),
                                ),
                              ),

                              // المستلم
                              _buildPartyCard(
                                title: 'المستلم',
                                name: _receiverNameController.text.isEmpty
                                    ? '........'
                                    : _receiverNameController.text,
                                account: _receiverAccountController.text.isEmpty
                                    ? '............'
                                    : _receiverAccountController.text,
                                bank: _receiverBankController.text.isEmpty
                                    ? '............................'
                                    : _receiverBankController.text,
                                color: const Color(0xFF27AE60),
                                icon: Icons.download_rounded,
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
                                      color: Color(0xFFE67E22), size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'معلومات التحويل',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE67E22),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('نوع التحويل:', _transferType),
                              _buildInfoRow('العملة:', _currency),
                              _buildInfoRow('رسوم التحويل:',
                                  _transferFee.toStringAsFixed(2)),
                              _buildInfoRow('المجموع:',
                                  _totalWithFee.toStringAsFixed(2)),
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

  Widget _buildPartyCard({
    required String title,
    required String name,
    required String account,
    required String bank,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رقم الحساب: $account',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'البنك: $bank',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
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
            Icon(icon, size: 22, color: const Color(0xFFE67E22)),
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
                  const BorderSide(color: Color(0xFFE67E22), width: 2.5),
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
                size: 22, color: Color(0xFFE67E22)),
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
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = color ?? const Color(0xFFE67E22);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: fieldColor),
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
              borderSide: BorderSide(color: fieldColor, width: 2.5),
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
