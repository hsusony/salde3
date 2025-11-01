import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/installments_provider.dart';
import '../../providers/customers_provider.dart';
import '../../models/installment.dart';

class AddInstallmentScreen extends StatefulWidget {
  const AddInstallmentScreen({super.key});

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _installmentAmountController = TextEditingController();
  final _numberOfInstallmentsController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorAddressController = TextEditingController();
  final _guarantorDetailsController = TextEditingController();
  final _witnessesController = TextEditingController();
  final _jobEntryController = TextEditingController();
  final _accessController = TextEditingController();
  final _deliveryController = TextEditingController();
  
  int? _selectedCustomerId;
  String _selectedCustomerName = '';
  String _installmentType = 'شخصي';
  String _paymentMethod = 'شهري';
  String _region = 'المنطقة الأولى';
  bool _isTwoInstallments = false;
  bool _isSingleInstallment = false;
  bool _printPage = false;
  bool _oneTimeStatement = false;
  DateTime _startDate = DateTime.now();
  int _numberOfInstallments = 1;
  double _installmentAmount = 0;

  @override
  void dispose() {
    _totalAmountController.dispose();
    _installmentAmountController.dispose();
    _numberOfInstallmentsController.dispose();
    _guarantorNameController.dispose();
    _guarantorAddressController.dispose();
    _guarantorDetailsController.dispose();
    _witnessesController.dispose();
    _jobEntryController.dispose();
    _accessController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  void _calculateInstallmentAmount() {
    if (_totalAmountController.text.isNotEmpty && _numberOfInstallments > 0) {
      final total = double.tryParse(_totalAmountController.text) ?? 0;
      setState(() {
        _installmentAmount = total / _numberOfInstallments;
        _installmentAmountController.text = _installmentAmount.toStringAsFixed(0);
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
            filled: true,
            fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }

  Future<void> _saveInstallment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الحساب')),
      );
      return;
    }

    final totalAmount = double.parse(_totalAmountController.text);

    final notes = '''
نوع القسط: $_installmentType
دخل الجدول: ${_jobEntryController.text}
الوصول: ${_accessController.text}
التوصيل: ${_deliveryController.text}
اسم الكفيل: ${_guarantorNameController.text}
عنوان الكفيل: ${_guarantorAddressController.text}
تفاصيل الكفيل: ${_guarantorDetailsController.text}
الضامنين: ${_witnessesController.text}
المنطقة: $_region
وسيلة الدفع: $_paymentMethod
''';

    final installment = Installment(
      customerId: _selectedCustomerId!,
      customerName: _selectedCustomerName,
      totalAmount: totalAmount,
      paidAmount: 0,
      remainingAmount: totalAmount,
      numberOfInstallments: _numberOfInstallments,
      paidInstallments: 0,
      installmentAmount: _installmentAmount,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
      notes: notes,
      status: 'active',
    );

    await Provider.of<InstallmentsProvider>(context, listen: false)
        .addInstallment(installment);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة القسط بنجاح'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      
      // Clear form
      _formKey.currentState!.reset();
      _totalAmountController.clear();
      _installmentAmountController.clear();
      _guarantorNameController.clear();
      _guarantorAddressController.clear();
      _guarantorDetailsController.clear();
      _witnessesController.clear();
      _jobEntryController.clear();
      _accessController.clear();
      _deliveryController.clear();
      setState(() {
        _selectedCustomerId = null;
        _selectedCustomerName = '';
        _startDate = DateTime.now();
        _numberOfInstallments = 1;
        _installmentAmount = 0;
        _isTwoInstallments = false;
        _isSingleInstallment = false;
        _printPage = false;
        _oneTimeStatement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة قسط جديد',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أدخل بيانات القسط الجديد',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Form Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Customer Selection & Installment Type
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الحساب',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Consumer<CustomersProvider>(
                                builder: (context, provider, _) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedCustomerId != null
                                            ? const Color(0xFF10B981)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      initialValue: _selectedCustomerId,
                                      decoration: const InputDecoration(
                                        hintText: 'اختر الحساب',
                                        prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF10B981)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      items: provider.customers.map((customer) {
                                        return DropdownMenuItem(
                                          value: customer.id,
                                          child: Text(customer.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCustomerId = value;
                                          _selectedCustomerName = provider.customers
                                              .firstWhere((c) => c.id == value)
                                              .name;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نوع القسط',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: _installmentType,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.category_rounded, color: Color(0xFF10B981)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: ['شخصي', 'تجاري', 'عقاري', 'سيارة'].map((type) {
                                    return DropdownMenuItem(value: type, child: Text(type));
                                  }).toList(),
                                  onChanged: (value) => setState(() => _installmentType = value!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 2: Job Entry, Access, Delivery
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'دخل الجدول',
                            _jobEntryController,
                            Icons.work_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'الوصول',
                            _accessController,
                            Icons.location_on_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'التوصيل',
                            _deliveryController,
                            Icons.local_shipping_rounded,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 3: Guarantor Info
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'اسم الكفيل',
                            _guarantorNameController,
                            Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'عنوان الكفيل',
                            _guarantorAddressController,
                            Icons.home_rounded,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 4: Guarantor Details & Witnesses
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'تفاصيل الكفيل',
                            _guarantorDetailsController,
                            Icons.description_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'الضامنين',
                            _witnessesController,
                            Icons.groups_rounded,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 5: Region & Payment Method
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المنطقة',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: _region,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.map_rounded, color: Color(0xFF10B981)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: ['المنطقة الأولى', 'المنطقة الثانية', 'المنطقة الثالثة'].map((region) {
                                    return DropdownMenuItem(value: region, child: Text(region));
                                  }).toList(),
                                  onChanged: (value) => setState(() => _region = value!),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'وسيلة الدفع (يومي-شهري)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: _paymentMethod,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.payment_rounded, color: Color(0xFF10B981)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: ['يومي', 'أسبوعي', 'شهري'].map((method) {
                                    return DropdownMenuItem(value: method, child: Text(method));
                                  }).toList(),
                                  onChanged: (value) => setState(() => _paymentMethod = value!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 6: Total Amount & Checkboxes
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مبلغ القسط الواحد (الأقل)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _totalAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'أدخل المبلغ',
                                  prefixIcon: Icon(Icons.attach_money_rounded, color: Color(0xFF10B981)),
                                  suffixText: 'د.ع',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال المبلغ';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'الرجاء إدخال رقم صحيح';
                                  }
                                  return null;
                                },
                                onChanged: (value) => _calculateInstallmentAmount(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: const Text('قسطين', style: TextStyle(fontSize: 14)),
                                value: _isTwoInstallments,
                                onChanged: (value) {
                                  setState(() {
                                    _isTwoInstallments = value!;
                                    if (value) _numberOfInstallments = 2;
                                    _calculateInstallmentAmount();
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: const Color(0xFF10B981),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                title: const Text('نوع القسطة احادية', style: TextStyle(fontSize: 14)),
                                value: _isSingleInstallment,
                                onChanged: (value) {
                                  setState(() {
                                    _isSingleInstallment = value!;
                                    if (value) _numberOfInstallments = 1;
                                    _calculateInstallmentAmount();
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: const Color(0xFF10B981),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 7: Options & Number of Installments
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: const Text('طباعة الصفحة', style: TextStyle(fontSize: 14)),
                                value: _printPage,
                                onChanged: (value) => setState(() => _printPage = value!),
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: const Color(0xFF10B981),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                title: const Text('بيان لمرة واحدة', style: TextStyle(fontSize: 14)),
                                value: _oneTimeStatement,
                                onChanged: (value) => setState(() => _oneTimeStatement = value!),
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: const Color(0xFF10B981),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'عدد الأقساط',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_numberOfInstallments > 1) {
                                          setState(() {
                                            _numberOfInstallments--;
                                            _calculateInstallmentAmount();
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444)),
                                    ),
                                    Text(
                                      '$_numberOfInstallments',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _numberOfInstallments++;
                                          _calculateInstallmentAmount();
                                        });
                                      },
                                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Row 8: Installment Amount & Start Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مبلغ القسط',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF10B981).withOpacity(0.1),
                                      const Color(0xFF059669).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calculate_rounded, color: Color(0xFF10B981), size: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'قيمة القسط الواحد',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color(0xFF10B981),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currencyFormat.format(_installmentAmount),
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: const Color(0xFF10B981),
                                              fontWeight: FontWeight.bold,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تاريخ أول قسط',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setState(() => _startDate = date);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF10B981),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF10B981)),
                                      const SizedBox(width: 16),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(_startDate),
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _saveInstallment,
                              icon: const Icon(Icons.save_rounded, size: 24),
                              label: const Text(
                                'حفظ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Print functionality
                              },
                              icon: const Icon(Icons.print_rounded, size: 24),
                              label: const Text(
                                'طباعة',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6366F1),
                                side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close_rounded, size: 24),
                              label: const Text(
                                'خروج',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(color: Color(0xFFEF4444), width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
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
    );
  }
}
