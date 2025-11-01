import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customers_provider.dart';
import '../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customerCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _discountController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _accountType = 'حساب عام';
  String _linkedAccount = 'لا يوجد';

  String _searchQuery = '';
  Customer? _selectedCustomer;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomersProvider>(context, listen: false).loadCustomers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customerCodeController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _discountController.dispose();
    _workplaceController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _customerCodeController.clear();
    _phoneController.clear();
    _cityController.clear();
    _addressController.clear();
    _emailController.clear();
    _discountController.clear();
    _workplaceController.clear();
    _notesController.clear();
    setState(() {
      _selectedCustomer = null;
      _isEditing = false;
      _accountType = 'حساب عام';
      _linkedAccount = 'لا يوجد';
    });
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: _isEditing ? _selectedCustomer!.id : null,
      name: _nameController.text,
      customerCode: _customerCodeController.text.isEmpty
          ? null
          : _customerCodeController.text,
      phone: _phoneController.text,
      address: _cityController.text, // استخدام المدينة كعنوان
      notes: null,
    );

    final provider = Provider.of<CustomersProvider>(context, listen: false);

    if (_isEditing) {
      await provider.updateCustomer(customer);
    } else {
      await provider.addCustomer(customer);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'تم تحديث الحساب بنجاح' : 'تم إضافة الحساب بنجاح'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _clearForm();
    }
  }

  void _editCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _isEditing = true;
      _nameController.text = customer.name;
      _customerCodeController.text = customer.customerCode ?? '';
      _phoneController.text = customer.phone;
      _cityController.text = customer.address ?? '';
      _addressController.text = customer.address ?? '';
      _emailController.text = '';
      _discountController.text = '';
      _workplaceController.text = '';
      _notesController.text = customer.notes ?? '';
      _accountNumberController.text = customer.id?.toString() ?? '';
    });
  }

  void _deleteCustomer(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<CustomersProvider>(context, listen: false)
          .deleteCustomer(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الحساب بنجاح'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Form Section (Right Side)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey.shade300)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Action Buttons
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.person_add_rounded,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing
                                      ? 'تعديل حساب زبون'
                                      : 'إضافة حساب زبون',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'أدخل بيانات الحساب',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons Row
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saveCustomer,
                            icon: const Icon(Icons.person_add, size: 20),
                            label: const Text('إضافة حساب'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              // أسباب النماذج
                            },
                            icon: const Icon(Icons.description_outlined,
                                size: 20),
                            label: const Text('أسباب النماذج'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1),
                              side: const BorderSide(color: Color(0xFF6366F1)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              // بيانات إضافية
                            },
                            icon:
                                const Icon(Icons.add_circle_outline, size: 20),
                            label: const Text('بيانات إضافية'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8B5CF6),
                              side: const BorderSide(color: Color(0xFF8B5CF6)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                          if (_isEditing)
                            OutlinedButton.icon(
                              onPressed: _clearForm,
                              icon: const Icon(Icons.close, size: 20),
                              label: const Text('إلغاء'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Row 1: Account Number & Account Type
                      Row(
                        children: [
                          if (_isEditing)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'رقم الحساب',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _accountNumberController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.numbers,
                                          color: Color(0xFF6366F1)),
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFF1F5F9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isEditing) const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نوع الزبون',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: _accountType,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.category,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  items: ['حساب عام', 'حساب خاص', 'حساب تاجر']
                                      .map((type) {
                                    return DropdownMenuItem(
                                        value: type, child: Text(type));
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _accountType = value!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 2: Name & Phone
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الأسم',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل اسم الزبون',
                                    prefixIcon: const Icon(Icons.person_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال اسم الزبون';
                                    }
                                    return null;
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
                                  'كود العميل',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _customerCodeController,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل كود العميل (اختياري)',
                                    prefixIcon: const Icon(
                                        Icons.qr_code_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Second Row: Phone Number
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رقم الهاتف',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل رقم الهاتف',
                                    prefixIcon: const Icon(Icons.phone_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال رقم الهاتف';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 3: City & Email
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المدينة',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل المدينة',
                                    prefixIcon: const Icon(Icons.location_city,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
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
                                  'الايميل',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل الايميل',
                                    prefixIcon: const Icon(Icons.email_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 4: Address & Workplace
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العنوان',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل العنوان',
                                    prefixIcon: const Icon(
                                        Icons.location_on_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
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
                                  'محل العمل',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _workplaceController,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل محل العمل',
                                    prefixIcon: const Icon(
                                        Icons.business_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 5: Discount & Linked Account
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نسبة الخصم %',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    prefixIcon: const Icon(
                                        Icons.discount_rounded,
                                        color: Color(0xFF10B981)),
                                    suffixText: '%',
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
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
                                  'ربط حسابات أخرى',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: _linkedAccount,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.link_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  items: [
                                    'لا يوجد',
                                    'حساب 1',
                                    'حساب 2',
                                    'حساب 3'
                                  ].map((type) {
                                    return DropdownMenuItem(
                                        value: type, child: Text(type));
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _linkedAccount = value!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 6: Notes
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ملاحظة',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'أدخل ملاحظات إضافية',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 60),
                                child: Icon(Icons.notes_rounded,
                                    color: Color(0xFF10B981)),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons Bottom
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _saveCustomer,
                                icon: Icon(
                                    _isEditing
                                        ? Icons.edit_rounded
                                        : Icons.save_rounded,
                                    size: 24),
                                label: Text(
                                  _isEditing ? 'تحديث' : 'حفظ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _clearForm,
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 24),
                                label: const Text(
                                  'جديد',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: _clearForm,
                                icon:
                                    const Icon(Icons.refresh_rounded, size: 24),
                                label: const Text(
                                  'مسح',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                  side: const BorderSide(
                                      color: Color(0xFFEF4444), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
            ),
          ),

          // Customers List Section (Left Side)
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey.shade300)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Search
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.people_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحسابات',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Consumer<CustomersProvider>(
                              builder: (context, provider, _) {
                                return Text(
                                  'العدد: ${provider.customers.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث عن زبون...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF6366F1)),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text('ت',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text('الأسم',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('العنوان',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('حذف',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 2,
                            child: Text('تحويل الحساب',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 2,
                            child: Text('تعديل',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 2,
                            child: Text('تفاصيل',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 2,
                            child: Text('الرصيد',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Customers List
                  Expanded(
                    child: Consumer<CustomersProvider>(
                      builder: (context, provider, _) {
                        final filteredCustomers =
                            provider.customers.where((customer) {
                          return customer.name
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              customer.phone.contains(_searchQuery);
                        }).toList();

                        if (filteredCustomers.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد حسابات',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedCustomer?.id == customer.id
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _editCustomer(customer),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              customer.phone,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          customer.address ?? '-',
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.delete_rounded,
                                                color: Color(0xFFEF4444)),
                                            onPressed: () =>
                                                _deleteCustomer(customer.id!),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.swap_horiz_rounded,
                                                color: Color(0xFF8B5CF6)),
                                            onPressed: () {
                                              // Transfer account functionality
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(Icons.edit_rounded,
                                                color: Color(0xFF06B6D4)),
                                            onPressed: () =>
                                                _editCustomer(customer),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(Icons.info_rounded,
                                                color: Color(0xFF10B981)),
                                            onPressed: () {
                                              // Show details functionality
                                            },
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          '0 د.ع',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
