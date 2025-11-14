import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/installments_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/installment.dart';
import '../../widgets/product_form_dialog.dart';

class AddInstallmentScreen extends StatefulWidget {
  const AddInstallmentScreen({Key? key}) : super(key: key);

  @override
  _AddInstallmentScreenState createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers
  final _transactionNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _addressController = TextEditingController();
  final _workTypeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _guarantorsController = TextEditingController();
  final _guarantorsAddressController = TextEditingController();
  final _guarantorsMobileController = TextEditingController();
  final _detailsController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _numberOfInstallmentsController = TextEditingController();
  final _totalBalanceController = TextEditingController();
  final _installmentAmountController = TextEditingController();
  final _firstInstallmentDateController = TextEditingController();
  final _closestManagerController = TextEditingController();
  final _latePercentageController = TextEditingController();

  String? _selectedProduct;
  String _installmentStatus = 'نشط'; // حالة القسط
  DateTime _selectedDate = DateTime.now();
  DateTime _firstInstallmentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _firstInstallmentDateController.text =
        DateFormat('yyyy-MM-dd').format(_firstInstallmentDate);

    // Auto-generate transaction number
    _generateTransactionNumber();

    // Add listeners for auto-calculation
    _unitPriceController.addListener(_calculateTotals);
    _numberOfInstallmentsController.addListener(_calculateTotals);

