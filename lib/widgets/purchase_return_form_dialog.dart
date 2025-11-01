import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/purchase_return.dart';
import '../models/product.dart';
import '../providers/purchases_provider.dart';
import '../providers/products_provider.dart';
import '../providers/theme_provider.dart';

class PurchaseReturnFormDialog extends StatefulWidget {
  final PurchaseReturn? purchaseReturn;

  const PurchaseReturnFormDialog({super.key, this.purchaseReturn});

  @override
  State<PurchaseReturnFormDialog> createState() =>
      _PurchaseReturnFormDialogState();
}

class _PurchaseReturnFormDialogState extends State<PurchaseReturnFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _supplierNameController;
  late TextEditingController _purchaseInvoiceController;
  late TextEditingController _reasonController;
  late TextEditingController _notesController;
  bool _isLoading = false;
  String _selectedReason = 'تالف';
  List<PurchaseReturnItem> _items = [];
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _supplierNameController =
        TextEditingController(text: widget.purchaseReturn?.supplierName ?? '');
    _purchaseInvoiceController = TextEditingController(
        text: widget.purchaseReturn?.purchaseInvoiceNumber ?? '');
    _reasonController =
        TextEditingController(text: widget.purchaseReturn?.reason ?? '');
    _notesController =
        TextEditingController(text: widget.purchaseReturn?.notes ?? '');

    if (widget.purchaseReturn != null) {
      _items = List.from(widget.purchaseReturn!.items);
      if (['تالف', 'غير مطابق', 'إلغاء طلب', 'أخرى']
              .contains(widget.purchaseReturn!.reason)) {
        _selectedReason = widget.purchaseReturn!.reason;
      }
    }
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _purchaseInvoiceController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _total {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.purchaseReturn != null;

    return Dialog(
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: ThemeProvider.errorColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_return_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'تعديل إرجاع شراء' : 'إضافة إرجاع شراء جديد',
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

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _supplierNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم المورد',
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _purchaseInvoiceController,
                              decoration: const InputDecoration(
                                labelText: 'رقم فاتورة الشراء (اختياري)',
                                prefixIcon: Icon(Icons.receipt_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedReason,
                        decoration: const InputDecoration(
                          labelText: 'سبب الإرجاع',
                          prefixIcon: Icon(Icons.info_rounded),
                        ),
                        items: ['تالف', 'غير مطابق', 'إلغاء طلب', 'أخرى']
                            .map((reason) {
                          return DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedReason = value;
                            });
                          }
                        },
                      ),

                      if (_selectedReason == 'أخرى') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            labelText: 'تفاصيل السبب',
                            prefixIcon: Icon(Icons.description_rounded),
                          ),
                          validator: (value) {
                            if (_selectedReason == 'أخرى' &&
                                (value == null || value.trim().isEmpty)) {
                              return 'يرجى إدخال تفاصيل السبب';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Products Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المنتجات المُرجعة',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: _addProduct,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('إضافة منتج'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeProvider.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'لم يتم إضافة أي منتجات للإرجاع بعد',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildProductItem(item, index);
                        }),

                      const SizedBox(height: 24),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: ThemeProvider.errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'إجمالي المبلغ المُرجع:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currencyFormat.format(_total),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات إضافية',
                          prefixIcon: Icon(Icons.note_rounded),
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
                    onPressed: _isLoading ? null : _saveReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.errorColor,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEdit ? 'حفظ التعديلات' : 'إضافة الإرجاع'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(PurchaseReturnItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الكمية المُرجعة: ${item.quantity} × ${_currencyFormat.format(item.unitPrice)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              _currencyFormat.format(item.totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ThemeProvider.errorColor,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _items.removeAt(index);
                });
              },
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => _ProductSelectDialog(
        onProductSelected: (product, quantity, price) {
          setState(() {
            _items.add(PurchaseReturnItem(
              productId: product.id!,
              productName: product.name,
              productBarcode: product.barcode,
              quantity: quantity,
              unitPrice: price,
              totalPrice: quantity * price,
            ));
          });
        },
      ),
    );
  }

  Future<void> _saveReturn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة منتج واحد على الأقل للإرجاع')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final purchaseReturn = PurchaseReturn(
        id: widget.purchaseReturn?.id,
        returnNumber: widget.purchaseReturn?.returnNumber ??
            'RET-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: widget.purchaseReturn?.createdAt ?? DateTime.now(),
        purchaseInvoiceNumber: _purchaseInvoiceController.text.trim().isEmpty
            ? null
            : _purchaseInvoiceController.text.trim(),
        supplierName: _supplierNameController.text.trim().isEmpty
            ? null
            : _supplierNameController.text.trim(),
        items: _items,
        totalAmount: _total,
        reason: _selectedReason == 'أخرى'
            ? _reasonController.text.trim()
            : _selectedReason,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final provider = Provider.of<PurchasesProvider>(context, listen: false);
      if (widget.purchaseReturn == null) {
        await provider.addReturn(purchaseReturn);
      } else {
        await provider.updateReturn(purchaseReturn);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.purchaseReturn == null
                ? 'تم إضافة الإرجاع بنجاح'
                : 'تم تحديث الإرجاع بنجاح'),
            backgroundColor: ThemeProvider.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: ThemeProvider.errorColor,
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

class _ProductSelectDialog extends StatefulWidget {
  final Function(Product, int, double) onProductSelected;

  const _ProductSelectDialog({required this.onProductSelected});

  @override
  State<_ProductSelectDialog> createState() => _ProductSelectDialogState();
}

class _ProductSelectDialogState extends State<_ProductSelectDialog> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر منتج للإرجاع'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ProductsProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<Product>(
                  initialValue: _selectedProduct,
                  decoration: const InputDecoration(
                    labelText: 'المنتج',
                    prefixIcon: Icon(Icons.inventory_rounded),
                  ),
                  items: provider.products.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (product) {
                    setState(() {
                      _selectedProduct = product;
                      _priceController.text =
                          product?.purchasePrice.toString() ?? '';
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية المُرجعة',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الوحدة',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      suffixText: 'د.ع',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedProduct != null &&
                _quantityController.text.isNotEmpty &&
                _priceController.text.isNotEmpty) {
              widget.onProductSelected(
                _selectedProduct!,
                int.parse(_quantityController.text),
                double.parse(_priceController.text),
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeProvider.errorColor,
          ),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
