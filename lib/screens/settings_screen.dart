import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reports/currency_report_screen.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  final List<_SettingSection> _sections = [
    _SettingSection(
      title: 'المستخدمين',
      icon: Icons.people_rounded,
      color: const Color(0xFF6366F1),
    ),
    _SettingSection(
      title: 'العملات',
      icon: Icons.currency_exchange_rounded,
      color: const Color(0xFF10B981),
    ),
    _SettingSection(
      title: 'تغيير كلمة المرور',
      icon: Icons.lock_reset_rounded,
      color: const Color(0xFFEF4444),
    ),
    _SettingSection(
      title: 'صلاحيات المستخدمين',
      icon: Icons.admin_panel_settings_rounded,
      color: const Color(0xFF8B5CF6),
    ),
    _SettingSection(
      title: 'إعدادات النظام',
      icon: Icons.settings_rounded,
      color: const Color(0xFF3B82F6),
    ),
    _SettingSection(
      title: 'إعدادات التقارير',
      icon: Icons.assessment_rounded,
      color: const Color(0xFF06B6D4),
    ),
    _SettingSection(
      title: 'نسخ قاعدة البيانات',
      icon: Icons.backup_rounded,
      color: const Color(0xFFF59E0B),
    ),
    _SettingSection(
      title: 'إعدادات الطابعات',
      icon: Icons.print_rounded,
      color: const Color(0xFF64748B),
    ),
    _SettingSection(
      title: 'الألوان',
      icon: Icons.palette_rounded,
      color: const Color(0xFFEC4899),
    ),
    _SettingSection(
      title: 'الاختصارات',
      icon: Icons.keyboard_rounded,
      color: const Color(0xFF14B8A6),
    ),
    _SettingSection(
      title: 'خدمات المربع الإضافية',
      icon: Icons.extension_rounded,
      color: const Color(0xFF84CC16),
    ),
    _SettingSection(
      title: 'إعدادات POS',
      icon: Icons.point_of_sale_rounded,
      color: const Color(0xFFF97316),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      body: Column(
        children: [
          // Modern Header
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Title
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإعدادات',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'إدارة إعدادات النظام والتخصيصات',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
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

          // Content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                Container(
                  width: 280,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _sections.length,
                          itemBuilder: (context, index) {
                            final section = _sections[index];
                            final isSelected = _selectedIndex == index;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? section.color.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? section.color
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? section.color
                                                : section.color
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            section.icon,
                                            size: 20,
                                            color: isSelected
                                                ? Colors.white
                                                : section.color,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            section.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? section.color
                                                  : (isDark
                                                      ? Colors.white70
                                                      : Colors.grey[700]),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.chevron_left_rounded,
                                            color: section.color,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Container(
                    color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _UsersSettings();
      case 1:
        return _CurrencySettings();
      case 2:
        return _PasswordSettings();
      case 3:
        return _PermissionsSettings();
      case 4:
        return _SystemSettings();
      case 5:
        return _ReportsSettings();
      case 6:
        return _BackupSettings();
      case 7:
        return _PrinterSettings();
      case 8:
        return _ColorSettings();
      case 9:
        return _ShortcutsSettings();
      case 10:
        return _ExtensionsSettings();
      case 11:
        return _POSSettings();
      default:
        return const Center(child: Text('قريباً...'));
    }
  }
}

class _SettingSection {
  final String title;
  final IconData icon;
  final Color color;

  _SettingSection({
    required this.title,
    required this.icon,
    required this.color,
  });
}

// ==================== المستخدمين ====================
class _UsersSettings extends StatefulWidget {
  @override
  State<_UsersSettings> createState() => _UsersSettingsState();
}

class _UsersSettingsState extends State<_UsersSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loginNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _loginNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Left Panel - User Form
        Expanded(
          flex: 2,
          child: Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'المستخدمين',
                      icon: Icons.people_rounded,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 30),

                    // User Image
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6366F1),
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload_rounded),
                            label: const Text('رفع الصورة'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name Field
                    const Text(
                      'الاسم',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم المستخدم',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Phone Field
                    const Text(
                      'رقم الهاتف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'أدخل رقم الهاتف',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Name Field
                    const Text(
                      'اسم الدخول',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _loginNameController,
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم الدخول',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    const Text(
                      'كلمة المرور',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'أدخل كلمة المرور',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        suffixIcon: const Icon(Icons.lock_rounded),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Save user
                              }
                            },
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('حفظ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _nameController.clear();
                              _phoneController.clear();
                              _loginNameController.clear();
                              _passwordController.clear();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('جديد'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.delete_rounded),
                            label: const Text('حذف'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFEF4444),
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

        // Right Panel - Users List
        Expanded(
          flex: 3,
          child: Container(
            color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.list_rounded,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'قائمة المستخدمين',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '1 مستخدم نشط',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Users Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 60, child: Text('الصورة')),
                                SizedBox(width: 20),
                                Expanded(flex: 2, child: Text('الاسم')),
                                Expanded(flex: 2, child: Text('رقم الهاتف')),
                                Expanded(flex: 2, child: Text('اسم الدخول')),
                                SizedBox(width: 100, child: Text('الحالة')),
                                SizedBox(width: 120, child: Text('الإجراءات')),
                              ],
                            ),
                          ),

                          // Sample User Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : Colors.grey[200]!,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF6366F1),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text(''),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text('admin'),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Color(0xFF10B981),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'نشط',
                                          style: TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.edit_rounded),
                                        color: const Color(0xFF3B82F6),
                                        tooltip: 'تعديل',
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.delete_rounded),
                                        color: const Color(0xFFEF4444),
                                        tooltip: 'حذف',
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== العملات ====================
class _CurrencySettings extends StatefulWidget {
  @override
  State<_CurrencySettings> createState() => _CurrencySettingsState();
}

