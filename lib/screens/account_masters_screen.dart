import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_masters_provider.dart';
import '../models/account_master.dart';

class AccountMastersScreen extends StatefulWidget {
  const AccountMastersScreen({super.key});

  @override
  State<AccountMastersScreen> createState() => _AccountMastersScreenState();
}

class _AccountMastersScreenState extends State<AccountMastersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedCategory = 'أصول ثابتة';
  bool _canUse = true;
  bool _canDelete = false;
  AccountMaster? _selectedAccount;
  bool _isEditing = false;

  final List<String> _categories = [
    'أصول ثابتة',
    'أصول متداولة',
    'نقدية',
    'مدينون',
    'دائنون',
    'حقوق الملكية',
    'مصروفات',
    'إيرادات',
    'حسابات خاصة',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountMastersProvider>(context, listen: false)
          .loadAccountMasters();
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _accountNumberController.clear();
    _accountNameController.clear();
    setState(() {
      _selectedAccount = null;
      _isEditing = false;
      _selectedCategory = 'أصول ثابتة';
      _canUse = true;
      _canDelete = false;
    });
  }

  void _saveAccount() async {
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
      final account = AccountMaster(
        id: _selectedAccount?.id,
        accountNumber: _accountNumberController.text,
        accountName: _accountNameController.text,
        category: _selectedCategory,
        canUse: _canUse,
        canDelete: _canDelete,
      );

      final provider =
          Provider.of<AccountMastersProvider>(context, listen: false);

      if (_isEditing) {
        await provider.updateAccountMaster(account);
      } else {
        await provider.addAccountMaster(account);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'تم تحديث الحساب بنجاح' : 'تم إضافة الحساب بنجاح'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }

      _clearForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editAccount(AccountMaster account) {
    setState(() {
      _selectedAccount = account;
      _isEditing = true;
      _accountNumberController.text = account.accountNumber;
      _accountNameController.text = account.accountName;
      _selectedCategory = account.category ?? 'أصول ثابتة';
      _canUse = account.canUse;
      _canDelete = account.canDelete;
    });
  }

  void _deleteAccount(int id) async {
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
      await Provider.of<AccountMastersProvider>(context, listen: false)
          .deleteAccountMaster(id);
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
                      // Enhanced Header
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
                                    const Color(0xFF3B82F6),
                                    const Color(0xFF2563EB),
                                  ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_isEditing
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF3B82F6))
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Navigator.pop(context),
                              tooltip: 'رجوع',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                    : Icons.account_tree_rounded,
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
                                        ? 'تعديل استاذ'
                                        : 'إضافة استاذ جديد',
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
                                        ? 'قم بتحديث بيانات الاستاذ أدناه'
                                        : 'املأ البيانات لإنشاء استاذ جديد في شجرة الحسابات',
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
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: OutlinedButton.icon(
                            onPressed: _clearForm,
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('إلغاء التعديل'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      // Form Fields
                      _buildSectionHeader(
                        title: 'بيانات الاستاذ',
                        icon: Icons.description_rounded,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // Account Number & Name
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF1E293B),
                                          const Color(0xFF334155)
                                        ]
                                      : [Colors.white, const Color(0xFFF8FAFC)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6)
                                        .withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.tag_rounded,
                                          color: Color(0xFF3B82F6),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'رقم الاستاذ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _accountNumberController,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: '1121',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400),
                                      prefixIcon: const Icon(Icons.numbers,
                                          color: Color(0xFF3B82F6)),
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? const Color(0xFF475569)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF3B82F6),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFEF4444)),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'مطلوب';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF1E293B),
                                          const Color(0xFF334155)
                                        ]
                                      : [Colors.white, const Color(0xFFF8FAFC)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.account_tree_rounded,
                                          color: Color(0xFF10B981),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'اسم الاستاذ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _accountNameController,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: 'مباني، آلات، سيارات...',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400),
                                      prefixIcon: const Icon(
                                          Icons.label_rounded,
                                          color: Color(0xFF10B981)),
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? const Color(0xFF475569)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF10B981),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFEF4444)),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'مطلوب';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF334155)
                                  ]
                                : [Colors.white, const Color(0xFFF8FAFC)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF475569)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.category_rounded,
                                    color: Color(0xFF8B5CF6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'التصنيف',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.folder_rounded,
                                    color: Color(0xFF8B5CF6)),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF8B5CF6),
                                    width: 2,
                                  ),
                                ),
                              ),
                              dropdownColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCategory = value!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Permissions Section
                      _buildSectionHeader(
                        title: 'الصلاحيات',
                        icon: Icons.lock_outline,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // Checkboxes
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF334155)
                                  ]
                                : [Colors.white, const Color(0xFFF8FAFC)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF475569)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _canUse
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      _canUse
                                          ? Icons.check_circle_rounded
                                          : Icons.check_circle_outline_rounded,
                                      color: const Color(0xFF10B981),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'يمكن استخدام الحساب',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                subtitle: const Padding(
                                  padding: EdgeInsets.only(right: 36),
                                  child: Text(
                                    'تفعيل هذا الخيار يسمح باستخدام الحساب في العمليات',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                value: _canUse,
                                onChanged: (value) =>
                                    setState(() => _canUse = value!),
                                activeColor: const Color(0xFF10B981),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _canDelete
                                      ? const Color(0xFFEF4444)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      _canDelete
                                          ? Icons.delete_rounded
                                          : Icons.delete_outline_rounded,
                                      color: const Color(0xFFEF4444),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'يمكن حذف الحساب',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                subtitle: const Padding(
                                  padding: EdgeInsets.only(right: 36),
                                  child: Text(
                                    'تفعيل هذا الخيار يسمح بحذف الحساب من النظام',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                value: _canDelete,
                                onChanged: (value) =>
                                    setState(() => _canDelete = value!),
                                activeColor: const Color(0xFFEF4444),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: OutlinedButton.icon(
                                onPressed: _clearForm,
                                icon:
                                    const Icon(Icons.refresh_rounded, size: 20),
                                label: const Text(
                                  'مسح الحقول',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6366F1),
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: _isEditing
                                      ? [
                                          const Color(0xFFEF4444),
                                          const Color(0xFFDC2626)
                                        ]
                                      : [
                                          const Color(0xFF10B981),
                                          const Color(0xFF059669)
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isEditing
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF10B981))
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _saveAccount,
                                icon: Icon(
                                  _isEditing
                                      ? Icons.update_rounded
                                      : Icons.add_circle_rounded,
                                  size: 22,
                                ),
                                label: Text(
                                  _isEditing
                                      ? 'تحديث الاستاذ'
                                      : 'إضافة الاستاذ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Info Note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(0.1),
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'نصيحة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'تأكد من اختيار التصنيف الصحيج للحساب لضمان دقة التقارير المالية',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
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
              ),
            ),
          ),

          // List Section (Left Side)
          Expanded(
            flex: 3,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                            : [
                                const Color(0xFF10B981),
                                const Color(0xFF059669)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
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
                          child: const Icon(
                            Icons.account_tree_rounded,
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
                                'شجرة الحسابات',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Consumer<AccountMastersProvider>(
                                builder: (context, provider, _) => Text(
                                  'إجمالي ${provider.accountMasters.length} حساب',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              const Text(
                                'نشط',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث برقم أو اسم الحساب...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Accounts List
                  Expanded(
                    child: Consumer<AccountMastersProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final accounts = provider.searchAccounts(
                          _searchController.text,
                        );

                        if (accounts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد حسابات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return _buildAccountCard(account, isDark);
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

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(AccountMaster account, bool isDark) {
    final categoryColors = {
      'أصول ثابتة': const Color(0xFF3B82F6),
      'أصول متداولة': const Color(0xFF10B981),
      'نقدية': const Color(0xFFF59E0B),
      'مدينون': const Color(0xFF8B5CF6),
      'دائنون': const Color(0xFFEF4444),
      'حقوق الملكية': const Color(0xFF06B6D4),
      'مصروفات': const Color(0xFFEC4899),
      'إيرادات': const Color(0xFF10B981),
      'حسابات خاصة': const Color(0xFF6366F1),
    };

    final categoryColor =
        categoryColors[account.category] ?? const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [categoryColor, categoryColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              account.accountNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        title: Text(
          account.accountName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    account.category ?? 'غير محدد',
                    style: TextStyle(
                      fontSize: 11,
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (account.canUse)
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                if (!account.canDelete)
                  const Icon(Icons.lock, size: 16, color: Colors.orange),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _editAccount(account),
              color: const Color(0xFF3B82F6),
              tooltip: 'تعديل',
            ),
            if (account.canDelete)
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                onPressed: () => _deleteAccount(account.id!),
                color: const Color(0xFFEF4444),
                tooltip: 'حذف',
              ),
          ],
        ),
      ),
    );
  }
}
