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
          status: 'active',
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
                                Tab(text: 'حافة القسط'),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حافة القسط',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('معلومات حافة القسط'),
                  subtitle: Text('سيتم إضافة المزيد من التفاصيل هنا'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'القسط',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('تفاصيل القسط'),
                  subtitle: Text('سيتم إضافة المزيد من التفاصيل هنا'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentDateTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تاريخ القسط',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('جدول تواريخ الأقساط'),
                  subtitle: Text('سيتم إضافة المزيد من التفاصيل هنا'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الحساب',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('معلومات الحساب'),
                  subtitle: Text('سيتم إضافة المزيد من التفاصيل هنا'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
