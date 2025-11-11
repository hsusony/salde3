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

class _ProductFormDialogState extends State<ProductFormDialog>
    with SingleTickerProviderStateMixin {
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
  late TextEditingController _cartonBarcodeController;
  late TextEditingController _cartonPurchasePriceController;
  late TextEditingController _cartonSellingPriceController;
  late TextEditingController _packagingCountController;
  late TextEditingController _packagingQuantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountPercentController;
  late TextEditingController _taxBuyController;
  late TextEditingController _taxSellController;
  late TextEditingController _specificationsController;
  late TextEditingController _sourceController;
  late TextEditingController _unitNumberController;
  late TextEditingController _locationController;
  late TextEditingController _minLimitController;
  late TextEditingController _serialNumberController;
  late TextEditingController _noteController;
  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedWarehouse;
  String _materialType = 'اعتيادية';
  String _packagingType = 'كارتونة';
  bool _showInPos = false;
  bool _isPacked = false;
  bool _sellByWeight = false;
  bool _isUsed = false;
  bool _exemptFromTax = false;
  Uint8List? _imageBytes;
  List<String> _additionalBarcodes = [];
  double _profitMargin = 0.0;
  double _cartonProfitMargin = 0.0;

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
    _tabController = TabController(length: 5, vsync: this);

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
    _cartonBarcodeController = TextEditingController(text: '');
    _cartonPurchasePriceController = TextEditingController(text: '');
    _cartonSellingPriceController = TextEditingController(text: '');
    _packagingCountController = TextEditingController(text: '');
    _packagingQuantityController = TextEditingController(text: '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _discountPercentController = TextEditingController(text: '');
    _taxBuyController = TextEditingController(text: '');
    _taxSellController = TextEditingController(text: '');
    _specificationsController = TextEditingController(text: '');
    _sourceController = TextEditingController(text: '');
    _unitNumberController = TextEditingController(text: '');
    _locationController = TextEditingController(text: '');
    _minLimitController = TextEditingController(text: '');
    _serialNumberController = TextEditingController(text: '');
    _noteController = TextEditingController(text: '');
    _additionalBarcodes = widget.product?.additionalBarcodes != null
        ? List<String>.from(widget.product!.additionalBarcodes!)
        : [];

    _calculateProfitMargin();
    _calculateCartonProfitMargin();

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
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return timestamp.substring(timestamp.length - 13);
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
        allowMultiple: false,
        withData: true,
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
    _cartonBarcodeController.dispose();
    _cartonPurchasePriceController.dispose();
    _cartonSellingPriceController.dispose();
    _packagingCountController.dispose();
    _packagingQuantityController.dispose();
    _descriptionController.dispose();
    _discountPercentController.dispose();
    _taxBuyController.dispose();
    _taxSellController.dispose();
    _specificationsController.dispose();
    _sourceController.dispose();
    _unitNumberController.dispose();
    _locationController.dispose();
    _minLimitController.dispose();
    _serialNumberController.dispose();
    _noteController.dispose();
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: ThemeProvider.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: ThemeProvider.primaryColor,
                indicatorWeight: 3,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14),
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline), text: 'عام'),
                  Tab(icon: Icon(Icons.discount_outlined), text: 'الخصومات'),
                  Tab(icon: Icon(Icons.more_horiz), text: 'بيانات إضافية'),
                  Tab(icon: Icon(Icons.history), text: 'حركة المادة'),
                  Tab(icon: Icon(Icons.update), text: 'تاريخ التعديلات'),
                ],
              ),
            ),

            // Form with Tabs
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
                    _buildModificationHistoryTab(),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
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

  // ===================== القسم الأول: عام =====================
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : widget.product?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                widget.product!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_outlined,
                                      size: 60, color: Colors.grey.shade400);
                                },
                              ),
                            )
                          : Icon(Icons.image_outlined,
                              size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(
                      _imageBytes != null || widget.product?.imageUrl != null
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

          // اسم المنتج والباركود
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
                          _barcodeController.text = _generateBarcode();
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
                  const Text('باركودات إضافية',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
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
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {
                                    setState(() {
                                      _additionalBarcodes
                                          .add(controller.text.trim());
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
                        deleteIcon: const Icon(Icons.close, size: 18),
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

          // الفئة
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة *',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
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
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: ThemeProvider.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    _showAddCategoryDialog();
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  tooltip: 'إضافة فئة جديدة',
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // المخزن (للسلع والمعبئة فقط)
          if (_materialType != 'خدمية')
            Consumer<WarehousesProvider>(
              builder: (context, warehousesProvider, child) {
                final warehouses = warehousesProvider.activeWarehouses;
                return DropdownButtonFormField<String>(
                  value: _selectedWarehouse,
                  decoration: const InputDecoration(
                    labelText: 'المخزن *',
                    prefixIcon: Icon(Icons.warehouse_rounded),
                  ),
                  items: warehouses.map((warehouse) {
                    return DropdownMenuItem(
                        value: warehouse.name, child: Text(warehouse.name));
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
                const Text('نوع المادة',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                          items: ['كارتونة', 'مرتبة', 'مترية'].map((type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
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
                  TextFormField(
                    controller: _cartonBarcodeController,
                    decoration: const InputDecoration(
                      labelText: 'باركود الكارتونة',
                      prefixIcon: Icon(Icons.qr_code_2_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'أدخل باركود الكارتونة',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // الأسعار الأساسية
          const Text(
            'الأسعار',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _purchasePriceController,
                  decoration: InputDecoration(
                    labelText: _materialType == 'خدمية'
                        ? 'سعر التكلفة *'
                        : 'سعر الشراء *',
                    prefixIcon: const Icon(Icons.shopping_cart_rounded),
                    suffixText: 'د.ع',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
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
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
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
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // نسبة الربح
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
                  color:
                      _profitMargin > 0 ? Colors.green[300]! : Colors.red[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _profitMargin > 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color:
                        _profitMargin > 0 ? Colors.green[700] : Colors.red[700],
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
                              color: Colors.grey[700]),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الربح لكل وحدة',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
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
          if (_profitMargin != 0) const SizedBox(height: 16),

          // الكمية والمخزون (للسلع والمعبئة فقط)
          if (_materialType != 'خدمية') ...[
            const Divider(height: 32),
            const Text(
              'إدارة المخزون',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية *',
                      prefixIcon: Icon(Icons.inventory_rounded),
                      hintText: 'الكمية الحالية',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      hintText: 'تنبيه عند النقص',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else ...[
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
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
          ],

          // الملاحظات
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'الملاحظات',
              prefixIcon: Icon(Icons.notes_rounded),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ===================== القسم الثاني: الخصومات =====================
  Widget _buildDiscountsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أسعار الكارتونة (إذا كانت معبئة)
          if (_materialType == 'معبئة') ...[
            const Text(
              'أسعار الكارتونة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بتحديد أسعار شراء وبيع الكارتونة',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cartonPurchasePriceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر شراء الكارتونة',
                      prefixIcon: Icon(Icons.shopping_cart_rounded),
                      suffixText: 'د.ع',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cartonSellingPriceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر بيع الكارتونة',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      suffixText: 'د.ع',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
              ],
            ),
            if (_cartonProfitMargin != 0.0)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _cartonProfitMargin > 0
                          ? [Colors.green[50]!, Colors.green[100]!]
                          : [Colors.red[50]!, Colors.red[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _cartonProfitMargin >= 0
                          ? Colors.green[300]!
                          : Colors.red[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _cartonProfitMargin >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: _cartonProfitMargin >= 0
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
                              'نسبة ربح الكارتونة',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_cartonProfitMargin.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _cartonProfitMargin >= 0
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
                            Text('الربح لكل كارتونة',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600])),
                            Text(
                              '${(double.tryParse(_cartonSellingPriceController.text) ?? 0) - (double.tryParse(_cartonPurchasePriceController.text) ?? 0)} د.ع',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _cartonProfitMargin >= 0
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
              ),

            const SizedBox(height: 32),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // خصومات وضرائب للمواد المعبئة
            const Text(
              'الخصومات والضرائب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // خصم نسبة ثابتة من السعر
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _discountPercentController,
                    decoration: const InputDecoration(
                      labelText: 'خصم نسبة ثابتة من السعر',
                      prefixIcon: Icon(Icons.percent_rounded),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.percent, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ضريبة البيع والشراء
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxBuyController,
                    decoration: InputDecoration(
                      labelText: 'ضريبة الشراء',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      suffixIcon: Icon(
                        Icons.arrow_downward,
                        color: Colors.red[400],
                        size: 20,
                      ),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _taxSellController,
                    decoration: InputDecoration(
                      labelText: 'ضريبة البيع',
                      prefixIcon: const Icon(Icons.sell_outlined),
                      suffixIcon: Icon(
                        Icons.arrow_upward,
                        color: Colors.green[400],
                        size: 20,
                      ),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // معفاة من الضريبة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: _exemptFromTax
                          ? ThemeProvider.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'معفاة من الضريبة',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                value: _exemptFromTax,
                onChanged: (value) {
                  setState(() {
                    _exemptFromTax = value!;
                    if (_exemptFromTax) {
                      _taxBuyController.clear();
                      _taxSellController.clear();
                    }
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: ThemeProvider.primaryColor,
              ),
            ),
          ] else ...[
            // حقول الخصومات والضرائب للمواد غير المعبئة
            const Text(
              'الخصومات والضرائب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // خصم نسبة ثابتة من السعر
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _discountPercentController,
                    decoration: const InputDecoration(
                      labelText: 'خصم نسبة ثابتة من السعر',
                      prefixIcon: Icon(Icons.percent_rounded),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.percent, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ضريبة البيع والشراء
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxBuyController,
                    decoration: InputDecoration(
                      labelText: 'ضريبة الشراء',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      suffixIcon: Icon(
                        Icons.arrow_downward,
                        color: Colors.red[400],
                        size: 20,
                      ),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _taxSellController,
                    decoration: InputDecoration(
                      labelText: 'ضريبة البيع',
                      prefixIcon: const Icon(Icons.sell_outlined),
                      suffixIcon: Icon(
                        Icons.arrow_upward,
                        color: Colors.green[400],
                        size: 20,
                      ),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // معفاة من الضريبة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: _exemptFromTax
                          ? ThemeProvider.primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'معفاة من الضريبة',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                value: _exemptFromTax,
                onChanged: (value) {
                  setState(() {
                    _exemptFromTax = value!;
                    if (_exemptFromTax) {
                      _taxBuyController.clear();
                      _taxSellController.clear();
                    }
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: ThemeProvider.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===================== القسم الثالث: بيانات إضافية =====================
  Widget _buildAdditionalDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خيارات ومعلومات إضافية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

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
                const Text('خيارات المنتج',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildCheckboxOption('إظهار في المس', _showInPos,
                        Icons.point_of_sale_rounded, (value) {
                      setState(() {
                        _showInPos = value!;
                      });
                    }),
                    _buildCheckboxOption('مفضلة', _isPacked, Icons.star_rounded,
                        (value) {
                      setState(() {
                        _isPacked = value!;
                      });
                    }),
                    if (_materialType != 'خدمية')
                      _buildCheckboxOption('منع السحب بالسالب', _sellByWeight,
                          Icons.block_rounded, (value) {
                        setState(() {
                          _sellByWeight = value!;
                        });
                      }),
                    _buildCheckboxOption(
                        'غير متاحة', _isUsed, Icons.cancel_outlined, (value) {
                      setState(() {
                        _isUsed = value!;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // الحقول الإضافية
          const Text(
            'معلومات تفصيلية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // المواصفات
          TextFormField(
            controller: _specificationsController,
            decoration: const InputDecoration(
              labelText: 'المواصفات',
              prefixIcon: Icon(Icons.description_outlined),
              hintText: 'أدخل المواصفات',
            ),
          ),
          const SizedBox(height: 16),

          // المصدر
          TextFormField(
            controller: _sourceController,
            decoration: const InputDecoration(
              labelText: 'المصدر',
              prefixIcon: Icon(Icons.business_outlined),
              hintText: 'أدخل المصدر',
            ),
          ),
          const SizedBox(height: 16),

          // رقم الوحدة
          TextFormField(
            controller: _unitNumberController,
            decoration: const InputDecoration(
              labelText: 'رقم الوحدة',
              prefixIcon: Icon(Icons.numbers),
              hintText: 'أدخل رقم الوحدة',
            ),
          ),
          const SizedBox(height: 16),

          // الموقع
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'الموقع',
              prefixIcon: Icon(Icons.location_on_outlined),
              hintText: 'أدخل الموقع',
            ),
          ),
          const SizedBox(height: 16),

          // الحد الأدنى
          TextFormField(
            controller: _minLimitController,
            decoration: const InputDecoration(
              labelText: 'الحد الأدنى',
              prefixIcon: Icon(Icons.vertical_align_bottom),
              hintText: '0',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
          ),
          const SizedBox(height: 16),

          // تسلسل العادة
          TextFormField(
            controller: _serialNumberController,
            decoration: const InputDecoration(
              labelText: 'تسلسل العادة',
              prefixIcon: Icon(Icons.format_list_numbered),
              hintText: 'أدخل التسلسل',
            ),
          ),
          const SizedBox(height: 16),

          // الملاحظة (حقل كبير متعدد الأسطر)
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'الملاحظة',
              prefixIcon: Icon(Icons.note_outlined),
              alignLabelWithHint: true,
              hintText: 'أدخل الملاحظات',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===================== القسم الرابع: حركة المادة =====================
  Widget _buildHistoryTab() {
    final isEdit = widget.product != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'حركة المادة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (isEdit)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add new movement
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة حركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (isEdit) ...[
            // جدول حركة المادة
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTableHeader('رقم الفاتورة', flex: 2),
                        _buildTableHeader('الموظف', flex: 2),
                        _buildTableHeader('نوع الحركة', flex: 2),
                        _buildTableHeader('مختصر الحركة', flex: 2),
                        _buildTableHeader('السعر', flex: 1),
                        _buildTableHeader('العدد', flex: 1),
                        _buildTableHeader('الرصيد', flex: 1),
                        _buildTableHeader('حركة القطع', flex: 2),
                        _buildTableHeader('التاريخ القطعي', flex: 2),
                        _buildTableHeader('التفاصيل', flex: 1),
                      ],
                    ),
                  ),
                  // Body - رسالة لا توجد حركات
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد حركات لهذه المادة',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // رسالة للمنتج الجديد
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'منتج جديد',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم تسجيل الحركات بعد حفظ المنتج',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: ThemeProvider.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ===================== القسم الخامس: تاريخ التعديلات =====================
  Widget _buildModificationHistoryTab() {
    final isEdit = widget.product != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'تاريخ التعديلات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // أزرار التحديث والطباعة والتصدير
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: تحديث البيانات
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('تحديث'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeProvider.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: طباعة
                    },
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('طباعة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: تصدير
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('تصدير'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isEdit) ...[
            // جدول تاريخ التعديلات
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildModificationTableHeader('اسم المادة', flex: 3),
                        _buildModificationTableHeader('سعر الشراء', flex: 2),
                        _buildModificationTableHeader('سعر البيع', flex: 2),
                        _buildModificationTableHeader('تاريخ التعديل', flex: 2),
                        _buildModificationTableHeader('اسم الموظف', flex: 2),
                      ],
                    ),
                  ),
                  // Body - رسالة لا توجد تعديلات
                  Container(
                    padding: const EdgeInsets.all(50),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history_outlined,
                              size: 70, color: Colors.grey[400]),
                          const SizedBox(height: 20),
                          Text(
                            'لا توجد تعديلات لهذه المادة',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سيتم تسجيل التعديلات تلقائياً عند تحديث بيانات المنتج',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
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

            // خيارات إضافية
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تصفية حسب الفترة',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'محدد بفترة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: 'period',
                          groupValue: 'period',
                          onChanged: (value) {},
                          activeColor: ThemeProvider.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.analytics_outlined,
                            color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'كل الحركات',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'عرض جميع التعديلات',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.check_circle,
                            color: Colors.green[700], size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // رسالة للمنتج الجديد
            Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.update_outlined,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      'منتج جديد',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'سيتم تسجيل تاريخ التعديلات تلقائياً بعد حفظ المنتج',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModificationTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: ThemeProvider.primaryColor,
        ),
        textAlign: TextAlign.center,
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
    if (!_formKey.currentState!.validate()) {
      // الانتقال إلى التاب الذي يحتوي على خطأ
      if (_nameController.text.isEmpty ||
          _barcodeController.text.isEmpty ||
          _selectedCategory == null) {
        _tabController.animateTo(0); // التاب الأول
      } else if (_purchasePriceController.text.isEmpty ||
          _sellingPriceController.text.isEmpty) {
        _tabController.animateTo(1); // التاب الثاني
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.product?.imageUrl;
      if (_imageBytes != null) {
        imageUrl = 'local_image_${DateTime.now().millisecondsSinceEpoch}';
      }

      final purchasePrice =
          double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
      final sellingPrice =
          double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
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
        wholesalePrice: _wholesalePriceController.text.isNotEmpty
            ? double.tryParse(_wholesalePriceController.text.trim())
            : null,
        quantity: quantity,
        minQuantity: minQuantity,
        cartonQuantity: _cartonQuantityController.text.isNotEmpty
            ? int.parse(_cartonQuantityController.text)
            : null,
        cartonPurchasePrice: _cartonPurchasePriceController.text.isNotEmpty
            ? double.tryParse(_cartonPurchasePriceController.text.trim())
            : null,
        cartonSellingPrice: _cartonSellingPriceController.text.isNotEmpty
            ? double.tryParse(_cartonSellingPriceController.text.trim())
            : null,
        discountPercent: _discountPercentController.text.isNotEmpty
            ? double.tryParse(_discountPercentController.text.trim())
            : null,
        taxBuy: _taxBuyController.text.isNotEmpty
            ? double.tryParse(_taxBuyController.text.trim())
            : null,
        taxSell: _taxSellController.text.isNotEmpty
            ? double.tryParse(_taxSellController.text.trim())
            : null,
        exemptFromTax: _exemptFromTax,
        specifications: _specificationsController.text.trim().isEmpty
            ? null
            : _specificationsController.text.trim(),
        source: _sourceController.text.trim().isEmpty
            ? null
            : _sourceController.text.trim(),
        unitNumber: _unitNumberController.text.trim().isEmpty
            ? null
            : _unitNumberController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        minLimit: _minLimitController.text.isNotEmpty
            ? double.tryParse(_minLimitController.text.trim())
            : null,
        serialNumber: _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
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

      await provider.loadProducts();

      if (mounted) {
        Navigator.pop(context, true);
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

  // دالة عرض نافذة إضافة فئة جديدة
  void _showAddCategoryDialog() {
    final categoryNameController = TextEditingController();
    final categoryCodeController = TextEditingController();
    final categoryDescriptionController = TextEditingController();
    final categoryNotesController = TextEditingController();
    final categoryParentController = TextEditingController();
    final categorySortOrderController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) {
        bool isActive = true;
        bool showInReports = true;
        bool allowDiscount = true;
        String selectedColor = 'blue';
        String selectedIcon = 'category';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 500,
                constraints: const BoxConstraints(maxHeight: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeProvider.primaryColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
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
                                  'إضافة فئة جديدة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'قم بتعبئة المعلومات أدناه',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اسم الفئة
                            TextField(
                              controller: categoryNameController,
                              decoration: InputDecoration(
                                labelText: 'اسم الفئة *',
                                hintText: 'مثال: إلكترونيات، ملابس، أغذية',
                                prefixIcon: const Icon(Icons.label_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),

                            // كود الفئة
                            TextField(
                              controller: categoryCodeController,
                              decoration: InputDecoration(
                                labelText: 'كود الفئة (اختياري)',
                                hintText: 'مثال: CAT001, ELEC, FOOD',
                                prefixIcon: const Icon(Icons.tag_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),

                            // الفئة الأساسية
                            TextField(
                              controller: categoryParentController,
                              decoration: InputDecoration(
                                labelText: 'الفئة الأساسية (اختياري)',
                                hintText: 'مثال: فئة رئيسية أو قسم',
                                prefixIcon: const Icon(Icons.folder_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),

                            // الوصف
                            TextField(
                              controller: categoryDescriptionController,
                              decoration: InputDecoration(
                                labelText: 'الوصف (اختياري)',
                                hintText: 'وصف مختصر عن الفئة',
                                prefixIcon:
                                    const Icon(Icons.description_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),

                            // اختيار اللون
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.palette_outlined, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'لون الفئة',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[50],
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _buildColorOption('blue', Colors.blue, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('green', Colors.green, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('red', Colors.red, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('orange', Colors.orange, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('purple', Colors.purple, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('teal', Colors.teal, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('pink', Colors.pink, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                      _buildColorOption('amber', Colors.amber, selectedColor, (color) {
                                        setDialogState(() {
                                          selectedColor = color;
                                        });
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // اختيار الأيقونة
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.emoji_symbols_outlined, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'أيقونة الفئة',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[50],
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _buildIconOption('category', Icons.category_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('electronics', Icons.electrical_services_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('food', Icons.restaurant_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('clothing', Icons.checkroom_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('sports', Icons.sports_soccer_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('books', Icons.menu_book_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('tools', Icons.construction_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                      _buildIconOption('beauty', Icons.face_rounded, selectedIcon, (icon) {
                                        setDialogState(() {
                                          selectedIcon = icon;
                                        });
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ترتيب الفئة
                            TextField(
                              controller: categorySortOrderController,
                              decoration: InputDecoration(
                                labelText: 'ترتيب العرض',
                                hintText: '0',
                                prefixIcon: const Icon(Icons.sort_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                helperText: 'الترتيب في القائمة (الأصغر أولاً)',
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),

                            // ملاحظات
                            TextField(
                              controller: categoryNotesController,
                              decoration: InputDecoration(
                                labelText: 'ملاحظات إضافية (اختياري)',
                                hintText: 'أي معلومات إضافية',
                                prefixIcon: const Icon(Icons.note_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                alignLabelWithHint: true,
                              ),
                              maxLines: 2,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 20),

                            // خيارات متقدمة
                            Text(
                              'الإعدادات المتقدمة',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // الحالة
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.toggle_on_rounded,
                                    color: isActive
                                        ? ThemeProvider.primaryColor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تفعيل الفئة',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'السماح باستخدام هذه الفئة',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isActive,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        isActive = value;
                                      });
                                    },
                                    activeColor: ThemeProvider.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // إظهار في التقارير
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.assessment_rounded,
                                    color: showInReports
                                        ? ThemeProvider.primaryColor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'إظهار في التقارير',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'عرض إحصائيات هذه الفئة في التقارير',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: showInReports,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        showInReports = value;
                                      });
                                    },
                                    activeColor: ThemeProvider.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // السماح بالخصم
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer_rounded,
                                    color: allowDiscount
                                        ? ThemeProvider.primaryColor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'السماح بالخصم',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'إمكانية تطبيق خصومات على منتجات هذه الفئة',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: allowDiscount,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        allowDiscount = value;
                                      });
                                    },
                                    activeColor: ThemeProvider.primaryColor,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ملاحظة
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'سيتم إضافة الفئة مباشرة لقائمة الفئات المتاحة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[900],
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

                    // Footer Buttons
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
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('إلغاء'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (categoryNameController.text
                                  .trim()
                                  .isNotEmpty) {
                                final categoryData = {
                                  'name': categoryNameController.text.trim(),
                                  'code': categoryCodeController.text.trim(),
                                  'parent': categoryParentController.text.trim(),
                                  'description':
                                      categoryDescriptionController.text.trim(),
                                  'notes': categoryNotesController.text.trim(),
                                  'sortOrder': categorySortOrderController.text.trim(),
                                  'color': selectedColor,
                                  'icon': selectedIcon,
                                  'isActive': isActive,
                                  'showInReports': showInReports,
                                  'allowDiscount': allowDiscount,
                                };
                                Navigator.pop(context, categoryData);
                              }
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('حفظ وإضافة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeProvider.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
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
          },
        );
      },
    ).then((categoryData) {
      if (categoryData != null && categoryData['name'].isNotEmpty) {
        final newCategory = categoryData['name'];
        setState(() {
          // التحقق من عدم وجود الفئة مسبقاً
          if (!_categories.contains(newCategory)) {
            _categories.add(newCategory);
            _selectedCategory = newCategory;

            // عرض رسالة نجاح مع التفاصيل
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('تم إضافة الفئة "$newCategory" بنجاح',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (categoryData['code'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 36),
                        child: Text(
                          'الكود: ${categoryData['code']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                backgroundColor: ThemeProvider.successColor,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // إذا كانت الفئة موجودة، اختيارها فقط
            _selectedCategory = newCategory;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('الفئة "$newCategory" موجودة بالفعل'),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    });
  }

  // دالة بناء خيار اللون
  Widget _buildColorOption(String colorName, Color color, String selectedColor,
      Function(String) onSelect) {
    final isSelected = selectedColor == colorName;
    return GestureDetector(
      onTap: () => onSelect(colorName),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
            : null,
      ),
    );
  }

  // دالة بناء خيار الأيقونة
  Widget _buildIconOption(String iconName, IconData icon, String selectedIcon,
      Function(String) onSelect) {
    final isSelected = selectedIcon == iconName;
    return GestureDetector(
      onTap: () => onSelect(iconName),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? ThemeProvider.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? ThemeProvider.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[700],
          size: 28,
        ),
      ),
    );
  }
}
