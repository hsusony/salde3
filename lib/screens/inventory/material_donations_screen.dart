import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/inventory_transaction.dart';
import '../../models/product.dart';

class MaterialDonationsScreen extends StatefulWidget {
  const MaterialDonationsScreen({Key? key}) : super(key: key);

  @override
  State<MaterialDonationsScreen> createState() =>
      _MaterialDonationsScreenState();
}

class _DonationItem {
  final Product product;
  double quantity;
  String? recipient;
  String? notes;

  _DonationItem({
    required this.product,
    this.quantity = 1,
    this.recipient,
    this.notes,
  });
}

class _MaterialDonationsScreenState extends State<MaterialDonationsScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedWarehouseId;
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  final _recipientController = TextEditingController();
  String _transactionNumber = '';
  final List<_DonationItem> _items = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadWarehouses();
      context.read<ProductsProvider>().loadProducts();
      _generateTransactionNumber();
    });
  }

  Future<void> _generateTransactionNumber() async {
    final number = await context
        .read<InventoryProvider>()
        .generateTransactionNumber(InventoryTransactionType.donation);
    setState(() {
      _transactionNumber = number;
    });
  }

  int get _totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity.toInt());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('إهداء المواد'),
        centerTitle: true,
        backgroundColor: const Color(0xFFEC4899),
        foregroundColor: Colors.white,
        actions: [
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'المواد: ${_items.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Right Panel - Donation Info
            Expanded(
              flex: 2,
              child: Container(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Header
                        Card(
                          elevation: 4,
                          color:
                              isDark ? const Color(0xFF334155) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEC4899)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.card_giftcard,
                                        color: Color(0xFFEC4899),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'معلومات الإهداء',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'رقم المعاملة: $_transactionNumber',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 20),

                                // Warehouse Selector
                                Consumer<InventoryProvider>(
                                  builder: (context, provider, child) {
                                    return DropdownButtonFormField<int>(
                                      value: _selectedWarehouseId,
                                      decoration: InputDecoration(
                                        labelText: 'المخزن المصدر',
                                        prefixIcon: const Icon(Icons.warehouse),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? const Color(0xFF1E293B)
                                            : Colors.grey[50],
                                      ),
                                      items:
                                          provider.warehouses.map((warehouse) {
                                        return DropdownMenuItem(
                                          value: warehouse.id,
                                          child: Text(warehouse.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedWarehouseId = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null)
                                          return 'الرجاء اختيار المخزن';
                                        return null;
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Date Picker
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _selectedDate = date);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'تاريخ الإهداء',
                                      prefixIcon:
                                          const Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.grey[50],
                                    ),
                                    child: Text(
                                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Recipient
                                TextFormField(
                                  controller: _recipientController,
                                  decoration: InputDecoration(
                                    labelText: 'المستلم',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال اسم المستلم';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Reference
                                TextFormField(
                                  controller: _referenceController,
                                  decoration: InputDecoration(
                                    labelText: 'المرجع (اختياري)',
                                    prefixIcon: const Icon(Icons.receipt_long),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.grey[50],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Notes
                                TextFormField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    labelText: 'ملاحظات (اختياري)',
                                    prefixIcon: const Icon(Icons.notes),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.grey[50],
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Items List
                        if (_items.isNotEmpty) ...[
                          Card(
                            elevation: 4,
                            color:
                                isDark ? const Color(0xFF334155) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.list_alt,
                                          color: Color(0xFF6366F1),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'المواد المحددة',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _items.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = _items[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'الباركود: ${item.product.barcode}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isDark
                                                          ? Colors.white60
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEC4899)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'الكمية: ${item.quantity.toInt()}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFEC4899),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _items.removeAt(index);
                                                });
                                              },
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'إجمالي الكمية:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEC4899),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$_totalQuantity قطعة',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Save Button
                        if (_items.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveTransaction,
                              icon: const Icon(Icons.card_giftcard, size: 24),
                              label: const Text(
                                'حفظ الإهداء',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEC4899),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
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
                ),
              ),
            ),

            // Left Panel - Product Selection
            Container(
              width: 400,
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF1E293B) : Colors.grey[100],
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'اختيار المواد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<ProductsProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (provider.products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 80,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد منتجات',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.products.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final product = provider.products[index];
                            final isSelected = _items
                                .any((item) => item.product.id == product.id);

                            return Card(
                              elevation: isSelected ? 4 : 1,
                              color: isSelected
                                  ? const Color(0xFFEC4899).withOpacity(0.1)
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFFEC4899)
                                      : (isDark
                                          ? const Color(0xFF334155)
                                          : Colors.grey[300]!),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFEC4899)
                                            .withOpacity(0.2)
                                        : const Color(0xFF6366F1)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.inventory_2,
                                    color: isSelected
                                        ? const Color(0xFFEC4899)
                                        : const Color(0xFF6366F1),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('الباركود: ${product.barcode}'),
                                    Text(
                                      'الكمية المتاحة: ${product.quantity.toInt()}',
                                      style: TextStyle(
                                        color: product.quantity > 0
                                            ? const Color(0xFF10B981)
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: isSelected
                                    ? null
                                    : ElevatedButton(
                                        onPressed: product.quantity > 0
                                            ? () => _addProduct(product)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEC4899),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('إضافة'),
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
          ],
        ),
      ),
    );
  }

  void _addProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        final quantityController = TextEditingController(text: '1');
        final recipientController = TextEditingController();
        final notesController = TextEditingController();

        return AlertDialog(
          title: Text('إهداء ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الكمية',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                  suffixText: 'متاح: ${product.quantity.toInt()}',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'المستلم (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
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
                final quantity = double.tryParse(quantityController.text) ?? 1;
                if (quantity > 0 && quantity <= product.quantity) {
                  setState(() {
                    _items.add(_DonationItem(
                      product: product,
                      quantity: quantity,
                      recipient: recipientController.text.isEmpty
                          ? null
                          : recipientController.text,
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                    ));
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(quantity > product.quantity
                          ? 'الكمية المطلوبة أكبر من المتاح'
                          : 'الكمية يجب أن تكون أكبر من صفر'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
              ),
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المخزن'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save each item as a separate transaction
    final inventoryProvider = context.read<InventoryProvider>();

    for (var item in _items) {
      final transaction = InventoryTransaction(
        type: InventoryTransactionType.donation,
        transactionNumber: _transactionNumber,
        productId: item.product.id,
        warehouseFromId: _selectedWarehouseId,
        quantity: item.quantity,
        reference: _referenceController.text.isEmpty
            ? null
            : _referenceController.text,
        notes:
            '${item.recipient != null ? "المستلم: ${item.recipient} - " : ""}${item.notes ?? _notesController.text}',
        transactionDate: _selectedDate,
      );

      await inventoryProvider.addTransaction(transaction);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('تم حفظ ${_items.length} عملية إهداء بنجاح'),
            ],
          ),
          backgroundColor: const Color(0xFFEC4899),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _referenceController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