class _CurrencySettingsState extends State<_CurrencySettings> {
  final _formKey = GlobalKey<FormState>();
  final _currencyNameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _lowestPriceController = TextEditingController();
  final _highestPriceController = TextEditingController();
  final _exchangeRateController = TextEditingController(text: '1,450');

  @override
  void dispose() {
    _currencyNameController.dispose();
    _symbolController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _lowestPriceController.dispose();
    _highestPriceController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Right Panel - Currency Form
        Expanded(
          flex: 2,
          child: Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'العملات',
                      icon: Icons.currency_exchange_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 30),

                    // Currency Name
                    const Text(
                      'اسم العملة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currencyNameController,
                      decoration: InputDecoration(
                        hintText: 'مثال: دينار، دولار',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Symbol
                    const Text(
                      'سعر الصنف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _symbolController,
                      decoration: InputDecoration(
                        hintText: 'د.ع، \$',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buy Price
                    const Text(
                      'سعر البيع',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _buyPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sell Price
                    const Text(
                      'سعر الشراء',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _sellPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lowest Price
                    const Text(
                      'اقل سعر',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lowestPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Highest Price (with translation)
                    const Text(
                      'اعلى ـ سعر',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _highestPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // اقفا ، سعره
                    const Text(
                      'اقفا ، سعره',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Exchange Rate (سعر)
                    const Text(
                      'سعر',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _exchangeRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Save currency
                              }
                            },
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('حفظ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

        // Left Panel - Currencies List
        Expanded(
          flex: 3,
          child: Container(
            color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
            child: Column(
              children: [
                // Header with Edit/Delete buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.currency_exchange_rounded,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'العملات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CurrencyReportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assessment_rounded, size: 18),
                        label: const Text('تقارير العملات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('الاضافات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Currencies Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 80, child: Text('حذف')),
                                SizedBox(width: 20),
                                SizedBox(width: 100, child: Text('عملة ا...')),
                                SizedBox(width: 20),
                                Expanded(child: Text('رمز...')),
                                Expanded(child: Text('اقص... ـ')),
                                Expanded(child: Text('اقل سعر')),
                                Expanded(child: Text('سعر البيع')),
                                Expanded(child: Text('سعر الص...')),
                                Expanded(child: Text('العملة')),
                              ],
                            ),
                          ),

                          // Sample Row - Dinar
                          _buildCurrencyRow(
                            isDark: isDark,
                            currency: 'دينار',
                            symbol: 'د.ع',
                            lowestPrice: '1',
                            highestPrice: '0',
                            sellPrice: '0',
                            buyPrice: '0',
                            exchangeRate: '0',
                            isMain: true,
                          ),

                          // Sample Row - Dollar
                          _buildCurrencyRow(
                            isDark: isDark,
                            currency: 'دولار',
                            symbol: '\$',
                            lowestPrice: '1,200',
                            highestPrice: '0',
                            sellPrice: '0',
                            buyPrice: '0',
                            exchangeRate: '0',
                            isMain: false,
                          ),
                        ],
                      ),
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

  Widget _buildCurrencyRow({
    required bool isDark,
    required String currency,
    required String symbol,
    required String lowestPrice,
    required String highestPrice,
    required String sellPrice,
    required String buyPrice,
    required String exchangeRate,
    required bool isMain,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          // Delete Button
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFFEF4444),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                if (isMain)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  )
                else
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : Colors.grey[400]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Currency Name
          SizedBox(
            width: 100,
            child: Text(
              currency,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 20),
          // Symbol
          Expanded(child: Text(symbol)),
          // Lowest Price
          Expanded(child: Text(lowestPrice)),
          // Highest Price
          Expanded(child: Text(highestPrice)),
          // Sell Price
          Expanded(child: Text(sellPrice)),
          // Buy Price
          Expanded(child: Text(buyPrice)),
          // Exchange Rate
          Expanded(child: Text(exchangeRate)),
        ],
      ),
    );
  }
}

// ==================== تغيير كلمة المرور ====================
class _PasswordSettings extends StatefulWidget {
  @override
  State<_PasswordSettings> createState() => _PasswordSettingsState();
}

class _PasswordSettingsState extends State<_PasswordSettings> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: '1');
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
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
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'تغيير كلمة المرور',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      const Text(
                        'اسم المستخدم',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Old Password
                      const Text(
                        'كلمة المرور القديمة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: _obscureOld,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureOld = !_obscureOld;
                              });
                            },
                            icon: Icon(
                              _obscureOld
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور القديمة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // New Password
                      const Text(
                        'كلمة المرور الجديدة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureNew = !_obscureNew;
                              });
                            },
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور الجديدة';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Confirm Password
                      const Text(
                        'تأكيد كلمة المرور الجديدة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء تأكيد كلمة المرور';
                          }
                          if (value != _newPasswordController.text) {
                            return 'كلمة المرور غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.lock_rounded),
                              label: const Text('إلغاء'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    isDark ? Colors.white70 : Colors.grey[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Save password
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('تم تغيير كلمة المرور بنجاح'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('تغيير'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}

// ==================== الصلاحيات ====================
class _PermissionsSettings extends StatefulWidget {
  @override
  State<_PermissionsSettings> createState() => _PermissionsSettingsState();
}

class _PermissionsSettingsState extends State<_PermissionsSettings> {
  String? _selectedUser;
  final List<String> _users = ['المستخدم 1', 'المستخدم 2', 'Admin'];

  // Permissions Map
  final Map<String, bool> _permissions = {
    'الرئيسية': false,
    'قائمة البيع': false,
    'نقطة بيع': false,
    'عروض سعر': false,
    'طلب معلق': false,
    'التقرير': false,
    'المخزون': false,
    'اضافة منتج': false,
    'إدارة فئات': false,
    'قائمة المشتريات': false,
    'إضافة مشترية': false,
    'الموردين': false,
    'التقارير الرقابية': false,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header with User Selection and Buttons
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // User Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[300]!,
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedUser,
                  hint: const Text('المستخدم'),
                  underline: const SizedBox(),
                  items: _users.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text(user),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value;
                    });
                  },
                ),
              ),
              const Spacer(),
              // Buttons
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('صلاحيات المستخدمين'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('فتح دفتر العل'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('عبول الجلسات'),
              ),
            ],
          ),
        ),

        // Permissions Grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'صلاحيات المستخدمين',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'نوع',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'الصلاحية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Permissions List
                      ..._permissions.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : Colors.grey[200]!,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Checkbox(
                                  value: entry.value,
                                  onChanged: (value) {
                                    setState(() {
                                      _permissions[entry.key] = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== إعدادات النظام ====================
class _SystemSettings extends StatefulWidget {
  @override
  State<_SystemSettings> createState() => _SystemSettingsState();
}

class _SystemSettingsState extends State<_SystemSettings> {
  bool _allowHistoryDates = false;
  bool _useDefaultLogin = false;
  bool _printSlogan = false;
  int _decimalAfterPrice = 2;
  int _decimalAfterQuantity = 2;
  bool _showDeletedAccounts = false;
  bool _allowNegativeBox = true;
  String _backupLocation = 'D:\\';
  bool _autoBackupImages = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Left Panel - Form
        Expanded(
          flex: 2,
          child: Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'إعدادات النظام',
                    icon: Icons.settings_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 30),

                  // Company Info Section
                  const Text(
                    'اسم الشركة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email/Gmail
                  const Text(
                    'البريد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Gmail'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Password
                  const Text(
                    'كلمة المرور',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone
                  const Text(
                    'الهاتف',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // City
                  const Text(
                    'المدينة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Activity
                  const Text(
                    'النشاط',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Installation Type
                  const Text(
                    'نتيب كتسيف',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'افتراضي',
                        child: Text('افتراضي'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),

                  // Code
                  const Text(
                    'الرقم',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chat Type
                  const Text(
                    'فئة الدخول',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'مسقفة',
                        child: Text('مسقفة'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right Panel - Settings Checkboxes
        Expanded(
          flex: 1,
          child: Container(
            color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkboxes
                  CheckboxListTile(
                    title: const Text('السماح بتغيير التاريخ في السندات'),
                    value: _allowHistoryDates,
                    onChanged: (value) {
                      setState(() {
                        _allowHistoryDates = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                  CheckboxListTile(
                    title: const Text('استخدام واجهة الدخول الإعتيادية'),
                    value: _useDefaultLogin,
                    onChanged: (value) {
                      setState(() {
                        _useDefaultLogin = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                  CheckboxListTile(
                    title: const Text('طباعة الشعار'),
                    value: _printSlogan,
                    onChanged: (value) {
                      setState(() {
                        _printSlogan = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'الأرقام بعد الفاصلة للسعار',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _decimalAfterPrice.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _decimalAfterPrice.toString(),
                    onChanged: (value) {
                      setState(() {
                        _decimalAfterPrice = value.toInt();
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                  Text('${_decimalAfterPrice}'),

                  const SizedBox(height: 20),
                  const Text(
                    'الأرقام بعد الفاصلة للأعداد',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _decimalAfterQuantity.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _decimalAfterQuantity.toString(),
                    onChanged: (value) {
                      setState(() {
                        _decimalAfterQuantity = value.toInt();
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                  Text('${_decimalAfterQuantity}'),

                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('إظهار الحسابات المحذوفة في التقارير'),
                    value: _showDeletedAccounts,
                    onChanged: (value) {
                      setState(() {
                        _showDeletedAccounts = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                  CheckboxListTile(
                    title: const Text('السماح لرصيد الصندوق بالسالب'),
                    value: _allowNegativeBox,
                    onChanged: (value) {
                      setState(() {
                        _allowNegativeBox = value ?? true;
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'موقع الخزن الاحتياطي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _backupLocation,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.folder_rounded),
                        color: const Color(0xFF3B82F6),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('النسخ الاحتياطي لبيانات صور المواد'),
                    value: _autoBackupImages,
                    onChanged: (value) {
                      setState(() {
                        _autoBackupImages = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('تصدير'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('تصدير'),
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
    );
  }
}

// ==================== إعدادات التقارير ====================
class _ReportsSettings extends StatefulWidget {
  @override
  State<_ReportsSettings> createState() => _ReportsSettingsState();
}

class _ReportsSettingsState extends State<_ReportsSettings> {
  // Report Checkboxes
  final Map<String, bool> _reports = {
    'اوجبة الحسابات': false,
    'كشف حساب': false,
    'كشف حساب...': false,
    'كشف المبيعات...': false,
    'كشف المبيعات...2': false,
    'كشف المشتر...': false,
    'عرض المواد': false,
    'الحسابات العا...': false,
    'فاتورة البيع': false,
    'كشف الأقساط': false,
    'فاتورة شراء': false,
    'حركة مادة': false,
    'الموردع': false,
    'ا رصدة اعملاث': false,
    'تقرير سعر الو...': false,
    'ا ريام وخسائر': false,
    'انواع الحقيقة': false,
    'المواد الاقل ب...': false,
    'سعر البيع الاق...': false,
    'رصيد المادة ن...': false,
    'ملاحية المواد...': false,
    'سواد الحد الادنى': false,
    'استرد المواد': false,
    'استرد الدخيصا...': false,
    'كشف نقهوات...': false,
    'تقرير الاريام...': false,
    'تقرير الاريام...2': false,
    'العواد الرانية': false,
    'نقل بين المخازن': false,
    'محتريات المواد': false,
    'عملية المواد': false,
    'سندة الاقساط': false,
    'طباعة بحاري': false,
    'قامحة بيع صغنص': false,
    'تقرير البيعات': false,
    'تقرير تجد ...': false,
    'تقرير وعديل...': false,
    'تعقيل ار صدة...': false,
  };

  // Settings Checkboxes
  bool _showCompanyLogo = false;
  bool _showCompanyInfo = false;
  bool _showBarcode = false;
  bool _showDate = false;
  bool _showMainReports = false;
  bool _showSubReports = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Right Panel - Reports List
        Expanded(
          flex: 2,
          child: Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assessment_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'التقارير',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF06B6D4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('تطبيق'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('حفظ'),
                      ),
                    ],
                  ),
                ),

                // Reports Grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _reports.entries.map((entry) {
                        return SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 13),
                            ),
                            value: entry.value,
                            onChanged: (value) {
                              setState(() {
                                _reports[entry.key] = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF06B6D4),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Left Panel - Settings
        Expanded(
          flex: 1,
          child: Container(
            color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkboxes
                  CheckboxListTile(
                    title: const Text('الشركة'),
                    value: _showCompanyLogo,
                    onChanged: (value) {
                      setState(() {
                        _showCompanyLogo = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF06B6D4),
                  ),
                  CheckboxListTile(
                    title: const Text('الاعلان'),
                    value: _showCompanyInfo,
                    onChanged: (value) {
                      setState(() {
                        _showCompanyInfo = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF06B6D4),
                  ),
                  CheckboxListTile(
                    title: const Text('الرخيص'),
                    value: _showBarcode,
                    onChanged: (value) {
                      setState(() {
                        _showBarcode = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF06B6D4),
                  ),
                  CheckboxListTile(
                    title: const Text('الرئيسية'),
                    value: _showMainReports,
                    onChanged: (value) {
                      setState(() {
                        _showMainReports = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF06B6D4),
                  ),
                  CheckboxListTile(
                    title: const Text('الفرعية'),
                    value: _showSubReports,
                    onChanged: (value) {
                      setState(() {
                        _showSubReports = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF06B6D4),
                  ),
                  CheckboxListTile(
                    title: const Text('الاموال'),
                    value: _showDate,
                    onChanged: (value) {
                      setState(() {
                        _showDate = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF06B6D4),
                  ),

                  const SizedBox(height: 30),

                  // Preview Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF06B6D4),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Company Logo/Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'شركة در الكمال',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'لبيع الفايلون الزراعي والمشمع الجبال وشباك صيد الأسماك ومستلزماتها',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'جاد عمل : 07706837991 - 07803868433',
                                style: TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'جاد مفعل : 07714415444 - 07714415444',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Table Headers
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'اكعدة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ةر احساب',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'دنتر',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Footer buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('اغلاق',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF06B6D4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('طبع',
                                    style: TextStyle(fontSize: 12)),
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
        ),
      ],
    );
  }
}

// ==================== النسخ الاحتياطي ====================
class _BackupSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'نسخ قاعدة البيانات',
            icon: Icons.backup_rounded,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 20),
          _SettingCard(
            child: Column(
              children: [
                _SettingTile(
                  title: 'نسخ احتياطي يدوي',
                  subtitle: 'إنشاء نسخة احتياطية الآن',
                  icon: Icons.backup_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingTile(
                  title: 'استعادة نسخة احتياطية',
                  subtitle: 'استعادة من نسخة سابقة',
                  icon: Icons.restore_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SwitchTile(
                  title: 'النسخ الاحتياطي التلقائي',
                  subtitle: 'نسخ احتياطي يومي في الساعة 12:00 AM',
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(height: 1),
                _SettingTile(
                  title: 'مسار حفظ النسخ',
                  subtitle: 'C:\\Backups\\SalesSystem',
                  icon: Icons.folder_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== الطابعات ====================
class _PrinterSettings extends StatefulWidget {
  @override
  State<_PrinterSettings> createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends State<_PrinterSettings> {
  final List<Map<String, dynamic>> _printers = [
    {
      'name': 'Microsoft Print to PDF',
      'driver': 'DASTPRN.GMPT',
      'status': 'Unknown',
      'isDefault': true,
      'isInstalled': true,
      'canTest': true,
    },
  ];

  void _setDefault(int index) {
    setState(() {
      for (var i = 0; i < _printers.length; i++) {
        _printers[i]['isDefault'] = i == index;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تعيين ${_printers[index]['name']} كطابعة افتراضية'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _uninstallPrinter(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: Text('هل تريد إلغاء تثبيت ${_printers[index]['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _printers.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء تثبيت الطابعة'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('اسم الطابعة', flex: 3),
                _buildHeaderCell('اختبار الطباعة', flex: 2),
                _buildHeaderCell('الموقع السائق', flex: 2),
                _buildHeaderCell('الافتراضية', flex: 1),
                _buildHeaderCell('الغاء التثبيت', flex: 1),
                _buildHeaderCell('حالة التطبيقة', flex: 1),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _printers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_disabled_rounded,
                          size: 80,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد طابعات مثبتة',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _printers.length,
                    itemBuilder: (context, index) {
                      final printer = _printers[index];
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF0F172A) : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // اسم الطابعة
                            _buildDataCell(
                              printer['name'],
                              flex: 3,
                              isDark: isDark,
                            ),
                            // اختبار الطباعة
                            _buildDataCell(
                              printer['status'],
                              flex: 2,
                              isDark: isDark,
                            ),
                            // الموقع السائق
                            _buildDataCell(
                              printer['driver'],
                              flex: 2,
                              isDark: isDark,
                            ),
                            // الافتراضية
                            _buildIconCell(
                              icon: printer['isDefault']
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: printer['isDefault']
                                  ? Colors.green
                                  : (isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!),
                              flex: 1,
                              onTap: () => _setDefault(index),
                            ),
                            // الغاء التثبيت
                            _buildIconCell(
                              icon: Icons.cancel,
                              color: Colors.red,
                              flex: 1,
                              onTap: () => _uninstallPrinter(index),
                            ),
                            // حالة التطبيقة
                            _buildIconCell(
                              icon: printer['isInstalled']
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: printer['isInstalled']
                                  ? Colors.green
                                  : Colors.red,
                              flex: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {int flex = 1, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildIconCell({
    required IconData icon,
    required Color color,
    int flex = 1,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        child: InkWell(
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ==================== الألوان ====================
class _ColorSettings extends StatefulWidget {
  @override
  State<_ColorSettings> createState() => _ColorSettingsState();
}

class _ColorSettingsState extends State<_ColorSettings> {
  String _selectedColor = 'أسود';
  String _selectedFont = 'AGA Arabesque';
  int _fontSize = 10;
  int _headerSize = 10;
  bool _mainPageButtons = false;
  bool _salePagePrice = false;

  final List<String> _colors = [
    'أسود',
    'أزرق',
    'أحمر',
    'أزرق غامق',
    'سماوي',
    'أحمر فاتح',
    'بنفسجي',
    'أخضر',
  ];

  final List<Map<String, dynamic>> _fonts = [
    {'name': 'عادي', 'icon': Icons.text_fields},
    {'name': 'غامق', 'icon': Icons.format_bold},
    {'name': 'مائل', 'icon': Icons.format_italic},
    {'name': 'تحته خط', 'icon': Icons.format_underlined},
    {'name': 'يتوسطه خط', 'icon': Icons.strikethrough_s},
  ];

  Color _getColorFromName(String name) {
    switch (name) {
      case 'أسود':
        return Colors.black;
      case 'أزرق':
        return const Color(0xFF6366F1);
      case 'أحمر':
        return const Color(0xFFEF4444);
      case 'أزرق غامق':
        return const Color(0xFF1E40AF);
      case 'سماوي':
        return const Color(0xFF06B6D4);
      case 'أحمر فاتح':
        return const Color(0xFFEC4899);
      case 'بنفسجي':
        return const Color(0xFF8B5CF6);
      case 'أخضر':
        return const Color(0xFF10B981);
      default:
        return Colors.black;
    }
  }

  void _applyColorSettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final selectedColor = _getColorFromName(_selectedColor);

    // تطبيق اللون
    themeProvider.setPrimaryColor(selectedColor);

    // تطبيق حجم الخط
    themeProvider.setFontSize(_fontSize.toDouble());

    // تطبيق نوع الخط
    themeProvider.setFontFamily(_selectedFont);

    // إعادة بناء الواجهة
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '✅ تم تطبيق الإعدادات بنجاح!\n'
                '🎨 اللون: $_selectedColor\n'
                '📝 الخط: $_selectedFont\n'
                '📏 الحجم: $_fontSize',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor:
            selectedColor == Colors.black ? Colors.grey[800] : selectedColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Color Selection Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // الاسم (Color Dropdown)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // معاينة اللون
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getColorFromName(_selectedColor),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isDark ? Colors.grey[600]! : Colors.grey[400]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getColorFromName(_selectedColor)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedColor,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _colors.map((color) {
                              return DropdownMenuItem(
                                value: color,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      color,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: _getColorFromName(color),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _getColorFromName(color),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedColor = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'الاسم',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // نوع الخط
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedFont,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              'AGA Arabesque',
                              'Arial',
                              'Times New Roman',
                              'Tahoma',
                            ].map((font) {
                              return DropdownMenuItem(
                                value: font,
                                child: Text(font, textAlign: TextAlign.right),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFont = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'نوع الخط',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // حجم الخط
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: TextEditingController(text: '$_fontSize'),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _fontSize = int.tryParse(value) ?? 10;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'حجم الخط',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // حجم خط الواجهة البيع
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller:
                              TextEditingController(text: '$_headerSize'),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _headerSize = int.tryParse(value) ?? 10;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'حجم خط الواجهة البيع',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Checkboxes
                  CheckboxListTile(
                    value: _mainPageButtons,
                    onChanged: (value) {
                      setState(() {
                        _mainPageButtons = value!;
                      });
                    },
                    title: const Text(
                      'توسعه عدد الازرار في الواجهة الرئيسية',
                      textAlign: TextAlign.right,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  CheckboxListTile(
                    value: _salePagePrice,
                    onChanged: (value) {
                      setState(() {
                        _salePagePrice = value!;
                      });
                    },
                    title: const Text(
                      'استخدام نفس نوع الخط في واجهة البيع',
                      textAlign: TextAlign.right,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 24),

                  // Font Style Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _fonts.map((font) {
                      return ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم تطبيق ${font['name']}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(font['name']),
                            const SizedBox(width: 8),
                            Icon(font['icon'], size: 20),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _applyColorSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'حفظ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
}

// ==================== الاختصارات ====================
class _ShortcutsSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'اختصارات لوحة المفاتيح',
            icon: Icons.keyboard_rounded,
            color: const Color(0xFF14B8A6),
          ),
          const SizedBox(height: 20),
          _SettingCard(
            child: Column(
              children: [
                _ShortcutTile(
                  action: 'فاتورة جديدة',
                  shortcut: 'F2',
                ),
                const Divider(height: 1),
                _ShortcutTile(
                  action: 'بحث عن منتج',
                  shortcut: 'Ctrl + F',
                ),
                const Divider(height: 1),
                _ShortcutTile(
                  action: 'حفظ',
                  shortcut: 'Ctrl + S',
                ),
                const Divider(height: 1),
                _ShortcutTile(
                  action: 'طباعة',
                  shortcut: 'Ctrl + P',
                ),
                const Divider(height: 1),
                _ShortcutTile(
                  action: 'إلغاء',
                  shortcut: 'Esc',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== الخدمات الإضافية ====================
class _ExtensionsSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'خدمات المربع الإضافية',
            icon: Icons.extension_rounded,
            color: const Color(0xFF84CC16),
          ),
          const SizedBox(height: 20),
          _SettingCard(
            child: Column(
              children: [
                _SwitchTile(
                  title: 'خدمة الرسائل النصية',
                  subtitle: 'إرسال رسائل للعملاء',
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(height: 1),
                _SwitchTile(
                  title: 'البريد الإلكتروني',
                  subtitle: 'إرسال الفواتير عبر البريد',
                  value: false,
                  onChanged: (v) {},
                ),
                const Divider(height: 1),
                _SwitchTile(
                  title: 'المزامنة السحابية',
                  subtitle: 'مزامنة البيانات مع السحابة',
                  value: false,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== إعدادات POS ====================
class _POSSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'إعدادات نقطة البيع (POS)',
            icon: Icons.point_of_sale_rounded,
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 20),
          _SettingCard(
            child: Column(
              children: [
                _SwitchTile(
                  title: 'فتح درج النقد تلقائياً',
                  subtitle: 'فتح الدرج عند إتمام البيع',
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(height: 1),
                _SwitchTile(
                  title: 'عرض الماسح الضوئي',
                  subtitle: 'تفعيل قارئ الباركود',
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(height: 1),
                _SettingTile(
                  title: 'نوع الفاتورة',
                  subtitle: 'حراري 80 ملم',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SwitchTile(
                  title: 'عرض الصور في POS',
                  subtitle: 'إظهار صور المنتجات',
                  value: true,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Components ====================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: trailing ?? const Icon(Icons.chevron_left_rounded),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String name;

  const _ColorOption({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String action;
  final String shortcut;

  const _ShortcutTile({
    required this.action,
    required this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(action),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF14B8A6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF14B8A6),
            width: 1,
          ),
        ),
        child: Text(
          shortcut,
          style: const TextStyle(
            color: Color(0xFF14B8A6),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
