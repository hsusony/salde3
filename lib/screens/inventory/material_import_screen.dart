import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'dart:io';
import '../../providers/inventory_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/inventory_transaction.dart';
import '../../models/product.dart';

class MaterialImportScreen extends StatefulWidget {
  const MaterialImportScreen({Key? key}) : super(key: key);

  @override
  State<MaterialImportScreen> createState() => _MaterialImportScreenState();
}

class _ImportedMaterial {
  String name;
  String barcode;
  double quantity;
  double unitCost;
  String? unit;
  String? notes;
  bool hasError;
  String? errorMessage;

  _ImportedMaterial({
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.unitCost,
    this.unit,
    this.notes,
    this.hasError = false,
    this.errorMessage,
  });
}

class _MaterialImportScreenState extends State<MaterialImportScreen> {
  final List<_ImportedMaterial> _importedMaterials = [];
  final TextEditingController _warehouseController =
      TextEditingController(text: 'المخزن 1');
  final TextEditingController _supplierController = TextEditingController();
  bool _isLoading = false;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InventoryProvider>()
          .loadTransactions(type: InventoryTransactionType.import);
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('استيراد المواد'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.file_upload,
                          color: Color(0xFF10B981),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'استيراد من Excel',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fileName ?? 'لم يتم اختيار ملف',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickExcelFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('اختيار ملف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_importedMaterials.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _warehouseController,
                            decoration: InputDecoration(
                              labelText: 'المخزن',
                              prefixIcon: const Icon(Icons.warehouse),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.grey[50],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _supplierController,
                            decoration: InputDecoration(
                              labelText: 'المورد (اختياري)',
                              prefixIcon: const Icon(Icons.business),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.grey[50],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _importedMaterials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 100,
                                color:
                                    isDark ? Colors.white24 : Colors.grey[300],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'اختر ملف Excel لاستيراد المواد',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'يجب أن يحتوي الملف على: الاسم، الباركود، الكمية، سعر الوحدة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              OutlinedButton.icon(
                                onPressed: _downloadTemplate,
                                icon: const Icon(Icons.download),
                                label: const Text('تحميل نموذج Excel'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6366F1),
                                  side: const BorderSide(
                                      color: Color(0xFF6366F1)),
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
                        )
                      : Column(
                          children: [
                            // Summary Cards
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'إجمالي المواد',
                                      '${_importedMaterials.length}',
                                      Icons.inventory_2,
                                      const Color(0xFF6366F1),
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'أخطاء',
                                      '${_importedMaterials.where((m) => m.hasError).length}',
                                      Icons.error,
                                      Colors.red,
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'التكلفة الإجمالية',
                                      '${_getTotalCost().toStringAsFixed(0)} د.ع',
                                      Icons.attach_money,
                                      const Color(0xFF10B981),
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Data Table
                            Expanded(
                              child: Card(
                                margin:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                elevation: 4,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                              width: 50,
                                              child: Text('#',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          const Expanded(
                                              flex: 2,
                                              child: Text('اسم المادة',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          const Expanded(
                                              child: Text('الباركود',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          const Expanded(
                                              child: Text('الكمية',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center)),
                                          const Expanded(
                                              child: Text('سعر الوحدة',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center)),
                                          const Expanded(
                                              child: Text('الإجمالي',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center)),
                                          const SizedBox(
                                              width: 60,
                                              child: Text('حالة',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center)),
                                        ],
                                      ),
                                    ),

                                    // Table Body
                                    Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _importedMaterials.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final material =
                                              _importedMaterials[index];
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration: BoxDecoration(
                                              color: material.hasError
                                                  ? Colors.red.withOpacity(0.05)
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    material.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: material.hasError
                                                          ? Colors.red
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    material.barcode,
                                                    style: TextStyle(
                                                      fontFamily: 'monospace',
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    material.quantity
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '${material.unitCost.toStringAsFixed(0)} د.ع',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '${(material.quantity * material.unitCost).toStringAsFixed(0)} د.ع',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  child: material.hasError
                                                      ? Tooltip(
                                                          message: material
                                                                  .errorMessage ??
                                                              'خطأ',
                                                          child: const Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                        )
                                                      : const Icon(
                                                          Icons.check_circle,
                                                          color:
                                                              Color(0xFF10B981),
                                                          size: 20,
                                                        ),
                                                ),
                                              ],
                                            ),
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
            ),

            // Bottom Actions
            if (_importedMaterials.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _importedMaterials.clear();
                            _fileName = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('مسح'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _importedMaterials.any((m) => m.hasError)
                            ? null
                            : _saveImportedMaterials,
                        icon: const Icon(Icons.save, size: 24),
                        label: const Text(
                          'حفظ واستيراد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
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

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _getTotalCost() {
    return _importedMaterials.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.unitCost),
    );
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
          _fileName = result.files.single.name;
        });

        await _parseExcelFile(result.files.single.path!);

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في قراءة الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _parseExcelFile(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = excel_pkg.Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) throw Exception('الملف فارغ');

      _importedMaterials.clear();

      // Skip header row (index 0)
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        if (row.isEmpty || row.every((cell) => cell?.value == null)) continue;

        try {
          final name = row[0]?.value?.toString() ?? '';
          final barcode = row[1]?.value?.toString() ?? '';
          final quantity =
              double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0;
          final unitCost =
              double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0;
          final unit = row.length > 4 ? row[4]?.value?.toString() : null;
          final notes = row.length > 5 ? row[5]?.value?.toString() : null;

          bool hasError = false;
          String? errorMessage;

          if (name.isEmpty) {
            hasError = true;
            errorMessage = 'اسم المادة مطلوب';
          } else if (barcode.isEmpty) {
            hasError = true;
            errorMessage = 'الباركود مطلوب';
          } else if (quantity <= 0) {
            hasError = true;
            errorMessage = 'الكمية يجب أن تكون أكبر من صفر';
          } else if (unitCost < 0) {
            hasError = true;
            errorMessage = 'سعر الوحدة غير صحيح';
          }

          _importedMaterials.add(_ImportedMaterial(
            name: name,
            barcode: barcode,
            quantity: quantity,
            unitCost: unitCost,
            unit: unit,
            notes: notes,
            hasError: hasError,
            errorMessage: errorMessage,
          ));
        } catch (e) {
          _importedMaterials.add(_ImportedMaterial(
            name: 'خطأ في الصف ${i + 1}',
            barcode: '',
            quantity: 0,
            unitCost: 0,
            hasError: true,
            errorMessage: e.toString(),
          ));
        }
      }
    } catch (e) {
      throw Exception('خطأ في معالجة الملف: $e');
    }
  }

  void _downloadTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تحميل نموذج Excel قريباً'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  Future<void> _saveImportedMaterials() async {
    if (_warehouseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال اسم المخزن'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productsProvider = context.read<ProductsProvider>();

      // Add products if they don't exist
      for (var material in _importedMaterials) {
        if (!material.hasError) {
          // Check if product exists
          final existingProduct = productsProvider.products
              .where((p) => p.barcode == material.barcode)
              .firstOrNull;

          if (existingProduct == null) {
            // Create new product
            await productsProvider.addProduct(Product(
              name: material.name,
              barcode: material.barcode,
              category: 'مواد مستوردة',
              purchasePrice: material.unitCost,
              sellingPrice: material.unitCost * 1.2, // 20% markup
              quantity: material.quantity.toInt(),
            ));
          }
        }
      }

      setState(() {
        _isLoading = false;
        _importedMaterials.clear();
        _fileName = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('تم استيراد المواد بنجاح'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _warehouseController.dispose();
    _supplierController.dispose();
    super.dispose();
  }
}