    // Load products for dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadProducts();
    });
  }

  void _generateTransactionNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _transactionNumberController.text = 'INST-$timestamp';
  }

  void _calculateTotals() {
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final numberOfInstallments =
        int.tryParse(_numberOfInstallmentsController.text) ?? 0;

    if (numberOfInstallments > 0) {
      final installmentAmount = unitPrice / numberOfInstallments;
      _installmentAmountController.text = installmentAmount.toStringAsFixed(2);
      _totalBalanceController.text = unitPrice.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transactionNumberController.dispose();
    _dateController.dispose();
    _customerNameController.dispose();
    _workplaceController.dispose();
    _addressController.dispose();
    _workTypeController.dispose();
    _mobileController.dispose();
    _guarantorsController.dispose();
    _guarantorsAddressController.dispose();
    _guarantorsMobileController.dispose();
    _detailsController.dispose();
    _unitPriceController.dispose();
    _numberOfInstallmentsController.dispose();
    _totalBalanceController.dispose();
    _installmentAmountController.dispose();
    _firstInstallmentDateController.dispose();
    _closestManagerController.dispose();
    _latePercentageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, bool isFirstInstallment) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFirstInstallment ? _firstInstallmentDate : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFirstInstallment) {
          _firstInstallmentDate = picked;
          _firstInstallmentDateController.text =
              DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _selectedDate = picked;
          _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _saveInstallment() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Build notes field with all additional information
        final notes = '''
رقم العملية: ${_transactionNumberController.text}
المادة: $_selectedProduct
محل الشغل: ${_workplaceController.text}
العنوان: ${_addressController.text}
النوع الشغل: ${_workTypeController.text}
الموبايل: ${_mobileController.text}
الضامنين: ${_guarantorsController.text}
عنوان الضامنين: ${_guarantorsAddressController.text}
موبايل الضامنين: ${_guarantorsMobileController.text}
تاريخ أول قسط مستحق: ${_firstInstallmentDateController.text}
قريب المسير: ${_closestManagerController.text}
النسبة التأخيرية: ${_latePercentageController.text}%
التفاصيل: ${_detailsController.text}
''';

        final installment = Installment(
          customerId:
              1, // Default customer ID - you may want to add customer selection
          customerName: _customerNameController.text,
          totalAmount: double.tryParse(_totalBalanceController.text) ?? 0,
          paidAmount: 0,
          remainingAmount: double.tryParse(_totalBalanceController.text) ?? 0,
          numberOfInstallments:
              int.tryParse(_numberOfInstallmentsController.text) ?? 0,
          paidInstallments: 0,
          installmentAmount:
              double.tryParse(_installmentAmountController.text) ?? 0,
          startDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
          notes: notes,
          status: _installmentStatus == 'نشط'
              ? 'active'
              : _installmentStatus == 'متأخر'
                  ? 'delayed'
                  : _installmentStatus == 'مكتمل'
                      ? 'completed'
                      : 'cancelled',
        );

        await Provider.of<InstallmentsProvider>(context, listen: false)
            .addInstallment(installment);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة عملية التقسيط بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form after saving
          _formKey.currentState?.reset();
          _transactionNumberController.clear();
          _customerNameController.clear();
          _workplaceController.clear();
          _addressController.clear();
          _workTypeController.clear();
          _mobileController.clear();
          _guarantorsController.clear();
          _guarantorsAddressController.clear();
          _guarantorsMobileController.clear();
          _detailsController.clear();
          _unitPriceController.clear();
          _numberOfInstallmentsController.clear();
          _totalBalanceController.clear();
          _installmentAmountController.clear();
          _closestManagerController.clear();
          _latePercentageController.clear();
          setState(() {
            _selectedProduct = null;
            _installmentStatus = 'نشط';
          });
          _generateTransactionNumber();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إضافة التقسيط: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        textAlign: TextAlign.right,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const Icon(Icons.payment, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Text(
                    'إضافة عملية تقسيط جديدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel - Tabs
                  Expanded(
                    flex: 2,
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.1),
                                  theme.colorScheme.secondary.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: theme.colorScheme.primary,
                              indicatorWeight: 3,
                              tabs: const [
                                Tab(text: 'حالة القسط'),
                                Tab(text: 'القسط'),
                                Tab(text: 'تاريخ القسط'),
                                Tab(text: 'الحساب'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildInstallmentEdgeTab(),
                                _buildInstallmentTab(),
                                _buildInstallmentDateTab(),
                                _buildAccountTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Panel - Form
                  Expanded(
                    flex: 3,
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            // Transaction Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.1),
                                    theme.colorScheme.secondary
                                        .withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _transactionNumberController,
                                      label: 'رقم عملية التقسيط',
                                      readOnly: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: Consumer<ProductsProvider>(
                                      builder: (context, provider, _) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child:
                                              DropdownButtonFormField<String>(
                                            value: _selectedProduct,
                                            decoration: InputDecoration(
                                              labelText: 'المادة',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            items: provider.products
                                                .map((product) {
                                              return DropdownMenuItem<String>(
                                                value: product.id.toString(),
                                                child: Text(product.name),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedProduct = value;
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'يرجى اختيار المادة';
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 16.0, left: 16.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              ProductFormDialog(product: null),
                                        );
                                        // Reload products after adding
                                        if (mounted) {
                                          await Provider.of<ProductsProvider>(
                                                  context,
                                                  listen: false)
                                              .loadProducts();
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('إضافة مادة'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _dateController,
                                      label: 'التاريخ',
                                      readOnly: true,
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Customer Information
                            Text(
                              'معلومات العميل',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _customerNameController,
                                    label: 'الاسم',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال الاسم';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _workplaceController,
                                    label: 'محل الشغل',
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _addressController,
                                    label: 'العنوان',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _workTypeController,
                                    label: 'النوع الشغل',
                                  ),
                                ),
                              ],
                            ),

                            _buildTextField(
                              controller: _mobileController,
                              label: 'الموبايل',
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 24),

                            // Guarantors Information
                            Text(
                              'معلومات الضامنين',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _guarantorsController,
                              label: 'الضامنين',
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _guarantorsAddressController,
                                    label: 'عنوان الضامنين',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _guarantorsMobileController,
                                    label: 'موبايل الضامنين',
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Financial Information
                            Text(
                              'المعلومات المالية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _unitPriceController,
                                    label: 'ثمن البيع الواحد',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال السعر';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _numberOfInstallmentsController,
                                    label: 'عدد الأقساط',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال عدد الأقساط';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _totalBalanceController,
                                    label: 'ميزان الأقساط الكلي',
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _installmentAmountController,
                                    label: 'مبلغ الأقساط',
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Other Information
                            Text(
                              'معلومات أخرى',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _firstInstallmentDateController,
                                    label: 'تاريخ أول قسط مستحق',
                                    readOnly: true,
                                    onTap: () => _selectDate(context, true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _closestManagerController,
                                    label: 'قريب المسير',
                                  ),
                                ),
                              ],
                            ),

                            _buildTextField(
                              controller: _latePercentageController,
                              label: 'النسبة التأخيرية (%)',
                              keyboardType: TextInputType.number,
                            ),

                            _buildTextField(
                              controller: _detailsController,
                              label: 'التفاصيل',
                              maxLines: 3,
                            ),

                            const SizedBox(height: 32),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Clear the form
                                    _formKey.currentState?.reset();
                                    _transactionNumberController.clear();
                                    _customerNameController.clear();
                                    _workplaceController.clear();
                                    _addressController.clear();
                                    _workTypeController.clear();
                                    _mobileController.clear();
                                    _guarantorsController.clear();
                                    _guarantorsAddressController.clear();
                                    _guarantorsMobileController.clear();
                                    _detailsController.clear();
                                    _unitPriceController.clear();
                                    _numberOfInstallmentsController.clear();
                                    _totalBalanceController.clear();
                                    _installmentAmountController.clear();
                                    _closestManagerController.clear();
                                    _latePercentageController.clear();
                                    setState(() {
                                      _selectedProduct = null;
                                      _installmentStatus = 'نشط';
                                    });
                                    _generateTransactionNumber();
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('إلغاء'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: _saveInstallment,
                                  icon: const Icon(Icons.save),
                                  label: const Text('حفظ'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildInstallmentEdgeTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'حالة القسط',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر حالة القسط:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildStatusOption(
                  'نشط',
                  'القسط قيد التنفيذ والدفعات مستمرة',
                  Icons.check_circle,
                  const Color(0xFF10B981),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildStatusOption(
                  'متأخر',
                  'يوجد تأخير في سداد الأقساط',
                  Icons.warning_amber_rounded,
                  const Color(0xFFF59E0B),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildStatusOption(
                  'مكتمل',
                  'تم سداد جميع الأقساط بنجاح',
                  Icons.task_alt_rounded,
                  const Color(0xFF3B82F6),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildStatusOption(
                  'ملغي',
                  'تم إلغاء عملية التقسيط',
                  Icons.cancel_rounded,
                  const Color(0xFFEF4444),
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor().withOpacity(0.1),
                  _getStatusColor().withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الحالة المحددة:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _installmentStatus,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
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
    );
  }

  Widget _buildStatusOption(String status, String description, IconData icon,
      Color color, bool isDark) {
    final isSelected = _installmentStatus == status;

    return InkWell(
      onTap: () {
        setState(() {
          _installmentStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_installmentStatus) {
      case 'نشط':
        return const Color(0xFF10B981);
      case 'متأخر':
        return const Color(0xFFF59E0B);
      case 'مكتمل':
        return const Color(0xFF3B82F6);
      case 'ملغي':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  IconData _getStatusIcon() {
    switch (_installmentStatus) {
      case 'نشط':
        return Icons.check_circle;
      case 'متأخر':
        return Icons.warning_amber_rounded;
      case 'مكتمل':
        return Icons.task_alt_rounded;
      case 'ملغي':
        return Icons.cancel_rounded;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildInstallmentTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat =
        NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

    // حساب المعلومات من الحقول
    final totalAmount = double.tryParse(_totalBalanceController.text) ?? 0;
    final numberOfInstallments =
        int.tryParse(_numberOfInstallmentsController.text) ?? 0;
    final installmentAmount =
        double.tryParse(_installmentAmountController.text) ?? 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.payment_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'تفاصيل القسط',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // بطاقة المبلغ الإجمالي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                      : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المبلغ الإجمالي',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(totalAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // معلومات الأقساط
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'عدد الأقساط',
                    numberOfInstallments.toString(),
                    Icons.format_list_numbered_rounded,
                    const Color(0xFF10B981),
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'مبلغ القسط',
                    currencyFormat.format(installmentAmount),
                    Icons.payments_rounded,
                    const Color(0xFF8B5CF6),
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'معلومات الدفع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('المدفوع', currencyFormat.format(0),
                      Icons.check_circle, const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  _buildInfoRow('المتبقي', currencyFormat.format(totalAmount),
                      Icons.pending, const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      'الأقساط المدفوعة',
                      '0 من $numberOfInstallments',
                      Icons.done_all,
                      const Color(0xFF3B82F6)),
                  const SizedBox(height: 12),
                  _buildInfoRow('نسبة الإنجاز', '0%', Icons.pie_chart,
                      const Color(0xFFF59E0B)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ملاحظة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: const Color(0xFF3B82F6), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم تحديث معلومات الدفع تلقائياً عند تسديد الأقساط',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
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

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentDateTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // حساب التواريخ
    final numberOfInstallments =
        int.tryParse(_numberOfInstallmentsController.text) ?? 0;
    final installmentAmount =
        double.tryParse(_installmentAmountController.text) ?? 0;
    final currencyFormat =
        NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'جدول تواريخ الأقساط',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // معلومات التواريخ الرئيسية
          Row(
            children: [
              Expanded(
                child: _buildDateCard(
                  'تاريخ البدء',
                  _dateController.text.isNotEmpty
                      ? _dateController.text
                      : 'غير محدد',
                  Icons.event_rounded,
                  const Color(0xFF3B82F6),
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateCard(
                  'أول قسط مستحق',
                  _firstInstallmentDateController.text.isNotEmpty
                      ? _firstInstallmentDateController.text
                      : 'غير محدد',
                  Icons.event_available_rounded,
                  const Color(0xFF10B981),
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // جدول الأقساط
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart_rounded,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'جدول الأقساط المتوقعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (numberOfInstallments > 0 &&
                    _firstInstallmentDateController.text.isNotEmpty)
                  ..._buildInstallmentSchedule(numberOfInstallments,
                      installmentAmount, currencyFormat, isDark)
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy_rounded,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'أدخل عدد الأقساط وتاريخ أول قسط لعرض الجدول',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ملاحظة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFEC4899).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: const Color(0xFFEC4899), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يتم حساب التواريخ شهرياً بشكل تلقائي من تاريخ أول قسط مستحق',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
      String title, String date, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInstallmentSchedule(int numberOfInstallments,
      double installmentAmount, NumberFormat currencyFormat, bool isDark) {
    List<Widget> schedule = [];

    try {
      final firstDate =
          DateFormat('yyyy-MM-dd').parse(_firstInstallmentDateController.text);

      // عرض أول 10 أقساط فقط لتجنب القائمة الطويلة
      final displayCount =
          numberOfInstallments > 10 ? 10 : numberOfInstallments;

      for (int i = 0; i < displayCount; i++) {
        final dueDate =
            DateTime(firstDate.year, firstDate.month + i, firstDate.day);
        final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);

        schedule.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'القسط ${i + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(installmentAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (numberOfInstallments > 10) {
        schedule.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '+ ${numberOfInstallments - 10} أقساط أخرى',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      schedule.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'تنسيق التاريخ غير صحيح',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ),
      );
    }

    return schedule;
  }

  Widget _buildAccountTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat =
        NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

    // حساب المعلومات المالية
    final totalAmount = double.tryParse(_totalBalanceController.text) ?? 0;
    final paidAmount = 0.0; // سيتم تحديثه عند التسديد
    final remainingAmount = totalAmount - paidAmount;
    final numberOfInstallments =
        int.tryParse(_numberOfInstallmentsController.text) ?? 0;
    final paidInstallments = 0;
    final remainingInstallments = numberOfInstallments - paidInstallments;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14B8A6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'ملخص الحساب',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // بطاقات المبالغ الرئيسية
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    'المبلغ الكلي',
                    currencyFormat.format(totalAmount),
                    Icons.attach_money_rounded,
                    const Color(0xFF3B82F6),
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinancialCard(
                    'المبلغ المتبقي',
                    currencyFormat.format(remainingAmount),
                    Icons.money_off_rounded,
                    const Color(0xFFEF4444),
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // معلومات الأقساط
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'تفاصيل الأقساط',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildAccountInfoRow(
                    'إجمالي الأقساط',
                    numberOfInstallments.toString(),
                    Icons.format_list_numbered_rounded,
                    const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 12),
                  _buildAccountInfoRow(
                    'الأقساط المدفوعة',
                    paidInstallments.toString(),
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildAccountInfoRow(
                    'الأقساط المتبقية',
                    remainingInstallments.toString(),
                    Icons.pending_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // نسبة الإنجاز
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                      : [const Color(0xFF14B8A6), const Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نسبة الإنجاز',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '0%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم يتم السداد بعد',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
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
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'معلومات العميل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildCustomerInfoRow(
                    'اسم العميل',
                    _customerNameController.text.isNotEmpty
                        ? _customerNameController.text
                        : 'غير محدد',
                    Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomerInfoRow(
                    'رقم الموبايل',
                    _mobileController.text.isNotEmpty
                        ? _mobileController.text
                        : 'غير محدد',
                    Icons.phone_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomerInfoRow(
                    'العنوان',
                    _addressController.text.isNotEmpty
                        ? _addressController.text
                        : 'غير محدد',
                    Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomerInfoRow(
                    'محل الشغل',
                    _workplaceController.text.isNotEmpty
                        ? _workplaceController.text
                        : 'غير محدد',
                    Icons.work_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ملاحظة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: const Color(0xFF14B8A6), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم تحديث معلومات الحساب تلقائياً عند كل عملية تسديد',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
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

  Widget _buildFinancialCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
