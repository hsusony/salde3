import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouses_provider.dart';
import '../../models/warehouse.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({Key? key}) : super(key: key);

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WarehousesProvider>().loadWarehouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
                : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSearchBar(isDark),
                    Expanded(child: _buildWarehousesList(isDark)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWarehouseDialog(null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة مخزن جديد'),
        backgroundColor: const Color(0xFF56AB2F),
        elevation: 8,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: isDark ? Colors.white : const Color(0xFF1565C0),
            iconSize: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة المخازن',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0D47A1),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'إضافة وتعديل المخازن',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF1976D2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.warehouse_rounded,
              size: 32,
              color: isDark ? Colors.white : const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'البحث عن مخزن...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildWarehousesList(bool isDark) {
    return Consumer<WarehousesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : const Color(0xFF56AB2F),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل المخازن...',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.warehouses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warehouse_rounded,
                    size: 80,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'لا توجد مخازن',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على الزر أدناه لإضافة مخزن جديد',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Filter warehouses
        final filteredWarehouses = provider.warehouses.where((warehouse) {
          final searchLower = _searchQuery.toLowerCase();
          return warehouse.name.toLowerCase().contains(searchLower) ||
              warehouse.location.toLowerCase().contains(searchLower) ||
              (warehouse.manager?.toLowerCase().contains(searchLower) ?? false);
        }).toList();

        if (filteredWarehouses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 60,
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد نتائج للبحث',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: filteredWarehouses.length,
          itemBuilder: (context, index) {
            final warehouse = filteredWarehouses[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: _buildWarehouseCard(warehouse, isDark),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWarehouseCard(Warehouse warehouse, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF56AB2F).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.warehouse_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warehouse.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          warehouse.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (warehouse.manager != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          warehouse.manager!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  color: const Color(0xFF667EEA),
                  onPressed: () => _showWarehouseDialog(warehouse),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 20),
                  color: const Color(0xFFEB3349),
                  onPressed: () => _deleteWarehouse(warehouse.id!),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWarehouseDialog(Warehouse? warehouse) {
    final nameController = TextEditingController(text: warehouse?.name ?? '');
    final locationController =
        TextEditingController(text: warehouse?.location ?? '');
    final descriptionController =
        TextEditingController(text: warehouse?.description ?? '');
    final managerController =
        TextEditingController(text: warehouse?.manager ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
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
                        Icons.warehouse_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      warehouse == null ? 'إضافة مخزن جديد' : 'تعديل المخزن',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: 'اسم المخزن',
                        icon: Icons.warehouse_rounded,
                        isDark: isDark,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: locationController,
                        label: 'الموقع',
                        icon: Icons.location_on_rounded,
                        isDark: isDark,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: managerController,
                        label: 'المسؤول',
                        icon: Icons.person_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: descriptionController,
                        label: 'الوصف',
                        icon: Icons.description_rounded,
                        isDark: isDark,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              locationController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء ملء الحقول المطلوبة'),
                                backgroundColor: Color(0xFFEB3349),
                              ),
                            );
                            return;
                          }

                          // Show loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF56AB2F)),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'جاري الحفظ...',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          final newWarehouse = Warehouse(
                            id: warehouse?.id,
                            name: nameController.text,
                            location: locationController.text,
                            description: descriptionController.text.isEmpty
                                ? null
                                : descriptionController.text,
                            manager: managerController.text.isEmpty
                                ? null
                                : managerController.text,
                          );

                          bool success;
                          try {
                            if (warehouse == null) {
                              success = await context
                                  .read<WarehousesProvider>()
                                  .addWarehouse(newWarehouse);
                            } else {
                              success = await context
                                  .read<WarehousesProvider>()
                                  .updateWarehouse(newWarehouse);
                            }
                          } catch (e) {
                            success = false;
                          }

                          // Close loading dialog
                          if (mounted) Navigator.pop(context);

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(warehouse == null
                                    ? 'تم إضافة المخزن بنجاح ✓'
                                    : 'تم تحديث المخزن بنجاح ✓'),
                                backgroundColor: const Color(0xFF56AB2F),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '⚠️ فشل الحفظ - تأكد من تشغيل خادم PHP'),
                                backgroundColor: Color(0xFFEB3349),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF56AB2F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'حفظ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool required = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _deleteWarehouse(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEB3349).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFEB3349),
                    size: 48,
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'هل أنت متأكد من حذف هذا المخزن؟\nلا يمكن التراجع عن هذا الإجراء',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await context
                              .read<WarehousesProvider>()
                              .deleteWarehouse(id);
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم حذف المخزن بنجاح ✓'),
                                backgroundColor: Color(0xFF56AB2F),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB3349),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'حذف',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }
}
