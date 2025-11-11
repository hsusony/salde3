import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../providers/warehouses_provider.dart';
import '../providers/theme_provider.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _wholesalePriceController;
  late TextEditingController _quantityController;
  late TextEditingController _minQuantityController;
  late TextEditingController _cartonQuantityController;
  late TextEditingController _cartonBarcodeController; // باركود الكارتونة
  late TextEditingController
      _cartonPurchasePriceController; // سعر شراء الكارتونة
  late TextEditingController _cartonSellingPriceController; // سعر بيع الكارتونة
  late TextEditingController _packagingCountController;
  late TextEditingController _packagingQuantityController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedWarehouse;
  String _materialType = 'اعتيادية'; // اعتيادية، معبئة، أو خدمية
  String _packagingType = 'كارتونة';
  bool _showInPos = false;
  bool _isPacked = false;
  bool _sellByWeight = false;
  bool _isUsed = false;
  Uint8List? _imageBytes;
  List<String> _additionalBarcodes = [];
  double _profitMargin = 0.0;
  double _cartonProfitMargin = 0.0; // نسبة ربح الكارتونة

  final List<String> _categories = [
    'إلكترونيات',
    'موبايلات',
    'حواسيب',
    'إكسسوارات',
    'أجهزة منزلية',
    'ملابس',
    'أغذية',
    'أدوات مكتبية',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // تحميل المخازن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WarehousesProvider>(context, listen: false).loadWarehouses();
    });

    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(
        text: widget.product?.barcode ?? _generateBarcode());
    final cat = widget.product?.category;
    _selectedCategory = (cat != null && cat.isNotEmpty) ? cat : null;
    _purchasePriceController = TextEditingController(
        text: widget.product?.purchasePrice.toString() ?? '');
    _sellingPriceController = TextEditingController(
        text: widget.product?.sellingPrice.toString() ?? '');
    _wholesalePriceController = TextEditingController(text: '');
    _quantityController =
        TextEditingController(text: widget.product?.quantity.toString() ?? '0');
    _minQuantityController = TextEditingController(
        text: widget.product?.minQuantity.toString() ?? '5');
    _cartonQuantityController = TextEditingController(
        text: widget.product?.cartonQuantity?.toString() ?? '');
    _cartonBarcodeController =
        TextEditingController(text: ''); // باركود الكارتونة
    _cartonPurchasePriceController =
        TextEditingController(text: ''); // سعر شراء الكارتونة
    _cartonSellingPriceController =
        TextEditingController(text: ''); // سعر بيع الكارتونة
    _packagingCountController = TextEditingController(text: '');
    _packagingQuantityController = TextEditingController(text: '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _additionalBarcodes = widget.product?.additionalBarcodes != null
        ? List<String>.from(widget.product!.additionalBarcodes!)
        : [];

    // حساب نسبة الربح عند التعديل
    _calculateProfitMargin();
    _calculateCartonProfitMargin();

    // إضافة listeners لحساب نسبة الربح تلقائياً
    _purchasePriceController.addListener(_calculateProfitMargin);
    _sellingPriceController.addListener(_calculateProfitMargin);
    _cartonPurchasePriceController.addListener(_calculateCartonProfitMargin);
    _cartonSellingPriceController.addListener(_calculateCartonProfitMargin);
  }

  void _calculateProfitMargin() {
    final purchase = double.tryParse(_purchasePriceController.text) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;

    if (purchase > 0) {
      setState(() {
        _profitMargin = ((selling - purchase) / purchase) * 100;
      });
    } else {
      setState(() {
        _profitMargin = 0.0;
      });
    }
  }

  void _calculateCartonProfitMargin() {
    final purchase = double.tryParse(_cartonPurchasePriceController.text) ?? 0;
    final selling = double.tryParse(_cartonSellingPriceController.text) ?? 0;

    if (purchase > 0) {
      setState(() {
        _cartonProfitMargin = ((selling - purchase) / purchase) * 100;
      });
    } else {
      setState(() {
        _cartonProfitMargin = 0.0;
      });
    }
  }

  String _generateBarcode() {
    // توليد باركود من 13 رقم (EAN-13 format)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return timestamp.substring(timestamp.length - 13);
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
        allowMultiple: false,
        withData: true, // مهم لـ Windows Desktop للحصول على البيانات
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _imageBytes = file.bytes;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحميل الصورة بنجاح'),
                backgroundColor: ThemeProvider.successColor,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لم يتم تحميل بيانات الصورة'),
                backgroundColor: ThemeProvider.errorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: $e'),
            backgroundColor: ThemeProvider.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _wholesalePriceController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _cartonQuantityController.dispose();
    _cartonBarcodeController.dispose(); // باركود الكارتونة
    _cartonPurchasePriceController.dispose(); // سعر شراء الكارتونة
    _cartonSellingPriceController.dispose(); // سعر بيع الكارتونة
    _packagingCountController.dispose();
    _packagingQuantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Dialog(
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: ThemeProvider.primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'تعديل المنتج' : 'إضافة منتج جديد',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: ThemeProvider.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: ThemeProvider.primaryColor,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.info_outline),
                    text: 'عام',
                  ),
                  Tab(
                    icon: Icon(Icons.discount_outlined),
                    text: 'الخصومات',
                  ),
                  Tab(
                    icon: Icon(Icons.more_horiz),
                    text: 'بيانات إضافية',
                  ),
                  Tab(
                    icon: Icon(Icons.history),
                    text: 'حركة المادة',
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(),
                    _buildDiscountsTab(),
                    _buildAdditionalDataTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'حفظ التعديلات' : 'إضافة المنتج'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
                      // صورة المنتج
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2),
                              ),
                              child: _imageBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : widget.product?.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Image.network(
                                            widget.product!.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(Icons.image_outlined,
                                                  size: 60,
                                                  color: Colors.grey.shade400);
                                            },
                                          ),
                                        )
                                      : Icon(Icons.image_outlined,
                                          size: 60,
                                          color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_rounded),
                              label: Text(_imageBytes != null ||
                                      widget.product?.imageUrl != null
                                  ? 'تغيير الصورة'
                                  : 'رفع صورة'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم المنتج *',
                                prefixIcon: Icon(Icons.label_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال اسم المنتج';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _barcodeController,
                              decoration: InputDecoration(
                                labelText: 'الباركود الرئيسي *',
                                prefixIcon: const Icon(Icons.qr_code_rounded),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.refresh_rounded),
                                  tooltip: 'توليد باركود جديد',
                                  onPressed: () {
                                    setState(() {
                                      _barcodeController.text =
                                          _generateBarcode();
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال الباركود';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // باركودات إضافية
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'باركودات إضافية',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final controller =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: const Text('إضافة باركود'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            labelText: 'الباركود',
                                            hintText: 'أدخل الباركود',
                                          ),
                                          autofocus: true,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (controller.text.isNotEmpty) {
                                                setState(() {
                                                  _additionalBarcodes.add(
                                                      controller.text.trim());
                                                });
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text('إضافة'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: const Text('إضافة باركود'),
                              ),
                            ],
                          ),
                          if (_additionalBarcodes.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _additionalBarcodes.map((barcode) {
                                  return Chip(
                                    label: Text(barcode),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setState(() {
                                        _additionalBarcodes.remove(barcode);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'الفئة *',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء اختيار الفئة';
                          }
                          return null;
                        },
                        hint: const Text('اختر الفئة'),
                      ),
                      const SizedBox(height: 16),

                      // اختيار المخزن (يظهر فقط للسلع والمعبئة)
                      if (_materialType != 'خدمية')
                        Consumer<WarehousesProvider>(
                          builder: (context, warehousesProvider, child) {
                            final warehouses =
                                warehousesProvider.activeWarehouses;

                            return DropdownButtonFormField<String>(
                              value: _selectedWarehouse,
                              decoration: const InputDecoration(
                                labelText: 'المخزن *',
                                prefixIcon: Icon(Icons.warehouse_rounded),
                              ),
                              items: warehouses.map((warehouse) {
                                return DropdownMenuItem(
                                  value: warehouse.name,
                                  child: Text(warehouse.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedWarehouse = value;
                                });
                              },
                              validator: (value) {
                                if (_materialType != 'خدمية' &&
                                    (value == null || value.isEmpty)) {
                                  return 'الرجاء اختيار المخزن';
                                }
                                return null;
                              },
                              hint: const Text('اختر المخزن'),
                            );
                          },
                        ),
                      if (_materialType != 'خدمية') const SizedBox(height: 16),

                      // حقول الأسعار (تظهر لجميع الأنواع)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _purchasePriceController,
                              decoration: InputDecoration(
                                labelText: _materialType == 'خدمية'
                                    ? 'سعر التكلفة *'
                                    : 'سعر الشراء *',
                                prefixIcon: Icon(Icons.shopping_cart_rounded),
                                suffixText: 'د.ع',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _materialType == 'خدمية'
                                      ? 'الرجاء إدخال سعر التكلفة'
                                      : 'الرجاء إدخال سعر الشراء';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'الرجاء إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sellingPriceController,
                              decoration: const InputDecoration(
                                labelText: 'سعر البيع *',
                                prefixIcon: Icon(Icons.attach_money_rounded),
                                suffixText: 'د.ع',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال سعر البيع';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'الرجاء إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _wholesalePriceController,
                              decoration: const InputDecoration(
                                labelText: 'البيع العام',
                                prefixIcon: Icon(Icons.storefront_rounded),
                                suffixText: 'د.ع',
                                hintText: 'سعر الجملة',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // عرض نسبة الربح
                      if (_profitMargin != 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _profitMargin > 0
                                  ? [Colors.green[50]!, Colors.green[100]!]
                                  : [Colors.red[50]!, Colors.red[100]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _profitMargin > 0
                                  ? Colors.green[300]!
                                  : Colors.red[300]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _profitMargin > 0
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: _profitMargin > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'نسبة الربح',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_profitMargin.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _profitMargin > 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الربح لكل وحدة',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${(double.tryParse(_sellingPriceController.text) ?? 0) - (double.tryParse(_purchasePriceController.text) ?? 0)} د.ع',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _profitMargin > 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // نوع المادة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'نوع المادة',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('اعتيادية'),
                                    value: 'اعتيادية',
                                    groupValue: _materialType,
                                    onChanged: (value) {
                                      setState(() {
                                        _materialType = value!;
                                      });
                                    },
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('معبئة'),
                                    value: 'معبئة',
                                    groupValue: _materialType,
                                    onChanged: (value) {
                                      setState(() {
                                        _materialType = value!;
                                      });
                                    },
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('خدمية'),
                                    value: 'خدمية',
                                    groupValue: _materialType,
                                    onChanged: (value) {
                                      setState(() {
                                        _materialType = value!;
                                      });
                                    },
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            if (_materialType == 'معبئة') ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _packagingType,
                                      decoration: const InputDecoration(
                                        labelText: 'نوع التعبئة',
                                        prefixIcon: Icon(Icons.widgets_rounded),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      hint: const Text('اختر نوع التعبئة'),
                                      items: ['كارتونة', 'مرتبة', 'مترية']
                                          .map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _packagingType = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _packagingCountController,
                                      decoration: const InputDecoration(
                                        labelText: 'عدد العبئة',
                                        prefixIcon: Icon(Icons.numbers_rounded),
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'عدد الوحدات',
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // باركود الكارتونة
                              TextFormField(
                                controller: _cartonBarcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'باركود الكارتونة',
                                  prefixIcon: Icon(Icons.qr_code_2_rounded),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'أدخل باركود الكارتونة',
                                ),
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 12),
                              // أسعار الكارتونة
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _cartonPurchasePriceController,
                                      decoration: const InputDecoration(
                                        labelText: 'سعر شراء الكارتونة',
                                        prefixIcon:
                                            Icon(Icons.shopping_cart_rounded),
                                        suffixText: 'د.ع',
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cartonSellingPriceController,
                                      decoration: const InputDecoration(
                                        labelText: 'سعر بيع الكارتونة',
                                        prefixIcon:
                                            Icon(Icons.attach_money_rounded),
                                        suffixText: 'د.ع',
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // نسبة ربح الكارتونة
                              if (_cartonProfitMargin != 0.0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _cartonProfitMargin >= 0
                                          ? ThemeProvider.successColor
                                              .withOpacity(0.1)
                                          : ThemeProvider.errorColor
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _cartonProfitMargin >= 0
                                            ? ThemeProvider.successColor
                                            : ThemeProvider.errorColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _cartonProfitMargin >= 0
                                              ? Icons.trending_up_rounded
                                              : Icons.trending_down_rounded,
                                          color: _cartonProfitMargin >= 0
                                              ? ThemeProvider.successColor
                                              : ThemeProvider.errorColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'نسبة ربح الكارتونة: ${_cartonProfitMargin.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: _cartonProfitMargin >= 0
                                                ? ThemeProvider.successColor
                                                : ThemeProvider.errorColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // الخيارات الأربعة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'خيارات إضافية',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildCheckboxOption(
                                  'إظهار في المس',
                                  _showInPos,
                                  Icons.point_of_sale_rounded,
                                  (value) {
                                    setState(() {
                                      _showInPos = value!;
                                    });
                                  },
                                ),
                                _buildCheckboxOption(
                                  'مفضلة',
                                  _isPacked,
                                  Icons.star_rounded,
                                  (value) {
                                    setState(() {
                                      _isPacked = value!;
                                    });
                                  },
                                ),
                                // إخفاء "منع السحب بالسالب" للخدمات
                                if (_materialType != 'خدمية')
                                  _buildCheckboxOption(
                                    'منع السحب بالسالب',
                                    _sellByWeight,
                                    Icons.block_rounded,
                                    (value) {
                                      setState(() {
                                        _sellByWeight = value!;
                                      });
                                    },
                                  ),
                                _buildCheckboxOption(
                                  'غير متاحة',
                                  _isUsed,
                                  Icons.cancel_outlined,
                                  (value) {
                                    setState(() {
                                      _isUsed = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // حقول الكمية والمخزون (تظهر فقط للسلع والمعبئة)
                      if (_materialType != 'خدمية')
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'الكمية *',
                                  prefixIcon: Icon(Icons.inventory_rounded),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (value) {
                                  if (_materialType != 'خدمية' &&
                                      (value == null || value.isEmpty)) {
                                    return 'الرجاء إدخال الكمية';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _minQuantityController,
                                decoration: const InputDecoration(
                                  labelText: 'الحد الأدنى للمخزون',
                                  prefixIcon: Icon(Icons.warning_rounded),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                          ],
                        ),

                      // رسالة توضيحية للخدمات
                      if (_materialType == 'خدمية')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'الخدمات لا تحتاج إلى إدارة مخزون',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          prefixIcon: Icon(Icons.description_rounded),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'حفظ التعديلات' : 'إضافة المنتج'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(
    String label,
    bool value,
    IconData icon,
    ValueChanged<bool?> onChanged,
  ) {
    return SizedBox(
      width: 200,
      child: CheckboxListTile(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: value ? ThemeProvider.primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: ThemeProvider.primaryColor,
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // في حالة رفع صورة جديدة، يمكن تحويلها إلى base64 أو رفعها لخادم
      String? imageUrl = widget.product?.imageUrl;
      if (_imageBytes != null) {
        // TODO: رفع الصورة إلى الخادم والحصول على الرابط
        // لحين الربط بالخادم، نستخدم data URL
        // imageUrl = 'data:image/png;base64,${base64Encode(_imageBytes!)}';
        imageUrl = 'local_image_${DateTime.now().millisecondsSinceEpoch}';
      }

      // التأكد من القيم قبل الإرسال
      final purchasePrice =
          double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
      final sellingPrice =
          double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;

      // للخدمات: الكمية = 0، للسلع والمعبئة: نأخذ من الحقل
      final quantity = _materialType == 'خدمية'
          ? 0
          : (int.tryParse(_quantityController.text.trim()) ?? 0);
      final minQuantity = _materialType == 'خدمية'
          ? 0
          : (int.tryParse(_minQuantityController.text.trim()) ?? 5);

      debugPrint('🔄 حفظ المنتج: ${_nameController.text.trim()}');
      debugPrint('   - نوع المادة: $_materialType');
      debugPrint('   - الباركود: ${_barcodeController.text.trim()}');
      debugPrint('   - سعر الشراء: $purchasePrice');
      debugPrint('   - سعر البيع: $sellingPrice');
      debugPrint('   - الكمية: $quantity');
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim(),
        additionalBarcodes:
            _additionalBarcodes.isNotEmpty ? _additionalBarcodes : null,
        category: _selectedCategory!,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
        minQuantity: minQuantity,
        cartonQuantity: _cartonQuantityController.text.isNotEmpty
            ? int.parse(_cartonQuantityController.text)
            : null,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: imageUrl,
        createdAt: widget.product?.createdAt,
      );

      final provider = Provider.of<ProductsProvider>(context, listen: false);
      if (widget.product == null) {
        debugPrint('📝 إضافة منتج جديد');
        await provider.addProduct(product);
      } else {
        debugPrint('✏️ تحديث منتج موجود - ID: ${product.id}');
        await provider.updateProduct(product);
      }

      // إعادة تحميل المنتجات للتأكد من التحديث
      await provider.loadProducts();

      if (mounted) {
        Navigator.pop(context, true); // إرجاع true للإشارة إلى النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.product == null
                    ? 'تم إضافة المنتج بنجاح'
                    : 'تم تحديث المنتج بنجاح'),
              ],
            ),
            backgroundColor: ThemeProvider.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ خطأ في حفظ المنتج: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('خطأ في الحفظ: $e')),
              ],
            ),
            backgroundColor: ThemeProvider.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
