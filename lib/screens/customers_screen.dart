import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/customers_provider.dart';
import '../models/customer.dart';
import 'account_masters_screen.dart';

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
  final _maxCreditController = TextEditingController(); // الحد الاعلى للرصيد
  final _percentAfterLimitController =
      TextEditingController(); // النسبة بعد تجاوز الحد
  final _referenceNumberController = TextEditingController(); // رقم الاستناد
  final _openingBalanceController = TextEditingController(); // رصيد افتتاحي

  String _accountType = 'حسابات الزبائن';
  String _linkedAccount = 'لا يوجد';
  String _priceLink = 'يوم'; // ربط الزبون بالأسعار
  String _distributorLink = 'لا يوجد'; // ربط بموزع
  bool _isSpecificDate = false; // حسابات تاريخ محددة
  bool _isAccountFrozen = false; // تجميد الحساب

  // متغيرات الصور
  File? _accountImage; // صورة الحساب
  List<File> _documentImages = []; // المستمسكات

  // قوائم ديناميكية
  List<String> _distributorsList = ['لا يوجد', 'موزع 1', 'موزع 2', 'موزع 3'];
  List<String> _linkedAccountsList = ['لا يوجد', 'حساب 1', 'حساب 2', 'حساب 3'];

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
    _maxCreditController.dispose();
    _percentAfterLimitController.dispose();
    _referenceNumberController.dispose();
    _openingBalanceController.dispose();
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
    _maxCreditController.clear();
    _percentAfterLimitController.clear();
    _referenceNumberController.clear();
    _openingBalanceController.clear();
    setState(() {
      _selectedCustomer = null;
      _isEditing = false;
      _accountType = 'حسابات الزبائن';
      _linkedAccount = 'لا يوجد';
      _priceLink = 'يوم';
      _distributorLink = 'لا يوجد';
      _isSpecificDate = false;
      _isAccountFrozen = false;
      _accountImage = null;
      _documentImages.clear();
    });
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final customer = Customer(
        id: _isEditing ? _selectedCustomer!.id : null,
        name: _nameController.text,
        customerCode: _customerCodeController.text.isEmpty
            ? null
            : _customerCodeController.text,
        phone: _phoneController.text,
        address: _cityController.text, // استخدام المدينة كعنوان
        balance: _openingBalanceController.text.isEmpty
            ? 0.0
            : double.tryParse(_openingBalanceController.text) ?? 0.0,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
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
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(_isEditing
                    ? 'تم تحديث الحساب بنجاح ✅'
                    : 'تم إضافة الحساب بنجاح ✅'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
      _openingBalanceController.text = customer.balance.toString();
      _notesController.text = customer.notes ?? '';
      _accountNumberController.text = customer.id?.toString() ?? '';
      _isAccountFrozen = false; // يمكن تحميلها من قاعدة البيانات لاحقاً
    });
  }

  void _showCustomerDetails(Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icons.person_rounded,
                        color: Color(0xFF10B981),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل الحساب',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'معلومات الزبون الكاملة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Customer Details
                _buildDetailRow(
                  icon: Icons.badge_rounded,
                  label: 'رقم الحساب',
                  value: customer.id?.toString() ?? '-',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.person_rounded,
                  label: 'الاسم',
                  value: customer.name,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.qr_code_rounded,
                  label: 'كود الزبون',
                  value: customer.customerCode ?? '-',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.phone_rounded,
                  label: 'رقم الهاتف',
                  value: customer.phone,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.location_on_rounded,
                  label: 'العنوان',
                  value: customer.address ?? '-',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.notes_rounded,
                  label: 'الملاحظات',
                  value: customer.notes ?? '-',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'الرصيد الحالي',
                  value: '0 د.ع',
                  isDark: isDark,
                  valueColor: const Color(0xFF10B981),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'إغلاق',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editCustomer(customer);
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text(
                        'تعديل',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text,
      {required int flex, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        textAlign: center ? TextAlign.center : TextAlign.start,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween(begin: 1.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(icon, color: color, size: 20),
                    onPressed: onPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddDistributorDialog() {
    final TextEditingController distributorNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text('إضافة موزع جديد'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: distributorNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الموزع',
                hintText: 'أدخل اسم الموزع',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (distributorNameController.text.isNotEmpty) {
                setState(() {
                  // إضافة الموزع للقائمة إذا لم يكن موجوداً
                  if (!_distributorsList
                      .contains(distributorNameController.text)) {
                    _distributorsList.add(distributorNameController.text);
                  }
                  _distributorLink = distributorNameController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'تم إضافة الموزع: ${distributorNameController.text}'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddLinkedAccountDialog() {
    final TextEditingController linkedAccountNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.link_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text('إضافة حساب جديد'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: linkedAccountNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الحساب',
                hintText: 'أدخل اسم الحساب',
                prefixIcon: Icon(Icons.account_circle),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (linkedAccountNameController.text.isNotEmpty) {
                setState(() {
                  // إضافة الحساب للقائمة إذا لم يكن موجوداً
                  if (!_linkedAccountsList
                      .contains(linkedAccountNameController.text)) {
                    _linkedAccountsList.add(linkedAccountNameController.text);
                  }
                  _linkedAccount = linkedAccountNameController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'تم إضافة الحساب: ${linkedAccountNameController.text}'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // دالة اختيار صورة الحساب
  Future<void> _pickAccountImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _accountImage = File(result.files.single.path!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم اختيار صورة الحساب'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // دالة اختيار المستمسكات (متعددة)
  Future<void> _pickDocumentImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _documentImages.addAll(
          result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
              .toList(),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إضافة ${result.files.length} مستمسك'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // حذف مستمسك معين
  void _removeDocumentImage(int index) {
    setState(() {
      _documentImages.removeAt(index);
    });
  }

  // دالة عرض نافذة البيانات الإضافية
  void _showAdditionalDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 700,
                constraints: const BoxConstraints(maxHeight: 700),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'البيانات الإضافية',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'رفع صورة الحساب والمستمسكات',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'إغلاق',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // المحتوى القابل للتمرير
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // قسم صورة الحساب
                            _buildImageSection(
                              title: '📷 صورة الحساب',
                              subtitle: 'اختر صورة شخصية أو شعار للحساب',
                              image: _accountImage,
                              onPickImage: () async {
                                await _pickAccountImage();
                                setDialogState(() {});
                              },
                              onRemoveImage: () {
                                setDialogState(() {
                                  _accountImage = null;
                                });
                              },
                              isDark: isDark,
                            ),

                            const SizedBox(height: 32),

                            // قسم المستمسكات
                            Text(
                              '📄 المستمسكات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'أضف صور الهوية، جواز السفر، أو أي مستندات أخرى',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // عرض المستمسكات المحددة
                            if (_documentImages.isNotEmpty)
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  _documentImages.length,
                                  (index) => _buildDocumentThumbnail(
                                    _documentImages[index],
                                    index,
                                    (idx) {
                                      _removeDocumentImage(idx);
                                      setDialogState(() {});
                                    },
                                    isDark,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // زر إضافة مستمسكات
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _pickDocumentImages();
                                setDialogState(() {});
                              },
                              icon: const Icon(
                                  Icons.add_photo_alternate_outlined),
                              label: const Text('إضافة مستمسكات'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8B5CF6),
                                side: const BorderSide(
                                  color: Color(0xFF8B5CF6),
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // أزرار الإجراءات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'إغلاق',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ تم حفظ البيانات الإضافية'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('حفظ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // بناء قسم الصورة
  Widget _buildImageSection({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onPickImage,
    required VoidCallback onRemoveImage,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        if (image != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: onRemoveImage,
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(8),
                  ),
                  tooltip: 'حذف الصورة',
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: onPickImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'اضغط لاختيار صورة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // بناء صورة مصغرة للمستمسك
  Widget _buildDocumentThumbnail(
    File image,
    int index,
    Function(int) onRemove,
    bool isDark,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            image,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            onPressed: () => onRemove(index),
            icon: const Icon(Icons.close_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(28, 28),
            ),
            tooltip: 'حذف',
          ),
        ),
      ],
    );
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
                      // Enhanced Header with Gradient
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isEditing
                                ? [
                                    const Color(0xFFEF4444),
                                    const Color(0xFFDC2626),
                                  ]
                                : [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_isEditing
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF6366F1))
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _isEditing
                                    ? Icons.edit_note_rounded
                                    : Icons.person_add_alt_1_rounded,
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
                                    _isEditing
                                        ? 'تعديل حساب'
                                        : 'إضافة حساب جديد',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isEditing
                                        ? 'قم بتحديث بيانات الحساب أدناه'
                                        : 'املأ البيانات لإنشاء حساب عميل جديد',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Quick Action Buttons
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildQuickActionButton(
                            label: 'إضافة استاذ',
                            icon: Icons.person_add_alt_rounded,
                            color: const Color(0xFF3B82F6),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AccountMastersScreen(),
                                ),
                              );
                            },
                            isDark: isDark,
                          ),
                          _buildQuickActionButton(
                            label: 'بيانات إضافية',
                            icon: Icons.add_circle_outline,
                            color: const Color(0xFF8B5CF6),
                            onPressed: _showAdditionalDataDialog,
                            isDark: isDark,
                          ),
                          if (_isEditing)
                            _buildQuickActionButton(
                              label: 'إلغاء التعديل',
                              icon: Icons.close_rounded,
                              color: const Color(0xFFEF4444),
                              onPressed: _clearForm,
                              isDark: isDark,
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // المعلومات الأساسية Section Header
                      _buildSectionHeader(
                        title: 'المعلومات الأساسية',
                        icon: Icons.badge_rounded,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

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
                                  'نوع الحساب',
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
                                  items: [
                                    'حسابات الزبائن',
                                    'المورد',
                                    'مخزون المنافع بعرض البيع',
                                    'مراكز العمليات / صيرفة',
                                    'حسابات متعهدين',
                                    'حسابات موقع',
                                    'حسابات ربح نقدي',
                                    'رأس المال المدفوع',
                                    'حسابات شركات صيرفة',
                                    'حسابات الصناديق',
                                    'حسابات البنوك',
                                    'حسابات مصاريف',
                                    'حسابات مندوبين',
                                    'حسابات الربح والخسائر',
                                    'حسابات الكلفة',
                                    'حسابات الموظفين',
                                    'حسابات الايرادات',
                                  ].map((type) {
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
                                    hintText: 'أدخل اسم الحساب',
                                    prefixIcon: const Icon(Icons.person_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال اسم الحساب ';
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

                      const SizedBox(height: 32),

                      // معلومات الاتصال Section Header
                      _buildSectionHeader(
                        title: 'معلومات الاتصال',
                        icon: Icons.contact_phone_rounded,
                        color: const Color(0xFF3B82F6),
                        isDark: isDark,
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

                      // Row 5: Discount & Opening Balance
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
                                  'رصيد افتتاحي',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _openingBalanceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    prefixIcon: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: Color(0xFF10B981)),
                                    suffixText: 'د.ع',
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

                      // Row 6: Linked Account
                      // Row 6: Linked Account
                      Row(
                        children: [
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _linkedAccount,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.link_rounded,
                                              color: Color(0xFF10B981)),
                                          filled: true,
                                          fillColor: isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFF1F5F9),
                                        ),
                                        items: _linkedAccountsList.map((type) {
                                          return DropdownMenuItem(
                                              value: type, child: Text(type));
                                        }).toList(),
                                        onChanged: (value) => setState(
                                            () => _linkedAccount = value!),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.white),
                                        onPressed: _showAddLinkedAccountDialog,
                                        tooltip: 'إضافة حساب جديد',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 6: ربط بموزع
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ربط بموزع',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _distributorLink,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                        Icons.local_shipping_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  items: _distributorsList.map((distributor) {
                                    return DropdownMenuItem(
                                        value: distributor,
                                        child: Text(distributor));
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _distributorLink = value!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _showAddDistributorDialog();
                                  },
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                  tooltip: 'إضافة موزع جديد',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 7: الحد الأعلى للرصيد + النسبة بعد تجاوز الحد
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الحد الاعلى للرصيد',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _maxCreditController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    prefixIcon: const Icon(
                                        Icons.account_balance_wallet_rounded,
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
                                  'النسبة بعد تجاوز الحد',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _percentAfterLimitController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    prefixIcon: const Icon(
                                        Icons.percent_rounded,
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
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Row 8: ربط الزبون بالأسعار + رقم الاستناد
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ربط الزبون بالأسعار',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _priceLink,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                        Icons.attach_money_rounded,
                                        color: Color(0xFF10B981)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                  ),
                                  items: ['يوم', 'اسبوع', 'شهر'].map((type) {
                                    return DropdownMenuItem(
                                        value: type, child: Text(type));
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _priceLink = value!),
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
                                  'رقم الاستناد',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _referenceNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل رقم الاستناد',
                                    prefixIcon: const Icon(
                                        Icons.numbers_rounded,
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

                      // Row 9: حسابات تاريخ محددة (Checkbox)
                      CheckboxListTile(
                        title: const Text('حسابات تاريخ محددة'),
                        value: _isSpecificDate,
                        onChanged: (value) {
                          setState(() {
                            _isSpecificDate = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF10B981),
                      ),

                      const SizedBox(height: 20),

                      // Row 10: Notes
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

                      const SizedBox(height: 20),

                      // Freeze Account Checkbox
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isAccountFrozen
                                ? const Color(0xFFEF4444)
                                : (isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isAccountFrozen,
                              onChanged: (value) {
                                setState(() {
                                  _isAccountFrozen = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              _isAccountFrozen
                                  ? Icons.lock_rounded
                                  : Icons.lock_open_rounded,
                              color: _isAccountFrozen
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تجميد الحساب',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isAccountFrozen
                                          ? const Color(0xFFEF4444)
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  if (_isAccountFrozen)
                                    Text(
                                      'الحساب مجمّد ولا يمكن استخدامه',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Enhanced Action Buttons
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF334155),
                                    const Color(0xFF1E293B),
                                  ]
                                : [
                                    const Color(0xFFF8FAFC),
                                    Colors.white,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700.withOpacity(0.3)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMainActionButton(
                                label:
                                    _isEditing ? 'تحديث الحساب' : 'حفظ الحساب',
                                icon: _isEditing
                                    ? Icons.update_rounded
                                    : Icons.save_rounded,
                                gradient: LinearGradient(
                                  colors: _isEditing
                                      ? [
                                          const Color(0xFFF59E0B),
                                          const Color(0xFFD97706),
                                        ]
                                      : [
                                          const Color(0xFF10B981),
                                          const Color(0xFF059669),
                                        ],
                                ),
                                onPressed: _saveCustomer,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMainActionButton(
                                label: 'حساب جديد',
                                icon: Icons.add_circle_outline_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                                onPressed: _clearForm,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMainActionButton(
                                label: 'مسح الكل',
                                icon: Icons.refresh_rounded,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEF4444),
                                    Color(0xFFDC2626),
                                  ],
                                ),
                                onPressed: _clearForm,
                                isDark: isDark,
                                isOutlined: true,
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '🔍 بحث عن زبون...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Icon(
                                Icons.search_rounded,
                                color:
                                    const Color(0xFF6366F1).withOpacity(value),
                                size: 26,
                              ),
                            );
                          },
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    color: Color(0xFFEF4444)),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF334155) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: (isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF7C3AED),
                          Color(0xFF8B5CF6)
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTableHeaderCell('ت', flex: 1),
                        _buildTableHeaderCell('الأسم', flex: 3),
                        _buildTableHeaderCell('العنوان', flex: 2),
                        _buildTableHeaderCell('حذف', flex: 2, center: true),
                        _buildTableHeaderCell('تحويل الحساب',
                            flex: 2, center: true),
                        _buildTableHeaderCell('تعديل', flex: 2, center: true),
                        _buildTableHeaderCell('تفاصيل', flex: 2, center: true),
                        _buildTableHeaderCell('الرصيد', flex: 2),
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
                            final isSelected =
                                _selectedCustomer?.id == customer.id;
                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 300 + (index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, animValue, child) {
                                return Opacity(
                                  opacity: animValue,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - animValue)),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  const Color(0xFF334155),
                                                  const Color(0xFF475569)
                                                ]
                                              : [
                                                  const Color(0xFFFAFAFA),
                                                  Colors.white
                                                ],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF10B981)
                                              : (isDark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[200]!),
                                          width: isSelected ? 2.5 : 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? const Color(0xFF10B981)
                                                    .withOpacity(0.3)
                                                : (isDark
                                                        ? Colors.black
                                                        : Colors.grey.shade300)
                                                    .withOpacity(0.2),
                                            blurRadius: isSelected ? 12 : 8,
                                            spreadRadius: isSelected ? 1 : 0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _editCustomer(customer),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          splashColor: const Color(0xFF10B981)
                                              .withOpacity(0.1),
                                          highlightColor:
                                              const Color(0xFF10B981)
                                                  .withOpacity(0.05),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 16),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xFF6366F1),
                                                          Color(0xFF8B5CF6)
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFF6366F1)
                                                              .withOpacity(0.3),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                      0xFF10B981)
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .person_rounded,
                                                              color: Color(
                                                                  0xFF10B981),
                                                              size: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              customer.name,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.phone_rounded,
                                                            color: Colors.grey,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            customer.phone,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .location_on_rounded,
                                                        color:
                                                            Color(0xFF6366F1),
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          customer.address ??
                                                              '-',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                _buildActionButton(
                                                  icon: Icons.delete_rounded,
                                                  color:
                                                      const Color(0xFFEF4444),
                                                  onPressed: () =>
                                                      _deleteCustomer(
                                                          customer.id!),
                                                  flex: 2,
                                                ),
                                                _buildActionButton(
                                                  icon:
                                                      Icons.swap_horiz_rounded,
                                                  color:
                                                      const Color(0xFF8B5CF6),
                                                  onPressed: () {},
                                                  flex: 2,
                                                ),
                                                _buildActionButton(
                                                  icon: Icons.edit_rounded,
                                                  color:
                                                      const Color(0xFF06B6D4),
                                                  onPressed: () =>
                                                      _editCustomer(customer),
                                                  flex: 2,
                                                ),
                                                _buildActionButton(
                                                  icon: Icons.info_rounded,
                                                  color:
                                                      const Color(0xFF10B981),
                                                  onPressed: () =>
                                                      _showCustomerDetails(
                                                          customer),
                                                  flex: 2,
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xFF10B981),
                                                          Color(0xFF059669)
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                                  0xFF10B981)
                                                              .withOpacity(0.3),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Text(
                                                      '0 د.ع',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

  // Helper Widget للأزرار السريعة
  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget لعناوين الأقسام
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget للأزرار الرئيسية
  Widget _buildMainActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
    required bool isDark,
    bool isOutlined = false,
  }) {
    return SizedBox(
      height: 62,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 24),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (gradient.colors.first).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 24),
                label: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
    );
  }
}
